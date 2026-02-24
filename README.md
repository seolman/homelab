# Cloud-Native Homelab: High-Availability GitOps Infrastructure

하드웨어 레이어부터 애플리케이션 서비스까지 전 과정을 자동화한 **고가용성(HA) 쿠버네티스 홈랩** 프로젝트입니다.
단순 구축을 넘어 실무 수준의 **Infrastructure as Code (IaC)**와 **GitOps** 패턴을 적용하여 운영 효율성과 보안을 극대화했습니다.

[이전 레포 (Mini-Rack)](https://github.com/seolman/mini-rack)

## 🚀 Key Highlights

- **Zero-Touch Provisioning**: Ansible을 사용하여 Raspberry Pi 및 Mini PC의 OS 설정, 커널 최적화(Cgroup 등), K3s 클러스터 구성을 완전 자동화했습니다.
- **True GitOps Workflow**: ArgoCD의 **App-of-Apps 패턴**을 적용하여 모든 인프라와 애플리케이션의 상태를 Git에서 선언적으로 관리합니다.
- **High Availability (HA)**: `kube-vip`를 통한 Control Plane 부하 분산과 `Longhorn`을 활용한 분산 스토리지를 통해 단일 장애점(SPOF)을 제거했습니다.
- **Automated Security & TLS**: `Sealed Secrets`를 통한 비밀번호 암호화 관리 및 `Cert-manager` + `Cloudflare DNS-01` 챌린지를 활용하여 내부 서비스에 대한 TLS 인증서를 자동 발급합니다.

## 🏗 Architecture

### 1. Infrastructure Layer
- **Orchestration**: K3s (Lightweight Kubernetes)
- **HA Management**: kube-vip (Virtual IP for Control Plane)
- **Automation**: Ansible (Day-0 & Day-1 Operations)

### 2. Platform Service Layer (GitOps Managed)
- **GitOps**: ArgoCD (Kustomize 기반 구성 관리)
- **Networking**: MetalLB (L2 LoadBalancer) & Traefik (Ingress Controller)
- **Storage**: Longhorn (Distributed Block Storage)
- **Security**: Sealed Secrets, Cert-manager
- **Database & Storage**: CloudNative-PG, Minio
- **Monitoring**: Prometheus & Grafana (kube-prometheus-stack)

## 🛠 Engineering Decisions

### 하드웨어 최적화 및 HA 클러스터 구성
- **Problem**: Raspberry Pi의 메모리 관리 이슈 및 단일 Master Node의 가용성 부족.
- **Solution**: Ansible Role(`k3s_raspberry`)을 통해 메모리 Cgroup을 자동 활성화하고, `kube-vip`를 적용하여 Master Node 장애 시에도 API Server 연결이 유지되도록 HA를 구성했습니다.
- **Detail**: K3s 기본 컴포넌트(Traefik, ServiceLB)를 비활성화하고, GitOps로 직접 제어할 수 있도록 커스텀 구성했습니다.

### 선언적 인프라 관리 (GitOps)
- **Workflow**: `infra/base`에 공통 설정을 두고, `infra/overlays/prod`에서 환경별 차이를 관리하는 **Kustomize** 구조를 채택했습니다.
- **Automation**: 신규 서비스 추가 시 `clusters/homelab/`에 Application Manifest만 추가하면 ArgoCD가 이를 감지하여 전체 스택을 배포합니다.

### 보안 및 인증 자동화
- **Sealed Secrets**: Git Public Repo에 민감한 정보(API Token 등)를 안전하게 커밋하기 위해 비대칭 암호화를 적용했습니다.
- **Wildcard TLS**: Let's Encrypt와 Cloudflare API를 연동하여, 포트를 개방하지 않고도 내부 서비스에 유효한 HTTPS 인증서를 자동 적용했습니다.

## 📁 Project Structure

```text
.
├── ansible/            # Day-0: OS 최적화 및 K3s HA 설치 자동화
├── clusters/           # Day-1: ArgoCD Root App 및 서비스 정의 (App-of-Apps)
├── infra/              # Day-2: 공통 인프라 설정 (Kustomize Base/Overlays)
│   ├── base/           # 공통 Manifest (Traefik, Longhorn, MetalLB 등)
│   └── overlays/prod/  # 운영 환경 특화 설정 (IP Pool, IngressRoute 등)
└── apps/               # 사용자 애플리케이션 워크로드 (Nginx 등)
```

## 🔌 Hardware Spec

10인치 [미니랙](https://www.youtube.com/watch?v=y1GCIwLm3is) 구성을 통해 컴팩트한 홈 인프라를 구축했습니다.

![19인치와 10인치 랙의 차이점](https://upload.wikimedia.org/wikipedia/commons/8/87/19_inch_vs_10_inch_correct_rack_dimensions.svg)

- **Rack**: [DeskPi RackMate T0](https://deskpi.com/products/deskpi-rackmate-t1-rackmount-10-inch-4u-server-cabinet-for-network-servers-audio-and-video-equipment)
- **Compute (Mini PC)**: [Firebat Ak2 Plus](https://firebat.net/firebat-ak2-plus-minipc-intel-n100-dual-band-wifi5-bt4-2-16gb-512gb-desktop-gaming-computer-mini-pc-gamer/) (Intel N100)
- **Compute (SBC)**: [Raspberry Pi 5 8GB](https://www.raspberrypi.com/products/raspberry-pi-5/)
- **Storage**: [Suptronics X1012-V1.2](https://suptronics.com/Raspberrypi/Storage/x1012-v1.2.html) (NVMe for RPi)
- **Networking**: [GL-INet Beryl AX](https://www.gl-inet.com/products/gl-mt3000/), [ipTIME PoE802](http://iptime.com/iptime/?page_id=11&pf=11&page=2&pt=458&pd=1), [Gigabit Poe Splitter]()
- **Management**: [JetKVM](https://jetkvm.com/), [Server Tap HDSVAL-14]()
