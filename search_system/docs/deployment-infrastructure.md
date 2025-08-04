# Knowledge Base Search System - Deployment & Infrastructure

## Overview

This document outlines the deployment strategy and infrastructure architecture for the knowledge base search system, focusing on scalability, reliability, and maintainability in a cloud environment.

## Infrastructure Architecture

```mermaid
graph TB
    subgraph "Internet"
        USERS[Users]
        CDN[Content Delivery Network]
    end
    
    subgraph "Edge Layer"
        WAF[Web Application Firewall]
        LB[Load Balancer]
    end
    
    subgraph "Application Tier"
        subgraph "Production Environment"
            APP1[App Instance 1]
            APP2[App Instance 2]
            APP3[App Instance 3]
        end
        
        subgraph "Staging Environment"
            STAGE_APP[Staging App]
        end
        
        subgraph "Development Environment"
            DEV_APP[Dev App]
        end
    end
    
    subgraph "Search Tier"
        ES_CLUSTER[Elasticsearch Cluster]
        ES_MASTER[Master Nodes]
        ES_DATA[Data Nodes]
        ES_INGEST[Ingest Nodes]
    end
    
    subgraph "Data Tier"
        DB_PRIMARY[(Primary Database)]
        DB_REPLICA[(Read Replicas)]
        CACHE_CLUSTER[(Redis Cluster)]
    end
    
    subgraph "Storage Tier"
        OBJECT_STORAGE[Object Storage]
        BACKUP_STORAGE[Backup Storage]
    end
    
    subgraph "Monitoring & Logging"
        MONITORING[Monitoring Stack]
        LOGGING[Centralized Logging]
        ALERTING[Alert Manager]
    end
    
    USERS --> CDN
    CDN --> WAF
    WAF --> LB
    
    LB --> APP1
    LB --> APP2
    LB --> APP3
    
    APP1 --> ES_CLUSTER
    APP2 --> ES_CLUSTER
    APP3 --> ES_CLUSTER
    
    APP1 --> DB_PRIMARY
    APP2 --> DB_REPLICA
    APP3 --> CACHE_CLUSTER
    
    ES_CLUSTER --> ES_MASTER
    ES_CLUSTER --> ES_DATA
    ES_CLUSTER --> ES_INGEST
    
    APP1 --> OBJECT_STORAGE
    DB_PRIMARY --> BACKUP_STORAGE
    
    APP1 --> MONITORING
    ES_CLUSTER --> LOGGING
    DB_PRIMARY --> ALERTING
```

## Cloud Platform Options

### 1. AWS Deployment Architecture

```yaml
# AWS Infrastructure Components
Production Environment:
  Compute:
    - ECS Fargate for containerized applications
    - Auto Scaling Groups for dynamic scaling
    - Application Load Balancer for traffic distribution
  
  Database:
    - RDS PostgreSQL with Multi-AZ deployment
    - ElastiCache Redis cluster
    - Amazon Elasticsearch Service
  
  Storage:
    - S3 for object storage and static assets
    - EBS for persistent volumes
    - S3 Glacier for long-term backups
  
  Networking:
    - VPC with public and private subnets
    - NAT Gateway for outbound internet access
    - CloudFront CDN for global content delivery
  
  Security:
    - WAF for application protection
    - Security Groups and NACLs
    - IAM roles and policies
    - AWS Certificate Manager for SSL/TLS
  
  Monitoring:
    - CloudWatch for metrics and logs
    - X-Ray for distributed tracing
    - AWS Config for compliance monitoring
```

### 2. Azure Deployment Architecture

```yaml
# Azure Infrastructure Components
Production Environment:
  Compute:
    - Azure Container Instances or AKS
    - Virtual Machine Scale Sets
    - Azure Load Balancer
  
  Database:
    - Azure Database for PostgreSQL
    - Azure Cache for Redis
    - Azure Cognitive Search
  
  Storage:
    - Azure Blob Storage
    - Azure Files for shared storage
    - Azure Backup for data protection
  
  Networking:
    - Virtual Network with subnets
    - Azure Front Door for global load balancing
    - Azure CDN for content delivery
  
  Security:
    - Azure Firewall and NSGs
    - Azure Key Vault for secrets
    - Azure Active Directory integration
  
  Monitoring:
    - Azure Monitor and Log Analytics
    - Application Insights
    - Azure Security Center
```

