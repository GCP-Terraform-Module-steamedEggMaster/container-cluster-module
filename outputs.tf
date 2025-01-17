# 클러스터 ID 출력
output "id" {
  description = "클러스터의 고유 ID (프로젝트, 위치, 클러스터 이름 조합)"
  value       = google_container_cluster.cluster.id
}

# 클러스터 엔드포인트 (Kubernetes API 서버) 출력
output "endpoint" {
  description = "클러스터의 Kubernetes API 서버 엔드포인트 (IP 주소)"
  value       = google_container_cluster.cluster.endpoint
}

# 클러스터 인증 정보 출력 (CA 인증서)
output "cluster_ca_certificate" {
  description = "클러스터 API 서버와 통신하기 위한 CA 인증서"
  value       = try(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate, null)
}

# 네트워크 정보
output "network" {
  description = "클러스터가 속한 네트워크 이름"
  value       = google_container_cluster.cluster.network
}

output "subnetwork" {
  description = "클러스터가 속한 서브네트워크 이름"
  value       = google_container_cluster.cluster.subnetwork
}

# 서비스 및 Pod의 CIDR 범위
output "services_ipv4_cidr" {
  description = "클러스터의 서비스에 할당된 IPv4 CIDR 범위"
  value       = google_container_cluster.cluster.services_ipv4_cidr
}

output "cluster_ipv4_cidr" {
  description = "클러스터의 Pod 네트워크에 할당된 IPv4 CIDR 범위"
  value       = google_container_cluster.cluster.cluster_ipv4_cidr
}

# 노드풀 URL 목록
output "node_pools" {
  description = "클러스터에 설정된 노드풀들의 URL 목록"
  value       = google_container_cluster.cluster.node_pool
}

# 클러스터 리소스 레이블
output "resource_labels" {
  description = "클러스터에 적용된 리소스 레이블 (Key-Value 형식)"
  value       = google_container_cluster.cluster.resource_labels
}

# 클러스터의 Kubernetes 마스터 버전
output "master_version" {
  description = "Kubernetes API 서버의 현재 버전"
  value       = google_container_cluster.cluster.master_version
}

# 클러스터의 프로젝트 ID
output "project" {
  description = "클러스터가 속한 GCP 프로젝트 ID"
  value       = google_container_cluster.cluster.project
}

# 클러스터의 위치
output "location" {
  description = "클러스터가 생성된 GCP 위치 (지역 또는 영역)"
  value       = google_container_cluster.cluster.location
}

# 클러스터의 셀프 링크 (URL)
output "self_link" {
  description = "GKE 클러스터의 셀프 링크 URL"
  value       = google_container_cluster.cluster.self_link
}
