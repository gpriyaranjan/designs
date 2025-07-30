# Atlassian Loom: Scalability Strategies

## Document Overview
This document defines comprehensive scalability strategies for the Atlassian Loom platform, covering horizontal and vertical scaling approaches, performance optimization techniques, and capacity planning for video workloads.

## 1. Horizontal Scaling Strategies

### 1.1 Microservices Scaling Patterns

#### 1.1.1 Service-Specific Scaling Configurations
```yaml
# Recording Service Scaling
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: recording-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: recording-service
  minReplicas: 5
  maxReplicas: 100
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
  - type: Pods
    pods:
      metric:
        name: active_recordings
      target:
        type: AverageValue
        averageValue: "10"
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 10
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60

---
# Video Processing Scaling
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: video-processor-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: video-processor
  minReplicas: 10
  maxReplicas: 500
  metrics:
  - type: External
    external:
      metric:
        name: sqs_messages_visible
        selector:
          matchLabels:
            queue: video-processing
      target:
        type: AverageValue
        averageValue: "5"
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 200
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 600
      policies:
      - type: Percent
        value: 5
        periodSeconds: 60
```

#### 1.1.2 Multi-Region Deployment Strategy
```yaml
# Global Load Balancer Configuration
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: loom-global-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: loom-tls-secret
    hosts:
    - "*.loom.com"

---
# Traffic Splitting by Region
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: loom-global-routing
spec:
  hosts:
  - "api.loom.com"
  gateways:
  - loom-global-gateway
  http:
  - match:
    - headers:
        x-user-region:
          exact: "us-west"
    route:
    - destination:
        host: recording-service.loom-production.svc.cluster.local
        subset: us-west
      weight: 100
  - match:
    - headers:
        x-user-region:
          exact: "eu-west"
    route:
    - destination:
        host: recording-service.loom-production.svc.cluster.local
        subset: eu-west
      weight: 100
  - route:
    - destination:
        host: recording-service.loom-production.svc.cluster.local
        subset: us-west
      weight: 60
    - destination:
        host: recording-service.loom-production.svc.cluster.local
        subset: eu-west
      weight: 40
```

### 1.2 Database Scaling Strategies

#### 1.2.1 Read Replica Configuration
```sql
-- PostgreSQL Read Replica Setup
-- Primary Database Configuration
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET wal_keep_segments = 64;
ALTER SYSTEM SET archive_mode = 'on';
ALTER SYSTEM SET archive_command = 'cp %p /var/lib/postgresql/archive/%f';

-- Read Replica Routing Configuration
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Connection Pooling with PgBouncer
[databases]
loom_primary = host=loom-primary.cluster-xyz.us-west-2.rds.amazonaws.com port=5432 dbname=loom
loom_read_1 = host=loom-read-1.cluster-xyz.us-west-2.rds.amazonaws.com port=5432 dbname=loom
loom_read_2 = host=loom-read-2.cluster-xyz.us-west-2.rds.amazonaws.com port=5432 dbname=loom

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 100
max_db_connections = 100
```

#### 1.2.2 Sharding Strategy
```go
// Database Sharding Implementation
package database

import (
    "fmt"
    "hash/fnv"
)

type ShardManager struct {
    shards []DatabaseConnection
    shardCount int
}

func NewShardManager(connections []DatabaseConnection) *ShardManager {
    return &ShardManager{
        shards: connections,
        shardCount: len(connections),
    }
}

func (sm *ShardManager) GetShardForUser(userID string) DatabaseConnection {
    hash := fnv.New32a()
    hash.Write([]byte(userID))
    shardIndex := hash.Sum32() % uint32(sm.shardCount)
    return sm.shards[shardIndex]
}

func (sm *ShardManager) GetShardForVideo(videoID string) DatabaseConnection {
    // Extract user ID from video ID for consistent sharding
    userID := extractUserIDFromVideoID(videoID)
    return sm.GetShardForUser(userID)
}

// Video table partitioning by user
CREATE TABLE videos_shard_0 (
    LIKE videos INCLUDING ALL
) INHERITS (videos);

CREATE TABLE videos_shard_1 (
    LIKE videos INCLUDING ALL
) INHERITS (videos);

-- Partition constraint
ALTER TABLE videos_shard_0 ADD CONSTRAINT videos_shard_0_check 
    CHECK (abs(hashtext(user_id)) % 4 = 0);

ALTER TABLE videos_shard_1 ADD CONSTRAINT videos_shard_1_check 
    CHECK (abs(hashtext(user_id)) % 4 = 1);
```