### 3. Google Cloud Platform Architecture

```yaml
# GCP Infrastructure Components
Production Environment:
  Compute:
    - Google Kubernetes Engine (GKE)
    - Compute Engine with managed instance groups
    - Cloud Load Balancing
  
  Database:
    - Cloud SQL for PostgreSQL
    - Memorystore for Redis
    - Elasticsearch on Compute Engine
  
  Storage:
    - Cloud Storage buckets
    - Persistent Disks
    - Cloud Backup and DR
  
  Networking:
    - VPC with custom subnets
    - Cloud CDN
    - Cloud Armor for DDoS protection
  
  Security:
    - Identity and Access Management
    - Cloud KMS for encryption keys
    - VPC Security Controls
  
  Monitoring:
    - Cloud Monitoring and Logging
    - Cloud Trace for performance
    - Error Reporting
```

## Container Strategy

### 1. Docker Configuration

```dockerfile
# Application Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM node:18-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

WORKDIR /app

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Security hardening
RUN apk add --no-cache dumb-init
RUN rm -rf /var/cache/apk/*

USER nextjs

EXPOSE 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### 2. Kubernetes Deployment

```yaml
# Kubernetes deployment configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kb-search-api
  namespace: knowledge-base
  labels:
    app: kb-search-api
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: kb-search-api
  template:
    metadata:
      labels:
        app: kb-search-api
        version: v1.0.0
    spec:
      serviceAccountName: kb-search-service-account
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: api
        image: kb-search-api:v1.0.0
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: kb-secrets
              key: database-url
        - name: ELASTICSEARCH_URL
          valueFrom:
            secretKeyRef:
              name: kb-secrets
              key: elasticsearch-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: kb-secrets
              key: redis-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: config
          mountPath: /app/config
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: kb-config
      imagePullSecrets:
      - name: registry-secret

---
apiVersion: v1
kind: Service
metadata:
  name: kb-search-api-service
  namespace: knowledge-base
spec:
  selector:
    app: kb-search-api
  ports:
  - name: http
    port: 80
    targetPort: 3000
    protocol: TCP
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kb-search-ingress
  namespace: knowledge-base
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - kb.company.com
    secretName: kb-tls-secret
  rules:
  - host: kb.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kb-search-api-service
            port:
              number: 80
```

## Database Deployment

### 1. PostgreSQL Configuration

```yaml
# PostgreSQL Helm values
postgresql:
  enabled: true
  auth:
    postgresPassword: "secure-password"
    database: "knowledge_base"
  
  primary:
    persistence:
      enabled: true
      size: 100Gi
      storageClass: "fast-ssd"
    
    resources:
      requests:
        memory: "2Gi"
        cpu: "1000m"
      limits:
        memory: "4Gi"
        cpu: "2000m"
    
    configuration: |
      # Performance tuning
      shared_buffers = 1GB
      effective_cache_size = 3GB
      maintenance_work_mem = 256MB
      checkpoint_completion_target = 0.9
      wal_buffers = 16MB
      default_statistics_target = 100
      random_page_cost = 1.1
      effective_io_concurrency = 200
      
      # Logging
      log_statement = 'mod'
      log_min_duration_statement = 1000
      log_checkpoints = on
      log_connections = on
      log_disconnections = on
      
      # Security
      ssl = on
      ssl_cert_file = '/etc/ssl/certs/server.crt'
      ssl_key_file = '/etc/ssl/private/server.key'
  
  readReplicas:
    replicaCount: 2
    persistence:
      enabled: true
      size: 100Gi
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"

  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
