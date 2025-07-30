# Atlassian Loom: Deployment & Infrastructure

## Document Overview
This document defines the comprehensive deployment and infrastructure architecture for the Atlassian Loom platform, covering Kubernetes deployments, Infrastructure as Code, CI/CD pipelines, and operational procedures.

## 1. Kubernetes Deployment Architecture

### 1.1 Production Cluster Configuration

#### 1.1.1 Namespace and Resource Management
```yaml
# Production Kubernetes Cluster
apiVersion: v1
kind: Namespace
metadata:
  name: loom-production
  labels:
    environment: production
    team: platform
---
apiVersion: v1
kind: Namespace
metadata:
  name: loom-processing
  labels:
    environment: production
    team: processing
---
# Resource Quotas
apiVersion: v1
kind: ResourceQuota
metadata:
  name: loom-production-quota
  namespace: loom-production
spec:
  hard:
    requests.cpu: "200"
    requests.memory: 400Gi
    limits.cpu: "400"
    limits.memory: 800Gi
    persistentvolumeclaims: "100"
    requests.storage: 10Ti
    count/deployments.apps: "50"
    count/services: "50"
    count/secrets: "100"
    count/configmaps: "100"

---
# Network Policies
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loom-network-policy
  namespace: loom-production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
    - namespaceSelector:
        matchLabels:
          name: loom-production
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: loom-production
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

#### 1.1.2 Service Mesh Configuration
```yaml
# Service Mesh Configuration
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: loom-control-plane
spec:
  values:
    global:
      meshID: loom-mesh
      network: loom-network
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: 1000m
            memory: 4Gi
          limits:
            cpu: 2000m
            memory: 8Gi
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        service:
          type: LoadBalancer
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
```

### 1.2 Application Deployments

#### 1.2.1 Recording Service Deployment
```yaml
# Recording Service Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recording-service
  namespace: loom-production
  labels:
    app: recording-service
    version: v1
spec:
  replicas: 5
  selector:
    matchLabels:
      app: recording-service
      version: v1
  template:
    metadata:
      labels:
        app: recording-service
        version: v1
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      serviceAccountName: recording-service
      containers:
      - name: recording-service
        image: loom/recording-service:1.0.0
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
        - name: KAFKA_BROKERS
          valueFrom:
            configMapKeyRef:
              name: kafka-config
              key: brokers
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        - name: temp-storage
          mountPath: /tmp
      volumes:
      - name: config-volume
        configMap:
          name: recording-service-config
      - name: temp-storage
        emptyDir:
          sizeLimit: "10Gi"

---
# Video Processing Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: video-processor
  namespace: loom-processing
  labels:
    app: video-processor
    version: v1
spec:
  replicas: 10
  selector:
    matchLabels:
      app: video-processor
      version: v1
  template:
    metadata:
      labels:
        app: video-processor
        version: v1
    spec:
      nodeSelector:
        workload-type: compute-intensive
      containers:
      - name: video-processor
        image: loom/video-processor:1.0.0
        resources:
          requests:
            cpu: 4000m
            memory: 8Gi
          limits:
            cpu: 8000m
            memory: 16Gi
        env:
        - name: FFMPEG_THREADS
          value: "8"
        - name: PROCESSING_QUEUE
          value: "video-processing"
        - name: S3_BUCKET
          valueFrom:
            configMapKeyRef:
              name: storage-config
              key: video-bucket
        volumeMounts:
        - name: processing-storage
          mountPath: /tmp/processing
        - name: ffmpeg-cache
          mountPath: /var/cache/ffmpeg
      volumes:
      - name: processing-storage
        emptyDir:
          sizeLimit: "50Gi"
      - name: ffmpeg-cache
        emptyDir:
          sizeLimit: "10Gi"
```

#### 1.2.2 Auto-Scaling Configuration
```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: recording-service-hpa
  namespace: loom-production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: recording-service
  minReplicas: 5
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60