### 1.3 Caching Layer Scaling

#### 1.3.1 Redis Cluster Configuration
```yaml
# Redis Cluster Deployment
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  serviceName: redis-cluster
  replicas: 6
  selector:
    matchLabels:
      app: redis-cluster
  template:
    metadata:
      labels:
        app: redis-cluster
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
          name: client
        - containerPort: 16379
          name: gossip
        command:
        - redis-server
        args:
        - /etc/redis/redis.conf
        - --cluster-enabled
        - "yes"
        - --cluster-config-file
        - /var/lib/redis/nodes.conf
        - --cluster-node-timeout
        - "5000"
        - --appendonly
        - "yes"
        resources:
          requests:
            cpu: 500m
            memory: 2Gi
          limits:
            cpu: 1000m
            memory: 4Gi
        volumeMounts:
        - name: redis-data
          mountPath: /var/lib/redis
        - name: redis-config
          mountPath: /etc/redis
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 100Gi
```

#### 1.3.2 Multi-Level Caching Strategy
```go
// Multi-Level Cache Implementation
package cache

import (
    "context"
    "time"
)

type CacheLevel int

const (
    L1Cache CacheLevel = iota // In-memory
    L2Cache                   // Redis
    L3Cache                   // CDN
)

type MultiLevelCache struct {
    l1Cache *InMemoryCache
    l2Cache *RedisCache
    l3Cache *CDNCache
}

func (mlc *MultiLevelCache) Get(ctx context.Context, key string) (interface{}, error) {
    // Try L1 cache first
    if value, found := mlc.l1Cache.Get(key); found {
        return value, nil
    }
    
    // Try L2 cache
    if value, err := mlc.l2Cache.Get(ctx, key); err == nil {
        // Populate L1 cache
        mlc.l1Cache.Set(key, value, 5*time.Minute)
        return value, nil
    }
    
    // Try L3 cache (CDN)
    if value, err := mlc.l3Cache.Get(ctx, key); err == nil {
        // Populate L2 and L1 caches
        mlc.l2Cache.Set(ctx, key, value, 30*time.Minute)
        mlc.l1Cache.Set(key, value, 5*time.Minute)
        return value, nil
    }
    
    return nil, ErrCacheMiss
}

func (mlc *MultiLevelCache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    // Set in all cache levels
    mlc.l1Cache.Set(key, value, min(ttl, 5*time.Minute))
    mlc.l2Cache.Set(ctx, key, value, min(ttl, 30*time.Minute))
    mlc.l3Cache.Set(ctx, key, value, ttl)
    return nil
}
```

## 2. Vertical Scaling Strategies

### 2.1 Resource Optimization

#### 2.1.1 Vertical Pod Autoscaler Configuration
```yaml
# VPA for Video Processing
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: video-processor-vpa
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
        cpu: 4000m
        memory: 8Gi
      maxAllowed:
        cpu: 32000m
        memory: 64Gi
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits

---
# VPA for AI Service
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: ai-service-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ai-service
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: ai-service
      minAllowed:
        cpu: 2000m
        memory: 4Gi
      maxAllowed:
        cpu: 16000m
        memory: 32Gi
      controlledResources: ["cpu", "memory"]
```

#### 2.1.2 Node Scaling Configuration
```yaml
# Cluster Autoscaler Configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.27.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/loom-production
        - --balance-similar-node-groups
        - --scale-down-enabled=true
        - --scale-down-delay-after-add=10m
        - --scale-down-unneeded-time=10m
        - --scale-down-utilization-threshold=0.5
        - --max-node-provision-time=15m
        env:
        - name: AWS_REGION
          value: us-west-2
```

### 2.2 Performance Optimization

