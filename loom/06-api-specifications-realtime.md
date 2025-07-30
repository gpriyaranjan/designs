# Atlassian Loom: API Specifications & Real-Time Communication

## Document Overview
This document defines the comprehensive API specifications and real-time communication patterns for the Atlassian Loom platform, including REST APIs, GraphQL schemas, WebSocket implementations, and webhook systems.

## 1. REST API Architecture

### 1.1 OpenAPI 3.0 Specification

#### 1.1.1 API Overview
```yaml
openapi: 3.0.3
info:
  title: Atlassian Loom API
  description: Comprehensive API for video recording, processing, and sharing
  version: 1.0.0
  contact:
    name: Loom API Support
    email: api-support@loom.com

servers:
  - url: https://api.loom.com/v1
    description: Production server
  - url: https://staging-api.loom.com/v1
    description: Staging server

security:
  - BearerAuth: []
  - ApiKeyAuth: []

paths:
  /recordings:
    get:
      summary: List recordings
      tags: [Recordings]
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 0
        - name: size
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Recording'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
    
    post:
      summary: Start recording
      tags: [Recordings]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/StartRecordingRequest'
      responses:
        '201':
          description: Recording session created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Recording'

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key

  schemas:
    Recording:
      type: object
      properties:
        id:
          type: string
          format: uuid
        title:
          type: string
        status:
          type: string
          enum: [preparing, recording, processing, completed, failed]
        recordingType:
          type: string
          enum: [screen, webcam, screen_webcam]
        duration:
          type: number
        createdAt:
          type: string
          format: date-time
      required: [id, status, recordingType, createdAt]

    StartRecordingRequest:
      type: object
      properties:
        title:
          type: string
        recordingType:
          type: string
          enum: [screen, webcam, screen_webcam]
        settings:
          type: object
      required: [recordingType]

    Pagination:
      type: object
      properties:
        page:
          type: integer
        size:
          type: integer
        totalPages:
          type: integer
        totalElements:
          type: integer
```

## 2. GraphQL API

### 2.1 Schema Definition

```graphql
scalar DateTime
scalar UUID

type Query {
  me: User
  recording(id: UUID!): Recording
  recordings(first: Int = 20, after: String): RecordingConnection
}

type Mutation {
  startRecording(input: StartRecordingInput!): StartRecordingPayload
  controlRecording(input: ControlRecordingInput!): ControlRecordingPayload
}

type Subscription {
  recordingUpdated(sessionId: UUID!): Recording
  recordingProgress(sessionId: UUID!): RecordingProgress
}

type User {
  id: UUID!
  email: String!
  username: String!
  recordings: [Recording!]!
}

type Recording {
  id: UUID!
  title: String!
  status: RecordingStatus!
  recordingType: RecordingType!
  duration: Float
  createdAt: DateTime!
}

enum RecordingStatus {
  PREPARING
  RECORDING
  PROCESSING
  COMPLETED
  FAILED
}

enum RecordingType {
  SCREEN
  WEBCAM
  SCREEN_WEBCAM
}

input StartRecordingInput {
  title: String!
  recordingType: RecordingType!
  settings: RecordingSettingsInput
}

type RecordingConnection {
  edges: [RecordingEdge!]!
  pageInfo: PageInfo!
}

type RecordingEdge {
  node: Recording!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
}
```

## 3. Real-Time Communication

### 3.1 WebSocket API

