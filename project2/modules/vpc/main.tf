resource "aws_vpc" "myVPC" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_internet_gateway" "myIG" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.myVPC.id

  tags = merge(
    var.tags,
    {
      Name = var.igw_name != "" ? var.igw_name : "${var.vpc_name}-igw"
    }
  )
}