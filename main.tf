resource "google_container_cluster" "cluster" {
  # 필수 설정
  name = var.name # 클러스터 이름. GCP 프로젝트와 위치 내에서 유일해야 합니다.

  # 옵션 설정
  location            = var.location # 클러스터가 생성될 위치. 지역(Region) 또는 존(Zone)을 지정합니다.
  project             = var.project
  node_locations      = var.node_locations      # 클러스터 노드가 배치될 존 목록입니다.
  description         = var.description         # 클러스터에 대한 설명으로 용도를 기록할 수 있습니다.
  deletion_protection = var.deletion_protection # 클러스터 삭제 보호 여부를 설정합니다.
  resource_labels     = var.resource_labels     # 클러스터에 적용할 리소스 라벨(key-value)입니다.

  # 네트워크 설정
  networking_mode            = var.networking_mode            # 네트워킹 모드(VPC_NATIVE 또는 ROUTES)를 설정합니다.
  network                    = var.network                    # 클러스터가 연결될 VPC 네트워크의 이름 또는 self_link를 지정합니다.
  subnetwork                 = var.subnetwork                 # 클러스터가 연결될 서브네트워크를 지정합니다.
  private_ipv6_google_access = var.private_ipv6_google_access # Google 서비스에 대한 IPv6 접근 허용 여부입니다.

  # IP 및 CIDR 설정
  cluster_ipv4_cidr         = var.cluster_ipv4_cidr         # Pod에 할당될 IP 주소 범위(CIDR 형식)입니다.
  default_max_pods_per_node = var.default_max_pods_per_node # 노드당 생성 가능한 최대 Pod 수를 지정합니다.

  # 초기 구성
  initial_node_count      = var.initial_node_count      # 초기 기본 노드 풀의 노드 수입니다.
  enable_kubernetes_alpha = var.enable_kubernetes_alpha # Kubernetes Alpha 기능 활성화 여부입니다.
  enable_tpu              = var.enable_tpu              # TPU 사용 여부를 설정합니다.
  enable_legacy_abac      = var.enable_legacy_abac      # 레거시 ABAC 활성화 여부를 설정합니다.
  enable_shielded_nodes   = var.enable_shielded_nodes   # Shielded Nodes 기능 활성화 여부를 설정합니다.
  enable_autopilot        = var.enable_autopilot        # Autopilot 클러스터 활성화 여부를 설정합니다.

  # 로깅 및 모니터링
  logging_service    = var.logging_service    # 로깅 서비스를 설정합니다. (예: Stackdriver 또는 none)
  monitoring_service = var.monitoring_service # 모니터링 서비스를 설정합니다. (예: Stackdriver 또는 none)


  # IP 할당 정책 설정
  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy != null ? [var.ip_allocation_policy] : []
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value.cluster_secondary_range_name  # Pod IP에 사용할 보조 IP 범위 이름입니다.
      services_secondary_range_name = ip_allocation_policy.value.services_secondary_range_name # 서비스 IP에 사용할 보조 IP 범위 이름입니다.
      cluster_ipv4_cidr_block       = ip_allocation_policy.value.cluster_ipv4_cidr_block       # Pod IP 주소 범위(CIDR 형식)입니다.
      services_ipv4_cidr_block      = ip_allocation_policy.value.services_ipv4_cidr_block      # 서비스 IP 주소 범위(CIDR 형식)입니다.
    }
  }

  # 애드온 구성 설정
  dynamic "addons_config" {
    for_each = var.addons_config != null ? [var.addons_config] : []
    content {
      horizontal_pod_autoscaling {
        disabled = addons_config.value.horizontal_pod_autoscaling.disabled # Horizontal Pod Autoscaling 비활성화 여부입니다.
      }
      http_load_balancing {
        disabled = addons_config.value.http_load_balancing.disabled # HTTP Load Balancing 비활성화 여부입니다.
      }
      network_policy_config {
        disabled = addons_config.value.network_policy_config.disabled # Network Policy 비활성화 여부입니다.
      }
    }
  }

  # 수직 Pod Autoscaling 설정
  dynamic "vertical_pod_autoscaling" {
    for_each = var.vertical_pod_autoscaling != null ? [var.vertical_pod_autoscaling] : []
    content {
      enabled = vertical_pod_autoscaling.value.enabled # 수직 Pod Autoscaling 활성화 여부입니다.
    }
  }

  # Workload Identity 설정
  dynamic "workload_identity_config" {
    for_each = var.workload_identity_config != null ? [var.workload_identity_config] : []
    content {
      workload_pool = workload_identity_config.value.workload_pool # Workload Identity 풀 이름입니다.
    }
  }

  # 클러스터 자동 확장 설정
  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling != null ? [var.cluster_autoscaling] : []
    content {
      enabled = cluster_autoscaling.value.enabled                               # 클러스터 자동 확장 활성화 여부입니다.
      resource_limits {                                                         # 리소스 제한 설정입니다.
        resource_type = cluster_autoscaling.value.resource_limits.resource_type # 제한할 리소스 유형(CPU, 메모리 등)입니다.
        minimum       = cluster_autoscaling.value.resource_limits.minimum       # 최소 리소스 수입니다.
        maximum       = cluster_autoscaling.value.resource_limits.maximum       # 최대 리소스 수입니다.
      }
    }
  }

  # Private Cluster 설정
  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config != null ? [var.private_cluster_config] : []
    content {
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes    # Private Node 활성화 여부입니다.
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint # Private Endpoint 활성화 여부입니다.
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block  # 마스터 노드 네트워크 IP 범위입니다.
    }
  }

  # Release Channel 설정
  dynamic "release_channel" {
    for_each = var.release_channel != null ? [var.release_channel] : []
    content {
      channel = release_channel.value.channel # Release Channel 설정입니다. (예: STABLE, REGULAR, RAPID)
    }
  }

  # Notification 설정
  dynamic "notification_config" {
    for_each = var.notification_config != null ? [var.notification_config] : []
    content {
      pubsub {
        enabled = notification_config.value.pubsub.enabled # Notification 활성화 여부입니다.
        topic   = notification_config.value.pubsub.topic   # Notification 대상 Pub/Sub 토픽입니다.
      }
    }
  }

  # 로깅 구성
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      enable_components = logging_config.value.enable_components # 활성화된 로깅 컴포넌트 목록입니다.
    }
  }

  # 모니터링 구성
  dynamic "monitoring_config" {
    for_each = var.monitoring_config != null ? [var.monitoring_config] : []
    content {
      enable_components = monitoring_config.value.enable_components # 활성화된 모니터링 컴포넌트 목록입니다.
    }
  }

  # 데이터베이스 암호화 설정
  dynamic "database_encryption" {
    for_each = var.database_encryption != null ? [var.database_encryption] : []
    content {
      state    = database_encryption.value.state    # 암호화 상태(ENCRYPTED 또는 DECRYPTED)입니다.
      key_name = database_encryption.value.key_name # 암호화 키 이름입니다.
    }
  }

  # SNAT 기본 상태 설정
  dynamic "default_snat_status" {
    for_each = var.default_snat_status != null ? [var.default_snat_status] : []
    content {
      disabled = default_snat_status.value.disabled # 기본 SNAT 비활성화 여부입니다.
    }
  }

  # DNS 구성
  dynamic "dns_config" {
    for_each = var.dns_config != null ? [var.dns_config] : []
    content {
      cluster_dns        = dns_config.value.cluster_dns        # 클러스터 DNS 제공자 설정입니다.
      cluster_dns_scope  = dns_config.value.cluster_dns_scope  # 클러스터 DNS 범위 설정입니다.
      cluster_dns_domain = dns_config.value.cluster_dns_domain # 클러스터 DNS 도메인 이름입니다.
    }
  }

  # 타임아웃 설정
  timeouts {
    create = var.create # 클러스터 생성 시 최대 대기 시간
    read   = var.read   # 클러스터 읽기 시 최대 대기 시간
    update = var.update # 클러스터 업데이트 시 최대 대기 시간
    delete = var.delete # 클러스터 삭제 시 최대 대기 시간
  }
}