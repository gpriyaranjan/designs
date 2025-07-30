-- Database Schema for Project Management System
-- PostgreSQL Database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================================
-- USERS AND AUTHENTICATION
-- ============================================================================

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User roles
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '[]',
    is_system_role BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User role assignments
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role_id)
);

-- User sessions for JWT token management
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_id VARCHAR(255) UNIQUE NOT NULL,
    refresh_token_hash VARCHAR(255),
    device_info JSONB,
    ip_address INET,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PROJECTS
-- ============================================================================

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    project_type VARCHAR(50) NOT NULL DEFAULT 'software',
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    lead_id UUID REFERENCES users(id),
    avatar_url TEXT,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project members
CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member',
    permissions JSONB DEFAULT '[]',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    added_by UUID REFERENCES users(id),
    UNIQUE(project_id, user_id)
);

-- Project categories/tags
CREATE TABLE project_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    color VARCHAR(7), -- Hex color code
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project category assignments
CREATE TABLE project_category_assignments (
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES project_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, category_id)
);

-- ============================================================================
-- ISSUES
-- ============================================================================

-- Issue types
CREATE TABLE issue_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_subtask BOOLEAN DEFAULT false,
    is_system_type BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, name)
);

-- Issue statuses
CREATE TABLE issue_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    category VARCHAR(20) NOT NULL, -- 'todo', 'in_progress', 'done'
    color VARCHAR(7),
    is_initial BOOLEAN DEFAULT false,
    is_final BOOLEAN DEFAULT false,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, name)
);

-- Issue priorities
CREATE TABLE issue_priorities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    level INTEGER NOT NULL, -- 1=lowest, 5=highest
    color VARCHAR(7),
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, name)
);

-- Issues table (partitioned by project_id for scalability)
CREATE TABLE issues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    issue_key VARCHAR(50) UNIQUE NOT NULL,
    summary VARCHAR(500) NOT NULL,
    description TEXT,
    issue_type_id UUID NOT NULL REFERENCES issue_types(id),
    status_id UUID NOT NULL REFERENCES issue_statuses(id),
    priority_id UUID NOT NULL REFERENCES issue_priorities(id),
    assignee_id UUID REFERENCES users(id),
    reporter_id UUID NOT NULL REFERENCES users(id),
    parent_id UUID REFERENCES issues(id), -- For subtasks
    epic_id UUID REFERENCES issues(id), -- Link to epic
    story_points INTEGER,
    original_estimate INTEGER, -- in minutes
    remaining_estimate INTEGER, -- in minutes
    time_spent INTEGER DEFAULT 0, -- in minutes
    due_date DATE,
    resolution VARCHAR(100),
    resolved_at TIMESTAMP WITH TIME ZONE,
    custom_fields JSONB DEFAULT '{}',
    labels TEXT[] DEFAULT '{}',
    environment TEXT,
    security_level VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
) PARTITION BY HASH (project_id);

-- Create partitions for issues table
CREATE TABLE issues_partition_0 PARTITION OF issues FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE issues_partition_1 PARTITION OF issues FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE issues_partition_2 PARTITION OF issues FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE issues_partition_3 PARTITION OF issues FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- Issue comments
CREATE TABLE issue_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false,
    parent_id UUID REFERENCES issue_comments(id), -- For threaded comments
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Issue attachments
CREATE TABLE issue_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    file_path TEXT NOT NULL,
    thumbnail_path TEXT,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Issue links (relationships between issues)
CREATE TABLE issue_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    target_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    link_type VARCHAR(50) NOT NULL, -- 'blocks', 'is_blocked_by', 'duplicates', 'relates_to', etc.
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(source_issue_id, target_issue_id, link_type)
);

-- Issue watchers
CREATE TABLE issue_watchers (
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (issue_id, user_id)
);

-- ============================================================================
-- WORKFLOWS
-- ============================================================================

