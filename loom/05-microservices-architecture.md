# Atlassian Loom: Microservices Architecture

## Document Overview
This document provides detailed specifications for the microservices architecture of the Atlassian Loom platform, including service definitions, data models, inter-service communication patterns, and implementation details for each core service.

## 1. Microservices Overview

### 1.1 Service Catalog

#### 1.1.1 Core Video Services
- **Recording Service**: Manage recording sessions and coordination
- **Video Processing Service**: Handle video transcoding and optimization
- **AI/ML Service**: Provide transcription and content analysis
- **Streaming Service**: Deliver video content with adaptive streaming

#### 1.1.2 Platform Services
- **User Management Service**: Authentication and user profiles
- **Sharing Service**: Video sharing and access control
- **Analytics Service**: Usage analytics and business intelligence
- **Integration Service**: Third-party integrations and webhooks
- **Notification Service**: Real-time notifications and messaging
- **Search Service**: Content search and indexing
- **Billing Service**: Subscription and payment management
- **Admin Service**: Administrative functions and system management

## 2. Core Video Services

### 2.1 Recording Service

#### 2.1.1 Service Overview
**Purpose**: Manage recording sessions, coordinate real-time recording, and handle recording metadata
**Technology Stack**: Go 1.21+, Gin framework, PostgreSQL, Redis, Kafka
**Deployment**: Kubernetes with horizontal pod autoscaling

#### 2.1.2 Data Model
```sql
-- Recording Sessions
CREATE TABLE recording_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    workspace_id UUID,
    title VARCHAR(255),
    description TEXT,
    recording_type VARCHAR(50) NOT NULL, -- screen, webcam, screen_webcam
    status VARCHAR(20) NOT NULL, -- preparing, recording, processing, completed, failed
    settings JSONB NOT NULL, -- recording configuration
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    file_size_bytes BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recording Segments (for pause/resume functionality)
CREATE TABLE recording_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    segment_number INTEGER NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    file_path VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recording Settings Templates
CREATE TABLE recording_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    settings JSONB NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.1.3 API Endpoints
```yaml
/api/v1/recordings:
  POST: Start new recording session
  GET: List user recordings

/api/v1/recordings/{sessionId}:
  GET: Get recording session details
  PUT: Update recording metadata
  DELETE: Delete recording

/api/v1/recordings/{sessionId}/control:
  POST: Control recording (pause, resume, stop)

/api/v1/recordings/templates:
  GET: List recording templates
  POST: Create recording template
```

### 2.2 Video Processing Service

#### 2.2.1 Service Overview
**Purpose**: Process raw video files, handle transcoding, generate thumbnails, and optimize videos
**Technology Stack**: Go 1.21+, FFmpeg, AWS S3, SQS, PostgreSQL
**Deployment**: Kubernetes with compute-intensive node pools

#### 2.2.2 Data Model
```sql
-- Video Processing Jobs
CREATE TABLE processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    job_type VARCHAR(50) NOT NULL, -- transcode, thumbnail, optimize, analyze
    status VARCHAR(20) NOT NULL, -- queued, processing, completed, failed
    progress DECIMAL(5,2) DEFAULT 0.00,
    input_path VARCHAR(500) NOT NULL,
    output_path VARCHAR(500),
    settings JSONB NOT NULL,
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Video Metadata
CREATE TABLE video_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    file_path VARCHAR(500) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    duration_seconds DECIMAL(10,3) NOT NULL,
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    frame_rate DECIMAL(6,3) NOT NULL,
    bitrate INTEGER NOT NULL,
    codec VARCHAR(50) NOT NULL,
    format VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2.3 AI/ML Service

#### 2.3.1 Service Overview
**Purpose**: Provide AI-powered features including transcription, content analysis, and insights
**Technology Stack**: Python 3.11+, FastAPI, TensorFlow, OpenAI Whisper, PostgreSQL, MongoDB
**Deployment**: Kubernetes with GPU-enabled nodes

