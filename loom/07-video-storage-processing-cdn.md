# Atlassian Loom: Video Storage, Processing & CDN Architecture

## Document Overview
This document defines the comprehensive video storage, processing, and content delivery network (CDN) architecture for the Atlassian Loom platform, covering multi-tier storage strategies, distributed processing pipelines, and global content delivery optimization.

## 1. Video Storage Strategy

### 1.1 Multi-Tier Storage Architecture

#### 1.1.1 Storage Tiers Configuration
```yaml
storage_tiers:
  hot_tier:
    description: "Recently uploaded and frequently accessed videos"
    storage_class: "S3 Standard"
    retention_period: "30 days"
    access_pattern: "Frequent access"
    cost_optimization: "Performance optimized"
    
  warm_tier:
    description: "Moderately accessed videos"
    storage_class: "S3 Standard-IA"
    retention_period: "90 days"
    access_pattern: "Infrequent access"
    cost_optimization: "Balanced cost and performance"
    
  cold_tier:
    description: "Archive videos and long-term storage"
    storage_class: "S3 Glacier"
    retention_period: "1+ years"
    access_pattern: "Rare access"
    cost_optimization: "Cost optimized"
    
  deep_archive_tier:
    description: "Compliance and legal retention"
    storage_class: "S3 Glacier Deep Archive"
    retention_period: "7+ years"
    access_pattern: "Very rare access"
    cost_optimization: "Lowest cost"

# Intelligent Tiering Rules
tiering_rules:
  - name: "Recent uploads"
    condition: "age < 30 days"
    target_tier: "hot_tier"
    
  - name: "Moderate usage"
    condition: "age >= 30 days AND age < 90 days"
    target_tier: "warm_tier"
    
  - name: "Low usage"
    condition: "age >= 90 days AND access_count < 10"
    target_tier: "cold_tier"
    
  - name: "Archive"
    condition: "age >= 365 days"
    target_tier: "deep_archive_tier"
```

### 1.2 Video Storage Implementation

#### 1.2.1 Storage Service
```go
// Video Storage Service
package storage

import (
    "context"
    "fmt"
    "io"
    "time"
    
    "github.com/aws/aws-sdk-go-v2/service/s3"
)

type VideoStorageService struct {
    s3Client     *s3.Client
    bucketName   string
    cdnDomain    string
}

type StorageMetadata struct {
    VideoID       string
    OriginalName  string
    ContentType   string
    Size          int64
    Duration      float64
    Resolution    Resolution
    Bitrate       int
    Codec         string
    StorageTier   string
    UploadedAt    time.Time
    LastAccessed  time.Time
    AccessCount   int
    Tags          map[string]string
}

func (vss *VideoStorageService) UploadVideo(ctx context.Context, videoID string, reader io.Reader, metadata StorageMetadata) error {
    storageKey := vss.generateStorageKey(videoID, metadata)
    
    uploadInput := &s3.PutObjectInput{
        Bucket:      &vss.bucketName,
        Key:         &storageKey,
        Body:        reader,
        ContentType: &metadata.ContentType,
    }
    
    _, err := vss.s3Client.PutObject(ctx, uploadInput)
    return err
}

func (vss *VideoStorageService) generateStorageKey(videoID string, metadata StorageMetadata) string {
    year := metadata.UploadedAt.Year()
    month := metadata.UploadedAt.Month()
    day := metadata.UploadedAt.Day()
    quality := vss.determineQuality(metadata.Bitrate, metadata.Resolution)
    
    return fmt.Sprintf("videos/%d/%02d/%02d/%s/%s.mp4", 
        year, month, day, quality, videoID)
}

func (vss *VideoStorageService) determineQuality(bitrate int, resolution Resolution) string {
    if resolution.Height >= 1080 {
        return "1080p"
    } else if resolution.Height >= 720 {
        return "720p"
    } else if resolution.Height >= 480 {
        return "480p"
    } else {
        return "360p"
    }
}
```

## 2. Video Processing Pipeline

### 2.1 Processing Configuration

