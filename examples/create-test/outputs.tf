output "cluster_details" {
  description = "GKE 클러스터의 세부 정보"
  value = {
    id                 = module.cluster.id
    endpoint           = module.cluster.endpoint
    network            = module.cluster.network
    subnetwork         = module.cluster.subnetwork
    services_ipv4_cidr = module.cluster.services_ipv4_cidr
    cluster_ipv4_cidr  = module.cluster.cluster_ipv4_cidr
    node_pools         = module.cluster.node_pools
    resource_labels    = module.cluster.resource_labels
    master_version     = module.cluster.master_version
    project            = module.cluster.project
    location           = module.cluster.location
    self_link          = module.cluster.self_link
  }
}