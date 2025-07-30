-- =====================================================
-- Phase II Database Enhancements
-- Jira-like Project Management System
-- =====================================================

-- This file contains all database schema enhancements for Phase II
-- It extends the Phase I schema with advanced features including:
-- - AI/ML data structures
-- - Advanced analytics tables
-- - Enterprise integration support
-- - Mobile and edge computing data
-- - Enhanced security and audit trails
-- - Real-time processing support
-- - Global infrastructure support

-- =====================================================
-- AI/ML PLATFORM TABLES
-- =====================================================

-- ML Models Registry
CREATE TABLE ml_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    model_type VARCHAR(100) NOT NULL, -- 'classification', 'regression', 'nlp', 'computer_vision'
    framework VARCHAR(50) NOT NULL, -- 'tensorflow', 'pytorch', 'scikit-learn'
    status VARCHAR(50) NOT NULL DEFAULT 'training', -- 'training', 'active', 'deprecated', 'archived'
    accuracy_score DECIMAL(5,4),
    model_path TEXT NOT NULL,
    metadata JSONB,
    training_data_hash VARCHAR(64),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deployed_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(name, version)
);

CREATE INDEX idx_ml_models_type_status ON ml_models(model_type, status);
CREATE INDEX idx_ml_models_created_at ON ml_models(created_at);

-- Feature Store
CREATE TABLE feature_store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_name VARCHAR(255) NOT NULL,
    feature_group VARCHAR(255) NOT NULL,
    data_type VARCHAR(50) NOT NULL, -- 'numeric', 'categorical', 'text', 'boolean'
    description TEXT,
    computation_logic TEXT,
    data_source VARCHAR(255),
    refresh_frequency VARCHAR(50), -- 'real-time', 'hourly', 'daily', 'weekly'
    last_updated TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(feature_name, feature_group)
);

CREATE INDEX idx_feature_store_group ON feature_store(feature_group);
CREATE INDEX idx_feature_store_type ON feature_store(data_type);

-- Feature Values (Time Series)
CREATE TABLE feature_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES feature_store(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL, -- project_id, user_id, issue_id, etc.
    entity_type VARCHAR(50) NOT NULL,
    feature_value JSONB NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX(feature_id, entity_id, timestamp)
);

-- Partition feature_values by timestamp for better performance
SELECT create_hypertable('feature_values', 'timestamp', if_not_exists => TRUE);

-- ML Predictions
CREATE TABLE ml_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID REFERENCES ml_models(id),
    prediction_type VARCHAR(100) NOT NULL, -- 'project_success', 'resource_demand', 'issue_priority'
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    input_features JSONB NOT NULL,
    prediction_result JSONB NOT NULL,
    confidence_score DECIMAL(5,4),
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_ml_predictions_type_entity ON ml_predictions(prediction_type, entity_id);
CREATE INDEX idx_ml_predictions_created_at ON ml_predictions(created_at);
CREATE INDEX idx_ml_predictions_expires_at ON ml_predictions(expires_at);

-- Model Training Jobs
CREATE TABLE ml_training_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID REFERENCES ml_models(id),
    job_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'queued', -- 'queued', 'running', 'completed', 'failed'
    training_config JSONB NOT NULL,
    training_data_query TEXT,
    metrics JSONB,
    logs TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ml_training_jobs_status ON ml_training_jobs(status);
CREATE INDEX idx_ml_training_jobs_model_id ON ml_training_jobs(model_id);

-- =====================================================
-- ADVANCED ANALYTICS TABLES
-- =====================================================

-- Real-time Metrics
CREATE TABLE real_time_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name VARCHAR(255) NOT NULL,
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'project', 'user', 'team', 'organization'
    metric_value DECIMAL(15,4) NOT NULL,
    metric_unit VARCHAR(50),
    dimensions JSONB, -- Additional dimensions for grouping/filtering
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX(metric_name, entity_id, timestamp),
    INDEX(entity_type, timestamp)
);

-- Partition for time-series data
SELECT create_hypertable('real_time_metrics', 'timestamp', if_not_exists => TRUE);

-- Analytics Dashboards
CREATE TABLE analytics_dashboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    dashboard_config JSONB NOT NULL,
    owner_id UUID REFERENCES users(id),
    visibility VARCHAR(50) NOT NULL DEFAULT 'private', -- 'private', 'team', 'organization', 'public'
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analytics_dashboards_owner ON analytics_dashboards(owner_id);
CREATE INDEX idx_analytics_dashboards_visibility ON analytics_dashboards(visibility);

-- Dashboard Widgets
CREATE TABLE dashboard_widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dashboard_id UUID REFERENCES analytics_dashboards(id) ON DELETE CASCADE,
    widget_type VARCHAR(100) NOT NULL, -- 'chart', 'table', 'metric', 'text'
    widget_config JSONB NOT NULL,
    position_x INTEGER NOT NULL,
    position_y INTEGER NOT NULL,
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dashboard_widgets_dashboard ON dashboard_widgets(dashboard_id);

-- Predictive Analytics Results
CREATE TABLE predictive_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_type VARCHAR(100) NOT NULL, -- 'timeline_forecast', 'resource_demand', 'risk_assessment'
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    input_parameters JSONB NOT NULL,
    prediction_results JSONB NOT NULL,
    confidence_metrics JSONB,
    scenario_data JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_predictive_analytics_type_entity ON predictive_analytics(analysis_type, entity_id);
CREATE INDEX idx_predictive_analytics_created_at ON predictive_analytics(created_at);

-- =====================================================
-- ENTERPRISE INTEGRATION TABLES
-- =====================================================

