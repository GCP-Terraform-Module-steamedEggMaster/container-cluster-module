module "vpc" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/vpc-module.git?ref=v1.0.0"

  name = "test-vpc"
}

module "subnet" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/subnets-module.git?ref=v1.0.0"

  name    = "test-subnetwork"
  network = module.vpc.id

  ip_cidr_range           = "10.0.0.0/24"
  region                   = "asia-northeast3"
  private_ip_google_access = true

  secondary_ip_ranges = [
    {
      range_name              = "test-k8s-pod-range"
      ip_cidr_range           = "10.0.1.0/24"
      reserved_internal_range = null
    },
    {
      range_name              = "test-k8s-service-range"
      ip_cidr_range           = "10.0.2.0/24"
      reserved_internal_range = null
    }
  ]
}

module "workload_identity_pool" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/workload-identity-pool-module.git?ref=v1.0.0"

  workload_identity_pool_id = "test-pool-id"
}

module "cluster" {
  source = "../../"

  # 필수 변수 설정
  name       = "test-cluster"
  location   = "asia-northeast3-a"
  network    = module.vpc.self_link
  subnetwork = module.subnet.self_link

  # 선택적 변수 설정
  description         = "test GKE Cluster"
  deletion_protection = false
  networking_mode     = "VPC_NATIVE"

  # 애드온 설정
  addons_config = {
    horizontal_pod_autoscaling = { disabled = false }
    http_load_balancing        = { disabled = false }
    network_policy_config      = { disabled = true }
  }

  # IP 할당 정책
  ip_allocation_policy = {
    cluster_secondary_range_name  = module.subnet.secondary_ip_ranges[0].range_name
    services_secondary_range_name = module.subnet.secondary_ip_ranges[1].range_name
    cluster_ipv4_cidr_block       = module.subnet.secondary_ip_ranges[0].ip_cidr_range
    services_ipv4_cidr_block      = module.subnet.secondary_ip_ranges[1].ip_cidr_range
  }

  # Workload Identity 설정
  workload_identity_config = {
    workload_pool = module.workload_identity_pool.workload_identity_pool_domain
  }
}