```

### 2. Elasticsearch Cluster

```yaml
# Elasticsearch cluster configuration
elasticsearch:
  clusterName: "kb-search-cluster"
  nodeGroup: "master"
  
  # Master nodes
  masterService: "kb-search-master"
  roles:
    master: "true"
    ingest: "false"
    data: "false"
  
  replicas: 3
  minimumMasterNodes: 2
  
  esConfig:
    elasticsearch.yml: |
      cluster.name: kb-search-cluster
      network.host: 0.0.0.0
      
      # Security
      xpack.security.enabled: true
      xpack.security.transport.ssl.enabled: true
      xpack.security.http.ssl.enabled: true
      
      # Performance
      indices.memory.index_buffer_size: 20%
      indices.queries.cache.size: 10%
      indices.fielddata.cache.size: 15%
      
      # Monitoring
      xpack.monitoring.enabled: true
      xpack.monitoring.collection.enabled: true
  
  resources:
    requests:
      cpu: "1000m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
  
  volumeClaimTemplate:
    accessModes: ["ReadWriteOnce"]
    storageClassName: "fast-ssd"
    resources:
      requests:
        storage: 100Gi

---
# Data nodes
elasticsearch:
  clusterName: "kb-search-cluster"
  nodeGroup: "data"
  
  roles:
    master: "false"
    ingest: "false"
    data: "true"
  
  replicas: 3
  
  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"
  
  volumeClaimTemplate:
    accessModes: ["ReadWriteOnce"]
    storageClassName: "fast-ssd"
    resources:
      requests:
        storage: 500Gi

---
# Ingest nodes
elasticsearch:
  clusterName: "kb-search-cluster"
  nodeGroup: "ingest"
  
  roles:
    master: "false"
    ingest: "true"
    data: "false"
  
  replicas: 2
  
  resources:
    requests:
      cpu: "1000m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
```

## CI/CD Pipeline

### 1. GitHub Actions Workflow

```yaml
name: Knowledge Base Search System CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: kb-search-system

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: kb_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      elasticsearch:
        image: elasticsearch:8.8.0
        env:
          discovery.type: single-node
          xpack.security.enabled: false
        options: >-
          --health-cmd "curl http://localhost:9200/_cluster/health"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 10
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run type checking
      run: npm run type-check
    
    - name: Run unit tests
      run: npm run test:unit
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/kb_test
        REDIS_URL: redis://localhost:6379
        ELASTICSEARCH_URL: http://localhost:9200
    
    - name: Run integration tests
      run: npm run test:integration
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/kb_test
        REDIS_URL: redis://localhost:6379
        ELASTICSEARCH_URL: http://localhost:9200
    
    - name: Run security tests
      run: npm run test:security
    
    - name: Generate coverage report
      run: npm run coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      packages: write
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    environment:
      name: staging
      url: https://kb-staging.company.com
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure kubectl
      uses: azure/k8s-set-context@v1
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.KUBE_CONFIG_STAGING }}
    
    - name: Deploy to staging
      run: |
        kubectl set image deployment/kb-search-api \
          api=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop \
          -n knowledge-base-staging
        
        kubectl rollout status deployment/kb-search-api \
          -n knowledge-base-staging --timeout=300s
    
    - name: Run smoke tests
      run: |
        npm run test:smoke -- --baseUrl=https://kb-staging.company.com

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: production
      url: https://kb.company.com
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure kubectl
      uses: azure/k8s-set-context@v1
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.KUBE_CONFIG_PRODUCTION }}
    
    - name: Deploy to production
      run: |
        kubectl set image deployment/kb-search-api \
          api=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest \
          -n knowledge-base
        
        kubectl rollout status deployment/kb-search-api \
          -n knowledge-base --timeout=600s
    
    - name: Run production health checks
      run: |
        npm run test:health -- --baseUrl=https://kb.company.com
    
    - name: Notify deployment
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Environment Configuration

### 1. Development Environment

```yaml
# Development environment configuration
development:
  replicas: 1
  
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
  
  database:
    host: "localhost"
    port: 5432
    name: "kb_development"
    ssl: false
  
  elasticsearch:
    host: "localhost"
    port: 9200
    ssl: false
  
  redis:
    host: "localhost"
    port: 6379
  
  logging:
    level: "debug"
    format: "pretty"
  
  features:
    analytics: false
    monitoring: false
    security_headers: false
```