-- SSO Configurations
CREATE TABLE sso_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    provider_type VARCHAR(50) NOT NULL, -- 'saml', 'oauth', 'oidc', 'ldap'
    provider_name VARCHAR(255) NOT NULL,
    configuration JSONB NOT NULL,
    attribute_mapping JSONB,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sso_configurations_org ON sso_configurations(organization_id);
CREATE INDEX idx_sso_configurations_active ON sso_configurations(is_active);

-- External System Integrations
CREATE TABLE external_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    integration_type VARCHAR(100) NOT NULL, -- 'jira_cloud', 'github', 'slack', 'teams'
    integration_name VARCHAR(255) NOT NULL,
    configuration JSONB NOT NULL,
    field_mappings JSONB,
    sync_settings JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'paused', 'error', 'disabled'
    last_sync_at TIMESTAMP WITH TIME ZONE,
    next_sync_at TIMESTAMP WITH TIME ZONE,
    error_details TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_external_integrations_org ON external_integrations(organization_id);
CREATE INDEX idx_external_integrations_type ON external_integrations(integration_type);
CREATE INDEX idx_external_integrations_status ON external_integrations(status);

-- Integration Sync Logs
CREATE TABLE integration_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    integration_id UUID REFERENCES external_integrations(id) ON DELETE CASCADE,
    sync_type VARCHAR(50) NOT NULL, -- 'full', 'incremental', 'manual'
    status VARCHAR(50) NOT NULL, -- 'started', 'completed', 'failed', 'partial'
    records_processed INTEGER DEFAULT 0,
    records_created INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    error_details TEXT,
    sync_duration_ms INTEGER,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_integration_sync_logs_integration ON integration_sync_logs(integration_id);
CREATE INDEX idx_integration_sync_logs_started_at ON integration_sync_logs(started_at);

-- Webhook Configurations
CREATE TABLE webhook_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    events TEXT[] NOT NULL,
    filters JSONB,
    headers JSONB,
    secret_token VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT true,
    retry_config JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_webhook_configurations_org ON webhook_configurations(organization_id);
CREATE INDEX idx_webhook_configurations_active ON webhook_configurations(is_active);

-- Webhook Delivery Logs
CREATE TABLE webhook_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    webhook_id UUID REFERENCES webhook_configurations(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    response_headers JSONB,
    delivery_attempts INTEGER DEFAULT 1,
    delivered_at TIMESTAMP WITH TIME ZONE,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_webhook_deliveries_webhook ON webhook_deliveries(webhook_id);
CREATE INDEX idx_webhook_deliveries_created_at ON webhook_deliveries(created_at);
CREATE INDEX idx_webhook_deliveries_next_retry ON webhook_deliveries(next_retry_at) WHERE next_retry_at IS NOT NULL;

-- =====================================================
-- MOBILE AND EDGE COMPUTING TABLES
-- =====================================================

-- Mobile Devices
CREATE TABLE mobile_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    platform VARCHAR(50) NOT NULL, -- 'ios', 'android', 'web'
    platform_version VARCHAR(50),
    app_version VARCHAR(50),
    push_token TEXT,
    device_info JSONB,
    last_active_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(device_id)
);

CREATE INDEX idx_mobile_devices_user ON mobile_devices(user_id);
CREATE INDEX idx_mobile_devices_active ON mobile_devices(is_active);
CREATE INDEX idx_mobile_devices_platform ON mobile_devices(platform);

-- Mobile Sync Sessions
CREATE TABLE mobile_sync_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID REFERENCES mobile_devices(id) ON DELETE CASCADE,
    sync_type VARCHAR(50) NOT NULL, -- 'full', 'incremental', 'upload'
    status VARCHAR(50) NOT NULL DEFAULT 'started', -- 'started', 'completed', 'failed'
    entities_synced TEXT[],
    records_downloaded INTEGER DEFAULT 0,
    records_uploaded INTEGER DEFAULT 0,
    data_size_bytes BIGINT DEFAULT 0,
    sync_token VARCHAR(255),
    error_details TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_mobile_sync_sessions_device ON mobile_sync_sessions(device_id);
CREATE INDEX idx_mobile_sync_sessions_started_at ON mobile_sync_sessions(started_at);

-- Offline Data Cache
CREATE TABLE offline_data_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID REFERENCES mobile_devices(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    data_snapshot JSONB NOT NULL,
    version_hash VARCHAR(64) NOT NULL,
    cached_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(device_id, entity_type, entity_id)
);

CREATE INDEX idx_offline_data_cache_device ON offline_data_cache(device_id);
CREATE INDEX idx_offline_data_cache_expires_at ON offline_data_cache(expires_at);

-- Edge Nodes
CREATE TABLE edge_nodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_id VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    location JSONB NOT NULL, -- region, datacenter, coordinates
    capabilities JSONB NOT NULL, -- cpu, memory, storage, gpu
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'maintenance'
    health_score DECIMAL(3,2),
    last_heartbeat TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_edge_nodes_status ON edge_nodes(status);
CREATE INDEX idx_edge_nodes_location ON edge_nodes USING GIN(location);