---
# Vertical Pod Autoscaler
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: video-processor-vpa
  namespace: loom-processing
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: video-processor
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: video-processor
      minAllowed:
        cpu: 2000m
        memory: 4Gi
      maxAllowed:
        cpu: 16000m
        memory: 32Gi
      controlledResources: ["cpu", "memory"]
```

## 2. Infrastructure as Code

### 2.1 Terraform Configuration

#### 2.1.1 AWS Infrastructure
```hcl
# main.tf - AWS Infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
  
  backend "s3" {
    bucket         = "loom-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# VPC Configuration
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Environment = var.environment
    Project     = "loom"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 5
      min_size     = 5
      max_size     = 20

      instance_types = ["m5.xlarge"]
      capacity_type  = "ON_DEMAND"

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }

      update_config = {
        max_unavailable_percentage = 25
      }
    }

    compute_intensive = {
      desired_size = 3
      min_size     = 0
      max_size     = 50

      instance_types = ["c5.4xlarge"]
      capacity_type  = "SPOT"

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "compute-intensive"
        workload-type = "compute-intensive"
      }

      taints = {
        compute = {
          key    = "compute-intensive"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = "loom"
  }
}
```

#### 2.1.2 Database Infrastructure
```hcl
# RDS Aurora PostgreSQL
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "${var.cluster_name}-postgresql"
  engine                 = "aurora-postgresql"
  engine_version         = "14.9"
  database_name          = "loom"
  master_username        = var.db_username
  master_password        = var.db_password
  backup_retention_period = 30
  preferred_backup_window = "07:00-09:00"
  preferred_maintenance_window = "sun:05:00-sun:07:00"
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  storage_encrypted = true
  kms_key_id       = aws_kms_key.rds.arn
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.cluster_name}-postgresql-final"
  
  tags = {
    Name        = "${var.cluster_name}-postgresql"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "postgresql_instances" {
  count              = 3
  identifier         = "${var.cluster_name}-postgresql-${count.index}"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.r6g.2xlarge"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn        = aws_iam_role.rds_enhanced_monitoring.arn
}

# S3 Buckets for Video Storage
resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.cluster_name}-video-storage"
  
  tags = {
    Name        = "${var.cluster_name}-video-storage"
    Environment = var.environment
    Purpose     = "video-storage"
  }
}