### 2. Staging Environment

```yaml
# Staging environment configuration
staging:
  replicas: 2
  
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  
  database:
    host: "kb-staging-db.company.com"
    port: 5432
    name: "kb_staging"
    ssl: true
    pool_size: 10
  
  elasticsearch:
    host: "kb-staging-es.company.com"
    port: 9200
    ssl: true
    replicas: 1
  
  redis:
    host: "kb-staging-redis.company.com"
    port: 6379
    ssl: true
  
  logging:
    level: "info"
    format: "json"
  
  features:
    analytics: true
    monitoring: true
    security_headers: true
  
  autoscaling:
    enabled: true
    min_replicas: 2
    max_replicas: 5
    target_cpu: 70
```

### 3. Production Environment

```yaml
# Production environment configuration
production:
  replicas: 3
  
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
  
  database:
    host: "kb-prod-db.company.com"
    port: 5432
    name: "kb_production"
    ssl: true
    pool_size: 20
    read_replicas: 2
  
  elasticsearch:
    host: "kb-prod-es.company.com"
    port: 9200
    ssl: true
    replicas: 3
    shards: 2
  
  redis:
    host: "kb-prod-redis.company.com"
    port: 6379
    ssl: true
    cluster: true
  
  logging:
    level: "warn"
    format: "json"
  
  features:
    analytics: true
    monitoring: true
    security_headers: true
    rate_limiting: true
  
  autoscaling:
    enabled: true
    min_replicas: 3
    max_replicas: 10
    target_cpu: 60
    target_memory: 70
  
  backup:
    enabled: true
    schedule: "0 2 * * *"  # Daily at 2 AM
    retention: "30d"
```

## Monitoring and Observability

### 1. Prometheus Configuration

```yaml
# Prometheus monitoring setup
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "/etc/prometheus/rules/*.yml"
    
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093
    
    scrape_configs:
      - job_name: 'kb-search-api'
        kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
                - knowledge-base
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            action: keep
            regex: kb-search-api-service
          - source_labels: [__meta_kubernetes_endpoint_port_name]
            action: keep
            regex: metrics
      
      - job_name: 'elasticsearch'
        static_configs:
          - targets: ['elasticsearch:9200']
        metrics_path: /_prometheus/metrics
      
      - job_name: 'postgresql'
        static_configs:
          - targets: ['postgres-exporter:9187']
      
      - job_name: 'redis'
        static_configs:
          - targets: ['redis-exporter:9121']

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: monitoring
data:
  kb-search.yml: |
    groups:
      - name: kb-search-alerts
        rules:
          - alert: HighResponseTime
            expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
            for: 2m
            labels:
              severity: warning
            annotations:
              summary: "High response time detected"
              description: "95th percentile response time is {{ $value }}s"
          
          - alert: HighErrorRate
            expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "High error rate detected"
              description: "Error rate is {{ $value | humanizePercentage }}"
          
          - alert: ElasticsearchClusterDown
            expr: up{job="elasticsearch"} == 0
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Elasticsearch cluster is down"
              description: "Elasticsearch cluster has been down for more than 1 minute"
          
          - alert: DatabaseConnectionsHigh
            expr: pg_stat_database_numbackends / pg_settings_max_connections > 0.8
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Database connections are high"
              description: "Database connections are at {{ $value | humanizePercentage }} of maximum"
```

### 2. Grafana Dashboards

