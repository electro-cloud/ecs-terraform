
#ECS VPC

locals {
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ecs-vpc"
  }
}

#Create internet gateway
resource "aws_internet_gateway" "ecs_ig" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags   = {
    Name = "ecs-vpc-igw"
  }
}

resource "aws_subnet" "private_ecs_subnet" {
  count             = 2  # Creating 2 private subnets (one in each availability zone)
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 4, count.index + 2)  # Different block from public
  availability_zone = element(local.availability_zones, count.index)  # Assign subnets to different AZs
  map_public_ip_on_launch = false  # No public IPs for instances in private subnets
  tags = {
    Name = "private-ecs-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public_ecs_subnet" {
  count       = 2
  vpc_id      = aws_vpc.ecs_vpc.id
  cidr_block  = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, count.index)
  availability_zone = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-ecs-subnet-${count.index + 1}"
 }
}
#Create routetable
resource "aws_route_table"  "ecs_public_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "public-route-table"

  }
}
# associate between route and public subnet
resource "aws_route_table_association" "ecs_pub_association" {
  count          = length(aws_subnet.public_ecs_subnet)  # Create one association per subnet
  subnet_id      = aws_subnet.public_ecs_subnet[count.index].id  # Use the index to get the subnet ID
  route_table_id = aws_route_table.ecs_public_route_table.id
}

#Main routes for public
resource "aws_route" "ecs_public_route" {
  route_table_id         = aws_route_table.ecs_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_ig.id
}

