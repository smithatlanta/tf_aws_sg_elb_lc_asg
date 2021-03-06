/*
 * Module: tf_aws_sg_elb_lc_asg
 *
 * This template creates the following resources
 *    - 2 security groups
 *      - 1 Ingress -> allow all traffic in on port 80; Outbound -> only to security group 2
 *      - 1 Ingress -> from ELB security group on port 80; Inbound on port 22 from anywhere; Outbound -> wide open
 *    - A load balancer
 *    - A launch configuration
 *    - An auto-scale group
 *
 */

resource "aws_security_group" "sg_elb" {
  name        = "${var.sg_elb_name}"
  vpc_id      = "${var.vpc_id}"

  # inbound HTTP access from anywhere
  ingress {
    from_port   = "${var.elb_listener_lb_port}"
    to_port     = "${var.elb_listener_lb_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound only to items with the sg_instance security group
  egress {
    from_port   = "${var.elb_listener_instance_port}"
    to_port     = "${var.elb_listener_instance_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg_instance.id}"]
  }
 }

resource "aws_security_group" "sg_instance" {
  name                        = "${var.sg_instance_name}"
  vpc_id                      = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }

resource "aws_elb" "elb" {
  depends_on          = ["aws_security_group.sg_elb"]
  name                = "${var.elb_name}"
  availability_zones  = ["${split(",", var.availability_zones)}"]
  security_groups     = ["${aws_security_group.sg_elb.id}"]
  internal            = "${var.elb_internal_bool}"

  listener {
    instance_port     = "${var.elb_listener_instance_port}"
    instance_protocol = "http"
    lb_port           = "${var.elb_listener_lb_port}"
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold = "${var.elb_health_check_healthy_threshold}"
    unhealthy_threshold = "${var.elb_health_check_unhealthy_threshold}"
    timeout = "${var.elb_health_check_timeout}"
    target = "${var.elb_health_check_target}"
    interval = "${var.elb_health_check_interval}"
  }
}

resource "aws_launch_configuration" "launch_config" {
  depends_on = ["aws_security_group.sg_instance"]
  name = "${var.lc_name}"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.sg_instance.id}"]
  user_data = "${file(var.user_data)}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
}

resource "aws_autoscaling_group" "main_asg" {
  # We want this to explicitly depend on the launch config above
  depends_on = ["aws_launch_configuration.launch_config", "aws_elb.elb"]

  name = "${var.asg_name}"

  # The chosen availability zones *must* match the AZs the VPC subnets are tied to.
  availability_zones = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.vpc_zone_subnets)}"]

  # Uses the ID from the launch config created above
  launch_configuration = "${aws_launch_configuration.launch_config.id}"

  max_size = "${var.asg_number_of_instances}"
  min_size = "${var.asg_minimum_number_of_instances}"
  desired_capacity = "${var.asg_number_of_instances}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type = "${var.health_check_type}"

  load_balancers = ["${var.elb_name}"]

  termination_policies = ["${split(",", var.termination_policy)}"]

  tag {
    key = "Name"
    value = "${var.instance_name}"
    propagate_at_launch = true
  }
}
