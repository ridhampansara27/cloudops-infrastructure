# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

resource "aws_vpc" "this" {

  # Use the dedicated CloudOps private address space.
  cidr_block = var.vpc_cidr

  # Required for normal Kubernetes DNS behavior.
  enable_dns_support = true

  # Required for AWS-generated DNS hostnames.
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}


# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------

resource "aws_internet_gateway" "this" {

  # Attach internet connectivity to the VPC.
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}


# ------------------------------------------------------------
# Public subnets
# ------------------------------------------------------------

resource "aws_subnet" "public" {

  # Create one public subnet per configured AZ.
  count = length(
    var.availability_zones,
  )

  # Place each subnet in the project VPC.
  vpc_id = aws_vpc.this.id

  # Generate a distinct /24 from the VPC address range.
  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index,
  )

  # Spread EKS nodes across Availability Zones.
  availability_zone = var.availability_zones[
    count.index
  ]

  # Give launched EC2 nodes public addresses.
  #
  # This deliberately avoids a NAT Gateway for the temporary
  # demonstration environment.
  map_public_ip_on_launch = true

  tags = {

    Name = (
      "${var.project_name}-${var.environment}-public-${count.index + 1}"
    )

    # Allow Kubernetes external load balancers to discover these subnets.
    "kubernetes.io/role/elb" = "1"
  }
}


# ------------------------------------------------------------
# Public routing
# ------------------------------------------------------------

resource "aws_route_table" "public" {

  # Create the route table inside the project VPC.
  vpc_id = aws_vpc.this.id

  route {

    # Route Internet traffic through the Internet Gateway.
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public"
  }
}


# Associate each public subnet with the Internet route table.
resource "aws_route_table_association" "public" {

  # Create one association per configured public subnet.
  #
  # Derive the instance count from configuration rather than from
  # resource attributes so Terraform knows the count during planning,
  # importing, and before any subnet exists.
  count = length(
    var.availability_zones,
  )

  # Select the current subnet.
  subnet_id = aws_subnet.public[
    count.index
  ].id

  # Use the public routing table.
  route_table_id = aws_route_table.public.id
}