#### 3.1.1 WebSocket Client Implementation
```javascript
class LoomWebSocketClient {
    constructor(apiUrl, authToken) {
        this.apiUrl = apiUrl;
        this.authToken = authToken;
        this.socket = null;
        this.eventHandlers = new Map();
    }
    
    connect() {
        const wsUrl = `${this.apiUrl.replace('http', 'ws')}/ws?token=${this.authToken}`;
        this.socket = new WebSocket(wsUrl);
        
        this.socket.onopen = (event) => {
            console.log('WebSocket connected');
            this.emit('connected', event);
        };
        
        this.socket.onmessage = (event) => {
            const message = JSON.parse(event.data);
            this.handleMessage(message);
        };
        
        this.socket.onclose = (event) => {
            console.log('WebSocket disconnected');
            this.emit('disconnected', event);
        };
    }
    
    handleMessage(message) {
        const { type, data } = message;
        
        switch (type) {
            case 'recording.status_update':
                this.emit('recordingStatusUpdate', data);
                break;
            case 'processing.progress':
                this.emit('processingProgress', data);
                break;
            case 'transcription.completed':
                this.emit('transcriptionCompleted', data);
                break;
        }
    }
    
    startRecording(sessionId, settings) {
        this.send('recording.start', { sessionId, settings });
    }
    
    send(type, data) {
        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({ type, data }));
        }
    }
    
    on(event, handler) {
        if (!this.eventHandlers.has(event)) {
            this.eventHandlers.set(event, []);
        }
        this.eventHandlers.get(event).push(handler);
    }
    
    emit(event, data) {
        const handlers = this.eventHandlers.get(event) || [];
        handlers.forEach(handler => handler(data));
    }
}
```

#### 3.1.2 Server-Side WebSocket Implementation
```go
package websocket

import (
    "encoding/json"
    "net/http"
    "sync"
    
    "github.com/gorilla/websocket"
)

type Hub struct {
    clients    map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
    mutex      sync.RWMutex
}

type Client struct {
    hub      *Hub
    conn     *websocket.Conn
    send     chan []byte
    userID   string
    sessions map[string]bool
}

type Message struct {
    Type string      `json:"type"`
    Data interface{} `json:"data"`
}

var upgrader = websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true
    },
}

func NewHub() *Hub {
    return &Hub{
        clients:    make(map[*Client]bool),
        broadcast:  make(chan []byte),
        register:   make(chan *Client),
        unregister: make(chan *Client),
    }
}

func (h *Hub) Run() {
    for {
        select {
        case client := <-h.register:
            h.mutex.Lock()
            h.clients[client] = true
            h.mutex.Unlock()
            
        case client := <-h.unregister:
            h.mutex.Lock()
            if _, ok := h.clients[client]; ok {
                delete(h.clients, client)
                close(client.send)
            }
            h.mutex.Unlock()
            
        case message := <-h.broadcast:
            h.mutex.RLock()
            for client := range h.clients {
                select {
                case client.send <- message:
                default:
                    close(client.send)
                    delete(h.clients, client)
                }
            }
            h.mutex.RUnlock()
        }
    }
}

func HandleWebSocket(hub *Hub, w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        return
    }
    
    userID := extractUserIDFromToken(r.URL.Query().Get("token"))
    if userID == "" {
        conn.Close()
        return
    }
    
    client := &Client{
        hub:      hub,
        conn:     conn,
        send:     make(chan []byte, 256),
        userID:   userID,
        sessions: make(map[string]bool),
    }
    
    client.hub.register <- client
    
    go client.writePump()
    go client.readPump()
}
```

## 4. Webhook System

### 4.1 Webhook Configuration

#### 4.1.1 Webhook Events
```yaml
webhook_events:
  recording:
    - recording.started
    - recording.paused
    - recording.resumed
    - recording.stopped
    - recording.completed
    - recording.failed
  
  processing:
    - processing.started
    - processing.progress
    - processing.completed
    - processing.failed
  
  video:
    - video.created
    - video.updated
    - video.deleted
    - video.shared
    - video.viewed
  
  transcription:
    - transcription.started
    - transcription.completed
    - transcription.failed
  
  user:
    - user.created
    - user.updated
    - user.deleted
```

