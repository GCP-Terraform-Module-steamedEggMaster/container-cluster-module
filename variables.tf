variable "name" {
  description = "클러스터 이름. 프로젝트와 위치 내에서 유일해야 합니다."
  type        = string
}

variable "location" {
  description = "클러스터가 생성될 지역(Region) 또는 존(Zone)입니다."
  type        = string
}

variable "project" {
  description = "워크로드 아이덴티티 풀을 생성할 GCP 프로젝트 ID (지정하지 않으면 provider 기본값 사용)"
  type        = string
  default     = null
}

variable "node_locations" {
  description = "클러스터 노드가 배치될 존 목록입니다."
  type        = list(string)
  default     = []
}

variable "description" {
  description = "클러스터에 대한 설명입니다."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "클러스터 삭제 보호 여부입니다."
  type        = bool
  default     = false
}

variable "networking_mode" {
  description = "네트워킹 모드(VPC_NATIVE 또는 ROUTES)입니다."
  type        = string
}

variable "logging_service" {
  description = "로깅 서비스. 예: logging.googleapis.com/kubernetes"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "모니터링 서비스. 예: monitoring.googleapis.com/kubernetes"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "network" {
  description = "클러스터가 연결될 VPC 네트워크 이름 또는 self_link입니다."
  type        = string
}

variable "subnetwork" {
  description = "클러스터가 연결될 서브네트워크 이름 또는 self_link입니다."
  type        = string
}

variable "resource_labels" {
  description = "클러스터에 적용할 리소스 라벨입니다."
  type        = map(string)
  default     = {}
}

variable "cluster_ipv4_cidr" {
  description = "Pod에 할당될 IP 주소 범위(CIDR 형식)입니다."
  type        = string
  default     = null
}

variable "default_max_pods_per_node" {
  description = "노드당 생성 가능한 최대 Pod 수입니다."
  type        = number
  default     = 110
}

variable "initial_node_count" {
  description = "초기 기본 노드 풀의 노드 수입니다."
  type        = number
  default     = 3
}

variable "enable_kubernetes_alpha" {
  description = "Kubernetes Alpha 기능 활성화 여부입니다."
  type        = bool
  default     = false
}

variable "enable_tpu" {
  description = "TPU 사용 여부입니다."
  type        = bool
  default     = false
}

variable "enable_legacy_abac" {
  description = "레거시 ABAC 활성화 여부입니다."
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Shielded Nodes 활성화 여부입니다."
  type        = bool
  default     = true
}

variable "enable_autopilot" {
  description = "Autopilot 클러스터 활성화 여부입니다."
  type        = bool
  default     = false
}

variable "private_ipv6_google_access" {
  description = "Google 서비스에 대한 IPv6 접근 허용 여부입니다."
  type        = string
  default     = null
}

variable "ip_allocation_policy" {
  description = "IP 할당 정책입니다."
  type = object({
    cluster_secondary_range_name  = string
    services_secondary_range_name = string
    cluster_ipv4_cidr_block       = string
    services_ipv4_cidr_block      = string
    stack_type                    = string
  })
  default = {
    cluster_secondary_range_name  = null
    services_secondary_range_name = null
    cluster_ipv4_cidr_block       = null
    services_ipv4_cidr_block      = null
    stack_type                    = "IPV4"
  }
}

variable "addons_config" {
  description = "애드온 구성입니다."
  type = object({
    horizontal_pod_autoscaling = object({ disabled = bool })
    http_load_balancing        = object({ disabled = bool })
    network_policy_config      = object({ disabled = bool })
  })
  default = { ## 이렇게 구성하면 원하는 값만 덮어쓰기 가능
    horizontal_pod_autoscaling = { disabled = false }
    http_load_balancing        = { disabled = false }
    network_policy_config      = { disabled = false }
  }
}


variable "vertical_pod_autoscaling" {
  description = "수직 Pod Autoscaling 설정입니다."
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "workload_identity_config" {
  description = "Workload Identity 설정입니다."
  type = object({
    workload_pool = string
  })
  default = {
    workload_pool = null
  }
}

variable "cluster_autoscaling" {
  description = "클러스터 자동 확장 설정입니다."
  type = object({
    enabled = bool
    resource_limits = object({
      resource_type = string
      minimum       = number
      maximum       = number
    })
  })
  default = {
    enabled = false
    resource_limits = {
      resource_type = null
      minimum       = null
      maximum       = null
    }
  }
}

variable "private_cluster_config" {
  description = "Private Cluster 설정입니다."
  type = object({
    enable_private_nodes    = bool
    enable_private_endpoint = bool
    master_ipv4_cidr_block  = string
  })
  default = {
    enable_private_nodes    = false
    enable_private_endpoint = false
    master_ipv4_cidr_block  = null
  }
}

variable "release_channel" {
  description = "Release Channel 설정입니다."
  type = object({
    channel = string
  })
  default = {
    channel = null
  }
}

variable "notification_config" {
  description = "Notification 설정입니다."
  type = object({
    pubsub = object({
      enabled = bool
      topic   = string
    })
  })
  default = {
    pubsub = {
      enabled = false
      topic   = null
    }
  }
}

variable "logging_config" {
  description = "로깅 구성입니다."
  type = object({
    enable_components = list(string)
  })
  default = {
    enable_components = []
  }
}

variable "monitoring_config" {
  description = "모니터링 구성입니다."
  type = object({
    enable_components = list(string)
  })
  default = {
    enable_components = []
  }
}

variable "database_encryption" {
  description = "데이터베이스 암호화 설정입니다."
  type = object({
    state    = string
    key_name = string
  })
  default = {
    state    = "DECRYPTED"
    key_name = null
  }
}

variable "default_snat_status" {
  description = "기본 SNAT 상태 설정입니다."
  type = object({
    disabled = bool
  })
  default = {
    disabled = false
  }
}

variable "dns_config" {
  description = "DNS 구성입니다."
  type = object({
    cluster_dns        = string
    cluster_dns_scope  = string
    cluster_dns_domain = string
  })
  default = {
    cluster_dns        = null
    cluster_dns_scope  = null
    cluster_dns_domain = null
  }
}

variable "create" {
  description = "클러스터 생성 타임아웃입니다."
  type        = string
  default     = "40m"
}

variable "read" {
  description = "클러스터 읽기 타임아웃입니다."
  type        = string
  default     = "40m"
}

variable "update" {
  description = "클러스터 업데이트 타임아웃입니다."
  type        = string
  default     = "60m"
}

variable "delete" {
  description = "클러스터 삭제 타임아웃입니다."
  type        = string
  default     = "40m"
}