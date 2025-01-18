module "vpc" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/vpc-module.git?ref=v1.0.0"

  name = "test-vpc"
  auto_create_subnetworks = false
}

module "subnet" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/subnets-module.git?ref=v1.0.0"

  name    = "test-subnetwork"
  network = module.vpc.id

  ip_cidr_range            = "10.0.0.0/18"
  region                   = "asia-northeast3"
  private_ip_google_access = true

  secondary_ip_ranges = [
    {
      range_name              = "test-k8s-pod-range"
      ip_cidr_range           = "10.48.0.0/14"
      reserved_internal_range = null
    },
    {
      range_name              = "test-k8s-service-range"
      ip_cidr_range           = "10.52.0.0/20"
      reserved_internal_range = null
    }
  ]
}

module "workload_identity_pool" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/workload-identity-pool-module.git?ref=v1.0.0"

  workload_identity_pool_id = "workload-identity-pool"
}

module "cluster" {
  source = "../../"

  name       = "test-cluster"
  location   = "asia-northeast3-a"
  network    = module.vpc.self_link
  subnetwork = module.subnet.self_link

  # 선택적 변수 설정
  description         = "test GKE Cluster"
  deletion_protection = false
  networking_mode     = "VPC_NATIVE"

  addons_config = {
    horizontal_pod_autoscaling = { disabled = true }
    http_load_balancing        = { disabled = false }
  }

  release_channel = {
    channel = "REGULAR"
  }

  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # IP 할당 정책
  ip_allocation_policy = {
    cluster_ipv4_cidr_block  = module.subnet.secondary_ip_ranges[0].ip_cidr_range
    services_ipv4_cidr_block = module.subnet.secondary_ip_ranges[1].ip_cidr_range
  }

  # Workload Identity 설정
  workload_identity_config = {
    workload_pool = "${module.workload_identity_pool.project}.svc.id.goog"
  }
}