#### 4.1.2 Webhook Implementation
```javascript
class WebhookService {
    constructor(database, httpClient) {
        this.db = database;
        this.http = httpClient;
        this.retryAttempts = 3;
        this.retryDelay = 1000; // 1 second
    }
    
    async sendWebhook(event, payload) {
        // Get all webhook subscriptions for this event
        const subscriptions = await this.db.getWebhookSubscriptions(event.type);
        
        for (const subscription of subscriptions) {
            await this.deliverWebhook(subscription, event, payload);
        }
    }
    
    async deliverWebhook(subscription, event, payload) {
        const webhookPayload = {
            id: generateUUID(),
            event: event.type,
            timestamp: new Date().toISOString(),
            data: payload,
            subscription_id: subscription.id
        };
        
        const signature = this.generateSignature(
            JSON.stringify(webhookPayload),
            subscription.secret
        );
        
        const headers = {
            'Content-Type': 'application/json',
            'X-Loom-Signature': signature,
            'X-Loom-Event': event.type,
            'X-Loom-Delivery': webhookPayload.id,
            'User-Agent': 'Loom-Webhooks/1.0'
        };
        
        let attempt = 0;
        while (attempt < this.retryAttempts) {
            try {
                const response = await this.http.post(
                    subscription.url,
                    webhookPayload,
                    { headers, timeout: 30000 }
                );
                
                if (response.status >= 200 && response.status < 300) {
                    // Success - log delivery
                    await this.logWebhookDelivery(
                        subscription.id,
                        webhookPayload.id,
                        'success',
                        response.status
                    );
                    return;
                }
                
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                
            } catch (error) {
                attempt++;
                
                if (attempt >= this.retryAttempts) {
                    // Final failure - log and give up
                    await this.logWebhookDelivery(
                        subscription.id,
                        webhookPayload.id,
                        'failed',
                        null,
                        error.message
                    );
                    return;
                }
                
                // Wait before retry with exponential backoff
                await this.sleep(this.retryDelay * Math.pow(2, attempt - 1));
            }
        }
    }
    
    generateSignature(payload, secret) {
        const crypto = require('crypto');
        return crypto
            .createHmac('sha256', secret)
            .update(payload)
            .digest('hex');
    }
    
    async logWebhookDelivery(subscriptionId, deliveryId, status, httpStatus, error) {
        await this.db.insertWebhookDelivery({
            subscription_id: subscriptionId,
            delivery_id: deliveryId,
            status: status,
            http_status: httpStatus,
            error_message: error,
            delivered_at: new Date()
        });
    }
    
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

## 5. API Rate Limiting

### 5.1 Rate Limiting Strategy

#### 5.1.1 Rate Limit Configuration
```yaml
rate_limits:
  # Per-user limits
  user_limits:
    - endpoint: "POST /recordings"
      window: "1h"
      limit: 100
      burst: 10
    
    - endpoint: "GET /recordings"
      window: "1m"
      limit: 60
      burst: 10
    
    - endpoint: "POST /videos/*/share"
      window: "1h"
      limit: 1000
      burst: 50
  
  # Per-API-key limits
  api_key_limits:
    - endpoint: "*"
      window: "1h"
      limit: 10000
      burst: 100
  
  # Global limits
  global_limits:
    - endpoint: "POST /recordings"
      window: "1m"
      limit: 1000
```

#### 5.1.2 Rate Limiting Implementation
```go
package ratelimit

import (
    "context"
    "fmt"
    "time"
    
    "github.com/go-redis/redis/v8"
)

type RateLimiter struct {
    redis  *redis.Client
    config RateLimitConfig
}

type RateLimitConfig struct {
    Window time.Duration
    Limit  int64
    Burst  int64
}

type RateLimitResult struct {
    Allowed   bool
    Remaining int64
    ResetTime time.Time
}

func NewRateLimiter(redisClient *redis.Client) *RateLimiter {
    return &RateLimiter{
        redis: redisClient,
    }
}

