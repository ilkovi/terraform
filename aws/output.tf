output "aws_region" {
  value = "${var.aws_region}"
}

output "resource_group_name" {
  value = "${aws_resourcegroups_group.resource_group.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_demo.id}"
}

output "route_table_id" {
  value = "${aws_route_table.public_route_table.id}"
}

output "security_group_id" {
  value = "${aws_security_group.demo_sec_group.id}"
}