#### 2.2.1 JVM Tuning for Java Services
```yaml
# Java Service with Optimized JVM Settings
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  template:
    spec:
      containers:
      - name: user-service
        image: loom/user-service:latest
        env:
        - name: JAVA_OPTS
          value: >-
            -Xms2g
            -Xmx8g
            -XX:+UseG1GC
            -XX:MaxGCPauseMillis=200
            -XX:+UseStringDeduplication
            -XX:+OptimizeStringConcat
            -XX:+UseCompressedOops
            -XX:+UseCompressedClassPointers
            -XX:+UnlockExperimentalVMOptions
            -XX:+UseCGroupMemoryLimitForHeap
            -XX:NewRatio=1
            -XX:SurvivorRatio=8
            -XX:+PrintGC
            -XX:+PrintGCDetails
            -XX:+PrintGCTimeStamps
            -Djava.security.egd=file:/dev/./urandom
        resources:
          requests:
            cpu: 1000m
            memory: 4Gi
          limits:
            cpu: 4000m
            memory: 10Gi
```

#### 2.2.2 Go Service Optimization
```go
// Go Service Performance Optimization
package main

import (
    "runtime"
    "runtime/debug"
)

func init() {
    // Set GOMAXPROCS to container CPU limit
    runtime.GOMAXPROCS(runtime.NumCPU())
    
    // Optimize garbage collection
    debug.SetGCPercent(100)
    debug.SetMemoryLimit(8 << 30) // 8GB
    
    // Set memory ballast for consistent GC behavior
    ballast := make([]byte, 1<<30) // 1GB ballast
    runtime.KeepAlive(ballast)
}

// Connection pooling optimization
func setupConnectionPools() {
    // Database connection pool
    db.SetMaxOpenConns(100)
    db.SetMaxIdleConns(50)
    db.SetConnMaxLifetime(5 * time.Minute)
    db.SetConnMaxIdleTime(1 * time.Minute)
    
    // HTTP client pool
    transport := &http.Transport{
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 20,
        IdleConnTimeout:     90 * time.Second,
        DisableKeepAlives:   false,
    }
    
    client := &http.Client{
        Transport: transport,
        Timeout:   30 * time.Second,
    }
}
```

## 3. Auto-Scaling Policies

### 3.1 Predictive Scaling

#### 3.1.1 Machine Learning-Based Scaling
```python
# Predictive Scaling Algorithm
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import joblib

class PredictiveScaler:
    def __init__(self):
        self.model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.scaler = StandardScaler()
        self.is_trained = False
    
    def prepare_features(self, timestamp, historical_metrics):
        """Prepare features for prediction"""
        features = []
        
        # Time-based features
        hour = timestamp.hour
        day_of_week = timestamp.weekday()
        day_of_month = timestamp.day
        
        # Cyclical encoding
        features.extend([
            np.sin(2 * np.pi * hour / 24),
            np.cos(2 * np.pi * hour / 24),
            np.sin(2 * np.pi * day_of_week / 7),
            np.cos(2 * np.pi * day_of_week / 7)
        ])
        
        # Historical metrics (last 24 hours)
        if len(historical_metrics) >= 24:
            recent_metrics = historical_metrics[-24:]
            features.extend([
                np.mean(recent_metrics),
                np.std(recent_metrics),
                np.max(recent_metrics),
                np.min(recent_metrics),
                recent_metrics[-1]  # Current value
            ])
        
        return np.array(features).reshape(1, -1)
    
    def predict_load(self, timestamp, historical_metrics):
        """Predict future load"""
        if not self.is_trained:
            return None
        
        features = self.prepare_features(timestamp, historical_metrics)
        features_scaled = self.scaler.transform(features)
        prediction = self.model.predict(features_scaled)
        
        return max(0, prediction[0])
    
    def calculate_required_replicas(self, predicted_load, current_replicas):
        """Calculate required replicas based on predicted load"""
        target_cpu_utilization = 70  # Target 70% CPU utilization
        
        # Calculate required replicas
        required_replicas = int(np.ceil(predicted_load / target_cpu_utilization * 100))
        
        # Apply scaling constraints
        min_replicas = 5
        max_replicas = 100
        
        # Gradual scaling to avoid thrashing
        max_scale_up = int(current_replicas * 1.5)
        max_scale_down = int(current_replicas * 0.7)
        
        required_replicas = max(min_replicas, min(max_replicas, required_replicas))
        required_replicas = max(max_scale_down, min(max_scale_up, required_replicas))
        
        return required_replicas
```

