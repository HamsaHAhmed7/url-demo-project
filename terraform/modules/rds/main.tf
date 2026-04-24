resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = var.subnet_ids
  tags = { Name = "${var.project}-rds-subnet-group" }
}

resource "aws_security_group" "rds" {
  name   = "${var.project}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group]
  }
  tags = { Name = "${var.project}-rds-sg" }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "shortener"
  username               = "app"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  storage_encrypted      = true
  backup_retention_period = 7
  multi_az               = false
  tags = { Name = "${var.project}-postgres" }
}