#### 2.1.1 Pipeline Stages
```yaml
processing_pipeline:
  stages:
    - name: "validation"
      timeout: "30s"
      retry_attempts: 3
      
    - name: "transcoding"
      timeout: "30m"
      retry_attempts: 2
      parallel_jobs: 4
      
    - name: "thumbnail_generation"
      timeout: "5m"
      retry_attempts: 3
      
    - name: "ai_processing"
      timeout: "20m"
      retry_attempts: 2
      
    - name: "optimization"
      timeout: "15m"
      retry_attempts: 2
      
    - name: "cdn_upload"
      timeout: "10m"
      retry_attempts: 3

  transcoding_profiles:
    - name: "4k_profile"
      resolution: "3840x2160"
      bitrate: "15000k"
      codec: "h264"
      
    - name: "1080p_profile"
      resolution: "1920x1080"
      bitrate: "5000k"
      codec: "h264"
      
    - name: "720p_profile"
      resolution: "1280x720"
      bitrate: "2500k"
      codec: "h264"
      
    - name: "480p_profile"
      resolution: "854x480"
      bitrate: "1000k"
      codec: "h264"
```

### 2.2 Processing Implementation

#### 2.2.1 Video Processor
```python
import asyncio
from typing import List, Dict, Any
from dataclasses import dataclass
from enum import Enum

class ProcessingStage(Enum):
    VALIDATION = "validation"
    TRANSCODING = "transcoding"
    THUMBNAIL = "thumbnail"
    AI_ANALYSIS = "ai_analysis"
    OPTIMIZATION = "optimization"
    CDN_UPLOAD = "cdn_upload"

@dataclass
class ProcessingJob:
    id: str
    video_id: str
    input_path: str
    output_paths: Dict[str, str]
    stages: List[ProcessingStage]
    profiles: List[str]
    status: str = "queued"
    progress: float = 0.0

class VideoProcessor:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.ffmpeg_path = config.get("ffmpeg_path", "/usr/bin/ffmpeg")
        self.max_concurrent_jobs = config.get("max_concurrent_jobs", 4)
        self.semaphore = asyncio.Semaphore(self.max_concurrent_jobs)
    
    async def process_video(self, job: ProcessingJob) -> ProcessingJob:
        async with self.semaphore:
            try:
                job.status = "processing"
                total_stages = len(job.stages)
                
                for i, stage in enumerate(job.stages):
                    job.progress = (i / total_stages) * 100
                    await self._process_stage(job, stage)
                    
                job.status = "completed"
                job.progress = 100.0
                
            except Exception as e:
                job.status = "failed"
                job.error = str(e)
                
            return job
    
    async def _process_stage(self, job: ProcessingJob, stage: ProcessingStage):
        if stage == ProcessingStage.VALIDATION:
            await self._validate_video(job)
        elif stage == ProcessingStage.TRANSCODING:
            await self._transcode_video(job)
        elif stage == ProcessingStage.THUMBNAIL:
            await self._generate_thumbnails(job)
    
    async def _validate_video(self, job: ProcessingJob):
        cmd = [
            self.ffmpeg_path,
            "-v", "error",
            "-i", job.input_path,
            "-f", "null",
            "-"
        ]
        
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        stdout, stderr = await process.communicate()
        
        if process.returncode != 0:
            raise Exception(f"Video validation failed: {stderr.decode()}")
    
    async def _transcode_video(self, job: ProcessingJob):
        tasks = []
        for profile_name in job.profiles:
            profile = self._get_transcoding_profile(profile_name)
            if profile:
                task = self._transcode_profile(job, profile)
                tasks.append(task)
        
        await asyncio.gather(*tasks)
    
    async def _transcode_profile(self, job: ProcessingJob, profile: Dict[str, Any]):
        profile_name = profile["name"]
        output_path = job.output_paths.get(profile_name)
        
        if not output_path:
            return
        
        cmd = [
            self.ffmpeg_path,
            "-i", job.input_path,
            "-c:v", profile["codec"],
            "-b:v", profile["bitrate"],
            "-s", profile["resolution"],
            "-c:a", "aac",
            "-b:a", "128k",
            "-y",
            output_path
        ]
        
        process = await asyncio.create_subprocess_exec(*cmd)
        await process.communicate()
        
        if process.returncode != 0:
            raise Exception(f"Transcoding failed for {profile_name}")
    
    def _get_transcoding_profile(self, profile_name: str):
        profiles = self.config.get("transcoding_profiles", [])
        return next((p for p in profiles if p["name"] == profile_name), None)
```

## 3. Global CDN Architecture

### 3.1 Multi-CDN Strategy