resource "aws_s3_bucket_versioning" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  rule {
    id     = "video_lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }
}
```

#### 2.1.3 Caching and CDN Infrastructure
```hcl
# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id         = "${var.cluster_name}-redis"
  description                  = "Redis cluster for ${var.cluster_name}"
  
  node_type                    = "cache.r6g.xlarge"
  port                         = 6379
  parameter_group_name         = "default.redis7"
  
  num_cache_clusters           = 6
  automatic_failover_enabled   = true
  multi_az_enabled            = true
  
  subnet_group_name           = aws_elasticache_subnet_group.redis.name
  security_group_ids          = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
  auth_token                  = var.redis_auth_token
  
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
  
  tags = {
    Name        = "${var.cluster_name}-redis"
    Environment = var.environment
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "video_cdn" {
  origin {
    domain_name = aws_s3_bucket.video_storage.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.video_storage.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.video_cdn.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.video_storage.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }

  # Cache behavior for video files
  ordered_cache_behavior {
    path_pattern     = "videos/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.video_storage.id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 2592000  # 30 days
    max_ttl                = 31536000 # 1 year
    compress               = false    # Videos are already compressed
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.cluster_name}-video-cdn"
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

## 3. CI/CD Pipeline

### 3.1 GitHub Actions Workflow

#### 3.1.1 Build and Deploy Pipeline
```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-west-2
  EKS_CLUSTER_NAME: loom-production
  ECR_REPOSITORY: loom

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'
    
    - name: Run tests
      run: |
        go test -v ./...
        go test -race -coverprofile=coverage.out ./...
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.out

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  build:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        # Build recording service
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/recording-service:$IMAGE_TAG ./services/recording
        docker push $ECR_REGISTRY/$ECR_REPOSITORY/recording-service:$IMAGE_TAG
        
        # Build video processor
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/video-processor:$IMAGE_TAG ./services/video-processor
        docker push $ECR_REGISTRY/$ECR_REPOSITORY/video-processor:$IMAGE_TAG
        
        # Build AI service
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/ai-service:$IMAGE_TAG ./services/ai
        docker push $ECR_REGISTRY/$ECR_REPOSITORY/ai-service:$IMAGE_TAG

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Update kube config
      run: aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION
    
    - name: Deploy to EKS
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        # Update deployment images
        kubectl set image deployment/recording-service \
          recording-service=$ECR_REGISTRY/$ECR_REPOSITORY/recording-service:$IMAGE_TAG \
          -n loom-production
        
        kubectl set image deployment/video-processor \
          video-processor=$ECR_REGISTRY/$ECR_REPOSITORY/video-processor:$IMAGE_TAG \
          -n loom-processing
        
        kubectl set image deployment/ai-service \
          ai-service=$ECR_REGISTRY/$ECR_REPOSITORY/ai-service:$IMAGE_TAG \
          -n loom-production
        
        # Wait for rollout to complete
        kubectl rollout status deployment/recording-service -n loom-production
        kubectl rollout status deployment/video-processor -n loom-processing
        kubectl rollout status deployment/ai-service -n loom-production
    
    - name: Verify deployment
      run: |
        kubectl get pods -n loom-production
        kubectl get pods -n loom-processing
        
        # Run health checks
        kubectl exec -n loom-production deployment/recording-service -- curl -f http://localhost:8080/health
```

### 3.2 Helm Charts

#### 3.2.1 Recording Service Helm Chart
```yaml
# charts/recording-service/values.yaml
replicaCount: 5

image:
  repository: loom/recording-service
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: api.loom.com
      paths:
        - path: /api/v1/recordings
          pathType: Prefix

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 50
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

# Environment variables
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: database-credentials
        key: url
  - name: REDIS_URL
    valueFrom:
      secretKeyRef:
        name: redis-credentials
        key: url

# ConfigMap data
config:
  logLevel: "info"
  maxRecordingDuration: "14400" # 4 hours
  tempStorageSize: "10Gi"
```

#### 3.2.2 Helm Chart Template
```yaml
# charts/recording-service/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "recording-service.fullname" . }}
  labels:
    {{- include "recording-service.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "recording-service.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "recording-service.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "recording-service.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /health/live
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          volumeMounts:
            - name: config-volume
              mountPath: /app/config
            - name: temp-storage
              mountPath: /tmp
      volumes:
        - name: config-volume
          configMap:
            name: {{ include "recording-service.fullname" . }}-config
        - name: temp-storage
          emptyDir:
            sizeLimit: {{ .Values.config.tempStorageSize }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

## 4. Monitoring and Observability

### 4.1 Prometheus Configuration

#### 4.1.1 Monitoring Stack
```yaml
# monitoring/prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp3
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 100Gi
    
    additionalScrapeConfigs:
      - job_name: 'loom-services'
        kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
                - loom-production
                - loom-processing
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)

grafana:
  adminPassword: ${GRAFANA_ADMIN_PASSWORD}
  persistence:
    enabled: true
    size: 10Gi
  
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'loom-dashboards'
        orgId: 1
        folder: 'Loom'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/loom

  dashboards:
    loom-dashboards:
      loom-overview:
        gnetId: 12345
        revision: 1
        datasource: Prometheus

alertmanager:
  config:
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@loom.com'
    
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
    
    receivers:
    - name: 'web.hook'
      email_configs:
      - to: 'ops-team@loom.com'
        subject: 'Loom Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .