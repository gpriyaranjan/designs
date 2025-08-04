# Atlassian Loom: Component Interaction Flows

This document illustrates the typical interaction flows between the various microservices and components during the key operations of recording, video processing, and streaming. These sequence diagrams highlight the communication patterns and data flow across the Atlassian Loom platform.

## 1. Recording Flow

This diagram shows the sequence of interactions when a user initiates and completes a recording.

```mermaid
sequenceDiagram
    participant User
    participant ClientApp as Client Application<br/>(Desktop/Browser/Mobile)
    participant API_GW as API Gateway
    participant RecordingSvc as Recording Service
    participant PostgreSQL as PostgreSQL DB
    participant Redis as Redis Cache
    participant Kafka as Kafka Event Bus

    User->>ClientApp: 1. Clicks "Start Recording"
    ClientApp->>API_GW: 2. Request: POST /api/v1/recordings (Start Session)
    API_GW->>RecordingSvc: 3. Route Request
    RecordingSvc->>PostgreSQL: 4. Create new recording_session entry (status: preparing)
    PostgreSQL-->>RecordingSvc: 5. Session ID created
    RecordingSvc->>Redis: 6. Store real-time session state (e.g., active, settings)
    Redis-->>RecordingSvc: 7. State stored
    RecordingSvc-->>API_GW: 8. Response: Session ID, Recording URL
    API_GW-->>ClientApp: 9. Response: Session ID, Recording URL
    ClientApp->>ClientApp: 10. Starts local screen/webcam/audio capture
    ClientApp->>ClientApp: 11. Buffers recorded data locally

    User->>ClientApp: 12. Clicks "Stop Recording"
    ClientApp->>API_GW: 13. Request: POST /api/v1/recordings/{sessionId}/control (Stop)
    API_GW->>RecordingSvc: 14. Route Request
    RecordingSvc->>PostgreSQL: 15. Update recording_session status (e.g., processing)
    PostgreSQL-->>RecordingSvc: 16. Status updated
    RecordingSvc->>Redis: 17. Update real-time session state
    Redis-->>RecordingSvc: 18. State updated
    RecordingSvc->>Kafka: 19. Publish "recording_completed" event (sessionId, metadata)
    Kafka-->>RecordingSvc: 20. Event acknowledged
    RecordingSvc-->>API_GW: 21. Response: Recording stopped confirmation
    API_GW-->>ClientApp: 22. Response: Recording stopped confirmation

    ClientApp->>API_GW: 23. Uploads recorded video file (chunked)
    API_GW->>VideoProcessingSvc: 24. Routes upload to dedicated endpoint
    VideoProcessingSvc->>S3_Storage: 25. Stores raw video file
    S3_Storage-->>VideoProcessingSvc: 26. File stored
    VideoProcessingSvc->>Kafka: 27. Publish "raw_video_uploaded" event (sessionId, S3_path)
    Kafka-->>VideoProcessingSvc: 28. Event acknowledged
```

## 2. Video Processing Flow

This diagram shows the asynchronous flow of video processing, triggered by a completed recording.

```mermaid
sequenceDiagram
    participant Kafka as Kafka Event Bus
    participant VideoProcessingSvc as Video Processing Service
    participant S3_Storage as S3 Storage
    participant AI_ML_Svc as AI/ML Service
    participant PostgreSQL as PostgreSQL DB
    participant MongoDB as MongoDB DB
    participant Elasticsearch as Elasticsearch
    participant NotificationSvc as Notification Service

    Kafka->>VideoProcessingSvc: 1. Consume "raw_video_uploaded" event
    VideoProcessingSvc->>PostgreSQL: 2. Create processing_job entry (status: queued)
    PostgreSQL-->>VideoProcessingSvc: 3. Job ID created
    VideoProcessingSvc->>S3_Storage: 4. Retrieve raw video file
    S3_Storage-->>VideoProcessingSvc: 5. Raw video stream
    VideoProcessingSvc->>VideoProcessingSvc: 6. Start parallel transcoding (1080p, 720p, etc.)
    VideoProcessingSvc->>S3_Storage: 7. Store transcoded video profiles
    S3_Storage-->>VideoProcessingSvc: 8. Profiles stored
    VideoProcessingSvc->>VideoProcessingSvc: 9. Generate thumbnails
    VideoProcessingSvc->>S3_Storage: 10. Store thumbnails
    S3_Storage-->>VideoProcessingSvc: 11. Thumbnails stored
    VideoProcessingSvc->>PostgreSQL: 12. Update processing_job status (e.g., transcoding_complete)
    PostgreSQL-->>VideoProcessingSvc: 13. Status updated

    VideoProcessingSvc->>AI_ML_Svc: 14. Request: Transcribe Audio (video_id, audio_stream)
    AI_ML_Svc->>AI_ML_Svc: 15. Perform Speech-to-Text (Whisper model)
    AI_ML_Svc->>PostgreSQL: 16. Store video_transcriptions
    PostgreSQL-->>AI_ML_Svc: 17. Transcriptions stored
    AI_ML_Svc->>Elasticsearch: 18. Index transcription for search
    Elasticsearch-->>AI_ML_Svc: 19. Indexed
    AI_ML_Svc-->>VideoProcessingSvc: 20. Response: Transcription complete

    VideoProcessingSvc->>AI_ML_Svc: 21. Request: Analyze Content (video_id, transcription_text)
    AI_ML_Svc->>AI_ML_Svc: 22. Perform NLP (sentiment, action items, summary)
    AI_ML_Svc->>MongoDB: 23. Store content_analysis results
    MongoDB-->>AI_ML_Svc: 24. Analysis stored
    AI_ML_Svc-->>VideoProcessingSvc: 25. Response: Analysis complete

    VideoProcessingSvc->>PostgreSQL: 26. Update processing_job status (completed)
    PostgreSQL-->>VideoProcessingSvc: 27. Status updated
    VideoProcessingSvc->>Kafka: 28. Publish "video_processed" event (sessionId, processed_urls)
    Kafka-->>VideoProcessingSvc: 29. Event acknowledged

    Kafka->>NotificationSvc: 30. Consume "video_processed" event
    NotificationSvc->>NotificationSvc: 31. Prepare user notification
    NotificationSvc->>User: 32. Send "Your video is ready!" notification
```

