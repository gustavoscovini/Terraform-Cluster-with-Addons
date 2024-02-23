#Get the list of L4 flavors in huawei cloud
data "huaweicloud_elb_flavors" "flavors_l4" {
  type            = "L4"
}

#Get the list of L7 flavors in huawei cloud
data "huaweicloud_elb_flavors" "flavors_l7" {
  type            = "L7"
}

resource "huaweicloud_elb_loadbalancer" "dedicated" {
  name              = "elb-ingress"
  description       = "basic example using ELB in nginx ingress controller"
  cross_vpc_backend = true

  vpc_id            = huaweicloud_vpc.vpc.id
  ipv4_subnet_id    = huaweicloud_vpc_subnet.subnet-1.ipv4_subnet_id

  l4_flavor_id = data.huaweicloud_elb_flavors.flavors_l4.ids[0]
  l7_flavor_id = data.huaweicloud_elb_flavors.flavors_l7.ids[0]

  availability_zone = ["sa-brazil-1a","sa-brazil-1b"]

  iptype                = "5_bgp"
  bandwidth_charge_mode = "traffic"
  sharetype             = "PER"
  bandwidth_size        = 10
}