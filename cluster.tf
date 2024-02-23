resource "huaweicloud_vpc" "vpc" {
  name = "vpc-terraform"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet-1" {
  name              = "subnet-terraform-1"
  cidr              = "192.168.1.0/24"
  gateway_ip        = "192.168.1.1"
  vpc_id            = huaweicloud_vpc.vpc.id
}

resource "huaweicloud_vpc_subnet" "subnet-2" {
  name              = "subnet-terraform-2"
  cidr              = "192.168.2.0/24"
  gateway_ip        = "192.168.2.1"
  vpc_id            = huaweicloud_vpc.vpc.id
}

#Create a CCE Cluster Turbo in Huawei Cloud
resource "huaweicloud_cce_cluster" "cluster" {
  name      = "cluster-huawei"
  flavor_id = "cce.s2.small" #s2 is gonna create a HA availabilty cluster with 3 master nodes, s1 is gonna create a single master node
  vpc_id    = huaweicloud_vpc.vpc.id
  subnet_id = huaweicloud_vpc_subnet.subnet-1.id
  cluster_version = "v1.27" #If not specified, gets the latest cluster version available
  container_network_type = "eni" #Cloud Native Network 2.0
  eni_subnet_id = join(",", [
    huaweicloud_vpc_subnet.subnet-1.ipv4_subnet_id,
    huaweicloud_vpc_subnet.subnet-2.ipv4_subnet_id
  ])
}