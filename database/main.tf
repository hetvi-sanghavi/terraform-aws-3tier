#Onto the last module. For the main.tf file here, we have a block that builds the database. One thing you could add for additional security is a a KMS key to encrypt the database.


# --- database/main.tf ---

resource "aws_db_instance" "three_tier_db" {
  allocated_storage      = var.db_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.dbuser
  password               = var.dbpassword
  db_subnet_group_name   = var.db_subnet_group_name
  identifier             = var.db_identifier
  skip_final_snapshot    = var.skip_db_snapshot
  vpc_security_group_ids = [var.rds_sg]

  tags = merge({
    Name = "three-tier-db"
  }, var.tags)
}