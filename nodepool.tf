variable "hwcloud_region" { type = string }
variable "hwcloud_ak" { type = string }
variable "hwcloud_sk" { type = string }
variable "availability_zone" { type = set(string) }
variable "password" { type = string }
variable "project_id" { type = string }

provider "huaweicloud" {
  region     = var.hwcloud_region
  access_key = var.hwcloud_ak
  secret_key = var.hwcloud_sk
}

provider "kubernetes" {
  config_path    = "C:/Users/g50037306/.kube/config"
  config_context = "external"
}

#Example on how to create a node pool on huawei cloud CCE
resource "huaweicloud_cce_node_pool" "node_pool_first" {
  cluster_id         = huaweicloud_cce_cluster.cluster.id
  name               = "pool-not-default"
  os                 = "Ubuntu 22.04"
  initial_node_count = 3
  flavor_id          = "c6ne.2xlarge.4"
  password                 = var.password
  scall_enable             = true
  min_node_count           = 1
  max_node_count           = 10
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"

  root_volume {
    size       = 50
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
}

#Example on how to create a node pool on huawei cloud CCE
resource "huaweicloud_cce_node" "my_only_node" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "node-dettached"
  flavor_id         = "c6ne.2xlarge.4"
  availability_zone = "sa-brazil-1a"
  password = var.password


  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }

  // Assign EIP
  iptype                = "5_bgp"
  bandwidth_charge_mode = "traffic"
  sharetype             = "PER"
  bandwidth_size        = 100
}