```json
{
  "dashboard": {
    "title": "Knowledge Base Search System",
    "tags": ["knowledge-base", "search"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ],
        "yAxes": [
          {
            "label": "Requests/sec"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          },
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "99th percentile"
          }
        ],
        "yAxes": [
          {
            "label": "Seconds"
          }
        ]
      },
      {
        "title": "Search Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(search_requests_total[5m])",
            "legendFormat": "Search requests/sec"
          },
          {
            "expr": "histogram_quantile(0.95, rate(search_duration_seconds_bucket[5m]))",
            "legendFormat": "Search response time (95th)"
          }
        ]
      },
      {
        "title": "Elasticsearch Cluster Health",
        "type": "stat",
        "targets": [
          {
            "expr": "elasticsearch_cluster_health_status",
            "legendFormat": "Cluster Status"
          }
        ]
      },
      {
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "Active connections"
          },
          {
            "expr": "pg_settings_max_connections",
            "legendFormat": "Max connections"
          }
        ]
      }
    ]
  }
}
```

## Disaster Recovery

### 1. Backup Strategy

```yaml
# Backup configuration
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: knowledge-base
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:14
            command:
            - /bin/bash
            - -c
            - |
              TIMESTAMP=$(date +%Y%m%d_%H%M%S)
              BACKUP_FILE="kb_backup_${TIMESTAMP}.sql"
              
              pg_dump $DATABASE_URL > /tmp/$BACKUP_FILE
              
              # Upload to cloud storage
              aws s3 cp /tmp/$BACKUP_FILE s3://kb-backups/database/$BACKUP_FILE
              
              # Cleanup old backups (keep 30 days)
              aws s3 ls s3://kb-backups/database/ | \
                awk '$1 < "'$(date -d '30 days ago' '+%Y-%m-%d')'" {print $4}' | \
                xargs -I {} aws s3 rm s3://kb-backups/database/{}
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: kb-secrets
                  key: database-url
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: access-key-id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: secret-access-key
          restartPolicy: OnFailure

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: elasticsearch-backup
  namespace: knowledge-base
spec:
  schedule: "0 3 * * *"  # Daily at 3 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: curlimages/curl:latest
            command:
            - /bin/sh
            - -c
            - |
              TIMESTAMP=$(date +%Y%m%d_%H%M%S)
              SNAPSHOT_NAME="kb_snapshot_${TIMESTAMP}"
              
              # Create snapshot
              curl -X PUT "$ELASTICSEARCH_URL/_snapshot/kb_backups/$SNAPSHOT_NAME" \
                -H "Content-Type: application/json" \
                -d '{
                  "indices": "kb-articles-*",
                  "ignore_unavailable": true,
                  "include_global_state": false
                }'
              
              # Wait for completion
              while true; do
                STATUS=$(curl -s "$ELASTICSEARCH_URL/_snapshot/kb_backups
/$SNAPSHOT_NAME" | jq -r '.snapshots[0].state')
                if [ "$STATUS" = "SUCCESS" ]; then
                  break
                elif [ "$STATUS" = "FAILED" ]; then
                  echo "Snapshot failed"
                  exit 1
                fi
                sleep 30
              done
              
              echo "Snapshot $SNAPSHOT_NAME completed successfully"
            env:
            - name: ELASTICSEARCH_URL
              valueFrom:
                secretKeyRef:
                  name: kb-secrets
                  key: elasticsearch-url
          restartPolicy: OnFailure
```

### 2. Disaster Recovery Plan

```yaml
# Disaster Recovery Procedures
Recovery Time Objective (RTO): 4 hours
Recovery Point Objective (RPO): 1 hour

Disaster Scenarios:
  1. Application Failure:
     - Automatic failover via load balancer
     - Auto-scaling triggers new instances
     - Expected recovery: < 5 minutes
  
  2. Database Failure:
     - Automatic failover to read replica
     - Promote replica to primary
     - Expected recovery: < 15 minutes
  
  3. Elasticsearch Cluster Failure:
     - Restore from latest snapshot
     - Rebuild indices from database
     - Expected recovery: < 2 hours
  
  4. Complete Region Failure:
     - Failover to secondary region
     - Restore from cross-region backups
     - Expected recovery: < 4 hours

Recovery Procedures:
  Database Recovery:
    1. Assess damage and data loss
    2. Restore from latest backup
    3. Apply transaction logs if available
    4. Verify data integrity
    5. Update application configuration
    6. Test functionality
  
  Elasticsearch Recovery:
    1. Provision new cluster
    2. Restore from snapshot
    3. Verify index health
    4. Reindex missing data
    5. Update application endpoints
    6. Test search functionality
  
  Application Recovery:
    1. Deploy to new infrastructure
    2. Update DNS records
    3. Verify all services
    4. Run smoke tests
    5. Monitor for issues
```