-- Workflows
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    issue_types UUID[] DEFAULT '{}', -- Array of issue type IDs
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workflow transitions
CREATE TABLE workflow_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES workflows(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    from_status_id UUID NOT NULL REFERENCES issue_statuses(id),
    to_status_id UUID NOT NULL REFERENCES issue_statuses(id),
    conditions JSONB DEFAULT '[]',
    validators JSONB DEFAULT '[]',
    post_functions JSONB DEFAULT '[]',
    screen_id UUID, -- For transition screens
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workflow transition history
CREATE TABLE workflow_transition_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    transition_id UUID NOT NULL REFERENCES workflow_transitions(id),
    from_status_id UUID NOT NULL REFERENCES issue_statuses(id),
    to_status_id UUID NOT NULL REFERENCES issue_statuses(id),
    executed_by UUID NOT NULL REFERENCES users(id),
    comment TEXT,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- SPRINTS AND AGILE
-- ============================================================================

-- Sprints
CREATE TABLE sprints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    goal TEXT,
    state VARCHAR(20) NOT NULL DEFAULT 'future', -- 'future', 'active', 'closed'
    start_date DATE,
    end_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sprint issues (many-to-many relationship)
CREATE TABLE sprint_issues (
    sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    added_by UUID NOT NULL REFERENCES users(id),
    PRIMARY KEY (sprint_id, issue_id)
);

-- Boards (Kanban/Scrum boards)
CREATE TABLE boards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'scrum', 'kanban'
    filter_query TEXT, -- JQL-like query for filtering issues
    column_config JSONB DEFAULT '[]',
    swimlane_config JSONB DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

-- Notification templates
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    subject_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    email_enabled BOOLEAN DEFAULT true,
    push_enabled BOOLEAN DEFAULT true,
    in_app_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, event_type)
);

-- ============================================================================
-- FILES AND ATTACHMENTS
-- ============================================================================

-- File storage metadata
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    file_path TEXT NOT NULL,
    thumbnail_path TEXT,
    checksum VARCHAR(64), -- SHA-256 hash
    storage_provider VARCHAR(50) DEFAULT 'local', -- 'local', 's3', 'gcs', etc.
    metadata JSONB DEFAULT '{}',
    uploaded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- REPORTS AND ANALYTICS
-- ============================================================================

-- Saved reports
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL, -- 'issue_summary', 'burndown', 'velocity', etc.
    query_config JSONB NOT NULL,
    chart_config JSONB DEFAULT '{}',
    is_public BOOLEAN DEFAULT false,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Report executions (for caching and history)
CREATE TABLE report_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
    result_data JSONB,
    error_message TEXT,
    execution_time_ms INTEGER,
    executed_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- AUDIT AND ACTIVITY LOGS
-- ============================================================================

-- Activity logs for audit trail
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL, -- 'issue', 'project', 'user', etc.
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'created', 'updated', 'deleted', etc.
    actor_id UUID REFERENCES users(id),
    actor_ip INET,
    changes JSONB DEFAULT '{}', -- Before/after values
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for activity logs
CREATE TABLE activity_logs_2025_01 PARTITION OF activity_logs 
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE activity_logs_2025_02 PARTITION OF activity_logs 
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- ============================================================================
-- WEBHOOKS
-- ============================================================================

-- Webhook configurations
CREATE TABLE webhooks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    url TEXT NOT NULL,
    events TEXT[] NOT NULL,
    secret VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    filters JSONB DEFAULT '{}',
    headers JSONB DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Webhook delivery logs
CREATE TABLE webhook_deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    webhook_id UUID NOT NULL REFERENCES webhooks(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    response_headers JSONB,
    delivery_attempts INTEGER DEFAULT 1,
    delivered_at TIMESTAMP WITH TIME ZONE,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- CUSTOM FIELDS
-- ============================================================================

-- Custom field definitions
CREATE TABLE custom_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    field_type VARCHAR(50) NOT NULL, -- 'text', 'number', 'date', 'select', 'multi_select', etc.
    field_config JSONB DEFAULT '{}', -- Options, validation rules, etc.
    is_required BOOLEAN DEFAULT false,
    is_searchable BOOLEAN DEFAULT true,
    applies_to_issue_types UUID[] DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, name)
);

-- Custom field values
CREATE TABLE custom_field_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    custom_field_id UUID NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
    value_text TEXT,
    value_number DECIMAL,
    value_date DATE,
    value_json JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(issue_id, custom_field_id)
);

-- ============================================================================
-- SEARCH AND INDEXING
-- ============================================================================

