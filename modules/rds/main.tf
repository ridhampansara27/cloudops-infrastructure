# Create a DB subnet group across private database subnets.
resource "aws_db_subnet_group" "this" {

  # Create an environment-scoped name.
  name = "${var.project_name}-${var.environment}"

  # Keep RDS in private database subnets.
  subnet_ids = var.subnet_ids
}


# Restrict PostgreSQL access to EKS.
resource "aws_security_group" "database" {

  # Name the database security group.
  name = "${var.project_name}-${var.environment}-postgres"

  # Place it in the application VPC.
  vpc_id = var.vpc_id
}


# Permit PostgreSQL only from the EKS cluster security group.
resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {

  # Protect the RDS security group.
  security_group_id = aws_security_group.database.id

  # Allow traffic from EKS.
  referenced_security_group_id = var.eks_security_group_id

  # PostgreSQL protocol.
  ip_protocol = "tcp"

  # PostgreSQL port.
  from_port = 5432

  # PostgreSQL port.
  to_port = 5432
}


# Create managed PostgreSQL.
resource "aws_db_instance" "this" {

  # Create a readable database identifier.
  identifier = (
    "${var.project_name}-${var.environment}-postgres"
  )

  # Use PostgreSQL.
  engine = "postgres"

  # Keep the portfolio instance small by default.
  instance_class = "db.t4g.micro"

  # Create the initial CloudOps database.
  db_name = "cloudops"

  # Create the database administrator user.
  username = "cloudops"

  # Ask RDS to create and manage the master password
  # securely in AWS Secrets Manager.
  manage_master_user_password = true

  # Begin with modest GP3 storage.
  allocated_storage = 20

  # Allow storage autoscaling.
  max_allocated_storage = 100

  # Use modern general-purpose storage.
  storage_type = "gp3"

  # Encrypt database storage and snapshots.
  storage_encrypted = true

  # Never expose PostgreSQL directly to the Internet.
  publicly_accessible = false

  # Use private database networking.
  db_subnet_group_name = aws_db_subnet_group.this.name

  # Restrict network access.
  vpc_security_group_ids = [
    aws_security_group.database.id,
  ]

  # Allow production to enable synchronous standby.
  multi_az = var.multi_az

  # Retain automated backups for recovery.
  backup_retention_period = 7

  # Apply changes during an explicit maintenance operation.
  apply_immediately = false

  # Development can destroy without a final snapshot.
  skip_final_snapshot = (
    var.environment == "dev"
  )

  # Protect non-development databases from accidental deletion.
  deletion_protection = (
    var.environment != "dev"
  )
}