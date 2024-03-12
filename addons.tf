locals {
  elb_id = huaweicloud_elb_loadbalancer.dedicated.id
}
#Add an Autoscaler Addon on cluster
data "huaweicloud_cce_addon_template" "autoscaler_addon" {
  name       = "autoscaler"
  cluster_id = huaweicloud_cce_cluster.cluster.id
  version    = "1.27.53"
}

resource "huaweicloud_cce_addon" "addon_autoscaler_finish" {
  template_name = "autoscaler"
  version       = "1.27.53"
  cluster_id    = huaweicloud_cce_cluster.cluster.id

  values {
    basic_json = jsonencode(jsondecode(data.huaweicloud_cce_addon_template.autoscaler_addon.spec).basic)
    custom_json = jsonencode(merge(
      jsondecode(data.huaweicloud_cce_addon_template.autoscaler_addon.spec).parameters.custom,
      {
        cluster_id             = huaweicloud_cce_cluster.cluster.id
        tenant_id              = var.project_id # Project ID of the region
      }
    ))
    flavor_json = jsonencode(jsondecode(data.huaweicloud_cce_addon_template.autoscaler_addon.spec).parameters.flavor2)
  }
}

#Add an nginx ingress controller in the CCE
data "huaweicloud_cce_addon_template" "nginx_controller_addon" {
  name       = "nginx-ingress"
  version    = "2.4.6"
  cluster_id = huaweicloud_cce_cluster.cluster.id
}

data "huaweicloud_cce_addon_template" "nginx-ingress" {
  cluster_id = huaweicloud_cce_cluster.cluster.id
  name       = "nginx-ingress"
  version    = "2.4.6"
}

resource "huaweicloud_cce_addon" "nginx-ingress" {
  cluster_id    = huaweicloud_cce_cluster.cluster.id
  template_name = "nginx-ingress"
  version       = "2.4.6"

  values {
    basic_json = jsonencode(jsondecode(data.huaweicloud_cce_addon_template.nginx-ingress.spec).basic)
    custom_json = jsonencode(merge(
      jsondecode(data.huaweicloud_cce_addon_template.nginx-ingress.spec).parameters.custom,
      {
        admissionWebhooks = { "enabled" = "true" }
        service = { 
          annotations = {
            "kubernetes.io/elb.class" = "performance"
            "kubernetes.io/elb.id"    = local.elb_id
          } 
        }
        tenant_id = var.project_id
      }
    ))
  }
}