#### 3.1.1 CDN Configuration
```yaml
cdn_strategy:
  primary_cdn:
    provider: "AWS CloudFront"
    regions: ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
    features:
      - "Edge caching"
      - "Origin shield"
      - "Real-time logs"
    
  secondary_cdn:
    provider: "Cloudflare"
    regions: ["Global"]
    features:
      - "DDoS protection"
      - "Web Application Firewall"
      - "Bot management"
    
  routing_rules:
    - condition: "geo_country == 'US'"
      primary: "AWS CloudFront"
      fallback: "Cloudflare"
      
    - condition: "geo_country IN ['GB', 'DE', 'FR']"
      primary: "AWS CloudFront"
      fallback: "Cloudflare"

caching_rules:
  video_files:
    cache_duration: "30 days"
    edge_cache: "enabled"
    browser_cache: "7 days"
    
  thumbnails:
    cache_duration: "7 days"
    edge_cache: "enabled"
    browser_cache: "1 day"
    
  hls_playlists:
    cache_duration: "1 hour"
    edge_cache: "enabled"
    browser_cache: "5 minutes"
```

### 3.2 CDN Implementation

#### 3.2.1 CDN Manager
```javascript
class CDNManager {
    constructor(config) {
        this.config = config;
        this.providers = {
            cloudfront: new CloudFrontProvider(config.cloudfront),
            cloudflare: new CloudflareProvider(config.cloudflare)
        };
        this.routingRules = config.routingRules;
    }
    
    async uploadVideo(videoId, filePath, metadata) {
        const uploadTasks = [];
        
        for (const [providerName, provider] of Object.entries(this.providers)) {
            const task = this.uploadToProvider(provider, videoId, filePath, metadata);
            uploadTasks.push(task);
        }
        
        const results = await Promise.allSettled(uploadTasks);
        return results;
    }
    
    async uploadToProvider(provider, videoId, filePath, metadata) {
        try {
            const cdnPath = this.generateCDNPath(videoId, metadata);
            const uploadResult = await provider.upload(filePath, cdnPath, {
                contentType: metadata.contentType,
                cacheControl: this.getCacheControl(metadata.fileType)
            });
            
            return {
                provider: provider.name,
                success: true,
                url: uploadResult.url,
                cdnPath: cdnPath
            };
        } catch (error) {
            return {
                provider: provider.name,
                success: false,
                error: error.message
            };
        }
    }
    
    getOptimalCDNUrl(videoId, userLocation, quality = '1080p') {
        const primaryCDN = this.selectPrimaryCDN(userLocation);
        const fallbackCDN = this.selectFallbackCDN(userLocation);
        
        const cdnPath = this.generateCDNPath(videoId, { quality });
        
        return {
            primary: `https://${primaryCDN.domain}/${cdnPath}`,
            fallback: `https://${fallbackCDN.domain}/${cdnPath}`,
            adaptive: this.generateAdaptiveStreamingUrls(videoId, primaryCDN)
        };
    }
    
    generateAdaptiveStreamingUrls(videoId, cdn) {
        const baseUrl = `https://${cdn.domain}/hls/${videoId}`;
        
        return {
            master: `${baseUrl}/master.m3u8`,
            profiles: {
                '4k': `${baseUrl}/4k/playlist.m3u8`,
                '1080p': `${baseUrl}/1080p/playlist.m3u8`,
                '720p': `${baseUrl}/720p/playlist.m3u8`,
                '480p': `${baseUrl}/480p/playlist.m3u8`
            }
        };
    }
    
    selectPrimaryCDN(userLocation) {
        for (const rule of this.routingRules) {
            if (this.evaluateRoutingCondition(rule.condition, userLocation)) {
                return this.providers[rule.primary];
            }
        }
        return this.providers.cloudflare;
    }
    
    generateCDNPath(videoId, metadata) {
        const quality = metadata.quality || '1080p';
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        
        return `videos/${year}/${month}/${quality}/${videoId}.mp4`;
    }
    
    getCacheControl(fileType) {
        const cacheRules = {
            'video': 'public, max-age=2592000', // 30 days
            'thumbnail': 'public, max-age=604800', // 7 days
            'playlist': 'public, max-age=3600', // 1 hour
            'segment': 'public, max-age=86400' // 24 hours
        };
        
        return cacheRules[fileType] || 'public, max-age=3600';
    }
    
    async invalidateCache(videoId, paths = []) {
        const invalidationTasks = [];
        
        const defaultPaths = [
            `/videos/*/${videoId}*`,
            `/hls/${videoId}/*`,
            `/thumbnails/${videoId}/*`
        ];
        
        const allPaths = [...defaultPaths, ...paths];
        
        for (const [providerName, provider] of Object.entries(this.providers)) {
            const task = provider.invalidate(allPaths);
            invalidationTasks.push(task);
        }
        
        const results = await Promise.allSettled(invalidationTasks);
        return results;
    }
}
```

## 4. Adaptive Streaming

### 4.1 HLS Implementation

#### 4.1.1 HLS Configuration
```yaml
hls_config:
  segment_duration: 10  # seconds
  playlist_type: "VOD"  # Video on Demand
  encryption: true
  
  quality_levels:
    - name: "4K"
      resolution: "3840x2160"
      bitrate: "15000k"
      bandwidth: 15000000
      
    - name: "1080p"
      resolution: "1920x1080"
      bitrate: "5000k"
      bandwidth: 5000000
      
    - name: "720p"
      resolution: "1280x720"
      bitrate: "2500k"
      bandwidth: 2500000
      
    - name: "480p"
      resolution: "854x480"
      bitrate: "1000k"
      bandwidth: 1000000
      
    - name: "360p"
      resolution: "640x360"
      bitrate: "500k"
      bandwidth: 500000

  master_playlist_template: |
    #EXTM3U
    #EXT-X-VERSION:6
    #EXT-X-STREAM-INF:BANDWIDTH={{bandwidth}},RESOLUTION={{resolution}},CODECS="avc1.640028,mp4a.40.2"
    {{quality}}/playlist.m3u8
