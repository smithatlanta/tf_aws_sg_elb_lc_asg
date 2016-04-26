module "my_autoscaling_group" {
  source = "github.com/smithatlanta/tf_aws_sg_elb_lc_asg"

  sg_elb_name = "${var.sg_elb_name}"

  sg_instance_name = "${var.sg_instance_name}"

  vpc_id = "${var.vpc_id}"

  elb_name = "${var.elb_name}"

  lc_name = "${var.lc_name}"

  ami_id = "${var.ami_id}"

  instance_type = "${var.instance_type}"

  key_name = "${var.key_name}"

  asg_name = "${var.asg_name}"
  asg_number_of_instances = "${var.asg_number_of_instances}"
  asg_minimum_number_of_instances = "${var.asg_minimum_number_of_instances}"

  health_check_type = "${var.health_check_type}"

  availability_zones = "${var.availability_zones}"
  vpc_zone_subnets = "${var.vpc_zone_subnets}"
}