## 3. Streaming Flow

This diagram shows how a user requests and streams a video, leveraging the CDN and adaptive bitrate.

```mermaid
sequenceDiagram
    participant User
    participant ClientApp as Client Application<br/>(Web/Mobile Player)
    participant API_GW as API Gateway
    participant StreamingSvc as Streaming Service
    participant CDN_Manager as CDN Manager
    participant CloudFront as AWS CloudFront (Primary CDN)
    participant Cloudflare as Cloudflare (Secondary CDN)
    participant S3_Storage as S3 Storage (Origin)
    participant AnalyticsSvc as Analytics Service
    participant InfluxDB as InfluxDB (Time-series DB)

    User->>ClientApp: 1. Clicks to play video (video_id)
    ClientApp->>API_GW: 2. Request: GET /api/v1/streams/{video_id} (Get Stream URL)
    API_GW->>StreamingSvc: 3. Route Request
    StreamingSvc->>StreamingSvc: 4. Validate user access (permissions, share token)
    StreamingSvc->>CDN_Manager: 5. Request optimal CDN URL (video_id, user_location)
    CDN_Manager->>CDN_Manager: 6. Select optimal CDN based on routing rules (e.g., geographic proximity, load)
    CDN_Manager->>CloudFront: 7. Request Master HLS Playlist (.m3u8)
    CloudFront->>S3_Storage: 8. If not cached, fetch Master Playlist from Origin
    S3_Storage-->>CloudFront: 9. Master Playlist
    CloudFront-->>CDN_Manager: 10. Master Playlist URL
    CDN_Manager-->>StreamingSvc: 11. Response: Stream URLs (Master, Quality Profiles)
    StreamingSvc->>AnalyticsSvc: 12. Track "stream_start" event (video_id, user_id, client_info)
    AnalyticsSvc->>InfluxDB: 13. Store real-time stream metrics
    InfluxDB-->>AnalyticsSvc: 14. Metrics stored
    AnalyticsSvc-->>StreamingSvc: 15. Event acknowledged
    StreamingSvc-->>API_GW: 16. Response: Stream URLs, Quality Options
    API_GW-->>ClientApp: 17. Response: Stream URLs, Quality Options

    ClientApp->>ClientApp: 18. Initializes video player with Master HLS Playlist
    ClientApp->>CloudFront: 19. Requests initial video segment (e.g., 720p segment 1)
    CloudFront->>S3_Storage: 20. If not cached, fetch segment from Origin
    S3_Storage-->>CloudFront: 21. Video Segment
    CloudFront-->>ClientApp: 22. Delivers video segment

    ClientApp->>ClientApp: 23. Monitors buffer and network conditions
    ClientApp->>CloudFront: 24. Requests next segments (adaptive bitrate based on conditions)
    alt Network degrades
        ClientApp->>CloudFront: 25. Requests lower quality segments (e.g., 480p)
    else Network improves
        ClientApp->>CloudFront: 26. Requests higher quality segments (e.g., 1080p)
    end
    ClientApp->>AnalyticsSvc: 27. Periodically sends "stream_progress" events (watch time, quality changes)
    AnalyticsSvc->>InfluxDB: 28. Updates real-time stream metrics
```

---
**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Focus**: Component interaction flows for core operations  
**Review Status**: Ready for review