-- Edge Data Sync
CREATE TABLE edge_data_sync (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    edge_node_id UUID REFERENCES edge_nodes(id) ON DELETE CASCADE,
    sync_type VARCHAR(50) NOT NULL, -- 'push', 'pull', 'bidirectional'
    data_types TEXT[] NOT NULL,
    sync_strategy VARCHAR(50) NOT NULL, -- 'full', 'incremental', 'delta'
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    records_synced INTEGER DEFAULT 0,
    data_size_bytes BIGINT DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    error_details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_edge_data_sync_node ON edge_data_sync(edge_node_id);
CREATE INDEX idx_edge_data_sync_status ON edge_data_sync(status);

-- =====================================================
-- ADVANCED SECURITY TABLES
-- =====================================================

-- Security Events
CREATE TABLE security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(100) NOT NULL, -- 'login_attempt', 'suspicious_activity', 'data_access'
    severity VARCHAR(50) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    user_id UUID REFERENCES users(id),
    source_ip INET,
    user_agent TEXT,
    location JSONB,
    event_details JSONB NOT NULL,
    risk_score DECIMAL(3,2),
    status VARCHAR(50) NOT NULL DEFAULT 'open', -- 'open', 'investigating', 'resolved', 'false_positive'
    assigned_to UUID REFERENCES users(id),
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_security_events_type ON security_events(event_type);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_security_events_user ON security_events(user_id);
CREATE INDEX idx_security_events_created_at ON security_events(created_at);
CREATE INDEX idx_security_events_status ON security_events(status);

-- Risk Assessments
CREATE TABLE risk_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'project', 'organization'
    entity_id UUID NOT NULL,
    assessment_type VARCHAR(100) NOT NULL, -- 'user_behavior', 'data_access', 'project_security'
    risk_score DECIMAL(3,2) NOT NULL,
    risk_level VARCHAR(50) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    risk_factors JSONB NOT NULL,
    recommendations JSONB,
    assessed_by VARCHAR(50) NOT NULL, -- 'system', 'manual', 'ml_model'
    model_version VARCHAR(50),
    valid_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_risk_assessments_entity ON risk_assessments(entity_type, entity_id);
CREATE INDEX idx_risk_assessments_level ON risk_assessments(risk_level);
CREATE INDEX idx_risk_assessments_created_at ON risk_assessments(created_at);

-- Data Loss Prevention Scans
CREATE TABLE dlp_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(100) NOT NULL, -- 'comment', 'attachment', 'description'
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    scan_results JSONB NOT NULL,
    violations_found INTEGER DEFAULT 0,
    risk_level VARCHAR(50), -- 'low', 'medium', 'high', 'critical'
    action_taken VARCHAR(100), -- 'allowed', 'blocked', 'redacted', 'quarantined'
    sanitized_content TEXT,
    scanned_by VARCHAR(50) NOT NULL DEFAULT 'system',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dlp_scans_entity ON dlp_scans(entity_type, entity_id);
CREATE INDEX idx_dlp_scans_risk_level ON dlp_scans(risk_level);
CREATE INDEX idx_dlp_scans_created_at ON dlp_scans(created_at);

-- Authentication Sessions (Enhanced)
CREATE TABLE authentication_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info JSONB,
    ip_address INET,
    location JSONB,
    user_agent TEXT,
    authentication_method VARCHAR(50) NOT NULL, -- 'password', 'sso', 'mfa', 'api_key'
    risk_score DECIMAL(3,2),
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_auth_sessions_user ON authentication_sessions(user_id);
CREATE INDEX idx_auth_sessions_token ON authentication_sessions(session_token);
CREATE INDEX idx_auth_sessions_active ON authentication_sessions(is_active);
CREATE INDEX idx_auth_sessions_expires_at ON authentication_sessions(expires_at);

-- =====================================================
-- REAL-TIME PROCESSING TABLES
-- =====================================================

-- Event Streams
CREATE TABLE event_streams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id VARCHAR(255) NOT NULL UNIQUE,
    event_type VARCHAR(100) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    source_service VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    correlation_id UUID,
    causation_id UUID,
    user_id UUID REFERENCES users(id),
    organization_id UUID REFERENCES organizations(id),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    INDEX(event_type, timestamp),
    INDEX(topic, timestamp),
    INDEX(correlation_id),
    INDEX(organization_id, timestamp)
);

-- Partition by timestamp for better performance
SELECT create_hypertable('event_streams', 'timestamp', if_not_exists => TRUE);

-- Event Subscriptions
CREATE TABLE event_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_name VARCHAR(255) NOT NULL,
    subscriber_type VARCHAR(50) NOT NULL, -- 'webhook', 'email', 'slack', 'internal'
    subscriber_config JSONB NOT NULL,
    event_filters JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_event_subscriptions_active ON event_subscriptions(is_active);
CREATE INDEX idx_event_subscriptions_type ON event_subscriptions(subscriber_type);

-- Complex Event Processing Patterns
CREATE TABLE cep_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pattern_name VARCHAR(255) NOT NULL,
    description TEXT,
    pattern_definition JSONB NOT NULL,
    actions JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cep_patterns_active ON cep_patterns(is_active);
CREATE INDEX idx_cep_patterns_name ON cep_patterns(pattern_name);

-- Pattern Matches
CREATE TABLE pattern_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pattern_id UUID REFERENCES cep_patterns(id) ON DELETE CASCADE,
    matched_events UUID[] NOT NULL,
    match_data JSONB NOT NULL,
    actions_triggered JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pattern_matches_pattern ON pattern_matches(pattern_id);
CREATE INDEX idx_pattern_matches_created_at ON pattern_matches(created_at);

-- =====================================================
-- GLOBAL INFRASTRUCTURE TABLES
-- =====================================================

-- Regions
CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_code VARCHAR(50) NOT NULL UNIQUE,
    region_name VARCHAR(255) NOT NULL,
    cloud_provider VARCHAR(50) NOT NULL, -- 'aws', 'azure', 'gcp'
    is_primary BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'maintenance', 'degraded', 'offline'
    capabilities JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_regions_status ON regions(status);