#### 3.1.2 Custom Metrics Scaling
```yaml
# Custom Metrics HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: video-processor-custom-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: video-processor
  minReplicas: 10
  maxReplicas: 500
  metrics:
  # Queue depth metric
  - type: External
    external:
      metric:
        name: sqs_messages_visible
        selector:
          matchLabels:
            queue: video-processing
      target:
        type: AverageValue
        averageValue: "5"
  
  # Processing time metric
  - type: Pods
    pods:
      metric:
        name: avg_processing_time_seconds
      target:
        type: AverageValue
        averageValue: "300" # 5 minutes
  
  # Active connections metric
  - type: Object
    object:
      metric:
        name: active_websocket_connections
      describedObject:
        apiVersion: v1
        kind: Service
        name: websocket-service
      target:
        type: Value
        value: "1000"
  
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 20
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### 3.2 Event-Driven Scaling

#### 3.2.1 KEDA Scaling Configuration
```yaml
# KEDA ScaledObject for Kafka-based scaling
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: video-processor-scaledobject
spec:
  scaleTargetRef:
    name: video-processor
  minReplicaCount: 10
  maxReplicaCount: 500
  triggers:
  - type: kafka
    metadata:
      bootstrapServers: kafka-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092
      consumerGroup: video-processing-group
      topic: video-processing
      lagThreshold: '10'
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-server.monitoring.svc.cluster.local:80
      metricName: video_processing_queue_size
      threshold: '50'
      query: sum(video_processing_queue_size)

---
# KEDA ScaledObject for SQS-based scaling
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ai-service-scaledobject
spec:
  scaleTargetRef:
    name: ai-service
  minReplicaCount: 5
  maxReplicaCount: 100
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-west-2.amazonaws.com/123456789/ai-processing
      queueLength: '5'
      awsRegion: us-west-2
    authenticationRef:
      name: keda-aws-credentials
```

## 4. Performance Optimization

### 4.1 Database Performance

#### 4.1.1 Query Optimization
```sql
-- Optimized queries with proper indexing
-- Video metadata queries
CREATE INDEX CONCURRENTLY idx_videos_user_created 
ON videos (user_id, created_at DESC) 
WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY idx_videos_status_processing 
ON videos (status, created_at) 
WHERE status IN ('processing', 'queued');

-- Partial index for active recordings
CREATE INDEX CONCURRENTLY idx_recordings_active 
ON recordings (user_id, started_at DESC) 
WHERE ended_at IS NULL;

-- Composite index for video sharing
CREATE INDEX CONCURRENTLY idx_video_shares_composite 
ON video_shares (video_id, shared_with_type, created_at DESC);

-- Optimized video search query
EXPLAIN (ANALYZE, BUFFERS) 
SELECT v.id, v.title, v.duration, v.thumbnail_url, v.created_at
FROM videos v
WHERE v.user_id = $1 
  AND v.deleted_at IS NULL
  AND ($2 IS NULL OR v.title ILIKE '%' || $2 || '%')
ORDER BY v.created_at DESC
LIMIT 20 OFFSET $3;

