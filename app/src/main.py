from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse, HTMLResponse
import os, hashlib, time
from .db import put_mapping, get_mapping, get_backend_type, increment_clicks
from .events import publish_click_event

app = FastAPI()

HTML = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>URL Shortener</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: #0f172a;
      color: #e2e8f0;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .card {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 1rem;
      padding: 2.5rem;
      width: 100%;
      max-width: 560px;
    }
    h1 { font-size: 1.6rem; font-weight: 700; margin-bottom: 0.4rem; }
    p.sub { color: #94a3b8; font-size: 0.9rem; margin-bottom: 1.8rem; }
    label { font-size: 0.85rem; color: #94a3b8; display: block; margin-bottom: 0.4rem; }
    input[type=url] {
      width: 100%;
      padding: 0.75rem 1rem;
      background: #0f172a;
      border: 1px solid #334155;
      border-radius: 0.5rem;
      color: #e2e8f0;
      font-size: 0.95rem;
      outline: none;
      transition: border-color 0.2s;
    }
    input[type=url]:focus { border-color: #6366f1; }
    button {
      margin-top: 1rem;
      width: 100%;
      padding: 0.75rem;
      background: #6366f1;
      color: white;
      border: none;
      border-radius: 0.5rem;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    button:hover { background: #4f46e5; }
    button:disabled { background: #334155; cursor: not-allowed; }
    #result { margin-top: 1.5rem; display: none; }
    .result-box {
      background: #0f172a;
      border: 1px solid #334155;
      border-radius: 0.5rem;
      padding: 0.75rem 1rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.75rem;
    }
    .result-box a { color: #818cf8; font-size: 0.95rem; text-decoration: none; word-break: break-all; }
    .result-box a:hover { text-decoration: underline; }
    .copy-btn {
      margin-top: 0;
      width: auto;
      padding: 0.4rem 0.85rem;
      font-size: 0.8rem;
      background: #334155;
      flex-shrink: 0;
    }
    .copy-btn:hover { background: #475569; }
    #error { margin-top: 1rem; color: #f87171; font-size: 0.875rem; display: none; }
    footer { margin-top: 2rem; color: #475569; font-size: 0.8rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>URL Shortener</h1>
    <p class="sub">Paste a long URL and get a short link instantly.</p>
    <label for="url">Long URL</label>
    <input type="url" id="url" placeholder="https://example.com/very/long/path" />
    <button id="btn" onclick="shorten()">Shorten</button>
    <div id="error"></div>
    <div id="result">
      <label>Your short link</label>
      <div class="result-box">
        <a id="short-link" href="#" target="_blank"></a>
        <button class="copy-btn" onclick="copy()">Copy</button>
      </div>
    </div>
  </div>
  <footer>hamsa-ahmed.co.uk &middot; built with FastAPI &amp; AWS ECS</footer>

  <script>
    async function shorten() {
      const input = document.getElementById('url');
      const btn = document.getElementById('btn');
      const error = document.getElementById('error');
      const result = document.getElementById('result');
      const url = input.value.trim();

      error.style.display = 'none';
      result.style.display = 'none';

      if (!url) { showError('Please enter a URL.'); return; }
      if (!/^https?:\/\//i.test(url)) { showError('Please include https:// in your URL.'); return; }

      btn.disabled = true;
      btn.textContent = 'Shortening...';

      try {
        const res = await fetch('/shorten', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        });
        const data = await res.json();
        if (!res.ok) { showError(data.detail || 'Something went wrong.'); return; }

        const link = document.getElementById('short-link');
        link.href = data.short_url;
        link.textContent = data.short_url;
        result.style.display = 'block';
      } catch (e) {
        showError('Network error. Please try again.');
      } finally {
        btn.disabled = false;
        btn.textContent = 'Shorten';
      }
    }

    function copy() {
      const url = document.getElementById('short-link').textContent;
      navigator.clipboard.writeText(url).then(() => {
        const btn = document.querySelector('.copy-btn');
        btn.textContent = 'Copied!';
        setTimeout(() => btn.textContent = 'Copy', 2000);
      });
    }

    function showError(msg) {
      const el = document.getElementById('error');
      el.textContent = msg;
      el.style.display = 'block';
    }

    document.getElementById('url').addEventListener('keydown', e => {
      if (e.key === 'Enter') shorten();
    });
  </script>
</body>
</html>"""


@app.get("/", response_class=HTMLResponse)
def index():
    return HTML


@app.get("/healthz")
def health():
    return {"status": "ok", "ts": int(time.time()), "db": get_backend_type()}


@app.post("/shorten")
async def shorten(req: Request):
    body = await req.json()
    url = body.get("url")
    if not url:
        raise HTTPException(400, "url required")
    if not url.startswith(("http://", "https://")):
        url = "https://" + url
    short = hashlib.sha256(url.encode()).hexdigest()[:8]
    put_mapping(short, url)
    base = os.environ.get("BASE_URL", str(req.base_url).rstrip("/"))
    if base.startswith("http://") and req.headers.get("x-forwarded-proto") == "https":
        base = "https://" + base[len("http://"):]
    return {"short": short, "url": url, "short_url": f"{base}/{short}"}


@app.get("/stats/{short_id}")
def stats(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(404, "not found")
    return {"short": short_id, "url": item["url"], "clicks": item.get("clicks", 0)}


@app.get("/{short_id}")
def resolve(short_id: str, request: Request):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(404, "not found")
    increment_clicks(short_id)
    publish_click_event(
        short_code=short_id,
        ip=request.client.host if request.client else "unknown",
        user_agent=request.headers.get("user-agent", ""),
        referer=request.headers.get("referer", ""),
    )
    return RedirectResponse(item["url"])
