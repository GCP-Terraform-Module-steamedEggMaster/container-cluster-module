# container-cluster-module
GCP Terraform Container Cluster Module Repo

GCP에서 Google Kubernetes Engine 클러스터 및 관련 리소스를 생성하고 관리하기 위한 Terraform 모듈입니다.  <br>
이 모듈은 클러스터, 노드 풀, Workload Identity, 네트워킹, 모니터링, 데이터베이스 암호화 등을 쉽게 설정할 수 있도록 설계되었습니다.

<br>

## 📑 **목차**
1. [모듈 특징](#모듈-특징)
2. [사용 방법](#사용-방법)
    1. [사전 준비](#1-사전-준비)
    2. [입력 변수](#2-입력-변수)
    3. [모듈 호출 예시](#3-모듈-호출-예시)
    4. [출력값 (Outputs)](#4-출력값-outputs)
    5. [지원 버전](#5-지원-버전)
    6. [모듈 개발 및 관리](#6-모듈-개발-및-관리)
3. [테스트](#테스트)
4. [주요 버전 관리](#주요-버전-관리)
5. [기여](#기여-contributing)
6. [라이선스](#라이선스-license)

---

## 모듈 특징

- **클러스터 생성 및 관리**: GKE 클러스터 및 노드 풀의 주요 설정을 쉽게 구성.
- **Workload Identity 통합**: Kubernetes와 GCP 서비스 계정 간 안전한 연동 가능.
- **프라이빗 클러스터 지원**: Private IP를 활용한 보안 강화 설정 가능.
- **네트워킹 설정**: VPC, 서브네트워크, CIDR 설정 및 IP 할당 정책 지원.
- **확장성과 확장성**: 클러스터 및 Pod Autoscaling 구성 가능.
- **데이터 암호화**: 클러스터 데이터의 암호화 및 관리 키 설정 지원.
- **모니터링 및 로깅**: 시스템 및 워크로드의 모니터링 및 로깅 컴포넌트 구성 가능.

---

## 사용 방법

### 1. 사전 준비

다음 사항을 확인하세요:
1. Google Cloud 프로젝트 준비.
2. 필요한 Terraform과 Google Provider 설치.
3. GCP 프로젝트에 적절한 권한 필요: `roles/container.admin`, `roles/iam.serviceAccountAdmin`.

<br>

### 2. 입력 변수

| 변수명                      | 타입            | 필수 여부 | 기본값              | 설명                                                                 |
|-----------------------------|-----------------|-----------|---------------------|----------------------------------------------------------------------|
| `name`                     | string          | ✅        | 없음                | 클러스터 이름. GCP 프로젝트와 위치 내에서 유일해야 함.                |
| `location`                 | string          | ✅        | 없음                | 클러스터 생성 지역 또는 영역.                                         |
| `project`                  | string          | ✅        | 없음                | GCP 프로젝트 ID.                                                     |
| `node_locations`           | list(string)    | ❌        | `[]`                | 클러스터 노드가 배치될 존 목록.                                       |
| `description`              | string          | ❌        | `null`              | 클러스터 설명.                                                        |
| `deletion_protection`      | bool            | ❌        | `false`             | 클러스터 삭제 보호 활성화 여부.                                        |
| `network`                  | string          | ✅        | 없음                | VPC 네트워크 이름 또는 self_link.                                      |
| `subnetwork`               | string          | ✅        | 없음                | 서브네트워크 이름 또는 self_link.                                      |
| `logging_service`          | string          | ❌        | `logging.googleapis.com/kubernetes` | 로깅 서비스 설정.                                                    |
| `monitoring_service`       | string          | ❌        | `monitoring.googleapis.com/kubernetes` | 모니터링 서비스 설정.                                               |
| `cluster_ipv4_cidr`        | string          | ❌        | `null`              | Pod 네트워크의 CIDR 범위.                                             |
| `default_max_pods_per_node`| number          | ❌        | `110`               | 노드당 생성 가능한 최대 Pod 수.                                       |
| `initial_node_count`       | number          | ❌        | `3`                 | 초기 노드 수.                                                        |
| `enable_kubernetes_alpha`  | bool            | ❌        | `false`             | Kubernetes Alpha 기능 활성화 여부.                                    |
| `enable_tpu`               | bool            | ❌        | `false`             | TPU 사용 여부.                                                        |
| `enable_shielded_nodes`    | bool            | ❌        | `true`              | Shielded Nodes 활성화 여부.                                           |
| `ip_allocation_policy`     | object          | ❌        | `null`              | IP 할당 정책 설정.                                                    |
| `addons_config`            | object          | ❌        | `null`              | 애드온 구성 (Pod Autoscaling, HTTP Load Balancing 등).                  |
| `workload_identity_config` | object          | ❌        | `null`              | Workload Identity 설정.                                               |
| `cluster_autoscaling`      | object          | ❌        | `null`              | 클러스터 자동 확장 설정.                                              |
| `dns_config`               | object          | ❌        | `null`              | DNS 구성.                                                            |
| `database_encryption`      | object          | ❌        | `null`              | 데이터베이스 암호화 설정.                                              |
| `logging_config`           | object          | ❌        | `null`              | 로깅 구성.                                                           |
| `monitoring_config`        | object          | ❌        | `null`              | 모니터링 구성.                                                       |
| `default_snat_status`      | object          | ❌        | `null`              | 기본 SNAT 상태 설정.                                                  |

##### `ip_allocation_policy`

| 필드명                          | 타입    | 기본값  | 설명                                                   |
|---------------------------------|---------|---------|-------------------------------------------------------|
| `cluster_secondary_range_name`  | string  | `null`  | 클러스터 Pod IP 범위를 설정할 이름.                     |
| `services_secondary_range_name` | string  | `null`  | 서비스(LoadBalancer, ClusterIP) IP 범위 이름.          |
| `cluster_ipv4_cidr_block`       | string  | `null`  | 클러스터 Pod IP CIDR 범위.                            |
| `services_ipv4_cidr_block`      | string  | `null`  | 서비스 IP CIDR 범위.                                  |
| `stack_type`                    | string  | `"IPV4"`| IP 스택 유형 (예: IPV4, IPV6).                        |

##### `addons_config`

| 필드명                        | 타입    | 기본값  | 설명                                                      |
|-------------------------------|---------|---------|----------------------------------------------------------|
| `horizontal_pod_autoscaling`  | object  | `{ disabled = false }` | Pod Autoscaling 활성화 여부.                              |
| `http_load_balancing`         | object  | `{ disabled = false }` | HTTP Load Balancer 활성화 여부.                           |
| `network_policy_config`       | object  | `{ disabled = false }` | Network Policy 활성화 여부.                               |

##### `cluster_autoscaling`

| 필드명              | 타입    | 기본값  | 설명                                                      |
|---------------------|---------|---------|----------------------------------------------------------|
| `enabled`           | bool    | `false` | 클러스터 자동 확장 활성화 여부.                           |
| `resource_limits`   | object  | `null`  | 리소스 제한 설정.                                         |

###### `resource_limits` 필드

| 필드명          | 타입    | 기본값  | 설명                                                      |
|-----------------|---------|---------|----------------------------------------------------------|
| `resource_type` | string  | `null`  | 리소스 유형 (예: CPU, 메모리 등).                         |
| `minimum`       | number  | `null`  | 최소 리소스 수.                                           |
| `maximum`       | number  | `null`  | 최대 리소스 수.                                           |

<br>

### 3. 모듈 호출 예시

```hcl
module "gke_cluster" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/container-cluster-module.git?ref=v1.0.0"

  name     = "primary-cluster"
  location = "asia-northeast3-a"
  project  = "my-gcp-project-id"

  node_locations = ["asia-northeast3-a", "asia-northeast3-b"]
  description     = "Main production Kubernetes cluster"
  network         = "projects/my-gcp-project/global/networks/my-vpc"
  subnetwork      = "projects/my-gcp-project/regions/asia-northeast3/subnetworks/my-subnet"

  ip_allocation_policy = {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  addons_config = {
    horizontal_pod_autoscaling = { disabled = false }
    http_load_balancing        = { disabled = true }
  }

  workload_identity_config = {
    workload_pool = "my-gcp-project.svc.id.goog"
  }

  cluster_autoscaling = {
    enabled = true
    resource_limits = {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }
  }
}
```

<br>

### 4. 출력값 (Outputs)

| 출력명                   | 설명                                                                 |
|--------------------------|---------------------------------------------------------------------|
| `id`                    | 클러스터의 고유 ID (프로젝트, 위치, 클러스터 이름 조합).            |
| `endpoint`              | 클러스터의 Kubernetes API 서버 엔드포인트 (IP 주소).                |
| `cluster_ca_certificate`| 클러스터 API 서버와 통신하기 위한 CA 인증서.                        |
| `network`               | 클러스터가 속한 네트워크 이름.                                      |
| `subnetwork`            | 클러스터가 속한 서브네트워크 이름.                                  |
| `services_ipv4_cidr`    | 클러스터의 서비스에 할당된 IPv4 CIDR 범위.                          |
| `cluster_ipv4_cidr`     | 클러스터의 Pod 네트워크에 할당된 IPv4 CIDR 범위.                    |
| `node_pools`            | 클러스터에 설정된 노드풀들의 URL 목록.                               |
| `resource_labels`       | 클러스터에 적용된 리소스 레이블 (Key-Value 형식).                    |
| `master_version`        | Kubernetes API 서버의 현재 버전.                                    |
| `project`               | 클러스터가 속한 GCP 프로젝트 ID.                                   |
| `location`              | 클러스터가 생성된 GCP 위치 (지역 또는 영역).                         |
| `self_link`             | GKE 클러스터의 셀프 링크 URL.                                       |

<br>

### 5. 지원 버전

#### a.  Terraform 버전
| 버전 범위 | 설명                              |
|-----------|-----------------------------------|
| `1.10.3`   | 최신 버전, 지원 및 테스트 완료                  |

#### b. Google Provider 버전
| 버전 범위 | 설명                              |
|-----------|-----------------------------------|
| `~> 6.0`  | 최소 지원 버전                   |

<br>

### 6. 모듈 개발 및 관리

- **저장소 구조**:
  ```
  project-iam-member-module/
  ├── .github/workflows/  # github actions 자동화 테스트
  ├── examples/           # 테스트를 위한 루트 모듈 모음 디렉터리
  ├── test/               # 테스트 구성 디렉터리
  ├── main.tf             # 모듈의 핵심 구현
  ├── variables.tf        # 입력 변수 정의
  ├── outputs.tf          # 출력 정의
  ├── versions.tf         # 버전 정의
  ├── README.md           # 문서화 파일
  ```
<br>

---

## Terratest를 이용한 테스트
이 모듈을 테스트하려면 제공된 Go 기반 테스트 프레임워크를 사용하세요. 아래를 확인하세요:

1. Terraform 및 Go 설치.
2. 필요한 환경 변수 설정 (GCP_PROJECT_ID, API_SERVICES 등).
3. 테스트 실행:
```bash
go test -v ./test
```

<br>

## 주요 버전 관리
이 모듈은 [Semantic Versioning](https://semver.org/)을 따릅니다.  
안정된 버전을 사용하려면 `?ref=<version>`을 활용하세요:

```hcl
source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/container-cluster-module.git?ref=v1.0.0"
```

### Module ref 버전
| Major | Minor | Patch |
|-----------|-----------|----------|
| `1.0.0`   |    |   |


<br>

## 기여 (Contributing)
기여를 환영합니다! 버그 제보 및 기능 요청은 GitHub Issues를 통해 제출해주세요.

<br>

## 라이선스 (License)
[MIT License](LICENSE)