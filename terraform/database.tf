locals {

  common_labels = {

    environment = var.environment
    managed_by  = "terraform"
  }

}
#-------------------------
#   POSGRES Database
#-------------------------

resource "aws_db_instance" "postgres_db" {
  allocated_storage             = var.db_allocated_storage
  db_name                       = var.db_name
  engine                        = var.db_engine
  engine_version                = var.db_engine_version
  instance_class                = var.db_instance_class
  username                      = var.db_username
  multi_az                      = true
  parameter_group_name          = aws_db_parameter_group.postgres_db.name
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.db_secret.key_id
  db_subnet_group_name          = module.vpc.database_subnet_group
  skip_final_snapshot           = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_db_parameter_group" "postgres_db" {
  name   = "postgres-db-pg"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "aws_kms_key" "db_secret" {
  description             = "KMS key for postgres RDS"
  deletion_window_in_days = 10
  tags                    = local.common_labels
}