-- Search index for full-text search
CREATE TABLE search_index (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    search_vector tsvector,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_type, entity_id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = true;

-- User sessions indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token_id ON user_sessions(token_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Projects indexes
CREATE INDEX idx_projects_key ON projects(key);
CREATE INDEX idx_projects_lead_id ON projects(lead_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_created_at ON projects(created_at);

-- Project members indexes
CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);

-- Issues indexes (applied to all partitions)
CREATE INDEX idx_issues_project_id ON issues(project_id);
CREATE INDEX idx_issues_key ON issues(issue_key);
CREATE INDEX idx_issues_assignee_id ON issues(assignee_id) WHERE assignee_id IS NOT NULL;
CREATE INDEX idx_issues_reporter_id ON issues(reporter_id);
CREATE INDEX idx_issues_status_id ON issues(status_id);
CREATE INDEX idx_issues_priority_id ON issues(priority_id);
CREATE INDEX idx_issues_created_at ON issues(created_at);
CREATE INDEX idx_issues_updated_at ON issues(updated_at);
CREATE INDEX idx_issues_parent_id ON issues(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX idx_issues_epic_id ON issues(epic_id) WHERE epic_id IS NOT NULL;
CREATE INDEX idx_issues_deleted_at ON issues(deleted_at) WHERE deleted_at IS NULL;

-- Composite indexes for common queries
CREATE INDEX idx_issues_project_status ON issues(project_id, status_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_issues_assignee_status ON issues(assignee_id, status_id, updated_at) WHERE deleted_at IS NULL AND assignee_id IS NOT NULL;
CREATE INDEX idx_issues_project_type ON issues(project_id, issue_type_id) WHERE deleted_at IS NULL;

-- Full-text search indexes
CREATE INDEX idx_issues_text_search ON issues USING gin(to_tsvector('english', summary || ' ' || COALESCE(description, '')));

-- Comments indexes
CREATE INDEX idx_issue_comments_issue_id ON issue_comments(issue_id);
CREATE INDEX idx_issue_comments_author_id ON issue_comments(author_id);
CREATE INDEX idx_issue_comments_created_at ON issue_comments(created_at);

-- Attachments indexes
CREATE INDEX idx_issue_attachments_issue_id ON issue_attachments(issue_id);
CREATE INDEX idx_issue_attachments_uploaded_by ON issue_attachments(uploaded_by);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Activity logs indexes
CREATE INDEX idx_activity_logs_entity ON activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_actor_id ON activity_logs(actor_id) WHERE actor_id IS NOT NULL;
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);

-- Search index
CREATE INDEX idx_search_index_entity ON search_index(entity_type, entity_id);
CREATE INDEX idx_search_index_project_id ON search_index(project_id) WHERE project_id IS NOT NULL;
CREATE INDEX idx_search_index_search_vector ON search_index USING gin(search_vector);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_issues_updated_at BEFORE UPDATE ON issues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_issue_comments_updated_at BEFORE UPDATE ON issue_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sprints_updated_at BEFORE UPDATE ON sprints FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_boards_updated_at BEFORE UPDATE ON boards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_webhooks_updated_at BEFORE UPDATE ON webhooks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_custom_fields_updated_at BEFORE UPDATE ON custom_fields FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_custom_field_values_updated_at BEFORE UPDATE ON custom_field_values FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_search_index_updated_at BEFORE UPDATE ON search_index FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update search index
CREATE OR REPLACE FUNCTION update_search_index()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        INSERT INTO search_index (entity_type, entity_id, project_id, title, content, search_vector)
        VALUES (
            'issue',
            NEW.id,
            NEW.project_id,
            NEW.summary,
            NEW.summary || ' ' || COALESCE(NEW.description, ''),
            to_tsvector('english', NEW.summary || ' ' || COALESCE(NEW.description, ''))
        )
        ON CONFLICT (entity_type, entity_id)
        DO UPDATE SET
            title = EXCLUDED.title,
            content = EXCLUDED.content,
            search_vector = EXCLUDED.search_vector,
            updated_at = NOW();
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM search_index WHERE entity_type = 'issue' AND entity_id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Apply search index trigger to issues
CREATE TRIGGER update_issues_search_index 
    AFTER INSERT OR UPDATE OR DELETE ON issues 
    FOR EACH ROW EXECUTE FUNCTION update_search_index();

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- Insert default roles
INSERT INTO roles (name, description, permissions, is_system_role) VALUES
('system_admin', 'System Administrator', '["admin:*"]', true),
('project_admin', 'Project Administrator', '["admin:projects", "write:projects", "read:projects", "admin:issues", "write:issues", "read:issues"]', true),
('developer', 'Developer', '["write:projects", "read:projects", "write:issues", "read:issues", "write:comments", "read:comments"]', true),
('reporter', 'Reporter', '["read:projects", "write:issues", "read:issues", "write:comments", "read:comments"]', true),
('viewer', 'Viewer', '["read:projects", "read:issues", "read:comments"]', true);

-- Insert default issue types
INSERT INTO issue_types (name, description, icon, color, is_system_type) VALUES
('Bug', 'A problem that impairs or prevents the functions of the product', 'bug', '#e74c3c', true),
('Task', 'A task that needs to be done', 'task', '#3498db', true),
('Story', 'A user story', 'story', '#2ecc71', true),
('Epic', 'A large user story that can be broken down into smaller stories', 'epic', '#9b59b6', true),
('Improvement', 'An improvement or enhancement to an existing feature', 'improvement', '#f39c12', true),
('New Feature', 'A new feature of the product', 'feature', '#1abc9c', true);

-- Insert default priorities
INSERT INTO issue_priorities (name, description, level, color, icon) VALUES
('Lowest', 'Lowest priority', 1, '#95a5a6', 'arrow-down'),
('Low', 'Low priority', 2, '#3498db', 'arrow-down'),
('Medium', 'Medium priority', 3, '#f39c12', 'arrow-right'),
('High', 'High priority', 4, '#e67e22', 'arrow-up'),
('Highest', 'Highest priority', 5, '#e74c3c', 'arrow-up');

-- Insert default notification templates
INSERT INTO notification_templates (name, event_type, subject_template, body_template) VALUES
('issue_assigned', 'issue.assigned', 'Issue {{issue.key}} assigned to you', 'The issue "{{issue.summary}}" has been assigned to you by {{actor.name}}.'),
('issue_updated', 'issue.updated', 'Issue {{issue.key}} updated', 'The issue "{{issue.summary}}" has been updated by {{actor.name}}.'),
('comment_added', 'comment.added', 'New comment on {{issue.key}}', '{{actor.name}} added a comment to "{{issue.summary}}": {{comment.content}}'),
('project_member_added', 'project.member_added', 'Added to project {{project.name}}', 'You have been added to the project "{{project.name}}" by {{actor.name}}.');

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for issue details with related information
CREATE VIEW issue_details AS
SELECT 
    i.id,
    i.issue_key,
    i.summary,
    i.description,
    i.story_points,
    i.time_spent,
    i.created_at,
    i.updated_at,
    p.id as project_id,
    p.key as project_key,
    p.name as project_name,
    it.name as issue_type,
    it.color as issue_type_color,
    ist.name as status,
    ist.category as status_category,
    ist.color as status_color,
    ip.name as priority,
    ip.level as priority_level,
    ip.color as priority_color,
    assignee.id as assignee_id,
    assignee.username as assignee_username,
    assignee.first_name || ' ' || assignee.last_name as assignee_name,
    reporter.id as reporter_id,
    reporter.username as reporter_username,
    reporter.first_name || ' ' || reporter.last_name as reporter_name
FROM issues i
JOIN projects p ON i.project_id = p.id
JOIN issue_types it ON i.issue_type_id = it.id
JOIN issue_statuses ist ON i.status_id = ist.id
JOIN issue_priorities ip ON i.priority_id = ip.id
LEFT JOIN users assignee ON i.assignee_id = assignee.id
LEFT JOIN users reporter ON i.reporter_id = reporter.id
WHERE i.deleted_at IS NULL;

-- View for project statistics
CREATE VIEW project_statistics AS
SELECT
    p.id as project_id,
    p.name as project_name,
    COUNT(i.id) as total_issues,
    COUNT(CASE WHEN ist.category = 'todo' THEN 1 END) as open_issues,
    COUNT(CASE WHEN ist.category = 'in_progress' THEN 1 END) as in_progress_issues,
    COUNT(CASE WHEN ist.category = 'done' THEN 1 END) as closed_issues,
    COUNT(CASE WHEN i.assignee_id IS NULL THEN 1 END) as unassigned_issues,
    AVG(CASE WHEN ist.category = 'done' AND i.created_at IS NOT NULL AND i.resolved_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (i.resolved_at - i.created_at))/86400 END) as avg_resolution_days
FROM projects p
LEFT JOIN issues i ON p.id = i.project_id AND i.deleted_at IS NULL
LEFT JOIN issue_statuses ist ON i.status_id = ist.id
GROUP BY p.id, p.name;

-- ============================================================================
-- FUNCTIONS FOR BUSINESS LOGIC
-- ============================================================================

-- Function to generate next issue key for a project
CREATE OR REPLACE FUNCTION generate_issue_key(project_key TEXT)
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    new_key TEXT;
BEGIN
    -- Get the next issue number for this project
    SELECT COALESCE(MAX(CAST(SUBSTRING(issue_key FROM LENGTH(project_key) + 2) AS INTEGER)), 0) + 1
    INTO next_number
    FROM issues
    WHERE issue_key LIKE project_key || '-%';
    
    new_key := project_key || '-' || next_number;
    RETURN new_key;
END;
$$ LANGUAGE plpgsql;

-- Function to check if user has permission
CREATE OR REPLACE FUNCTION user_has_permission(user_uuid UUID, permission_name TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    has_permission BOOLEAN := FALSE;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = user_uuid
        AND (
            r.permissions ? permission_name
            OR r.permissions ? 'admin:*'
            OR r.permissions ? (SPLIT_PART(permission_name, ':', 1) || ':*')
        )
    ) INTO has_permission;
    
    RETURN has_permission;
END;
$$ LANGUAGE plpgsql;

-- Function to get user's project role
CREATE OR REPLACE FUNCTION get_user_project_role(user_uuid UUID, project_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT pm.role INTO user_role
    FROM project_members pm
    WHERE pm.user_id = user_uuid AND pm.project_id = project_uuid;
    
    RETURN COALESCE(user_role, 'none');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STORED PROCEDURES FOR COMMON OPERATIONS
-- ============================================================================

-- Procedure to create a new issue
CREATE OR REPLACE FUNCTION create_issue(
    p_project_id UUID,
    p_summary TEXT,
    p_description TEXT DEFAULT NULL,
    p_issue_type_id UUID,
    p_priority_id UUID,
    p_reporter_id UUID,
    p_assignee_id UUID DEFAULT NULL,
    p_custom_fields JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
    new_issue_id UUID;
    project_key TEXT;
    new_issue_key TEXT;
    initial_status_id UUID;
BEGIN
    -- Get project key
    SELECT key INTO project_key FROM projects WHERE id = p_project_id;
    IF project_key IS NULL THEN
        RAISE EXCEPTION 'Project not found';
    END IF;
    
    -- Generate issue key
    new_issue_key := generate_issue_key(project_key);
    
    -- Get initial status for this project
    SELECT id INTO initial_status_id
    FROM issue_statuses
    WHERE project_id = p_project_id AND is_initial = true
    LIMIT 1;
    
    IF initial_status_id IS NULL THEN
        RAISE EXCEPTION 'No initial status found for project';
    END IF;
    
    -- Create the issue
    INSERT INTO issues (
        project_id, issue_key, summary, description,
        issue_type_id, status_id, priority_id,
        reporter_id, assignee_id, custom_fields
    ) VALUES (
        p_project_id, new_issue_key, p_summary, p_description,
        p_issue_type_id, initial_status_id, p_priority_id,
        p_reporter_id, p_assignee_id, p_custom_fields
    ) RETURNING id INTO new_issue_id;
    
    RETURN new_issue_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to transition issue status
CREATE OR REPLACE FUNCTION transition_issue(
    p_issue_id UUID,
    p_transition_id UUID,
    p_user_id UUID,
    p_comment TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    current_status_id UUID;
    target_status_id UUID;
    transition_from_status UUID;
    workflow_id UUID;
BEGIN
    -- Get current issue status
    SELECT status_id INTO current_status_id FROM issues WHERE id = p_issue_id;
    
    -- Get transition details
    SELECT from_status_id, to_status_id, workflow_id
    INTO transition_from_status, target_status_id, workflow_id
    FROM workflow_transitions
    WHERE id = p_transition_id;
    
    -- Validate transition
    IF current_status_id != transition_from_status THEN
        RAISE EXCEPTION 'Invalid transition: issue is not in the expected status';
    END IF;
    
    -- Update issue status
    UPDATE issues
    SET status_id = target_status_id,
        updated_at = NOW(),
        resolved_at = CASE
            WHEN (SELECT category FROM issue_statuses WHERE id = target_status_id) = 'done'
            THEN NOW()
            ELSE resolved_at
        END
    WHERE id = p_issue_id;
    
    -- Log the transition
    INSERT INTO workflow_transition_history (
        issue_id, transition_id, from_status_id, to_status_id, executed_by, comment
    ) VALUES (
        p_issue_id, p_transition_id, current_status_id, target_status_id, p_user_id, p_comment
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SECURITY POLICIES (Row Level Security)
-- ============================================================================

-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_comments ENABLE ROW LEVEL SECURITY;

-- Policy for users - users can only see their own data unless they're admin
CREATE POLICY users_policy ON users
    FOR ALL
    TO authenticated_user
    USING (
        id = current_setting('app.current_user_id')::UUID
        OR user_has_permission(current_setting('app.current_user_id')::UUID, 'admin:users')
    );

-- Policy for projects - users can only see projects they're members of
CREATE POLICY projects_policy ON projects
    FOR ALL
    TO authenticated_user
    USING (
        EXISTS (
            SELECT 1 FROM project_members pm
            WHERE pm.project_id = id
            AND pm.user_id = current_setting('app.current_user_id')::UUID
        )
        OR user_has_permission(current_setting('app.current_user_id')::UUID, 'admin:projects')
    );

-- Policy for issues - users can only see issues from projects they're members of
CREATE POLICY issues_policy ON issues
    FOR ALL
    TO authenticated_user
    USING (
        EXISTS (
            SELECT 1 FROM project_members pm
            WHERE pm.project_id = project_id
            AND pm.user_id = current_setting('app.current_user_id')::UUID
        )
        OR user_has_permission(current_setting('app.current_user_id')::UUID, 'admin:issues')
    );

-- ============================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Partial indexes for better performance
CREATE INDEX CONCURRENTLY idx_issues_open
ON issues (project_id, created_at)
WHERE deleted_at IS NULL AND status_id IN (
    SELECT id FROM issue_statuses WHERE category IN ('todo', 'in_progress')
);

CREATE INDEX CONCURRENTLY idx_issues_recent
ON issues (updated_at DESC)
WHERE deleted_at IS NULL AND updated_at > NOW() - INTERVAL '30 days';

CREATE INDEX CONCURRENTLY idx_notifications_unread_recent
ON notifications (user_id, created_at DESC)
WHERE is_read = false AND created_at > NOW() - INTERVAL '7 days';

-- Covering indexes for common queries
CREATE INDEX CONCURRENTLY idx_issues_list_covering
ON issues (project_id, status_id, priority_id, assignee_id, created_at)
INCLUDE (id, issue_key, summary, updated_at)
WHERE deleted_at IS NULL;

-- ============================================================================
-- MAINTENANCE PROCEDURES
-- ============================================================================

-- Procedure to clean up old data
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS VOID AS $$
BEGIN
    -- Clean up old user sessions (older than 30 days)
    DELETE FROM user_sessions WHERE expires_at < NOW() - INTERVAL '30 days';
    
    -- Clean up old webhook deliveries (older than 90 days)
    DELETE FROM webhook_deliveries WHERE created_at < NOW() - INTERVAL '90 days';
    
    -- Clean up old activity logs (older than 2 years)
    DELETE FROM activity_logs WHERE created_at < NOW() - INTERVAL '2 years';
    
    -- Clean up read notifications (older than 30 days)
    DELETE FROM notifications
    WHERE is_read = true AND read_at < NOW() - INTERVAL '30 days';
    
    RAISE NOTICE 'Cleanup completed at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- Procedure to update search index
CREATE OR REPLACE FUNCTION refresh_search_index()
RETURNS VOID AS $$
BEGIN
    -- Refresh search index for all issues
    INSERT INTO search_index (entity_type, entity_id, project_id, title, content, search_vector)
    SELECT
        'issue',
        i.id,
        i.project_id,
        i.summary,
        i.summary || ' ' || COALESCE(i.description, ''),
        to_tsvector('english', i.summary || ' ' || COALESCE(i.description, ''))
    FROM issues i
    WHERE i.deleted_at IS NULL
    ON CONFLICT (entity_type, entity_id)
    DO UPDATE SET
        title = EXCLUDED.title,
        content = EXCLUDED.content,
        search_vector = EXCLUDED.search_vector,
        updated_at = NOW();
    
    RAISE NOTICE 'Search index refreshed at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MONITORING AND STATISTICS
-- ============================================================================

-- View for database statistics
CREATE VIEW database_statistics AS
SELECT
    'users' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as recent_records
FROM users
UNION ALL
SELECT
    'projects' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as recent_records
FROM projects
UNION ALL
SELECT
    'issues' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as recent_records
FROM issues
WHERE deleted_at IS NULL
UNION ALL
SELECT
    'issue_comments' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as recent_records
FROM issue_comments
WHERE deleted_at IS NULL;

-- View for system health metrics
CREATE VIEW system_health_metrics AS
SELECT
    'active_users_last_24h' as metric_name,
    COUNT(DISTINCT user_id)::TEXT as metric_value
FROM user_sessions
WHERE last_used_at > NOW() - INTERVAL '24 hours'
UNION ALL
SELECT
    'issues_created_last_7d' as metric_name,
    COUNT(*)::TEXT as metric_value
FROM issues
WHERE created_at > NOW() - INTERVAL '7 days' AND deleted_at IS NULL
UNION ALL
SELECT
    'avg_issue_resolution_time_days' as metric_name,
    ROUND(AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/86400), 2)::TEXT as metric_value
FROM issues
WHERE resolved_at IS NOT NULL
AND resolved_at > NOW() - INTERVAL '30 days'
AND deleted_at IS NULL;

-- ============================================================================
-- BACKUP AND RECOVERY HELPERS
-- ============================================================================

-- Function to create a backup of critical configuration
CREATE OR REPLACE FUNCTION backup_configuration()
RETURNS TABLE(
    table_name TEXT,
    backup_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'roles'::TEXT, jsonb_agg(to_jsonb(r)) FROM roles r
    UNION ALL
    SELECT 'issue_types'::TEXT, jsonb_agg(to_jsonb(it)) FROM issue_types it WHERE is_system_type = true
    UNION ALL
    SELECT 'issue_priorities'::TEXT, jsonb_agg(to_jsonb(ip)) FROM issue_priorities ip
    UNION ALL
    SELECT 'notification_templates'::TEXT, jsonb_agg(to_jsonb(nt)) FROM notification_templates nt;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FINAL SETUP
-- ============================================================================

-- Create a role for the application
CREATE ROLE app_user;
GRANT CONNECT ON DATABASE postgres TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Create a role for read-only access (for reporting)
CREATE ROLE app_readonly;
GRANT CONNECT ON DATABASE postgres TO app_readonly;
GRANT USAGE ON SCHEMA public TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;

-- Create authenticated_user role for RLS policies
CREATE ROLE authenticated_user;

COMMIT;

-- ============================================================================
-- NOTES AND DOCUMENTATION
-- ============================================================================

/*
SCHEMA DESIGN NOTES:

1. PARTITIONING:
   - Issues table is partitioned by project_id hash for better performance
   - Activity logs are partitioned by date range for easier maintenance
   - Additional partitions can be added as data grows

2. INDEXING STRATEGY:
   - Primary indexes on foreign keys and frequently queried columns
   - Composite indexes for common query patterns
   - Partial indexes for filtered queries
   - Covering indexes to avoid table lookups

3. SECURITY:
   - Row Level Security (RLS) policies for multi-tenant data isolation
   - Separate roles for application and read-only access
   - Audit trail through activity_logs table

4. SCALABILITY:
   - UUID primary keys for distributed systems
   - JSONB fields for flexible schema evolution
   - Efficient search through full-text search indexes
   - Prepared for horizontal scaling with partitioning

5. MAINTENANCE:
   - Automated cleanup procedures for old data
   - Search index refresh procedures
   - Database statistics views for monitoring
   - Backup helpers for configuration data

6. PERFORMANCE:
   - Optimized indexes for common query patterns
   - Materialized views can be added for complex aggregations
   - Connection pooling recommended at application level
   - Consider read replicas for reporting workloads

MIGRATION STRATEGY:
- Use versioned migration scripts
- Test migrations on staging environment
- Plan for zero-downtime deployments
- Monitor performance after schema changes
- Keep rollback scripts ready

MONITORING RECOMMENDATIONS:
- Monitor table sizes and growth rates
- Track slow queries and optimize indexes
- Monitor connection pool usage
- Set up alerts for failed constraint checks
- Regular VACUUM and ANALYZE operations
*/