CREATE INDEX idx_regions_primary ON regions(is_primary);

-- Region Health Metrics
CREATE TABLE region_health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id UUID REFERENCES regions(id) ON DELETE CASCADE,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4) NOT NULL,
    metric_unit VARCHAR(50),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX(region_id, metric_name, timestamp)
);

SELECT create_hypertable('region_health_metrics', 'timestamp', if_not_exists => TRUE);

-- Data Replication Status
CREATE TABLE data_replication_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_region_id UUID REFERENCES regions(id),
    target_region_id UUID REFERENCES regions(id),
    database_name VARCHAR(255) NOT NULL,
    replication_type VARCHAR(50) NOT NULL, -- 'streaming', 'logical', 'physical'
    status VARCHAR(50) NOT NULL, -- 'healthy', 'lagging', 'broken', 'paused'
    lag_seconds INTEGER,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    error_details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_data_replication_source ON data_replication_status(source_region_id);
CREATE INDEX idx_data_replication_target ON data_replication_status(target_region_id);
CREATE INDEX idx_data_replication_status ON data_replication_status(status);

-- Failover Events
CREATE TABLE failover_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL, -- 'initiated', 'completed', 'failed', 'rolled_back'
    from_region_id UUID REFERENCES regions(id),
    to_region_id UUID REFERENCES regions(id),
    services_affected TEXT[],
    reason TEXT,
    initiated_by VARCHAR(100), -- 'automatic', 'manual', 'user_id'
    duration_seconds INTEGER,
    impact_assessment JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_failover_events_type ON failover_events(event_type);
CREATE INDEX idx_failover_events_created_at ON failover_events(created_at);

-- =====================================================
-- ENHANCED CORE TABLES EXTENSIONS
-- =====================================================

-- User Behavior Analytics
CREATE TABLE user_behavior_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    behavior_type VARCHAR(100) NOT NULL, -- 'activity_pattern', 'productivity', 'collaboration'
    metrics JSONB NOT NULL,
    insights JSONB,
    recommendations JSONB,
    date_analyzed DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, behavior_type, date_analyzed)
);

CREATE INDEX idx_user_behavior_analytics_user ON user_behavior_analytics(user_id);
CREATE INDEX idx_user_behavior_analytics_type ON user_behavior_analytics(behavior_type);
CREATE INDEX idx_user_behavior_analytics_date ON user_behavior_analytics(date_analyzed);

-- Project Health Assessments
CREATE TABLE project_health_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    health_score DECIMAL(3,2) NOT NULL,
    health_level VARCHAR(50) NOT NULL, -- 'excellent', 'good', 'fair', 'poor', 'critical'
    assessment_details JSONB NOT NULL,
    recommendations JSONB,
    assessed_by VARCHAR(50) NOT NULL DEFAULT 'system',
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_health_project ON project_health_assessments(project_id);
CREATE INDEX idx_project_health_level ON project_health_assessments(health_level);
CREATE INDEX idx_project_health_created_at ON project_health_assessments(created_at);

-- Issue Intelligence
CREATE TABLE issue_intelligence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    classification JSONB,
    effort_estimation JSONB,
    similar_issues UUID[],
    resolution_suggestions JSONB,
    sentiment_analysis JSONB,
    ai_insights JSONB,
    confidence_scores JSONB,
    model_versions JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_issue_intelligence_issue ON issue_intelligence(issue_id);
CREATE INDEX idx_issue_intelligence_created_at ON issue_intelligence(created_at);

-- =====================================================
-- MONITORING AND OBSERVABILITY TABLES
-- =====================================================

-- System Metrics
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name VARCHAR(255) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    instance_id VARCHAR(255),
    metric_value DECIMAL(15,4) NOT NULL,
    metric_unit VARCHAR(50),
    tags JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX(metric_name, service_name, timestamp),
    INDEX(service_name, timestamp)
);

SELECT create_hypertable('system_metrics', 'timestamp', if_not_exists => TRUE);

-- Alert Rules
CREATE TABLE alert_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(255) NOT NULL,
    description TEXT,
    metric_query TEXT NOT NULL,
    condition_operator VARCHAR(10) NOT NULL, -- '>', '<', '>=', '<=', '==', '!='
    threshold_value DECIMAL(15,4) NOT NULL,
    evaluation_duration VARCHAR(50) NOT NULL, -- '1m', '5m', '15m', etc.
    severity VARCHAR(50) NOT NULL, -- 'info', 'warning', 'critical'
    actions JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alert_rules_active ON alert_rules(is_active);
CREATE INDEX idx_alert_rules_severity ON alert_rules(severity);

-- Alert Instances
CREATE TABLE alert_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_id UUID REFERENCES alert_rules(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'firing', -- 'firing', 'resolved'
    current_value DECIMAL(15,4) NOT NULL,
    threshold_value DECIMAL(15,4) NOT NULL,
    evaluation_data JSONB,
    labels JSONB,
    annotations JSONB,
    fired_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_alert_instances_rule ON alert_instances(rule_id);
CREATE INDEX idx_alert_instances_status ON alert_instances(status);
CREATE INDEX idx_alert_instances_fired_at ON alert_instances(fired_at);

-- Distributed Traces
CREATE TABLE distributed_traces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id VARCHAR(255) NOT NULL,
    span_id VARCHAR(255) NOT NULL,
    parent_span_id VARCHAR(255),
    operation_name VARCHAR(255) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_microseconds BIGINT NOT NULL,
    status VARCHAR(50), -- 'ok', 'error', 'timeout'
    tags JSONB,
    logs JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(trace_id, span_id)
);

