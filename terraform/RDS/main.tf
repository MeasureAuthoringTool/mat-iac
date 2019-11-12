terraform {
  required_version = ">= 0.12.2"
  backend "s3" {
    bucket = "bmat-tf-state"
    key    = "BMAT-tfstate/BMAT-dev-RDS.tfstate"
    region = "us-east-1"

  }
}



resource "aws_db_instance" "mat-dev" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.medium"
  username             = "root"
  password             = ""
deletion_protection = "true"
storage_encrypted = "true"
copy_tags_to_snapshot = "true"
tags = {"Project" = "bonnie-mat"}
vpc_security_group_ids                = ["sg-0404fb7a007b30ac0"]
}