```

### 4.2 Streaming Service

#### 4.2.1 Streaming Implementation
```go
package streaming

import (
    "context"
    "fmt"
    "net/http"
)

type StreamingService struct {
    cdnManager    CDNManager
    cache         Cache
    analytics     AnalyticsService
    accessControl AccessControlService
}

type StreamRequest struct {
    VideoID     string
    Quality     string
    UserID      string
    ShareToken  string
    ClientInfo  ClientInfo
}

type StreamResponse struct {
    StreamURL     string
    ManifestURL   string
    Qualities     []QualityOption
    Subtitles     []SubtitleTrack
    Analytics     AnalyticsConfig
}

func (ss *StreamingService) GetStreamURL(ctx context.Context, req StreamRequest) (*StreamResponse, error) {
    // Validate access permissions
    hasAccess, err := ss.accessControl.ValidateAccess(ctx, req.VideoID, req.UserID, req.ShareToken)
    if err != nil {
        return nil, fmt.Errorf("access validation failed: %w", err)
    }
    if !hasAccess {
        return nil, fmt.Errorf("access denied")
    }
    
    // Get optimal CDN URLs
    cdnURLs := ss.cdnManager.GetOptimalCDNUrl(req.VideoID, req.ClientInfo.Location, req.Quality)
    
    // Generate streaming response
    response := &StreamResponse{
        StreamURL:   cdnURLs.Primary,
        ManifestURL: cdnURLs.Adaptive.Master,
        Qualities:   ss.getAvailableQualities(req.VideoID),
        Subtitles:   ss.getSubtitleTracks(req.VideoID),
        Analytics:   ss.getAnalyticsConfig(req.VideoID, req.UserID),
    }
    
    // Track streaming event
    ss.analytics.TrackStreamStart(ctx, AnalyticsEvent{
        VideoID:    req.VideoID,
        UserID:     req.UserID,
        Quality:    req.Quality,
        ClientInfo: req.ClientInfo,
        Timestamp:  time.Now(),
    })
    
    return response, nil
}