CREATE INDEX idx_distributed_traces_trace_id ON distributed_traces(trace_id);
CREATE INDEX idx_distributed_traces_service ON distributed_traces(service_name);
CREATE INDEX idx_distributed_traces_operation ON distributed_traces(operation_name);
CREATE INDEX idx_distributed_traces_start_time ON distributed_traces(start_time);
CREATE INDEX idx_distributed_traces_duration ON distributed_traces(duration_microseconds);

-- =====================================================
-- NOTIFICATION AND COMMUNICATION TABLES
-- =====================================================

-- Enhanced Notifications
CREATE TABLE enhanced_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    priority VARCHAR(50) NOT NULL DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    category VARCHAR(100), -- 'issue', 'project', 'system', 'security'
    entity_id UUID,
    entity_type VARCHAR(50),
    metadata JSONB,
    delivery_channels TEXT[], -- 'in_app', 'email', 'push', 'sms', 'slack'
    delivery_status JSONB,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_enhanced_notifications_user ON enhanced_notifications(user_id);
CREATE INDEX idx_enhanced_notifications_type ON enhanced_notifications(notification_type);
CREATE INDEX idx_enhanced_notifications_priority ON enhanced_notifications(priority);
CREATE INDEX idx_enhanced_notifications_read ON enhanced_notifications(is_read);
CREATE INDEX idx_enhanced_notifications_created_at ON enhanced_notifications(created_at);

-- Notification Preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(100) NOT NULL,
    channels JSONB NOT NULL, -- enabled channels and their settings
    frequency VARCHAR(50) NOT NULL DEFAULT 'immediate', -- 'immediate', 'hourly', 'daily', 'weekly', 'disabled'
    quiet_hours JSONB, -- start_time, end_time, timezone
    filters JSONB, -- priority, category, project filters
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, notification_type)
);

CREATE INDEX idx_notification_preferences_user ON notification_preferences(user_id);

-- Communication Channels
CREATE TABLE communication_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    channel_type VARCHAR(50) NOT NULL, -- 'slack', 'teams', 'discord', 'email'
    channel_name VARCHAR(255) NOT NULL,
    configuration JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_communication_channels_org ON communication_channels(organization_id);
CREATE INDEX idx_communication_channels_type ON communication_channels(channel_type);
CREATE INDEX idx_communication_channels_active ON communication_channels(is_active);

-- =====================================================
-- COLLABORATION AND SOCIAL FEATURES
-- =====================================================

-- User Mentions
CREATE TABLE user_mentions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentioned_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    mentioned_by_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL, -- 'comment', 'description', 'message'
    entity_id UUID NOT NULL,
    context TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_mentions_mentioned_user ON user_mentions(mentioned_user_id);
CREATE INDEX idx_user_mentions_entity ON user_mentions(entity_type, entity_id);
CREATE INDEX idx_user_mentions_read ON user_mentions(is_read);

-- User Reactions
CREATE TABLE user_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL, -- 'comment', 'issue', 'project'
    entity_id UUID NOT NULL,
    reaction_type VARCHAR(50) NOT NULL, -- 'like', 'love', 'laugh', 'angry', 'sad'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, entity_type, entity_id, reaction_type)
);

CREATE INDEX idx_user_reactions_entity ON user_reactions(entity_type, entity_id);
CREATE INDEX idx_user_reactions_user ON user_reactions(user_id);

-- Team Collaboration Metrics
CREATE TABLE team_collaboration_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    metric_type VARCHAR(100) NOT NULL, -- 'communication_frequency', 'response_time', 'collaboration_score'
    metric_value DECIMAL(10,4) NOT NULL,
    metric_details JSONB,
    date_calculated DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(team_id, metric_type, date_calculated)
);

CREATE INDEX idx_team_collaboration_metrics_team ON team_collaboration_metrics(team_id);
CREATE INDEX idx_team_collaboration_metrics_type ON team_collaboration_metrics(metric_type);
CREATE INDEX idx_team_collaboration_metrics_date ON team_collaboration_metrics(date_calculated);

-- =====================================================
-- ADVANCED SEARCH AND INDEXING
-- =====================================================

-- Search Index
CREATE TABLE search_index (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    title TEXT,
    content TEXT,
    metadata JSONB,
    tags TEXT[],
    search_vector tsvector,
    organization_id UUID REFERENCES organizations(id),
    project_id UUID REFERENCES projects(id),
    visibility VARCHAR(50) NOT NULL DEFAULT 'private', -- 'private', 'team', 'organization', 'public'
    indexed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(entity_type, entity_id)
);

CREATE INDEX idx_search_index_entity ON search_index(entity_type, entity_id);
CREATE INDEX idx_search_index_org ON search_index(organization_id);
CREATE INDEX idx_search_index_project ON search_index(project_id);
CREATE INDEX idx_search_index_visibility ON search_index(visibility);
CREATE INDEX idx_search_index_tags ON search_index USING GIN(tags);
CREATE INDEX idx_search_index_vector ON search_index USING GIN(search_vector);

-- Search Analytics
CREATE TABLE search_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    search_query TEXT NOT NULL,
    search_filters JSONB,
    results_count INTEGER NOT NULL,
    clicked_results UUID[],
    search_duration_ms INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_analytics_user ON search_analytics(user_id);
CREATE INDEX idx_search_analytics_timestamp ON search_analytics(timestamp);

-- =====================================================
-- PERFORMANCE OPTIMIZATION TABLES
-- =====================================================