func (rl *RateLimiter) CheckLimit(ctx context.Context, key string, config RateLimitConfig) (*RateLimitResult, error) {
    now := time.Now()
    window := now.Truncate(config.Window)
    
    // Use sliding window log algorithm
    pipe := rl.redis.Pipeline()
    
    // Remove expired entries
    pipe.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%d", window.Unix()-int64(config.Window.Seconds())))
    
    // Count current requests
    pipe.ZCard(ctx, key)
    
    // Add current request
    pipe.ZAdd(ctx, key, &redis.Z{
        Score:  float64(now.Unix()),
        Member: fmt.Sprintf("%d", now.UnixNano()),
    })
    
    // Set expiration
    pipe.Expire(ctx, key, config.Window*2)
    
    results, err := pipe.Exec(ctx)
    if err != nil {
        return nil, err
    }
    
    count := results[1].(*redis.IntCmd).Val()
    
    allowed := count < config.Limit
    remaining := config.Limit - count
    if remaining < 0 {
        remaining = 0
    }
    
    resetTime := window.Add(config.Window)
    
    return &RateLimitResult{
        Allowed:   allowed,
        Remaining: remaining,
        ResetTime: resetTime,
    }, nil
}

// Middleware for Gin
func RateLimitMiddleware(rateLimiter *RateLimiter) gin.HandlerFunc {
    return gin.HandlerFunc(func(c *gin.Context) {
        userID := c.GetString("user_id")
        endpoint := fmt.Sprintf("%s %s", c.Request.Method, c.FullPath())
        
        // Get rate limit config for endpoint
        config := getRateLimitConfig(endpoint)
        if config == nil {
            c.Next()
            return
        }
        
        // Check rate limit
        key := fmt.Sprintf("rate_limit:%s:%s", userID, endpoint)
        result, err := rateLimiter.CheckLimit(c.Request.Context(), key, *config)
        if err != nil {
            c.JSON(500, gin.H{"error": "Rate limit check failed"})
            c.Abort()
            return
        }
        
        // Set rate limit headers
        c.Header("X-RateLimit-Limit", fmt.Sprintf("%d", config.Limit))
        c.Header("X-RateLimit-Remaining", fmt.Sprintf("%d", result.Remaining))
        c.Header("X-RateLimit-Reset", fmt.Sprintf("%d", result.ResetTime.Unix()))
        
        if !result.Allowed {
            c.JSON(429, gin.H{
                "error": "Rate limit exceeded",
                "retry_after": result.ResetTime.Sub(time.Now()).Seconds(),
            })
            c.Abort()
            return
        }
        
        c.Next()
    })
}
```

## 6. API Authentication & Authorization

### 6.1 JWT Authentication

#### 6.1.1 JWT Implementation
```javascript
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

class JWTService {
    constructor(config) {
        this.accessTokenSecret = config.accessTokenSecret;
        this.refreshTokenSecret = config.refreshTokenSecret;
        this.accessTokenExpiry = config.accessTokenExpiry || '15m';
        this.refreshTokenExpiry = config.refreshTokenExpiry || '7d';
    }
    
    generateTokenPair(payload) {
        const accessToken = jwt.sign(
            payload,
            this.accessTokenSecret,
            { 
                expiresIn: this.accessTokenExpiry,
                issuer: 'loom-api',
                audience: 'loom-client'
            }
        );
        
        const refreshToken = jwt.sign(
            { userId: payload.userId },
            this.refreshTokenSecret,
            { 
                expiresIn: this.refreshTokenExpiry,
                issuer: 'loom-api',
                audience: 'loom-client'
            }
        );
        
        return { accessToken, refreshToken };
    }
    
    verifyAccessToken(token) {
        try {
            return jwt.verify(token, this.accessTokenSecret, {
                issuer: 'loom-api',
                audience: 'loom-client'
            });
        } catch (error) {
            throw new Error('Invalid access token');
        }
    }
    
    verifyRefreshToken(token) {
        try {
            return jwt.verify(token, this.refreshTokenSecret, {
                issuer: 'loom-api',
                audience: 'loom-client'
            });
        } catch (error) {
            throw new Error('Invalid refresh token');
        }
    }
    
