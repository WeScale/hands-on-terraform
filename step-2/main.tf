#
# TODO: Ecrire une datasource de type aws_vpc pour récupérer le vpc créé au step-1
# Hints:
#   https://www.terraform.io/docs/providers/aws/d/vpc.html
#
data "aws_vpc" "devoxx_vpc" {
  cidr_block = "10.10.0.0/16"
}

data "aws_subnet_ids" "devoxx_subnets" {
  vpc_id = "${data.aws_vpc.devoxx_vpc.id}"
}

data "aws_subnet" "devoxx_subnet_details" {
  count = "${length(data.aws_subnet_ids.devoxx_subnets.ids)}"
  id    = "${data.aws_subnet_ids.devoxx_subnets.ids[count.index]}"
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair-key"
  public_key = "${var.instance_keypair}"
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.devoxx_vpc.id}"

  tags = {
    Name = "${var.name}"
  }
}

#
# TODO: Ecrire une ressource de type aws_security_group_rule, liée au security_group nommé allow_all
# Elle doit être de type ingress et autoriser tous les ports, tous les protocoles, et toutes les ip d'origine en entrée
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
#
resource "aws_security_group_rule" "allow_all_in" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_all.id}"
}

#
# TODO: Ecrire une ressource de type aws_security_group_rule, liée au security_group nommé allow_all
# Elle doit être de type egress et autoriser tous les ports, tous les protocoles, et toutes les ip de destination
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
#
resource "aws_security_group_rule" "allow_all_out" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_all.id}"
}

resource "aws_instance" "instance" {
  tags = {
    Name = "${var.name}"
  }

  instance_type = "${var.instance_type}"

  ami      = "${var.instance_ami}"
  key_name = "${aws_key_pair.keypair.key_name}"

  # network
  associate_public_ip_address = true
  subnet_id                   = "${element(data.aws_subnet.devoxx_subnet_details.*.id, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