func (ss *StreamingService) HandleStreamingRequest(w http.ResponseWriter, r *http.Request) {
    videoID := r.URL.Query().Get("video_id")
    quality := r.URL.Query().Get("quality")
    
    if videoID == "" {
        http.Error(w, "Missing video_id parameter", http.StatusBadRequest)
        return
    }
    
    clientInfo := ss.extractClientInfo(r)
    
    streamReq := StreamRequest{
        VideoID:    videoID,
        Quality:    quality,
        ClientInfo: clientInfo,
    }
    
    streamResp, err := ss.GetStreamURL(r.Context(), streamReq)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Cache-Control", "no-cache")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    
    json.NewEncoder(w).Encode(streamResp)
}
```

## 5. Performance Optimization

### 5.1 Caching Strategy

#### 5.1.1 Multi-Level Caching
```yaml
caching_strategy:
  levels:
    - name: "CDN Edge Cache"
      location: "Edge locations"
      ttl: "30 days"
      content_types: ["video", "thumbnail", "manifest"]
      
    - name: "Origin Cache"
      location: "Origin servers"
      ttl: "7 days"
      content_types: ["processed_video", "metadata"]
      
    - name: "Application Cache"
      location: "Application servers"
      ttl: "1 hour"
      content_types: ["metadata", "user_preferences"]
      
    - name: "Database Cache"
      location: "Database layer"
      ttl: "15 minutes"
      content_types: ["query_results", "session_data"]

  cache_warming:
    triggers:
      - "video_upload_complete"
      - "high_view_count"
      - "trending_content"
    
    strategies:
      - name: "Popular content preloading"
        condition: "view_count > 1000"
        action: "preload_to_edge"
        
      - name: "Geographic preloading"
        condition: "user_location_pattern"
        action: "preload_to_region"
```

### 5.2 Bandwidth Optimization

#### 5.2.1 Adaptive Bitrate Streaming
```javascript
class AdaptiveBitrateController {
    constructor(player, config) {
        this.player = player;
        this.config = config;
        this.currentQuality = 'auto';
        this.bandwidthHistory = [];
        this.qualityLevels = config.qualityLevels;
        this.switchThreshold = config.switchThreshold || 0.8;
    }
    
    startMonitoring() {
        setInterval(() => {
            this.measureBandwidth();
            this.adjustQuality();
        }, 5000); // Check every 5 seconds
    }
    
    measureBandwidth() {
        const stats = this.player.getStats();
        const currentBandwidth = stats.bandwidth;
        
        this.bandwidthHistory.push({
            bandwidth: currentBandwidth,
            timestamp: Date.now(),
            bufferLevel: stats.bufferLevel
        });
        
        // Keep only last 10 measurements
        if (this.bandwidthHistory.length > 10) {
            this.bandwidthHistory.shift();
        }
    }
    
    adjustQuality() {
        if (this.currentQuality === 'manual') {
            return; // User has manually selected quality
        }
        
        const averageBandwidth = this.calculateAverageBandwidth();
        const bufferLevel = this.player.getBufferLevel();
        const currentQualityLevel = this.getCurrentQualityLevel();
        
        // Determine optimal quality based on bandwidth and buffer
        const optimalQuality = this.selectOptimalQuality(
            averageBandwidth,
            bufferLevel,
            currentQualityLevel
        );
        
        if (optimalQuality !== currentQualityLevel.name) {
            this.switchQuality(optimalQuality);
        }
    }
    
    calculateAverageBandwidth() {
        if (this.bandwidthHistory.length === 0) {
            return 0;
        }
        
        const sum = this.bandwidthHistory.reduce((acc, entry) => acc + entry.bandwidth, 0);
        return sum / this.bandwidthHistory.length;
    }
    
    selectOptimalQuality(bandwidth, bufferLevel, currentQuality) {
        // Sort quality levels by bandwidth requirement
        const sortedQualities = [...this.qualityLevels].sort((a, b) => a.bandwidth - b.bandwidth);
        
        // If buffer is low, switch to lower quality immediately
        if (bufferLevel < 5) { // Less than 5 seconds buffered
            const lowerQuality = this.findLowerQuality(currentQuality);
            if (lowerQuality) {
                return lowerQuality.name;
            }
        }
        
        // Find highest quality that fits within bandwidth
        for (let i = sortedQualities.length - 1; i >= 0; i--) {
            const quality = sortedQualities[i];
            const requiredBandwidth = quality.bandwidth * this.switchThreshold;
            
            if (bandwidth >= requiredBandwidth) {
                return quality.name;
            }
        }
        
        // Fallback to lowest quality
        return sortedQualities[0].name;
    }
    
    switchQuality(newQuality) {
        console.log(`Switching quality from ${this.currentQuality} to ${newQuality}`);
        
        this.player.setQuality(newQuality);
        this.currentQuality = newQuality;
        
        // Track quality switch for analytics
        this.trackQualitySwitch(newQuality);
    }
    