#### 2.3.2 Data Model
```sql
-- AI Processing Results
CREATE TABLE ai_processing_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    processing_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    progress DECIMAL(5,2) DEFAULT 0.00,
    results JSONB,
    confidence_score DECIMAL(5,4),
    processing_time_ms INTEGER,
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Transcriptions
CREATE TABLE video_transcriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    language VARCHAR(10) NOT NULL,
    full_text TEXT NOT NULL,
    segments JSONB NOT NULL, -- Array of timestamped segments
    confidence_score DECIMAL(5,4),
    word_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Analysis
CREATE TABLE content_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES recording_sessions(id),
    entities JSONB, -- Named entities found in content
    topics JSONB, -- Key topics and themes
    summary TEXT,
    sentiment_score DECIMAL(3,2), -- -1 to 1
    action_items JSONB, -- Extracted action items
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2.4 Streaming Service

#### 2.4.1 Service Overview
**Purpose**: Handle video streaming, adaptive bitrate delivery, and CDN integration
**Technology Stack**: Go 1.21+, HLS/DASH, CloudFront, Redis
**Deployment**: Edge locations with CDN integration

## 3. Platform Services

### 3.1 User Management Service

#### 3.1.1 Service Overview
**Purpose**: Handle user authentication, authorization, profiles, and team management
**Technology Stack**: Node.js 18+, Express.js, PostgreSQL, Redis, JWT
**Deployment**: Kubernetes with session affinity

### 3.2 Analytics Service

#### 3.2.1 Service Overview
**Purpose**: Collect, process, and analyze usage data for business intelligence
**Technology Stack**: Python 3.11+, FastAPI, MongoDB, Elasticsearch, Apache Kafka
**Deployment**: Kubernetes with data processing pipelines

### 3.3 Integration Service

#### 3.3.1 Service Overview
**Purpose**: Handle third-party integrations, webhooks, and API management
**Technology Stack**: Node.js 18+, Express.js, Redis, Kafka
**Deployment**: Kubernetes with auto-scaling

## 4. Inter-Service Communication

### 4.1 Communication Patterns

#### 4.1.1 Synchronous Communication
- **REST APIs**: Direct service-to-service HTTP calls
- **GraphQL**: Federated schema for complex queries
- **gRPC**: High-performance binary protocol for internal services

#### 4.1.2 Asynchronous Communication
- **Event Streaming**: Kafka for event-driven architecture
- **Message Queues**: Redis Streams for real-time messaging
- **Webhooks**: HTTP callbacks for external integrations

### 4.2 Service Mesh

#### 4.2.1 Istio Configuration
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: loom-services
spec:
  hosts:
  - recording-service
  - video-processing-service
  - ai-ml-service
  http:
  - match:
    - uri:
        prefix: /api/v1/recordings
    route:
    - destination:
        host: recording-service
        port:
          number: 8080
  - match:
    - uri:
        prefix: /api/v1/processing
    route:
    - destination:
        host: video-processing-service
        port:
          number: 8080
```

## 5. Data Management

### 5.1 Database Strategy

#### 5.1.1 Database per Service
- **Recording Service**: PostgreSQL for transactional data
- **Video Processing**: PostgreSQL for job tracking
- **AI/ML Service**: PostgreSQL + MongoDB for results
- **Analytics**: MongoDB + Elasticsearch for time-series data
- **User Management**: PostgreSQL for user data

#### 5.1.2 Data Consistency
- **Eventual Consistency**: Accept temporary inconsistency for performance
- **Saga Pattern**: Distributed transaction management
- **Event Sourcing**: Store events as source of truth
- **CQRS**: Separate read and write models

### 5.2 Caching Strategy

#### 5.2.1 Multi-Level Caching
- **Application Cache**: In-memory caching within services
- **Distributed Cache**: Redis for shared caching
- **CDN Cache**: CloudFront for static content
- **Database Cache**: Query result caching

## 6. Service Discovery & Configuration

### 6.1 Service Discovery

#### 6.1.1 Kubernetes Native
```yaml
apiVersion: v1
kind: Service
metadata:
  name: recording-service
  labels:
    app: recording-service
spec:
  selector:
    app: recording-service
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
```

### 6.2 Configuration Management

#### 6.2.1 ConfigMaps and Secrets
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: recording-service-config
data:
  database_host: "postgres.loom.svc.cluster.local"
  redis_host: "redis.loom.svc.cluster.local"
  kafka_brokers: "kafka.loom.svc.cluster.local:9092"
---
apiVersion: v1
kind: Secret
metadata:
  name: recording-service-secrets
type: Opaque
data:
  database_password: <base64-encoded-password>
  jwt_secret: <base64-encoded-secret>
```

## 7. Monitoring & Observability

### 7.1 Distributed Tracing

#### 7.1.1 Jaeger Integration
```go
// Tracing middleware
func TracingMiddleware() gin.HandlerFunc {
    return gin.HandlerFunc(func(c *gin.Context) {
        span, ctx := opentracing.StartSpanFromContext(
            c.Request.Context(),
            c.Request.URL.Path,
        )
        defer span.Finish()
        
        c.Request = c.Request.WithContext(ctx)
        c.Next()
    })
}
```

### 7.2 Metrics Collection

#### 7.2.1 Prometheus Metrics
```go
// Custom metrics
var (
    recordingDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "recording_duration_seconds",
            Help: "Duration of recording sessions",
        },
        []string{"user_id", "recording_type"},
    )
    
    processingJobs = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "processing_jobs_total",
            Help: "Total number of processing jobs",
        },
        []string{"job_type", "status"},
    )
)
```

## 8. Security Implementation

### 8.1 Service-to-Service Security

#### 8.1.1 mTLS Configuration
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: recording-service-policy
spec:
  selector:
    matchLabels:
      app: recording-service
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/loom/sa/api-gateway"]
  - to:
    - operation:
        methods: ["GET", "POST", "PUT", "DELETE"]
```

### 8.2 API Security

