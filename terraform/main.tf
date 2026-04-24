module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  region  = var.aws_region
}

module "ecr" {
  source  = "./modules/ecr"
  project = var.project
}

module "sqs" {
  source  = "./modules/sqs"
  project = var.project
}

module "rds" {
  source             = "./modules/rds"
  project            = var.project
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  ecs_security_group = module.ecs.task_security_group_id
  db_password        = var.db_password
}

module "elasticache" {
  source             = "./modules/elasticache"
  project            = var.project
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  ecs_security_group = module.ecs.task_security_group_id
}

module "alb" {
  source     = "./modules/alb"
  project    = var.project
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}

module "iam" {
  source       = "./modules/iam"
  project      = var.project
  aws_region   = var.aws_region
  sqs_arn      = module.sqs.queue_arn
  ecr_arns     = module.ecr.repository_arns
  github_org   = var.github_org
  github_repo  = var.github_repo
}

module "ecs" {
  source              = "./modules/ecs"
  project             = var.project
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  api_image           = "${module.ecr.api_repository_url}:latest"
  worker_image        = "${module.ecr.worker_repository_url}:latest"
  dashboard_image     = "${module.ecr.dashboard_repository_url}:latest"
  api_task_role_arn       = module.iam.api_task_role_arn
  worker_task_role_arn    = module.iam.worker_task_role_arn
  dashboard_task_role_arn = module.iam.dashboard_task_role_arn
  execution_role_arn      = module.iam.ecs_execution_role_arn
  db_url              = module.rds.connection_url
  redis_url           = module.elasticache.redis_url
  sqs_queue_url       = module.sqs.queue_url
  alb_api_tg_arn       = module.alb.api_target_group_arn
  alb_dashboard_tg_arn = module.alb.dashboard_target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
}

module "monitoring" {
  source       = "./modules/monitoring"
  project      = var.project
  aws_region   = var.aws_region
  alert_email  = var.alert_email
  alb_arn      = module.alb.alb_arn
  sqs_queue_name = module.sqs.queue_name
  rds_id       = module.rds.instance_id
  redis_id     = module.elasticache.cluster_id
  ecs_cluster  = module.ecs.cluster_name
}