-- Query Performance Logs
CREATE TABLE query_performance_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query_hash VARCHAR(64) NOT NULL,
    query_text TEXT,
    execution_time_ms INTEGER NOT NULL,
    rows_examined BIGINT,
    rows_returned BIGINT,
    index_usage JSONB,
    execution_plan JSONB,
    database_name VARCHAR(255),
    user_id UUID REFERENCES users(id),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_query_performance_hash ON query_performance_logs(query_hash);
CREATE INDEX idx_query_performance_time ON query_performance_logs(execution_time_ms);
CREATE INDEX idx_query_performance_timestamp ON query_performance_logs(timestamp);

-- Cache Statistics
CREATE TABLE cache_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cache_name VARCHAR(255) NOT NULL,
    cache_type VARCHAR(50) NOT NULL, -- 'redis', 'memcached', 'application'
    hit_count BIGINT NOT NULL DEFAULT 0,
    miss_count BIGINT NOT NULL DEFAULT 0,
    eviction_count BIGINT NOT NULL DEFAULT 0,
    memory_usage_bytes BIGINT,
    key_count INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cache_statistics_name ON cache_statistics(cache_name);
CREATE INDEX idx_cache_statistics_timestamp ON cache_statistics(timestamp);

-- =====================================================
-- DATA ARCHIVAL AND RETENTION
-- =====================================================

-- Data Retention Policies
CREATE TABLE data_retention_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(255) NOT NULL,
    retention_period INTERVAL NOT NULL,
    archive_before_delete BOOLEAN NOT NULL DEFAULT true,
    archive_location TEXT,
    policy_conditions JSONB,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_data_retention_policies_table ON data_retention_policies(table_name);
CREATE INDEX idx_data_retention_policies_active ON data_retention_policies(is_active);

-- Archive Jobs
CREATE TABLE archive_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID REFERENCES data_retention_policies(id),
    table_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
    records_processed INTEGER DEFAULT 0,
    records_archived INTEGER DEFAULT 0,
    records_deleted INTEGER DEFAULT 0,
    archive_location TEXT,
    error_details TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_archive_jobs_policy ON archive_jobs(policy_id);