    refreshAccessToken(refreshToken) {
        const decoded = this.verifyRefreshToken(refreshToken);
        
        // Generate new access token
        const newAccessToken = jwt.sign(
            { userId: decoded.userId },
            this.accessTokenSecret,
            { 
                expiresIn: this.accessTokenExpiry,
                issuer: 'loom-api',
                audience: 'loom-client'
            }
        );
        
        return newAccessToken;
    }
}

// Authentication middleware
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }
    
    try {
        const decoded = jwtService.verifyAccessToken(token);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(403).json({ error: 'Invalid or expired token' });
    }
}
```

### 6.2 API Key Authentication

#### 6.2.1 API Key Management
```go
package auth

import (
    "crypto/rand"
    "crypto/sha256"
    "encoding/hex"
    "fmt"
    "time"
)

type APIKey struct {
    ID          string    `json:"id" db:"id"`
    Name        string    `json:"name" db:"name"`
    KeyHash     string    `json:"-" db:"key_hash"`
    KeyPrefix   string    `json:"key_prefix" db:"key_prefix"`
    UserID      string    `json:"user_id" db:"user_id"`
    Scopes      []string  `json:"scopes" db:"scopes"`
    LastUsedAt  *time.Time `json:"last_used_at" db:"last_used_at"`
    ExpiresAt   *time.Time `json:"expires_at" db:"expires_at"`
    CreatedAt   time.Time `json:"created_at" db:"created_at"`
    IsActive    bool      `json:"is_active" db:"is_active"`
}

type APIKeyService struct {
    db Database
}

func (aks *APIKeyService) CreateAPIKey(userID, name string, scopes []string, expiresAt *time.Time) (*APIKey, string, error) {
    // Generate random key
    keyBytes := make([]byte, 32)
    if _, err := rand.Read(keyBytes); err != nil {
        return nil, "", err
    }
    
    rawKey := hex.EncodeToString(keyBytes)
    keyPrefix := rawKey[:8]
    fullKey := fmt.Sprintf("loom_%s_%s", keyPrefix, rawKey[8:])
    
    // Hash the key for storage
    hash := sha256.Sum256([]byte(fullKey))
    keyHash := hex.EncodeToString(hash[:])
    
    apiKey := &APIKey{
        ID:        generateUUID(),
        Name:      name,
        KeyHash:   keyHash,
        KeyPrefix: keyPrefix,
        UserID:    userID,
        Scopes:    scopes,
        ExpiresAt: expiresAt,
        CreatedAt: time.Now(),
        IsActive:  true,
    }
    
    if err := aks.db.CreateAPIKey(apiKey); err != nil {
        return nil, "", err
    }
    
    return apiKey, fullKey, nil
}

func (aks *APIKeyService) ValidateAPIKey(key string) (*APIKey, error) {
    // Hash the provided key
    hash := sha256.Sum256([]byte(key))
    keyHash := hex.EncodeToString(hash[:])
    
    // Look up the key
    apiKey, err := aks.db.GetAPIKeyByHash(keyHash)
    if err != nil {
        return nil, fmt.Errorf("invalid API key")
    }
    
    // Check if key is active
    if !apiKey.IsActive {
        return nil, fmt.Errorf("API key is disabled")
    }
    
    // Check expiration
    if apiKey.ExpiresAt != nil && time.Now().After(*apiKey.ExpiresAt) {
        return nil, fmt.Errorf("API key has expired")
    }
    
    // Update last used timestamp
    now := time.Now()
    apiKey.LastUsedAt = &now
    aks.db.UpdateAPIKeyLastUsed(apiKey.ID, now)
    
    return apiKey, nil
}