-- Connection pooling optimization
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET max_connections = 1000;
ALTER SYSTEM SET shared_buffers = '8GB';
ALTER SYSTEM SET effective_cache_size = '24GB';
ALTER SYSTEM SET work_mem = '256MB';
ALTER SYSTEM SET maintenance_work_mem = '2GB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '64MB';
ALTER SYSTEM SET default_statistics_target = 100;
```

#### 4.1.2 Database Partitioning
```sql
-- Time-based partitioning for video analytics
CREATE TABLE video_analytics (
    id BIGSERIAL,
    video_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE video_analytics_2024_01 PARTITION OF video_analytics
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE video_analytics_2024_02 PARTITION OF video_analytics
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Automatic partition creation function
CREATE OR REPLACE FUNCTION create_monthly_partition(table_name text, start_date date)
RETURNS void AS $$
DECLARE
    partition_name text;
    end_date date;
BEGIN
    partition_name := table_name || '_' || to_char(start_date, 'YYYY_MM');
    end_date := start_date + interval '1 month';
    
    EXECUTE format('CREATE TABLE %I PARTITION OF %I FOR VALUES FROM (%L) TO (%L)',
                   partition_name, table_name, start_date, end_date);
    
    EXECUTE format('CREATE INDEX ON %I (video_id, created_at)', partition_name);
    EXECUTE format('CREATE INDEX ON %I (user_id, created_at)', partition_name);
END;
$$ LANGUAGE plpgsql;
```

### 4.2 Application Performance

#### 4.2.1 Connection Pooling and Circuit Breakers
```go
// Advanced connection pooling and circuit breaker implementation
package infrastructure

import (
    "context"
    "database/sql"
    "time"
    
    "github.com/sony/gobreaker"
    _ "github.com/lib/pq"
)

type DatabaseManager struct {
    primary   *sql.DB
    readReplicas []*sql.DB
    circuitBreaker *gobreaker.CircuitBreaker
    currentReplicaIndex int
}

func NewDatabaseManager(primaryDSN string, replicaDSNs []string) (*DatabaseManager, error) {
    // Primary database connection
    primary, err := sql.Open("postgres", primaryDSN)
    if err != nil {
        return nil, err
    }
    
    // Configure connection pool
    primary.SetMaxOpenConns(100)
    primary.SetMaxIdleConns(50)
    primary.SetConnMaxLifetime(5 * time.Minute)
    primary.SetConnMaxIdleTime(1 * time.Minute)
    
    // Read replica connections
    var readReplicas []*sql.DB
    for _, dsn := range replicaDSNs {
        replica, err := sql.Open("postgres", dsn)
        if err != nil {
            return nil, err
        }
        
        replica.SetMaxOpenConns(50)
        replica.SetMaxIdleConns(25)
        replica.SetConnMaxLifetime(5 * time.Minute)
        readReplicas = append(readReplicas, replica)
    }
    
    // Circuit breaker configuration
    settings := gobreaker.Settings{
        Name:        "database",
        MaxRequests: 3,
        Interval:    10 * time.Second,
        Timeout:     30 * time.Second,
        ReadyToTrip: func(counts gobreaker.Counts) bool {
            failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
            return counts.Requests >= 3 && failureRatio >= 0.6
        },
    }
    
    return &DatabaseManager{
        primary:        primary,
        readReplicas:   readReplicas,
        circuitBreaker: gobreaker.NewCircuitBreaker(settings),
    }, nil
}

func (dm *DatabaseManager) QueryContext(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
    result, err := dm.circuitBreaker.Execute(func() (interface{}, error) {
        // Use read replica for SELECT queries
        db := dm.getReadReplica()
        return db.QueryContext(ctx, query, args...)
    })
    
    if err != nil {
        return nil, err
    }
    
    return result.(*sql.Rows), nil
}

func (dm *DatabaseManager) getReadReplica() *sql.DB {
    if len(dm.readReplicas) == 0 {
        return dm.primary
    }
    
    // Round-robin load balancing
    replica := dm.readReplicas[dm.currentReplicaIndex]
    dm.currentReplicaIndex = (dm.currentReplicaIndex + 1) % len(dm.readReplicas)
    
    return replica
}
```

#### 4.2.2 Caching Strategies
```go
// Multi-level caching with cache warming
package cache

import (
    "context"
    "encoding/json"
    "fmt"
    "time"
    
    "github.com/go-redis/redis/v8"
    "github.com/patrickmn/go-cache"
)

type VideoCache struct {
    localCache  *cache.Cache
    redisClient *redis.Client
    warmupChan  chan string
}

func NewVideoCache(redisClient *redis.Client) *VideoCache {
    vc := &VideoCache{
        localCache:  cache.New(5*time.Minute, 10*time.Minute),
        redisClient: redisClient,
        warmupChan:  make(chan string, 1000),
    }
    
    // Start cache warming goroutine
    go vc.cacheWarmer()
    
    return vc
}

func (vc *VideoCache) GetVideo(ctx context.Context, videoID string) (*Video, error) {
    cacheKey := fmt.Sprintf("video:%s", videoID)
    
    // Try local cache first
    if video, found := vc.localCache.Get(cacheKey); found {
        return video.(*Video), nil
    }
    
    // Try Redis cache
    videoJSON, err := vc.redisClient.Get(ctx, cacheKey).Result()
    if err == nil {
        var video Video
        if err := json.Unmarshal([]byte(videoJSON), &video); err == nil {
            // Populate local cache
            vc.localCache.Set(cacheKey, &video, cache.DefaultExpiration)
            return &video, nil
        }
    }
    
    return nil, ErrCacheMiss
}

func (vc *VideoCache) SetVideo(ctx context.Context, video *Video) error {
    cacheKey := fmt.Sprintf("video:%s", video.ID)
    
    // Set in local cache
    vc.localCache.Set(cacheKey, video, cache.DefaultExpiration)
    
    // Set in Redis cache
    videoJSON, err := json.Marshal(video)
    if err != nil {
        return err
    }