CREATE INDEX idx_archive_jobs_status ON archive_jobs(status);
CREATE INDEX idx_archive_jobs_created_at ON archive_jobs(created_at);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update search vector
CREATE OR REPLACE FUNCTION update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('english',
        COALESCE(NEW.title, '') || ' ' ||
        COALESCE(NEW.content, '') || ' ' ||
        COALESCE(array_to_string(NEW.tags, ' '), '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for search index
CREATE TRIGGER search_index_vector_update
    BEFORE INSERT OR UPDATE ON search_index
    FOR EACH ROW
    EXECUTE FUNCTION update_search_vector();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_ml_models_updated_at BEFORE UPDATE ON ml_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_analytics_dashboards_updated_at BEFORE UPDATE ON analytics_dashboards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dashboard_widgets_updated_at BEFORE UPDATE ON dashboard_widgets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sso_configurations_updated_at BEFORE UPDATE ON sso_configurations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_external_integrations_updated_at BEFORE UPDATE ON external_integrations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_webhook_configurations_updated_at BEFORE UPDATE ON webhook_configurations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_mobile_devices_updated_at BEFORE UPDATE ON mobile_devices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_edge_nodes_updated_at BEFORE UPDATE ON edge_nodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_regions_updated_at BEFORE UPDATE ON regions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_data_replication_status_updated_at BEFORE UPDATE ON data_replication_status FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_issue_intelligence_updated_at BEFORE UPDATE ON issue_intelligence FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_alert_rules_updated_at BEFORE UPDATE ON alert_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_communication_channels_updated_at BEFORE UPDATE ON communication_channels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_data_retention_policies_updated_at BEFORE UPDATE ON data_retention_policies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function for automatic data archival
CREATE OR REPLACE FUNCTION schedule_data_archival()
RETURNS void AS $$
DECLARE
    policy_record RECORD;
    cutoff_date TIMESTAMP WITH TIME ZONE;
BEGIN
    FOR policy_record IN
        SELECT * FROM data_retention_policies WHERE is_active = true
    LOOP
        cutoff_date := CURRENT_TIMESTAMP - policy_record.retention_period;
        
        INSERT INTO archive_jobs (policy_id, table_name, status)
        VALUES (policy_record.id, policy_record.table_name, 'pending');
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate project health score
CREATE OR REPLACE FUNCTION calculate_project_health_score(project_uuid UUID)
RETURNS DECIMAL(3,2) AS $$
DECLARE
    health_score DECIMAL(3,2) := 0.0;
    timeline_score DECIMAL(3,2) := 0.0;
    budget_score DECIMAL(3,2) := 0.0;
    quality_score DECIMAL(3,2) := 0.0;
    team_score DECIMAL(3,2) := 0.0;
BEGIN
    -- Calculate timeline score (25% weight)
    -- Implementation would analyze project timeline vs actual progress
    timeline_score := 0.85;
    
    -- Calculate budget score (25% weight)
    -- Implementation would analyze budget utilization
    budget_score := 0.72;
    
    -- Calculate quality score (25% weight)
    -- Implementation would analyze bug rates, test coverage, etc.
    quality_score := 0.88;
    
    -- Calculate team score (25% weight)
    -- Implementation would analyze team velocity, satisfaction, etc.
    team_score := 0.75;
    
    health_score := (timeline_score * 0.25) + (budget_score * 0.25) +
                   (quality_score * 0.25) + (team_score * 0.25);
    
    RETURN health_score;
END;
$$ LANGUAGE plpgsql;

-- Function to generate AI insights for issues
CREATE OR REPLACE FUNCTION generate_issue_insights(issue_uuid UUID)
RETURNS JSONB AS $$
DECLARE
    insights JSONB := '{}';
    similar_issues UUID[];
    effort_estimate JSONB;
BEGIN
    -- Find similar issues based on title and description similarity
    -- This is a simplified version - actual implementation would use ML models
    SELECT ARRAY(
        SELECT id FROM issues
        WHERE id != issue_uuid
        AND similarity(title, (SELECT title FROM issues WHERE id = issue_uuid)) > 0.3
        LIMIT 5
    ) INTO similar_issues;
    
    -- Generate effort estimate based on historical data
    effort_estimate := jsonb_build_object(
        'story_points', 5,
        'hours', 8,
        'confidence', 0.76
    );
    
    insights := jsonb_build_object(
        'similar_issues', to_jsonb(similar_issues),
        'effort_estimate', effort_estimate,
        'generated_at', CURRENT_TIMESTAMP
    );
    
    RETURN insights;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Project Health Dashboard View
CREATE VIEW project_health_dashboard AS
SELECT
    p.id,
    p.name,
    p.status,
    pha.health_score,
    pha.health_level,
    pha.assessment_details,
    pha.created_at as last_assessed
FROM projects p
LEFT JOIN LATERAL (
    SELECT * FROM project_health_assessments
    WHERE project_id = p.id
    ORDER BY created_at DESC
    LIMIT 1
) pha ON true;

-- User Activity Summary View
CREATE VIEW user_activity_summary AS
SELECT
    u.id,
    u.email,
    u.name,
    uba.metrics as activity_metrics,
    uba.date_analyzed as last_analyzed
FROM users u
LEFT JOIN LATERAL (
    SELECT * FROM user_behavior_analytics
    WHERE user_id = u.id
    AND behavior_type = 'activity_pattern'
    ORDER BY date_analyzed DESC
    LIMIT 1
) uba ON true;

-- Real-time Metrics Summary View
CREATE VIEW real_time_metrics_summary AS
SELECT
    entity_type,
    entity_id,
    metric_name,
    AVG(metric_value) as avg_value,
    MAX(metric_value) as max_value,
    MIN(metric_value) as min_value,
    COUNT(*) as data_points,
    MAX(timestamp) as last_updated
FROM real_time_metrics
WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
GROUP BY entity_type, entity_id, metric_name;

-- Security Events Summary View
CREATE VIEW security_events_summary AS
SELECT
    event_type,
    severity,
    COUNT(*) as event_count,
    AVG(risk_score) as avg_risk_score,
    COUNT(*) FILTER (WHERE status = 'open') as open_events,
    MAX(created_at) as latest_event
FROM security_events
WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY event_type, severity;

-- =====================================================
-- MATERIALIZED VIEWS FOR PERFORMANCE
-- =====================================================

-- Daily Project Metrics (Materialized View)
CREATE MATERIALIZED VIEW daily_project_metrics AS
SELECT
    project_id,
    DATE(timestamp) as metric_date,
    metric_name,
    AVG(metric_value) as avg_value,
    MAX(metric_value) as max_value,
    MIN(metric_value) as min_value,
    COUNT(*) as data_points
FROM real_time_metrics
WHERE entity_type = 'project'
GROUP BY project_id, DATE(timestamp), metric_name;

CREATE UNIQUE INDEX idx_daily_project_metrics_unique
ON daily_project_metrics(project_id, metric_date, metric_name);

-- Weekly Team Performance (Materialized View)
CREATE MATERIALIZED VIEW weekly_team_performance AS
SELECT
    team_id,
    DATE_TRUNC('week', date_calculated) as week_start,
    metric_type,
    AVG(metric_value) as avg_value,
    COUNT(*) as data_points
FROM team_collaboration_metrics
GROUP BY team_id, DATE_TRUNC('week', date_calculated), metric_type;

CREATE UNIQUE INDEX idx_weekly_team_performance_unique
ON weekly_team_performance(team_id, week_start, metric_type);

-- =====================================================
-- CLEANUP AND MAINTENANCE PROCEDURES
-- =====================================================

-- Procedure to refresh materialized views
CREATE OR REPLACE FUNCTION refresh_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY daily_project_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_team_performance;
END;
$$ LANGUAGE plpgsql;

-- Procedure to clean up expired data
CREATE OR REPLACE FUNCTION cleanup_expired_data()
RETURNS void AS $$
BEGIN
    -- Clean up expired predictions
    DELETE FROM ml_predictions WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Clean up old sync sessions
    DELETE FROM mobile_sync_sessions
    WHERE completed_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Clean up old webhook deliveries
    DELETE FROM webhook_deliveries
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
    
    -- Clean up resolved security events older than 1 year
    DELETE FROM security_events
    WHERE status = 'resolved'
    AND resolved_at < CURRENT_TIMESTAMP - INTERVAL '1 year';
    
    -- Clean up old search analytics
    DELETE FROM search_analytics
    WHERE timestamp < CURRENT_TIMESTAMP - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- INITIAL DATA AND CONFIGURATION
-- =====================================================

-- Insert default ML models
INSERT INTO ml_models (name, version, model_type, framework, status, metadata) VALUES
('project_success_predictor', '1.0.0', 'classification', 'tensorflow', 'active', '{"description": "Predicts project success probability"}'),
('issue_priority_classifier', '1.0.0', 'classification', 'scikit-learn', 'active', '{"description": "Classifies issue priority automatically"}'),
('resource_demand_forecaster', '1.0.0', 'regression', 'tensorflow', 'active', '{"description": "Forecasts resource demand"}'),
('sentiment_analyzer', '1.0.0', 'nlp', 'pytorch', 'active', '{"description": "Analyzes sentiment in comments and descriptions"}');

-- Insert default feature store entries
INSERT INTO feature_store (feature_name, feature_group, data_type, description, refresh_frequency) VALUES
('team_size', 'project_features', 'numeric', 'Number of team members in project', 'daily'),
('project_duration_days', 'project_features', 'numeric', 'Project duration in days', 'daily'),
('complexity_score', 'project_features', 'numeric', 'Project complexity score (1-10)', 'daily'),
('team_experience_avg', 'project_features', 'numeric', 'Average team experience in years', 'daily'),
('requirements_stability', 'project_features', 'numeric', 'Requirements stability score (0-1)', 'daily'),
('stakeholder_engagement', 'project_features', 'numeric', 'Stakeholder engagement score (0-1)', 'daily');

-- Insert default regions
INSERT INTO regions (region_code, region_name, cloud_provider, is_primary, status) VALUES
('us-east-1', 'US East (Virginia)', 'aws', true, 'active'),
('eu-west-1', 'EU West (Ireland)', 'aws', false, 'active'),
('ap-southeast-1', 'Asia Pacific (Singapore)', 'aws', false, 'active'),
('us-central1', 'US Central', 'gcp', false, 'active'),
('europe-west1', 'Europe West', 'gcp', false, 'active');

-- Insert default data retention policies
INSERT INTO data_retention_policies (table_name, retention_period, archive_before_delete, is_active, created_by) VALUES
('event_streams', '2 years', true, true, (SELECT id FROM users WHERE email = 'system@jira-platform.com' LIMIT 1)),
('real_time_metrics', '1 year', true, true, (SELECT id FROM users WHERE email = 'system@jira-platform.com' LIMIT 1)),
('system_metrics', '6 months', true, true, (SELECT id FROM users WHERE email = 'system@jira-platform.com' LIMIT 1)),
('distributed_traces', '30 days', false, true, (SELECT id FROM users WHERE email = 'system@jira-platform.com' LIMIT 1)),
('webhook_deliveries', '90 days', false, true, (SELECT id FROM users WHERE email = 'system@jira-platform.com' LIMIT 1));

-- =====================================================
-- PERFORMANCE OPTIMIZATION INDEXES
-- =====================================================

-- Additional composite indexes for common query patterns
CREATE INDEX idx_ml_predictions_entity_type_created ON ml_predictions(entity_type, entity_id, created_at);
CREATE INDEX idx_real_time_metrics_entity_metric_time ON real_time_metrics(entity_type, entity_id, metric_name, timestamp);
CREATE INDEX idx_security_events_user_severity_created ON security_events(user_id, severity, created_at);
CREATE INDEX idx_enhanced_notifications_user_read_created ON enhanced_notifications(user_id, is_read, created_at);
CREATE INDEX idx_event_streams_org_type_timestamp ON event_streams(organization_id, event_type, timestamp);

-- Partial indexes for active records
CREATE INDEX idx_ml_models_active ON ml_models(model_type, created_at) WHERE status = 'active';
CREATE INDEX idx_external_integrations_active ON external_integrations(integration_type, organization_id) WHERE status = 'active';
CREATE INDEX idx_webhook_configurations_active ON webhook_configurations(organization_id, events) WHERE is_active = true;
CREATE INDEX idx_mobile_devices_active ON mobile_devices(user_id, platform) WHERE is_active = true;
CREATE INDEX idx_edge_nodes_active ON edge_nodes(status, location) WHERE status = 'active';

-- =====================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON TABLE ml_models IS 'Registry of machine learning models used throughout the platform';
COMMENT ON TABLE feature_store IS 'Central repository for ML features with metadata and lineage';
COMMENT ON TABLE ml_predictions IS 'Storage for ML model predictions with confidence scores';
COMMENT ON TABLE real_time_metrics IS 'Time-series storage for real-time system and business metrics';
COMMENT ON TABLE analytics_dashboards IS 'User-defined analytics dashboards and their configurations';
COMMENT ON TABLE security_events IS 'Security-related events for threat detection and analysis';
COMMENT ON TABLE mobile_devices IS 'Registry of mobile devices for push notifications and sync';
COMMENT ON TABLE edge_nodes IS 'Edge computing nodes for distributed processing';
COMMENT ON TABLE event_streams IS 'Event sourcing storage for real-time event processing';
COMMENT ON TABLE distributed_traces IS 'Distributed tracing data for system observability';

-- =====================================================
-- FINAL SETUP AND VALIDATION
-- =====================================================

-- Enable row level security on sensitive tables
ALTER TABLE security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE authentication_sessions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (examples)
CREATE POLICY security_events_policy ON security_events
    FOR ALL TO authenticated_users
    USING (user_id = current_user_id() OR has_role('security_admin'));

CREATE POLICY risk_assessments_policy ON risk_assessments
    FOR ALL TO authenticated_users
    USING (has_role('security_admin') OR has_role('project_manager'));

-- Grant appropriate permissions
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO application_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO application_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO application_user;

-- Create read-only role for analytics
CREATE ROLE analytics_reader;
GRANT SELECT ON analytics_dashboards, dashboard_widgets, real_time_metrics,
      predictive_analytics, user_behavior_analytics, project_health_assessments,
      team_collaboration_metrics TO analytics_reader;

-- Validate schema
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') > 50,
           'Expected more than 50 tables in schema';
    
    ASSERT (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public') > 500,
           'Expected more than 500 columns in schema';
    
    RAISE NOTICE 'Phase II database schema validation completed successfully';
END $$;

-- =====================================================
-- END OF PHASE II DATABASE ENHANCEMENTS
-- =====================================================