## Scaling Strategy

### 1. Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: kb-search-api-hpa
  namespace: knowledge-base
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: kb-search-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: search_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max
```

### 2. Vertical Pod Autoscaler

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: kb-search-api-vpa
  namespace: knowledge-base
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: kb-search-api
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: api
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 2000m
        memory: 2Gi
      controlledResources: ["cpu", "memory"]
```

### 3. Cluster Autoscaler

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-autoscaler-status
  namespace: kube-system
data:
  nodes.max: "50"
  nodes.min: "3"
  scale-down-delay-after-add: "10m"
  scale-down-unneeded-time: "10m"
  scale-down-utilization-threshold: "0.5"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 300Mi
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/kb-cluster
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

## Cost Optimization

### 1. Resource Right-sizing

```yaml
# Resource optimization recommendations
Resource Optimization:
  Development:
    - Use smaller instance types
    - Single replica deployments
    - Shared databases
    - Minimal monitoring
    
  Staging:
    - Medium instance types
    - 2 replicas for testing
    - Dedicated but smaller databases
    - Basic monitoring
    
  Production:
    - Right-sized instances based on metrics
    - Auto-scaling enabled
    - High-availability setup
    - Comprehensive monitoring

Cost Monitoring:
  - Set up billing alerts
  - Use cost allocation tags
  - Regular cost reviews
  - Reserved instances for predictable workloads
  - Spot instances for non-critical workloads
```

### 2. Environment Scheduling

```yaml
# Development environment auto-shutdown
apiVersion: batch/v1
kind: CronJob
metadata:
  name: dev-environment-shutdown
  namespace: knowledge-base-dev
spec:
  schedule: "0 18 * * 1-5"  # Weekdays at 6 PM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: shutdown
            image: bitnami/kubectl:latest
            command:
            - /bin/bash
            - -c
            - |
              # Scale down deployments
              kubectl scale deployment --all --replicas=0 -n knowledge-base-dev
              
              # Stop databases
              kubectl patch statefulset postgres -p '{"spec":{"replicas":0}}' -n knowledge-base-dev
              kubectl patch statefulset elasticsearch -p '{"spec":{"replicas":0}}' -n knowledge-base-dev
          restartPolicy: OnFailure

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: dev-environment-startup
  namespace: knowledge-base-dev
spec:
  schedule: "0 8 * * 1-5"  # Weekdays at 8 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: startup
            image: bitnami/kubectl:latest
            command:
            - /bin/bash
            - -c
            - |
              # Start databases first
              kubectl patch statefulset postgres -p '{"spec":{"replicas":1}}' -n knowledge-base-dev
              kubectl patch statefulset elasticsearch -p '{"spec":{"replicas":1}}' -n knowledge-base-dev
              
              # Wait for databases to be ready
              kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s -n knowledge-base-dev
              kubectl wait --for=condition=ready pod -l app=elasticsearch --timeout=300s -n knowledge-base-dev
              
              # Scale up applications
              kubectl scale deployment kb-search-api --replicas=1 -n knowledge-base-dev
          restartPolicy: OnFailure
```

## Security Hardening

### 1. Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: kb-search-api-netpol
  namespace: knowledge-base
spec:
  podSelector:
    matchLabels:
      app: kb-search-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app: kb-frontend
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: elasticsearch
    ports:
    - protocol: TCP
      port: 9200
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-default
  namespace: knowledge-base
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 2. Pod Security Standards

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knowledge-base
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kb-search-service-account
  namespace: knowledge-base
automountServiceAccountToken: false

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kb-search-role
  namespace: knowledge-base
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kb-search-rolebinding
  namespace: knowledge-base
subjects:
- kind: ServiceAccount
  name: kb-search-service-account
  namespace: knowledge-base