    trackQualitySwitch(newQuality) {
        // Send analytics event
        analytics.track('quality_switch', {
            from_quality: this.currentQuality,
            to_quality: newQuality,
            bandwidth: this.calculateAverageBandwidth(),
            buffer_level: this.player.getBufferLevel(),
            timestamp: Date.now()
        });
    }
}
```

## 6. Monitoring & Analytics

### 6.1 Performance Monitoring

#### 6.1.1 Metrics Collection
```yaml
monitoring_metrics:
  storage_metrics:
    - name: "storage_utilization"
      type: "gauge"
      description: "Storage utilization by tier"
      labels: ["tier", "region"]
      
    - name: "storage_costs"
      type: "gauge"
      description: "Storage costs by tier"
      labels: ["tier", "region"]
      
    - name: "access_patterns"
      type: "counter"
      description: "File access patterns"
      labels: ["tier", "access_type"]
  
  processing_metrics:
    - name: "processing_duration"
      type: "histogram"
      description: "Video processing duration"
      labels: ["stage", "profile", "resolution"]
      
    - name: "processing_queue_size"
      type: "gauge"
      description: "Processing queue size"
      labels: ["priority", "stage"]
      
    - name: "processing_errors"
      type: "counter"
      description: "Processing errors by type"
      labels: ["stage", "error_type"]
  
  cdn_metrics:
    - name: "cdn_cache_hit_ratio"
      type: "gauge"
      description: "CDN cache hit ratio"
      labels: ["provider", "region", "content_type"]
      
    - name: "cdn_bandwidth_usage"
      type: "counter"
      description: "CDN bandwidth usage"
      labels: ["provider", "region"]
      
    - name: "cdn_response_time"
      type: "histogram"
      description: "CDN response time"
      labels: ["provider", "region", "edge_location"]
```

### 6.2 Analytics Implementation

#### 6.2.1 Video Analytics Service
```python
class VideoAnalyticsService:
    def __init__(self, database, time_series_db):
        self.db = database
        self.tsdb = time_series_db
    
    async def track_video_event(self, event_type: str, video_id: str, user_id: str, metadata: dict):
        """Track video-related events"""
        event = {
            'event_type': event_type,
            'video_id': video_id,
            'user_id': user_id,
            'timestamp': time.time(),
            'metadata': metadata
        }
        
        # Store in time series database for analytics
        await self.tsdb.write_point(
            measurement='video_events',
            tags={
                'event_type': event_type,
                'video_id': video_id,
                'user_id': user_id
            },
            fields=metadata,
            timestamp=event['timestamp']
        )
        
        # Update aggregated metrics
        await self.update_video_metrics(video_id, event_type, metadata)
    
    async def update_video_metrics(self, video_id: str, event_type: str, metadata: dict):
        """Update aggregated video metrics"""
        if event_type == 'video_view':
            await self.increment_view_count(video_id)
            await self.update_watch_time(video_id, metadata.get('watch_time', 0))
        elif event_type == 'video_share':
            await self.increment_share_count(video_id)
        elif event_type == 'video_like':
            await self.increment_like_count(video_id)
    
    async def get_video_analytics(self, video_id: str, timeframe: str = '30d') -> dict:
        """Get comprehensive analytics for a video"""
        # Query time series data
        query = f"""
        SELECT 
            COUNT(*) as total_views,
            COUNT(DISTINCT user_id) as unique_viewers,
            AVG(watch_time) as avg_watch_time,
            SUM(watch_time) as total_watch_time
        FROM video_events 
        WHERE video_id = '{video_id}' 
        AND event_type = 'video_view'
        AND time >= now() - {timeframe}
        """
        
        results = await self.tsdb.query(query)
        
        # Get geographic distribution
        geo_query = f"""
        SELECT 
            country,
            COUNT(*) as views
        FROM video_events 
        WHERE video_id = '{video_id}' 
        AND event_type = 'video_view'
        AND time >= now() - {timeframe}
        GROUP BY country
        ORDER BY views DESC
        """
        
        geo_results = await self.tsdb.query(geo_query)
        
        return {
            'video_id': video_id,
            'timeframe': timeframe,
            'total_views': results[0]['total_views'],
            'unique_viewers': results[0]['unique_viewers'],
            'average_watch_time': results[0]['avg_watch_time'],
            'total_watch_time': results[0]['total_watch_time'],
            'geographic_distribution': geo_results,
            'engagement_rate': self.calculate_engagement_rate(video_id, timeframe),
            'completion_rate': await self.calculate_completion_rate(video_id, timeframe)
        }
    
    async def