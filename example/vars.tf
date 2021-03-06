variable "sg_elb_name" {
  default = "mysgelb"
}
variable "sg_instance_name" {
  default = "mysginstance"
}
variable "vpc_id" {
  default = "vpc-32109d57"
}

variable "elb_name" {
  default = "myelb"
}
variable "elb_listener_lb_port" {
  default = "80"
}
variable "elb_listener_instance_port" {
  default = "80"
}
variable "elb_health_check_target" {
  default = "HTTP:80/healthcheck"
}

variable "lc_name" {
  default = "mylc"
}
variable "user_data_file" {
  default = "user-data.sh"
}
variable "ami_id" {
  default = "ami-fce3c696"
}
variable "instance_type" {
  default = "t2.small"
}
variable "key_name" {
  default = "masmith_ec2"
}

variable "asg_name" {
  default = "myasg"
}
variable "asg_number_of_instances" {
  default = 2
}
variable "availability_zones" {
  default = "us-east-1a,us-east-1b"
}
variable "vpc_zone_subnets" {
  default = "subnet-70ed015b,subnet-dd64c6aa"
}
variable "instance_name" {
  default = "myinstance"
}