roleRef:
  kind: Role
  name: kb-search-role
  apiGroup: rbac.authorization.k8s.io
```

## Performance Testing

### 1. Load Testing Configuration

```yaml
# K6 load testing script
apiVersion: v1
kind: ConfigMap
metadata:
  name: load-test-script
  namespace: knowledge-base
data:
  load-test.js: |
    import http from 'k6/http';
    import { check, sleep } from 'k6';
    import { Rate } from 'k6/metrics';
    
    export let errorRate = new Rate('errors');
    
    export let options = {
      stages: [
        { duration: '2m', target: 10 },   // Ramp up
        { duration: '5m', target: 50 },   // Stay at 50 users
        { duration: '2m', target: 100 },  // Ramp up to 100 users
        { duration: '5m', target: 100 },  // Stay at 100 users
        { duration: '2m', target: 0 },    // Ramp down
      ],
      thresholds: {
        http_req_duration: ['p(95)<500'],  // 95% of requests under 500ms
        http_req_failed: ['rate<0.05'],    // Error rate under 5%
        errors: ['rate<0.05'],
      },
    };
    
    const BASE_URL = __ENV.BASE_URL || 'https://kb.company.com';
    
    export default function() {
      // Test search endpoint
      let searchResponse = http.get(`${BASE_URL}/api/v1/search?q=authentication`);
      check(searchResponse, {
        'search status is 200': (r) => r.status === 200,
        'search response time < 500ms': (r) => r.timings.duration < 500,
        'search has results': (r) => JSON.parse(r.body).total > 0,
      }) || errorRate.add(1);
      
      sleep(1);
      
      // Test article endpoint
      let articleResponse = http.get(`${BASE_URL}/api/v1/articles/sample-article`);
      check(articleResponse, {
        'article status is 200': (r) => r.status === 200,
        'article response time < 200ms': (r) => r.timings.duration < 200,
      }) || errorRate.add(1);
      
      sleep(2);
    }

---
apiVersion: batch/v1
kind: Job
metadata:
  name: load-test
  namespace: knowledge-base
spec:
  template:
    spec:
      containers:
      - name: k6
        image: grafana/k6:latest
        command: ["k6", "run", "/scripts/load-test.js"]
        env:
        - name: BASE_URL
          value: "https://kb-staging.company.com"
        volumeMounts:
        - name: script
          mountPath: /scripts
      volumes:
      - name: script
        configMap:
          name: load-test-script
      restartPolicy: Never
  backoffLimit: 1
```

### 2. Chaos Engineering

```yaml
# Chaos Monkey configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: chaos-monkey-config
  namespace: knowledge-base
data:
  config.yaml: |
    # Chaos Monkey configuration
    chaosMonkey:
      enabled: true
      schedule: "0 10 * * 1-5"  # Weekdays at 10 AM
      
      experiments:
        - name: pod-failure
          enabled: true
          probability: 0.1
          targets:
            - deployment: kb-search-api
              namespace: knowledge-base
          
        - name: network-latency
          enabled: true
          probability: 0.05
          duration: "5m"
          latency: "100ms"
          
        - name: cpu-stress
          enabled: true
          probability: 0.05
          duration: "10m"
          cpu_load: 80
          
        - name: memory-stress
          enabled: false  # Disabled in production
          probability: 0.02
          duration: "5m"
          memory_load: 70

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: chaos-monkey
  namespace: knowledge-base
spec:
  schedule: "0 10 * * 1-5"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: chaos-monkey
            image: chaostoolkit/chaostoolkit:latest
            command:
            - /bin/bash
            - -c
            - |
              # Run chaos experiments
              chaos run /config/chaos-experiments.yaml
            volumeMounts:
            - name: config
              mountPath: /config
          volumes:
          - name: config
            configMap:
              name: chaos-monkey-config
          restartPolicy: OnFailure
```

This comprehensive deployment and infrastructure design provides a robust, scalable, and maintainable foundation for the knowledge base search system, with proper CI/CD pipelines, monitoring, security, and disaster recovery capabilities.