// Middleware for API key authentication
func APIKeyMiddleware(apiKeyService *APIKeyService) gin.HandlerFunc {
    return gin.HandlerFunc(func(c *gin.Context) {
        apiKey := c.GetHeader("X-API-Key")
        if apiKey == "" {
            c.JSON(401, gin.H{"error": "API key required"})
            c.Abort()
            return
        }
        
        keyInfo, err := apiKeyService.ValidateAPIKey(apiKey)
        if err != nil {
            c.JSON(401, gin.H{"error": err.Error()})
            c.Abort()
            return
        }
        
        c.Set("api_key", keyInfo)
        c.Set("user_id", keyInfo.UserID)
        c.Next()
    })
}
```

## 7. API Documentation & Testing

### 7.1 API Documentation

#### 7.1.1 Interactive Documentation
```yaml
# Swagger UI Configuration
swagger_ui:
  title: "Loom API Documentation"
  description: "Interactive API documentation for Loom platform"
  version: "1.0.0"
  servers:
    - url: "https://api.loom.com/v1"
      description: "Production"
    - url: "https://staging-api.loom.com/v1"
      description: "Staging"
  
  features:
    - try_it_out: true
    - code_samples: true
    - curl_examples: true
    - sdk_examples: true
  
  authentication:
    - type: "bearer"
      description: "JWT token authentication"
    - type: "apiKey"
      description: "API key authentication"
```

### 7.2 API Testing

#### 7.2.1 Integration Tests
```javascript
// API Integration Tests
const request = require('supertest');
const app = require('../app');

describe('Recording API', () => {
    let authToken;
    let recordingId;
    
    beforeAll(async () => {
        // Get authentication token
        const loginResponse = await request(app)
            .post('/auth/login')
            .send({
                email: 'test@example.com',
                password: 'password123'
            });
        
        authToken = loginResponse.body.token;
    });
    
    describe('POST /recordings', () => {
        it('should create a new recording', async () => {
            const response = await request(app)
                .post('/api/v1/recordings')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    title: 'Test Recording',
                    recordingType: 'screen',
                    settings: {
                        resolution: { width: 1920, height: 1080 },
                        frameRate: 30,
                        quality: 'high'
                    }
                });
            
            expect(response.status).toBe(201);
            expect(response.body).toHaveProperty('id');
            expect(response.body.title).toBe('Test Recording');
            expect(response.body.status).toBe('preparing');
            
            recordingId = response.body.id;
        });
        
        it('should return 400 for invalid recording type', async () => {
            const response = await request(app)
                .post('/api/v1/recordings')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    title: 'Invalid Recording',
                    recordingType: 'invalid_type'
                });
            
            expect(response.status).toBe(400);
            expect(response.body).toHaveProperty('error');
        });
    });
    
    describe('GET /recordings', () => {
        it('should list user recordings', async () => {
            const response = await request(app)
                .get('/api/v1/recordings')
                .set('Authorization', `Bearer ${authToken}`);
            
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('data');
            expect(response.body).toHaveProperty('pagination');
            expect(Array.isArray(response.body.data)).toBe(true);
        });
    });
    
    describe('POST /recordings/:id/control', () => {
        it('should control recording session', async () => {
            const response = await request(app)
                .post(`/api/v1/recordings/${recordingId}/control`)
                .set('Authorization', `Bearer ${authToken}`)
                .send({ action: 'stop' });
            
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('status');
        });
    });
});
```

## Conclusion

This comprehensive API specification provides a robust foundation for the Atlassian Loom platform's communication layer. Key features include:

### API Benefits
1. **RESTful Design**: Intuitive and standards-compliant REST APIs
2. **GraphQL Flexibility**: Efficient data fetching with GraphQL
3. **Real-Time Communication**: WebSocket support for live updates
4. **Webhook Integration**: Reliable event notifications
5. **Security**: JWT and API key authentication with rate limiting
6. **Documentation**: Interactive API documentation and testing tools

### Implementation Priorities
1. **Phase 1**: Core REST APIs and authentication
2. **Phase 2**: WebSocket real-time communication
3. **Phase 3**: GraphQL API and webhook system
4. **Phase 4**: Advanced features and optimizations

This API architecture ensures scalable, secure, and developer-friendly access to all Loom platform capabilities.

---
**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Related Documents**: 05-microservices-architecture.md, 07-video-storage-processing-cdn.md