#### 8.2.1 JWT Validation
```go
func JWTMiddleware(secret string) gin.HandlerFunc {
    return gin.HandlerFunc(func(c *gin.Context) {
        tokenString := c.GetHeader("Authorization")
        if tokenString == "" {
            c.JSON(401, gin.H{"error": "Missing authorization header"})
            c.Abort()
            return
        }
        
        token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
            return []byte(secret), nil
        })
        
        if err != nil || !token.Valid {
            c.JSON(401, gin.H{"error": "Invalid token"})
            c.Abort()
            return
        }
        
        claims := token.Claims.(jwt.MapClaims)
        c.Set("user_id", claims["user_id"])
        c.Next()
    })
}
```

## 9. Error Handling & Resilience

### 9.1 Circuit Breaker Pattern

#### 9.1.1 Implementation
```go
type CircuitBreaker struct {
    maxFailures int
    timeout     time.Duration
    failures    int
    lastFailure time.Time
    state       string // "closed", "open", "half-open"
    mutex       sync.Mutex
}

func (cb *CircuitBreaker) Call(fn func() error) error {
    cb.mutex.Lock()
    defer cb.mutex.Unlock()
    
    if cb.state == "open" {
        if time.Since(cb.lastFailure) > cb.timeout {
            cb.state = "half-open"
        } else {
            return errors.New("circuit breaker is open")
        }
    }
    
    err := fn()
    if err != nil {
        cb.failures++
        cb.lastFailure = time.Now()
        
        if cb.failures >= cb.maxFailures {
            cb.state = "open"
        }
        return err
    }
    
    cb.failures = 0
    cb.state = "closed"
    return nil
}
```

### 9.2 Retry Logic

#### 9.2.1 Exponential Backoff
```go
func RetryWithBackoff(fn func() error, maxRetries int) error {
    var err error
    for i := 0; i < maxRetries; i++ {
        err = fn()
        if err == nil {
            return nil
        }
        
        backoff := time.Duration(math.Pow(2, float64(i))) * time.Second
        time.Sleep(backoff)
    }
    return err
}
```

## 10. Testing Strategy

### 10.1 Unit Testing

#### 10.1.1 Service Testing
```go
func TestRecordingService_StartRecording(t *testing.T) {
    // Setup
    mockDB := &MockDatabase{}
    mockCache := &MockCache{}
    mockEventBus := &MockEventBus{}
    
    service := &RecordingService{
        db:       mockDB,
        cache:    mockCache,
        eventBus: mockEventBus,
    }
    
    // Test data
    req := StartRecordingRequest{
        UserID:        uuid.New(),
        Title:         "Test Recording",
        RecordingType: RecordingTypeScreen,
        Settings:      RecordingSettings{},
    }
    
    // Execute
    session, err := service.StartRecording(context.Background(), req)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, session)
    assert.Equal(t, req.Title, session.Title)
    assert.Equal(t, StatusPreparing, session.Status)
}
```

### 10.2 Integration Testing

#### 10.2.1 Service Integration
```go
func TestRecordingToProcessingIntegration(t *testing.T) {
    // Setup test environment
    testDB := setupTestDatabase()
    testKafka := setupTestKafka()
    
    recordingService := NewRecordingService(testDB, testKafka)
    processingService := NewVideoProcessingService(testDB, testKafka)
    
    // Start recording
    session, err := recordingService.StartRecording(context.Background(), testRequest)
    require.NoError(t, err)
    
    // Complete recording
    err = recordingService.ControlRecording(context.Background(), session.ID, ActionStop)
    require.NoError(t, err)
    
    // Verify processing job created
    jobs, err := processingService.GetJobsForSession(context.Background(), session.ID)
    require.NoError(t, err)
    assert.Len(t, jobs, 1)
}
```

## 11. Deployment Specifications

### 11.1 Service Deployments

#### 11.1.1 Recording Service Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recording-service
  namespace: loom-production
spec:
  replicas: 5
  selector:
    matchLabels:
      app: recording-service
  template:
    metadata:
      labels:
        app: recording-service
        version: v1
    spec:
      containers:
      - name: recording-service
        image: loom/recording-service:1.0.0
        ports:
        - containerPort: 8080
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
```

### 11.2 Auto-Scaling Configuration

#### 11.2.1 Horizontal Pod Autoscaler
```yaml
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
```

## Conclusion

This microservices architecture provides a robust, scalable foundation for the Atlassian Loom platform. Key benefits include:

### Architecture Benefits
1. **Scalability**: Independent scaling of services based on demand
2. **Resilience**: Fault isolation and graceful degradation
3. **Technology Diversity**: Optimal technology choice per service
4. **Team Autonomy**: Independent development and deployment
5. **Maintainability**: Clear service boundaries and responsibilities

### Implementation Priorities
1. **Phase 1**: Core video services (Recording, Processing, Streaming)
2. **Phase 2**: Platform services (User Management, Analytics)
3. **Phase 3**: Advanced services (AI/ML, Integration)
4. **Phase 4**: Optimization and enterprise features

This architecture serves as the detailed blueprint for implementing each service in the Atlassian Loom platform.

---
**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Related Documents**: 04-system-architecture.md, 06-api-specifications.md