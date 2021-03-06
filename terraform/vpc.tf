#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "bmat-dev" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "bmat-dev-eks-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "bmat-dev" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.bmat-dev.id}"

  tags = "${
    map(
      "Name", "bmat-dev-eks-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "bmat-dev" {
  vpc_id = "${aws_vpc.bmat-dev.id}"

  tags = {
    Name = "bmat-dev-eks"
    Project = "bonnie-mat"
  }
}

resource "aws_route_table" "bmat-dev" {
  vpc_id = "${aws_vpc.bmat-dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bmat-dev.id}"
  }
}

resource "aws_route_table_association" "bmat-dev" {
  count = 2

  subnet_id      = "${aws_subnet.bmat-dev.*.id[count.index]}"
  route_table_id = "${aws_route_table.bmat-dev.id}"
}
