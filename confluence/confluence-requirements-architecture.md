# Confluence: Team Collaboration & Documentation Platform
## Requirements and Scalable Architecture

## Table of Contents
1. [Product Overview](#1-product-overview)
2. [Functional Requirements](#2-functional-requirements)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [System Architecture](#4-system-architecture)
5. [Data Models & Storage](#5-data-models--storage)
6. [API Specifications](#6-api-specifications)
7. [Real-Time Collaboration](#7-real-time-collaboration)
8. [Search & Discovery](#8-search--discovery)
9. [Security & Permissions](#9-security--permissions)
10. [Deployment & Infrastructure](#10-deployment--infrastructure)
11. [Performance & Scalability](#11-performance--scalability)
12. [Implementation Roadmap](#12-implementation-roadmap)

## 1. Product Overview

### 1.1 Vision Statement
Build a comprehensive team collaboration and knowledge management platform that enables organizations to create, organize, and share information effectively, fostering transparency and collaboration across teams.

### 1.2 Core Value Propositions
- **Centralized Knowledge Hub**: Single source of truth for organizational knowledge
- **Real-Time Collaboration**: Simultaneous editing and commenting capabilities
- **Powerful Organization**: Hierarchical spaces and pages with flexible navigation
- **Rich Content Creation**: Support for multimedia, diagrams, and interactive content
- **Enterprise Integration**: Seamless integration with development and business tools
- **Advanced Search**: Intelligent content discovery and recommendation

### 1.3 Target Users
- **Content Creators**: Technical writers, product managers, team leads
- **Knowledge Workers**: Developers, designers, analysts, consultants
- **Decision Makers**: Executives, managers requiring access to organizational knowledge
- **External Collaborators**: Partners, contractors, customers (with controlled access)

### 1.4 Key Differentiators
- **Atlassian Document Format (ADF)**: Rich, structured content representation
- **Template System**: Reusable blueprints for consistent documentation
- **Macro Ecosystem**: Extensible functionality through custom macros
- **Space-Based Organization**: Logical grouping of related content
- **Version Control**: Complete history and rollback capabilities

## 2. Functional Requirements

### 2.1 Content Management

#### Page Creation & Editing
- **Rich Text Editor**: WYSIWYG editor with markdown support
- **Real-Time Collaboration**: Multiple users editing simultaneously
- **Auto-Save**: Continuous saving with conflict resolution
- **Version History**: Complete revision tracking with diff visualization
- **Draft Management**: Save drafts and publish when ready
- **Page Templates**: Pre-built and custom templates for consistency
- **Content Blocks**: Reusable content components across pages

#### Content Types & Media
- **Text Formatting**: Headers, lists, tables, quotes, code blocks
- **Media Support**: Images, videos, audio files with inline preview
- **File Attachments**: Document uploads with version control
- **Diagrams**: Built-in diagramming tools (flowcharts, org charts, wireframes)
- **Embedded Content**: External content integration (YouTube, Google Docs, etc.)
- **Interactive Elements**: Forms, polls, decision matrices
- **Code Snippets**: Syntax highlighting for 100+ programming languages

#### Page Organization
- **Hierarchical Structure**: Parent-child page relationships
- **Page Trees**: Visual navigation of page hierarchies
- **Cross-References**: Linking between pages with backlink tracking
- **Labels & Tags**: Flexible categorization system
- **Breadcrumbs**: Clear navigation path indication
- **Page Ordering**: Custom sorting within page trees

### 2.2 Space Management

#### Space Types & Structure
- **Team Spaces**: Collaborative workspaces for teams
- **Personal Spaces**: Individual knowledge repositories
- **Project Spaces**: Temporary spaces for specific initiatives
- **Knowledge Base Spaces**: Formal documentation repositories
- **Archive Spaces**: Historical content preservation

#### Space Features
- **Space Homepage**: Customizable landing page with widgets
- **Space Navigation**: Custom sidebar navigation menus
- **Space Templates**: Pre-configured space structures
- **Space Permissions**: Granular access control per space
- **Space Analytics**: Usage metrics and content performance
- **Space Themes**: Visual customization and branding

### 2.3 Collaboration Features

#### Real-Time Editing
- **Simultaneous Editing**: Multiple cursors and live updates
- **Conflict Resolution**: Automatic merging of concurrent changes
- **User Presence**: Show who's currently viewing/editing
- **Edit Notifications**: Real-time alerts for page changes
- **Collaborative Cursors**: See other users' cursor positions
- **Voice/Video Integration**: Built-in communication tools

#### Comments & Discussions
- **Inline Comments**: Comments on specific content sections
- **Page Comments**: General discussion threads
- **Comment Threading**: Nested conversation support
- **Comment Resolution**: Mark comments as resolved
- **@Mentions**: Notify specific users in comments
- **Comment Notifications**: Email and in-app alerts

#### Review & Approval
- **Review Workflows**: Multi-stage content approval process
- **Reviewer Assignment**: Assign specific reviewers to content
- **Approval Status**: Track approval progress and status
- **Review Comments**: Feedback collection during review
- **Publication Controls**: Restrict publishing until approved
- **Review Templates**: Standardized review processes

### 2.4 Search & Discovery

#### Search Capabilities
- **Full-Text Search**: Search across all content types
- **Advanced Filters**: Filter by space, author, date, content type
- **Search Suggestions**: Auto-complete and query suggestions
- **Saved Searches**: Bookmark frequently used search queries
- **Search Analytics**: Track search patterns and popular content
- **Federated Search**: Search across integrated external systems

#### Content Discovery
- **Recently Viewed**: Quick access to recent content
- **Popular Content**: Trending pages and spaces
- **Recommended Content**: AI-powered content recommendations
- **Related Pages**: Suggest related content based on context
- **Content Calendar**: Timeline view of content creation/updates
- **Activity Feeds**: Real-time updates on followed content

### 2.5 Templates & Blueprints

#### Template System
- **Page Templates**: Pre-designed page layouts and structures
- **Space Blueprints**: Complete space setups for common use cases
- **Custom Templates**: User-created templates for team consistency
- **Template Variables**: Dynamic content insertion in templates
- **Template Inheritance**: Hierarchical template relationships
- **Template Marketplace**: Community-contributed templates

#### Common Templates
- **Meeting Notes**: Structured meeting documentation
- **Project Plans**: Project planning and tracking templates
- **Requirements Documents**: Software requirement specifications
- **How-To Guides**: Step-by-step instruction templates
- **Decision Records**: Architecture decision documentation
- **Team Retrospectives**: Agile retrospective formats

### 2.6 Macros & Extensions

#### Built-in Macros
- **Table of Contents**: Automatic page navigation
- **Status Macros**: Visual status indicators
- **Chart Macros**: Data visualization components
- **Calendar Macros**: Event and deadline tracking
- **Task Lists**: Interactive to-do lists
- **Code Blocks**: Syntax-highlighted code display
- **Excerpt Macros**: Content reuse across pages

#### Custom Macros
- **Macro Development**: SDK for custom macro creation
- **Macro Parameters**: Configurable macro behavior
- **Macro Marketplace**: Third-party macro distribution
- **Macro Security**: Sandboxed execution environment
- **Macro Analytics**: Usage tracking and performance metrics

## 3. Non-Functional Requirements

### 3.1 Performance Requirements

#### Response Time
- **Page Load**: < 2 seconds for 95% of page loads
- **Search Results**: < 500ms for search queries
- **Real-Time Updates**: < 100ms for collaborative editing
- **File Upload**: Support files up to 100MB with progress indication
- **Export Operations**: < 30 seconds for space exports

#### Throughput
- **Concurrent Users**: Support 10,000+ simultaneous editors
- **Page Views**: Handle 1M+ page views per hour
- **Search Queries**: Process 100,000+ searches per hour
- **API Requests**: Support 50,000+ API calls per minute
- **File Storage**: Manage 10TB+ of content and attachments

### 3.2 Scalability Requirements

#### User Scaling
- **User Growth**: Scale from 100 to 100,000+ users
- **Content Volume**: Support millions of pages and attachments
- **Space Scaling**: Handle 10,000+ spaces per instance
- **Concurrent Editing**: 1,000+ users editing simultaneously
- **Global Distribution**: Multi-region deployment support

#### Infrastructure Scaling
- **Horizontal Scaling**: Auto-scale application instances
- **Database Scaling**: Read replicas and sharding support
- **Storage Scaling**: Elastic file storage with CDN integration
- **Cache Scaling**: Distributed caching across regions
- **Search Scaling**: Elasticsearch cluster auto-scaling

### 3.3 Availability & Reliability

#### Uptime Requirements
- **Service Availability**: 99.9% uptime SLA
- **Data Durability**: 99.999999999% (11 9's) data durability
- **Backup Recovery**: RTO < 4 hours, RPO < 1 hour
- **Disaster Recovery**: Multi-region failover capability
- **Maintenance Windows**: < 4 hours monthly planned downtime

#### Fault Tolerance
- **Auto-Recovery**: Automatic recovery from transient failures
- **Circuit Breakers**: Prevent cascade failures
- **Graceful Degradation**: Core features remain available during outages
- **Data Consistency**: Eventual consistency with conflict resolution
- **Load Balancing**: Traffic distribution across healthy instances

### 3.4 Security Requirements

#### Authentication & Authorization
- **Multi-Factor Authentication**: TOTP, SMS, hardware tokens
- **Single Sign-On**: SAML 2.0, OAuth 2.0, LDAP integration
- **Fine-Grained Permissions**: Page, space, and feature-level access control
- **Guest Access**: Controlled external user access
- **API Security**: OAuth 2.0 and API key authentication

#### Data Protection
- **Encryption at Rest**: AES-256 encryption for all stored data
- **Encryption in Transit**: TLS 1.3 for all communications
- **Data Loss Prevention**: Prevent unauthorized data export
- **Audit Logging**: Comprehensive activity tracking
- **Privacy Controls**: GDPR compliance and data portability

### 3.5 Compliance Requirements

#### Regulatory Compliance
- **SOC 2 Type II**: Annual security compliance certification
- **GDPR**: European data protection regulation compliance
- **HIPAA**: Healthcare data protection (optional module)
- **ISO 27001**: Information security management standards
- **FedRAMP**: US government cloud security standards

#### Data Governance
- **Data Retention**: Configurable retention policies
- **Data Classification**: Automatic content sensitivity detection
- **Data Archival**: Long-term storage for compliance
- **Right to Erasure**: Complete data deletion capabilities
- **Data Portability**: Export user data in standard formats

## 4. System Architecture

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Load Balancer / CDN                      │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                     API Gateway                                 │
│  - Authentication & Authorization                               │
│  - Rate Limiting & Request Routing                             │
│  - API Versioning & Documentation                              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                   Frontend Applications                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │   Web App   │ │ Mobile Apps │ │  Admin UI   │ │   Desktop   ││
│  │   (React)   │ │(iOS/Android)│ │   (React)   │ │    App      ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                    Core Services Layer                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │   Content   │ │    Space    │ │Collaboration│ │   Search    ││
│  │ Management  │ │ Management  │ │   Service   │ │   Service   ││
│  │   Service   │ │   Service   │ │             │ │             ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │  Template   │ │    Macro    │ │    File     │ │Notification ││
│  │   Service   │ │   Service   │ │   Service   │ │   Service   ││
│  │             │ │             │ │             │ │             ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                  Platform Services Layer                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │    User     │ │    Auth     │ │   Export    │ │  Analytics  ││
│  │ Management  │ │   Service   │ │   Service   │ │   Service   ││
│  │   Service   │ │             │ │             │ │             ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                   Infrastructure Layer                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │  Message    │ │   Cache     │ │   File      │ │  Monitoring ││
│  │   Queue     │ │   Layer     │ │  Storage    │ │ & Logging   ││
│  │ (Kafka)     │ │ (Redis)     │ │   (S3)      │ │(ELK/Grafana)││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                     Data Layer                                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │ PostgreSQL  │ │ Elasticsearch│ │   MongoDB   │ │   Redis     ││
│  │(Relational  │ │  (Search &  │ │ (Document   │ │  (Cache &   ││
│  │   Data)     │ │  Analytics) │ │   Store)    │ │  Sessions)  ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Microservices Architecture

#### Content Management Service
**Responsibilities:**
- Page CRUD operations and version management
- Content rendering and ADF processing
- Draft management and auto-save functionality
- Content validation and sanitization
- Page hierarchy and relationship management

**Technology Stack:**
- Runtime: Node.js 18+ with Express.js
- Database: MongoDB for flexible content storage
- Cache: Redis for rendered content caching
- Queue: Kafka for content change events

#### Space Management Service
**Responsibilities:**
- Space creation, configuration, and management
- Space permissions and access control
- Space templates and blueprints
- Space analytics and usage metrics
- Space archival and restoration

**Technology Stack:**
- Runtime: Java 17 with Spring Boot
- Database: PostgreSQL for structured space data
- Cache: Redis for permission caching
- Queue: Kafka for space events

#### Collaboration Service
**Responsibilities:**
- Real-time collaborative editing
- Comment management and threading
- User presence and activity tracking
- Conflict resolution and operational transforms
- Review and approval workflows

**Technology Stack:**
- Runtime: Node.js with Socket.io
- Database: MongoDB for real-time data
- Cache: Redis for session management
- WebSocket: Real-time communication

#### Search Service
**Responsibilities:**
- Content indexing and search
- Advanced search with filters and facets
- Search suggestions and auto-complete
- Content recommendations
- Search analytics and optimization

**Technology Stack:**
- Runtime: Python with FastAPI
- Search Engine: Elasticsearch cluster
- Cache: Redis for search results
- Queue: Kafka for indexing events

## 5. Data Models & Storage

### 5.1 Content Storage (MongoDB)

#### Page Document Schema
```javascript
// Page Collection
{
  _id: ObjectId("..."),
  spaceId: ObjectId("..."),
  title: "Getting Started Guide",
  slug: "getting-started-guide",
  
  // Atlassian Document Format (ADF)
  content: {
    version: 1,
    type: "doc",
    content: [
      {
        type: "heading",
        attrs: { level: 1 },
        content: [
          {
            type: "text",
            text: "Getting Started"
          }
        ]
      },
      {
        type: "paragraph",
        content: [
          {
            type: "text",
            text: "Welcome to our platform..."
          }
        ]
      }
    ]
  },
  
  // Page metadata
  parentId: ObjectId("..."), // null for root pages
  position: 0, // Order within parent
  depth: 1, // Hierarchy depth
  
  // Authoring information
  createdBy: ObjectId("..."),
  updatedBy: ObjectId("..."),
  createdAt: ISODate("..."),
  updatedAt: ISODate("..."),
  
  // Status and workflow
  status: "published", // draft, published, archived
  publishedAt: ISODate("..."),
  
  // Version control
  version: 5,
  versionComment: "Updated installation instructions",
  
  // Organization
  labels: ["tutorial", "onboarding", "beginner"],
  
  // Permissions (inherited from space if not specified)
  permissions: {
    view: ["space:view"],
    edit: ["space:edit"],
    admin: ["space:admin"]
  },
  
  // Attachments
  attachments: [
    {
      id: ObjectId("..."),
      filename: "architecture-diagram.png",
      contentType: "image/png",
      size: 1024000,
      storageKey: "attachments/space123/page456/arch-diagram.png",
      uploadedBy: ObjectId("..."),
      uploadedAt: ISODate("...")
    }
  ],
  
  // Analytics
  analytics: {
    views: 1250,
    uniqueViews: 890,
    lastViewed: ISODate("..."),
    avgTimeOnPage: 180, // seconds
    popularityScore: 0.85
  },
  
  // SEO and metadata
  excerpt: "Learn how to get started with our platform...",
  metaDescription: "Complete guide to getting started...",
  
  // Full-text search
  searchableContent: "Getting Started Welcome to our platform...",
  
  // Indexing
  indexes: {
    spaceId: 1,
    parentId: 1,
    createdAt: -1,
    updatedAt: -1,
    status: 1,
    labels: 1,
    "analytics.popularityScore": -1
  }
}

// Page Version History Collection
{
  _id: ObjectId("..."),
  pageId: ObjectId("..."),
  version: 4,
  content: { /* Previous version content */ },
  updatedBy: ObjectId("..."),
  updatedAt: ISODate("..."),
  versionComment: "Fixed typos and added examples",
  changeType: "minor", // major, minor, patch
  
  // Change tracking
  changes: [
    {
      type: "text_change",
      path: ["content", 1, "content", 0, "text"],
      oldValue: "Welcome to platform",
      newValue: "Welcome to our platform"
    }
  ]
}
```

#### Comment System Schema
```javascript
// Comments Collection
{
  _id: ObjectId("..."),
  pageId: ObjectId("..."),
  
  // Comment content
  content: "This section needs more detail about error handling",
  contentType: "text", // text, rich_text
  
  // Comment positioning (for inline comments)
  anchor: {
    type: "text_selection",
    startOffset: 150,
    endOffset: 200,
    selectedText: "error handling"
  },
  
  // Threading
  parentCommentId: ObjectId("..."), // null for root comments
  threadId: ObjectId("..."), // groups related comments
  
  // Authoring
  authorId: ObjectId("..."),
  createdAt: ISODate("..."),
  updatedAt: ISODate("..."),
  
  // Status
  status: "open", // open, resolved, deleted
  resolvedBy: ObjectId("..."),
  resolvedAt: ISODate("..."),
  
  // Mentions
  mentions: [ObjectId("user1"), ObjectId("user2")],
  
  // Reactions
  reactions: {
    "👍": [ObjectId("user1"), ObjectId("user3")],
    "❤️": [ObjectId("user2")]
  }
}
```

### 5.2 Space Management (PostgreSQL)

#### Space Schema
```sql
-- Spaces table
CREATE TABLE spaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(50) UNIQUE NOT NULL, -- URL-friendly identifier
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Space type and configuration
    type VARCHAR(50) NOT NULL DEFAULT 'team', -- team, personal, project, knowledge_base
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, archived, deleted
    
    -- Ownership and permissions
    owner_id UUID NOT NULL REFERENCES users(id),
    created_by UUID NOT NULL REFERENCES users(id),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE,
    
    -- Configuration
    settings JSONB NOT NULL DEFAULT '{}',
    
    -- Homepage configuration
    homepage_id UUID, -- References page in MongoDB
    
    -- Theme and branding
    theme JSONB DEFAULT '{}',
    
    -- Analytics
    analytics JSONB DEFAULT '{}',
    
    -- Search and indexing
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', name || ' ' || COALESCE(description, ''))
    ) STORED
);

-- Space permissions
CREATE TABLE space_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    
    -- Permission subject (user or group)
    subject_type VARCHAR(20) NOT NULL, -- user, group, anonymous, authenticated
    subject_id UUID, -- NULL for anonymous/authenticated
    
    -- Permission level
    permission VARCHAR(50) NOT NULL, -- view, create, edit, admin
    
    -- Grant details
    granted_by UUID NOT NULL REFERENCES users(id),
    granted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(space_id, subject_type, subject_id, permission)
);

-- Space templates
CREATE TABLE space_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    
    -- Template configuration
    template_data JSONB NOT NULL,
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Availability
    is_global BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Usage tracking
    usage_count INTEGER NOT NULL DEFAULT 0
);

-- Indexes for performance
CREATE INDEX idx_spaces_owner ON spaces(owner_id);
CREATE INDEX idx_spaces_type_status ON spaces(type, status);
CREATE INDEX idx_spaces_created_at ON spaces(created_at DESC);
CREATE INDEX idx_spaces_search ON spaces USING gin(search_vector);

CREATE INDEX idx_space_permissions_space ON space_permissions(space_id);
CREATE INDEX idx_space_permissions_subject ON space_permissions(subject_type, subject_id);
```

### 5.3 User Management (PostgreSQL)

#### User and Authentication Schema
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    
    -- Profile information
    display_name VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url VARCHAR(500),
    bio TEXT,
    
    -- Account status
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, inactive, suspended
    email_verified BOOLEAN NOT NULL DEFAULT false,
    
    -- Authentication
    password_hash VARCHAR(255), -- NULL for SSO-only users
    password_changed_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-factor authentication
    mfa_enabled BOOLEAN NOT NULL DEFAULT false,
    mfa_secret VARCHAR(255),
    backup_codes TEXT[], -- Encrypted backup codes
    
    -- Preferences
    preferences JSONB NOT NULL DEFAULT '{}',
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en-US',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', 
            display_name || ' ' || 
            username || ' ' || 
            email || ' ' || 
            COALESCE(first_name, '') || ' ' || 
            COALESCE(last_name, '')
        )
    ) STORED
);

-- User groups
CREATE TABLE user_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Group type
    type VARCHAR(50) NOT NULL DEFAULT 'custom', -- system, ldap, custom
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Configuration
    settings JSONB DEFAULT '{}'
);

-- Group memberships
CREATE TABLE group_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Membership details
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- member, admin
    added_by UUID NOT NULL REFERENCES users(id),
    added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    UNIQUE(group_id, user_id)
);

-- User sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Session details
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    
    -- Client information
    ip_address INET,
    user_agent TEXT,
    device_info JSONB,
    
    -- Session lifecycle
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_accessed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_search ON users USING gin(search_vector);

CREATE INDEX idx_group_memberships_group ON group_memberships(group_id);
CREATE INDEX idx_group_memberships_user ON group_memberships(user_id);

CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);
```

### 5.4 Search Index (Elasticsearch)

#### Content Index Mapping
```json
{
  "mappings": {
    "properties": {
      "id": {
        "type": "keyword"
      },
      "type": {
        "type": "keyword"
      },
      "spaceId": {
        "type": "keyword"
      },
      "spaceKey": {
        "type": "keyword"
      },
      "spaceName": {
        "type": "text",
        "analyzer": "standard"
      },
      "title": {
        "type": "text",
        "analyzer": "standard",
        "fields": {
          "keyword": {
            "type": "keyword"
          },
          "suggest": {
            "type": "completion"
          }
        }
      },
      "content": {
        "type": "text",
        "analyzer": "standard"
      },
      "excerpt": {
        "type": "text",
        "analyzer": "standard"
      },
      "labels": {
        "type": "keyword"
      },
      "authorId": {
        "type": "keyword"
      },
      "authorName": {
        "type": "text",
        "analyzer": "standard"
      },
      "createdAt": {
        "type": "date"
      },
      "updatedAt": {
        "type": "date"
      },
      "status": {
        "type": "keyword"
      },
      "permissions": {
        "type": "nested",
        "properties": {
          "type": {
            "type": "keyword"
          },
          "subjects": {
            "type": "keyword"
          }
        }
      },
      "analytics": {
        "properties": {
          "views": {
            "type": "integer"
          },
          "uniqueViews": {
            "type": "integer"
          },
          "popularityScore": {
            "type": "float"
          }
        }
      },
      "attachments": {
        "type": "nested",
        "properties": {
          "filename": {
            "type": "text",
            "analyzer": "standard"
          },
          "contentType": {
            "type": "keyword"
          },
          "extractedText": {
            "
            "type": "text",
            "analyzer": "standard"
          }
        }
      }
    }
  },
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "content_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "stop",
            "snowball"
          ]
        }
      }
    }
  }
}
```

## 6. API Specifications

### 6.1 REST API Design

#### Content Management API
```yaml
openapi: 3.0.3
info:
  title: Confluence Content API
  description: API for managing pages, spaces, and content
  version: 1.0.0

paths:
  /api/v1/spaces:
    get:
      summary: List spaces
      parameters:
        - name: type
          in: query
          schema:
            type: string
            enum: [team, personal, project, knowledge_base]
        - name: limit
          in: query
          schema:
            type: integer
            default: 25
            maximum: 100
        - name: start
          in: query
          schema:
            type: integer
            default: 0
      responses:
        '200':
          description: List of spaces
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      $ref: '#/components/schemas/Space'
                  start:
                    type: integer
                  limit:
                    type: integer
                  size:
                    type: integer
                  _links:
                    $ref: '#/components/schemas/Links'
    
    post:
      summary: Create space
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateSpaceRequest'
      responses:
        '201':
          description: Space created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Space'

  /api/v1/spaces/{spaceKey}:
    get:
      summary: Get space
      parameters:
        - name: spaceKey
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Space details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Space'
    
    put:
      summary: Update space
      parameters:
        - name: spaceKey
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateSpaceRequest'
      responses:
        '200':
          description: Space updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Space'

  /api/v1/spaces/{spaceKey}/content:
    get:
      summary: List content in space
      parameters:
        - name: spaceKey
          in: path
          required: true
          schema:
            type: string
        - name: type
          in: query
          schema:
            type: string
            enum: [page, blogpost, comment, attachment]
        - name: status
          in: query
          schema:
            type: string
            enum: [current, trashed, draft]
        - name: depth
          in: query
          schema:
            type: string
            enum: [all, root]
        - name: expand
          in: query
          schema:
            type: string
            description: "Comma-separated list of properties to expand"
      responses:
        '200':
          description: Content list
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      $ref: '#/components/schemas/Content'

  /api/v1/content:
    get:
      summary: Search content
      parameters:
        - name: cql
          in: query
          schema:
            type: string
          description: "Confluence Query Language query"
        - name: expand
          in: query
          schema:
            type: string
        - name: limit
          in: query
          schema:
            type: integer
            default: 25
      responses:
        '200':
          description: Search results
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      $ref: '#/components/schemas/Content'
    
    post:
      summary: Create content
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateContentRequest'
      responses:
        '201':
          description: Content created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Content'

  /api/v1/content/{contentId}:
    get:
      summary: Get content
      parameters:
        - name: contentId
          in: path
          required: true
          schema:
            type: string
        - name: expand
          in: query
          schema:
            type: string
        - name: version
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Content details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Content'
    
    put:
      summary: Update content
      parameters:
        - name: contentId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateContentRequest'
      responses:
        '200':
          description: Content updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Content'
    
    delete:
      summary: Delete content
      parameters:
        - name: contentId
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Content deleted

  /api/v1/content/{contentId}/child:
    get:
      summary: Get child content
      parameters:
        - name: contentId
          in: path
          required: true
          schema:
            type: string
        - name: type
          in: query
          schema:
            type: string
            enum: [page, comment, attachment]
      responses:
        '200':
          description: Child content
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      $ref: '#/components/schemas/Content'

components:
  schemas:
    Space:
      type: object
      properties:
        id:
          type: string
        key:
          type: string
        name:
          type: string
        description:
          type: string
        type:
          type: string
          enum: [team, personal, project, knowledge_base]
        status:
          type: string
          enum: [active, archived]
        homepage:
          $ref: '#/components/schemas/Content'
        permissions:
          type: array
          items:
            $ref: '#/components/schemas/Permission'
        _links:
          $ref: '#/components/schemas/Links'
    
    Content:
      type: object
      properties:
        id:
          type: string
        type:
          type: string
          enum: [page, blogpost, comment, attachment]
        status:
          type: string
          enum: [current, trashed, draft]
        title:
          type: string
        space:
          $ref: '#/components/schemas/Space'
        body:
          $ref: '#/components/schemas/ContentBody'
        version:
          $ref: '#/components/schemas/Version'
        ancestors:
          type: array
          items:
            $ref: '#/components/schemas/Content'
        children:
          type: object
          properties:
            page:
              type: object
              properties:
                results:
                  type: array
                  items:
                    $ref: '#/components/schemas/Content'
        metadata:
          type: object
        _links:
          $ref: '#/components/schemas/Links'
    
    ContentBody:
      type: object
      properties:
        storage:
          type: object
          properties:
            value:
              type: string
              description: "Content in Atlassian Document Format"
            representation:
              type: string
              enum: [storage, view, export_view, styled_view, editor]
        view:
          type: object
          properties:
            value:
              type: string
              description: "Rendered HTML content"
            representation:
              type: string
    
    Version:
      type: object
      properties:
        by:
          $ref: '#/components/schemas/User'
        when:
          type: string
          format: date-time
        friendlyWhen:
          type: string
        message:
          type: string
        number:
          type: integer
        minorEdit:
          type: boolean
    
    User:
      type: object
      properties:
        accountId:
          type: string
        accountType:
          type: string
        email:
          type: string
        publicName:
          type: string
        displayName:
          type: string
        profilePicture:
          type: object
          properties:
            path:
              type: string
            width:
              type: integer
            height:
              type: integer
            isDefault:
              type: boolean
    
    Permission:
      type: object
      properties:
        subjects:
          type: object
          properties:
            user:
              type: object
              properties:
                results:
                  type: array
                  items:
                    $ref: '#/components/schemas/User'
            group:
              type: object
              properties:
                results:
                  type: array
                  items:
                    $ref: '#/components/schemas/Group'
        operation:
          type: object
          properties:
            operation:
              type: string
              enum: [create, read, update, delete, export, administer]
            targetType:
              type: string
              enum: [space, page, blogpost, comment, attachment]
    
    Links:
      type: object
      properties:
        base:
          type: string
        context:
          type: string
        self:
          type: string
        tinyui:
          type: string
        editui:
          type: string
        webui:
          type: string
```

### 6.2 Real-Time Collaboration API

#### WebSocket Events
```javascript
// WebSocket Event Types
const COLLABORATION_EVENTS = {
  // Document editing
  DOCUMENT_OPENED: 'document:opened',
  DOCUMENT_CLOSED: 'document:closed',
  CONTENT_CHANGED: 'content:changed',
  CURSOR_MOVED: 'cursor:moved',
  SELECTION_CHANGED: 'selection:changed',
  
  // User presence
  USER_JOINED: 'user:joined',
  USER_LEFT: 'user:left',
  USER_ACTIVE: 'user:active',
  USER_IDLE: 'user:idle',
  
  // Comments
  COMMENT_ADDED: 'comment:added',
  COMMENT_UPDATED: 'comment:updated',
  COMMENT_DELETED: 'comment:deleted',
  COMMENT_RESOLVED: 'comment:resolved',
  
  // Notifications
  MENTION_ADDED: 'mention:added',
  PAGE_SHARED: 'page:shared'
};

// Operational Transform for Collaborative Editing
class OperationalTransform {
  // Transform operation against concurrent operation
  static transform(op1, op2, priority) {
    if (op1.type === 'insert' && op2.type === 'insert') {
      if (op1.position <= op2.position && priority === 'left') {
        return {
          ...op2,
          position: op2.position + op1.text.length
        };
      } else if (op1.position < op2.position) {
        return {
          ...op2,
          position: op2.position + op1.text.length
        };
      }
      return op2;
    }
    
    if (op1.type === 'delete' && op2.type === 'insert') {
      if (op1.position <= op2.position) {
        return {
          ...op2,
          position: Math.max(op2.position - op1.length, op1.position)
        };
      }
      return op2;
    }
    
    if (op1.type === 'insert' && op2.type === 'delete') {
      if (op1.position <= op2.position) {
        return {
          ...op2,
          position: op2.position + op1.text.length
        };
      }
      return op2;
    }
    
    if (op1.type === 'delete' && op2.type === 'delete') {
      if (op1.position <= op2.position) {
        return {
          ...op2,
          position: Math.max(op2.position - op1.length, op1.position),
          length: Math.max(0, op2.length - Math.max(0, op1.position + op1.length - op2.position))
        };
      }
      return op2;
    }
    
    return op2;
  }
  
  // Apply operation to document
  static apply(document, operation) {
    switch (operation.type) {
      case 'insert':
        return document.slice(0, operation.position) + 
               operation.text + 
               document.slice(operation.position);
      
      case 'delete':
        return document.slice(0, operation.position) + 
               document.slice(operation.position + operation.length);
      
      case 'retain':
        return document;
      
      default:
        throw new Error(`Unknown operation type: ${operation.type}`);
    }
  }
}

// WebSocket Server Implementation
class CollaborationServer {
  constructor() {
    this.rooms = new Map(); // documentId -> Set of connections
    this.documentStates = new Map(); // documentId -> document state
    this.operationHistory = new Map(); // documentId -> operation history
  }
  
  handleConnection(socket) {
    socket.on('join-document', (data) => {
      const { documentId, userId } = data;
      
      // Add user to room
      if (!this.rooms.has(documentId)) {
        this.rooms.set(documentId, new Set());
      }
      this.rooms.get(documentId).add(socket);
      
      // Send current document state
      socket.emit('document-state', {
        content: this.documentStates.get(documentId) || '',
        version: this.getDocumentVersion(documentId),
        collaborators: this.getCollaborators(documentId)
      });
      
      // Notify other users
      this.broadcastToRoom(documentId, 'user-joined', {
        userId,
        timestamp: Date.now()
      }, socket);
    });
    
    socket.on('operation', (data) => {
      const { documentId, operation, version } = data;
      
      // Transform operation against concurrent operations
      const transformedOp = this.transformOperation(documentId, operation, version);
      
      // Apply operation to document
      const currentContent = this.documentStates.get(documentId) || '';
      const newContent = OperationalTransform.apply(currentContent, transformedOp);
      this.documentStates.set(documentId, newContent);
      
      // Store operation in history
      this.addToHistory(documentId, transformedOp);
      
      // Broadcast to other users
      this.broadcastToRoom(documentId, 'operation', {
        operation: transformedOp,
        version: this.getDocumentVersion(documentId),
        userId: data.userId
      }, socket);
    });
    
    socket.on('cursor-position', (data) => {
      const { documentId, position, selection } = data;
      
      this.broadcastToRoom(documentId, 'cursor-update', {
        userId: data.userId,
        position,
        selection,
        timestamp: Date.now()
      }, socket);
    });
    
    socket.on('disconnect', () => {
      // Remove from all rooms
      for (const [documentId, connections] of this.rooms.entries()) {
        if (connections.has(socket)) {
          connections.delete(socket);
          this.broadcastToRoom(documentId, 'user-left', {
            userId: socket.userId,
            timestamp: Date.now()
          });
        }
      }
    });
  }
  
  transformOperation(documentId, operation, clientVersion) {
    const history = this.operationHistory.get(documentId) || [];
    const serverVersion = history.length;
    
    if (clientVersion === serverVersion) {
      return operation; // No transformation needed
    }
    
    // Transform against operations that happened after client version
    let transformedOp = operation;
    for (let i = clientVersion; i < serverVersion; i++) {
      transformedOp = OperationalTransform.transform(
        history[i], 
        transformedOp, 
        'left'
      );
    }
    
    return transformedOp;
  }
  
  broadcastToRoom(documentId, event, data, excludeSocket = null) {
    const connections = this.rooms.get(documentId);
    if (connections) {
      connections.forEach(socket => {
        if (socket !== excludeSocket) {
          socket.emit(event, data);
        }
      });
    }
  }
}
```

## 7. Real-Time Collaboration

### 7.1 Collaborative Editing Architecture

#### Conflict-Free Replicated Data Types (CRDTs)
```javascript
// Y.js integration for collaborative editing
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';
import { QuillBinding } from 'y-quill';

class CollaborativeEditor {
  constructor(documentId, userId) {
    this.documentId = documentId;
    this.userId = userId;
    
    // Create Y.js document
    this.ydoc = new Y.Doc();
    
    // Create shared text type
    this.ytext = this.ydoc.getText('content');
    
    // Set up WebSocket provider
    this.provider = new WebsocketProvider(
      'wss://collaboration.confluence.com',
      documentId,
      this.ydoc,
      {
        params: {
          userId: userId,
          token: this.getAuthToken()
        }
      }
    );
    
    // Set up awareness (user presence)
    this.awareness = this.provider.awareness;
    this.awareness.setLocalStateField('user', {
      id: userId,
      name: this.getUserName(),
      color: this.getUserColor(),
      cursor: null
    });
    
    // Listen for awareness changes
    this.awareness.on('change', this.handleAwarenessChange.bind(this));
    
    // Set up editor binding
    this.setupEditor();
  }
  
  setupEditor() {
    // Initialize Quill editor
    this.quill = new Quill('#editor', {
      theme: 'snow',
      modules: {
        toolbar: [
          ['bold', 'italic', 'underline', 'strike'],
          ['blockquote', 'code-block'],
          [{ 'header': 1 }, { 'header': 2 }],
          [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          [{ 'script': 'sub'}, { 'script': 'super' }],
          [{ 'indent': '-1'}, { 'indent': '+1' }],
          [{ 'direction': 'rtl' }],
          [{ 'size': ['small', false, 'large', 'huge'] }],
          [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
          [{ 'color': [] }, { 'background': [] }],
          [{ 'font': [] }],
          [{ 'align': [] }],
          ['clean'],
          ['link', 'image', 'video']
        ],
        cursors: true
      }
    });
    
    // Bind Y.js text to Quill
    this.binding = new QuillBinding(this.ytext, this.quill, this.awareness);
    
    // Handle cursor position updates
    this.quill.on('selection-change', (range) => {
      if (range) {
        this.awareness.setLocalStateField('cursor', {
          index: range.index,
          length: range.length
        });
      }
    });
  }
  
  handleAwarenessChange(changes) {
    // Update user presence indicators
    const users = Array.from(this.awareness.getStates().values())
      .filter(state => state.user && state.user.id !== this.userId);
    
    this.updatePresenceIndicators(users);
  }
  
  updatePresenceIndicators(users) {
    const presenceContainer = document.getElementById('presence-indicators');
    presenceContainer.innerHTML = '';
    
    users.forEach(user => {
      const indicator = document.createElement('div');
      indicator.className = 'presence-indicator';
      indicator.style.backgroundColor = user.user.color;
      indicator.textContent = user.user.name.charAt(0).toUpperCase();
      indicator.title = `${user.user.name} is editing`;
      presenceContainer.appendChild(indicator);
    });
  }
  
  // Save document to server
  async saveDocument() {
    const content = this.ytext.toString();
    const adfContent = this.convertToADF(content);
    
    try {
      await fetch(`/api/v1/content/${this.documentId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.getAuthToken()}`
        },
        body: JSON.stringify({
          version: {
            number: await this.getNextVersion()
          },
          body: {
            storage: {
              value: adfContent,
              representation: 'storage'
            }
          }
        })
      });
      
      this.showSaveStatus('saved');
    } catch (error) {
      this.showSaveStatus('error');
      console.error('Failed to save document:', error);
    }
  }
  
  convertToADF(content) {
    // Convert editor content to Atlassian Document Format
    // This is a simplified example - real implementation would be more complex
    return {
      version: 1,
      type: 'doc',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: content
            }
          ]
        }
      ]
    };
  }
  
  destroy() {
    this.binding.destroy();
    this.provider.destroy();
    this.ydoc.destroy();
  }
}
```

### 7.2 Comment System Implementation

#### Real-Time Comments
```javascript
class CommentSystem {
  constructor(pageId, userId) {
    this.pageId = pageId;
    this.userId = userId;
    this.comments = new Map();
    this.socket = io('/comments');
    
    this.setupSocketListeners();
    this.loadExistingComments();
  }
  
  setupSocketListeners() {
    this.socket.on('comment:added', (comment) => {
      this.addCommentToUI(comment);
    });
    
    this.socket.on('comment:updated', (comment) => {
      this.updateCommentInUI(comment);
    });
    
    this.socket.on('comment:deleted', (commentId) => {
      this.removeCommentFromUI(commentId);
    });
    
    this.socket.on('comment:resolved', (commentId) => {
      this.markCommentResolved(commentId);
    });
  }
  
  async loadExistingComments() {
    try {
      const response = await fetch(`/api/v1/content/${this.pageId}/child/comment`);
      const data = await response.json();
      
      data.results.forEach(comment => {
        this.addCommentToUI(comment);
      });
    } catch (error) {
      console.error('Failed to load comments:', error);
    }
  }
  
  addInlineComment(selection, content) {
    const commentData = {
      pageId: this.pageId,
      content: content,
      anchor: {
        type: 'text_selection',
        startOffset: selection.start,
        endOffset: selection.end,
        selectedText: selection.text
      },
      authorId: this.userId
    };
    
    // Emit to server
    this.socket.emit('comment:add', commentData);
    
    // Add comment indicator to text
    this.addCommentIndicator(selection, commentData);
  }
  
  addCommentIndicator(selection, comment) {
    const range = document.createRange();
    const textNode = this.getTextNodeAtOffset(selection.start);
    
    range.setStart(textNode, selection.start);
    range.setEnd(textNode, selection.end);
    
    const commentSpan = document.createElement('span');
    commentSpan.className = 'comment-highlight';
    commentSpan.dataset.commentId = comment.id;
    commentSpan.addEventListener('click', () => {
      this.showCommentThread(comment.id);
    });
    
    try {
      range.surroundContents(commentSpan);
    } catch (e) {
      // Handle complex selections that span multiple elements
      this.handleComplexSelection(range, commentSpan);
    }
  }
  
  showCommentThread(commentId) {
    const comment = this.comments.get(commentId);
    if (!comment) return;
    
    const sidebar = document.getElementById('comment-sidebar');
    const threadContainer = document.createElement('div');
    threadContainer.className = 'comment-thread';
    threadContainer.innerHTML = `
      <div class="comment-header">
        <img src="${comment.author.avatar}" class="comment-avatar">
        <div class="comment-meta">
          <span class="comment-author">${comment.author.displayName}</span>
          <span class="comment-time">${this.formatTime(comment.createdAt)}</span>
        </div>
      </div>
      <div class="comment-content">${comment.content}</div>
      <div class="comment-actions">
        <button onclick="this.replyToComment('${commentId}')">Reply</button>
        <button onclick="this.resolveComment('${commentId}')">Resolve</button>
      </div>
      <div class="comment-replies" id="replies-${commentId}"></div>
    `;
    
    sidebar.appendChild(threadContainer);
    sidebar.classList.add('visible');
  }
  
  replyToComment(parentCommentId) {
    const replyForm = document.createElement('div');
    replyForm.className = 'reply-form';
    replyForm.innerHTML = `
      <textarea placeholder="Add a reply..." class="reply-input"></textarea>
      <div class="reply-actions">
        <button onclick="this.submitReply('${parentCommentId}')">Reply</button>
        <button onclick="this.cancelReply()">Cancel</button>
      </div>
    `;
    
    const repliesContainer = document.getElementById(`replies-${parentCommentId}`);
    repliesContainer.appendChild(replyForm);
  }
  
  submitReply(parentCommentId, content) {
    const replyData = {
      pageId: this.pageId,
      parentCommentId: parentCommentId,
      content: content,
      authorId: this.userId
    };
    
    this.socket.emit('comment:add', replyData);
  }
  
  resolveComment(commentId) {
    this.socket.emit('comment:resolve', {
      commentId: commentId,
      resolvedBy: this.userId
    });
  }
  
  addCommentToUI(comment) {
    this.comments.set(comment.id, comment);
    
    if (comment.anchor) {
      // Inline comment
      this.addCommentIndicator(comment.anchor, comment);
    } else {
      // Page comment
      this.addPageComment(comment);
    }
  }
  
  updateCommentInUI(comment) {
    this.comments.set(comment.id, comment);
    
    const commentElement = document.querySelector(`[data-comment-id="${comment.id}"]`);
    if (commentElement) {
      const contentElement = commentElement.querySelector('.comment-content');
      contentElement.textContent = comment.content;
    }
  }
  
  removeCommentFromUI(commentId) {
    this.comments.delete(commentId);
    
    const commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
    if (commentElement) {
      commentElement.remove();
    }
  }
  
  markCommentResolved(commentId) {
    const comment = this.comments.get(commentId);
    if (comment) {
      comment.status = 'resolved';
      
      const commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
      if (commentElement) {
        commentElement.classList.add('resolved');
      }
    }
  }
}
```

## 8. Search & Discovery

### 8.1 Advanced Search Implementation

#### Elasticsearch Query Builder
```javascript
class ConfluenceSearchService {
  constructor(elasticsearchClient) {
    this.client = elasticsearchClient;
    this.index = 'confluence-content';
  }
  
  async search(query, filters = {}, options = {}) {
    const searchBody = this.buildSearchQuery(query, filters, options);
    
    try {
      const response = await this.client.search({
        index: this.index,
        body: searchBody
      });
      
      return this.formatSearchResults(response);
    } catch (error) {
      console.error('Search failed:', error);
      throw new SearchError('Search request failed', error);
    }
  }
  
  buildSearchQuery(query, filters, options) {
    const must = [];
    const filter = [];
    const should = [];
    
    // Main text search
    if (query && query.trim()) {
      must.push({
        multi_match: {
          query: query,
          fields: [
            'title^3',
            'content^2',
            'excerpt',
            'labels',
            'spaceName',
            'authorName'
          ],
          type: 'best_fields',
          fuzziness: 'AUTO',
          operator: 'and'
        }
      });
      
      // Boost exact phrase matches
      should.push({
        multi_match: {
          query: query,
          fields: ['title^5', 'content^3'],
          type: 'phrase',
          boost: 2
        }
      });
      
      // Boost title matches
      should.push({
        match: {
          'title.keyword': {
            query: query,
            boost: 3
          }
        }
      });
    }
    
    // Space filter
    if (filters.spaceKeys && filters.spaceKeys.length > 0) {
      filter.push({
        terms: {
          spaceKey: filters.spaceKeys
        }
      });
    }
    
    // Author filter
    if (filters.authorIds && filters.authorIds.length > 0) {
      filter.push({
        terms: {
          authorId: filters.authorIds
        }
      });
    }
    
    // Date range filter
    if (filters.dateRange) {
      const dateFilter = {
        range: {
          updatedAt: {}
        }
      };
      
      if (filters.dateRange.from) {
        dateFilter.range.updatedAt.gte = filters.dateRange.from;
      }
      
      if (filters.dateRange.to) {
        dateFilter.range.updatedAt.lte = filters.dateRange.to;
      }
      
      filter.push(dateFilter);
    }
    
    // Content type filter
    if (filters.contentTypes && filters.contentTypes.length > 0) {
      filter.push({
        terms: {
          type: filters.contentTypes
        }
      });
    }
    
    // Labels filter
    if (filters.labels && filters.labels.length > 0) {
      filter.push({
        terms: {
          labels: filters.labels
        }
      });
    }
    
    // Permission filter - only show content user can access
    if (filters.userId) {
      should.push(
        // Public content
        { term: { 'permissions.type': 'public' } },
        // User has explicit permission
        { term: { 'permissions.subjects': filters.userId } },
        // User's groups have permission
        { terms: { 'permissions.subjects': filters.userGroups || [] } }
      );
    }
    
    const searchBody = {
      query: {
        bool: {
          must: must,
          filter: filter,
          should: should.length > 0 ? should : undefined,
          minimum_should_match: should.length > 0 ? 1 : undefined
        }
      },
      highlight: {
        fields: {
          title: {
            pre_tags: ['<mark>'],
            post_tags: ['</mark>'],
            number_of_fragments: 0
          },
          content: {
            pre_tags: ['<mark>'],
            post_tags: ['</mark>'],
            fragment_size: 150,
            number_of_fragments: 3
          }
        }
      },
      sort: this.buildSortCriteria(options.sort),
      from: options.from || 0,
      size: options.size || 25,
      _source: [
        'id', 'type', 'title', 'excerpt', 'spaceId', 'spaceKey', 'spaceName',
        'authorId', 'authorName', 'createdAt', 'updatedAt', 'labels',
        'analytics.views', 'analytics.popularityScore'
      ]
    };
    
    // Add aggregations for faceted search
    if (options.includeFacets) {
      searchBody.aggs = {
        spaces: {
          terms: {
            field: 'spaceKey',
            size: 20
          }
        },
        authors: {
          terms: {
            field: 'authorId',
            size: 20
          }
        },
        contentTypes: {
          terms: {
            field: 'type',
            size: 10
          }
        },
        labels: {
          terms: {
            field: 'labels',
            size: 50
          }
        },
        dateHistogram: {
          date_histogram: {
            field: 'updatedAt',
            calendar_interval: 'month',
            format: 'yyyy-MM'
          }
        }
      };
    }
    
    return searchBody;
  }
  
  buildSortCriteria(sortOption) {
    switch (sortOption) {
      case 'relevance':
        return [
          '_score',
          { 'analytics.popularityScore': { order: 'desc' } },
          { updatedAt: { order: 'desc' } }
        ];
      
      case 'newest':
        return [{ createdAt: { order: 'desc' } }];
      
      case 'oldest':
        return [{ createdAt: { order: 'asc' } }];
      
      case 'updated':
        return [{ updatedAt: { order: 'desc' } }];
      
      case 'popular':
        return [
          { 'analytics.views': { order: 'desc' } },
          { 'analytics.popularityScore': { order: 'desc' } }
        ];
      
      case 'title':
        return [{ 'title.keyword': { order: 'asc' } }];
      
      default:
        return ['_score'];
    }
  }
  
  formatSearchResults(response) {
    const results = response.body.hits.hits.map(hit => ({
      id: hit._source.id,
      type: hit._source.type,
      title: hit._source.title,
      excerpt: hit._source.excerpt,
      space: {
        id: hit._source.spaceId,
        key: hit._source.spaceKey,
        name: hit._source.spaceName
      },
      author: {
        id: hit._source.authorId,
        name: hit._source.authorName
      },
      createdAt: hit._source.createdAt,
      updatedAt: hit._source.updatedAt,
      labels: hit._source.labels,
      analytics: {
        views: hit._source.analytics?.views || 0,
        popularityScore: hit._source.analytics?.popularityScore || 0
      },
      highlights: hit.highlight,
      score: hit._score
    }));
    
    return {
      results: results,
      total: response.body.hits.total.value,
      maxScore: response.body.hits.max_score,
      facets: response.body.aggregations ? this.formatFacets(response.body.aggregations) : null,
      took: response.body.took
    };
  }
  
  formatFacets(aggregations) {
    return {
      spaces: aggregations.spaces.buckets.map(bucket => ({
        key: bucket.key,
        count: bucket.doc_count
      })),
      authors: aggregations.authors.buckets.map(bucket => ({
        key: bucket.key,
        count: bucket.doc_count
      })),
      contentTypes: aggregations.contentTypes.buckets.map(bucket => ({
        key: bucket.key,
        count: bucket.doc_count
      })),
      labels: aggregations.labels.buckets.map(bucket => ({
        key: bucket.key,
        count: bucket.doc_count
      })),
      dateHistogram: aggregations.dateHistogram.buckets.map(bucket => ({
        key: bucket.key_as_string,
        count: bucket.doc_count
      }))
    };
  }
  
  async suggest(query, options = {}) {
    const suggestBody = {
      suggest: {
        title_suggest: {
          prefix: query,
          completion: {
            field: 'title.suggest',
            size: options.size || 10,
            contexts: {
              space: options.spaceKeys || []
            }
          }
        },
        content_suggest: {
          text: query,
          phrase: {
            field: 'content',
            size: options.size || 5,
            gram_size: 3,
            direct_generator: [{
              field: 'content',
              suggest_mode: 'always'
            }],
            highlight: {
              pre_tag: '<em>',
              post_tag: '</em>'
            }
          }
        }
      }
    };
    
    const response = await this.client.search({
      index: this.index,
      body: suggestBody
    });
    
    return {
      titleSuggestions: response.body.suggest.title_suggest[0].options,
      contentSuggestions: response.body.suggest.content_suggest[0].options
    };
  }
}
```

### 8.2 Content Recommendation Engine

#### AI-Powered Recommendations
```python
# Python-based recommendation service
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import LatentDirichletAllocation
import pandas as pd
from typing import List, Dict, Tuple

class ContentRecommendationEngine:
    def __init__(self):
        self.tfidf_vectorizer = TfidfVectorizer(
            max_features=10000,
            stop_words='english',
            ngram_range=(1, 2)
        )
        self.lda_model = LatentDirichletAllocation(
            n_components=50,
            random_state=42
        )
        self.content_vectors = None
        self.content_topics = None
        self.content_metadata = {}
        
    def train_models(self, content_data: List[Dict]):
        """Train recommendation models on content corpus"""
        
        # Prepare text data
        texts = []
        for content in content_data:
            text = f"{content['title']} {content['content']} {' '.join(content.get('labels', []))}"
            texts.append(text)
            self.content_metadata[content['id']] = content
        
        # Train TF-IDF model
        self.content_vectors = self.tfidf_vectorizer.fit_transform(texts)
        
        # Train LDA topic model
        self.content_topics = self.lda_model.fit_transform(self.content_vectors)
        
        print(f"Trained models on {len(content_data)} documents")
        
    def get_similar_content(self, content_id: str, limit: int = 10) -> List[Dict]:
        """Find similar content based on TF-IDF similarity"""
        
        if content_id not in self.content_metadata:
            return []
        
        # Get content index
        content_ids = list(self.content_metadata.keys())
        content_index = content_ids.index(content_id)
        
        # Calculate cosine similarity
        similarities = cosine_similarity(
            self.content_vectors[content_index:content_index+1],
            self.content_vectors
        ).flatten()
        
        # Get top similar content (excluding self)
        similar_indices = similarities.argsort()[::-1][1:limit+1]
        
        recommendations = []
        for idx in similar_indices:
            similar_content_id = content_ids[idx]
            content = self.content_metadata[similar_content_id]
            
            recommendations.append({
                'id': similar_content_id,
                'title': content['title'],
                'space': content['space'],
                'similarity_score': float(similarities[idx]),
                'reason': 'Similar content'
            })
        
        return recommendations
    
    def get_topic_based_recommendations(self, user_id: str, limit: int = 10) -> List[Dict]:
        """Recommend content based on user's topic interests"""
        
        # Get user's reading history and preferences
        user_interests = self.get_user_topic_interests(user_id)
        
        if not user_interests:
            return self.get_popular_content(limit)
        
        # Calculate content scores based on topic alignment
        content_scores = []
        content_ids = list(self.content_metadata.keys())
        
        for i, content_id in enumerate(content_ids):
            content = self.content_metadata[content_id]
            
            # Skip if user already viewed
            if self.user_has_viewed(user_id, content_id):
                continue
            
            # Calculate topic alignment score
            topic_score = np.dot(user_interests, self.content_topics[i])
            
            # Apply additional factors
            recency_boost = self.calculate_recency_boost(content['updated_at'])
            popularity_boost = self.calculate_popularity_boost(content.get('views', 0))
            
            final_score = topic_score * recency_boost * popularity_boost
            
            content_scores.append({
                'id': content_id,
                'title': content['title'],
                'space': content['space'],
                'score': final_score,
                'reason': 'Based on your interests'
            })
        
        # Sort by score and return top recommendations
        content_scores.sort(key=lambda x: x['score'], reverse=True)
        return content_scores[:limit]
    
    def get_collaborative_recommendations(self, user_id: str, limit: int = 10) -> List[Dict]:
        """Recommend content based on similar users' behavior"""
        
        # Find users with similar reading patterns
        similar_users = self.find_similar_users(user_id)
        
        if not similar_users:
            return []
        
        # Get content viewed by similar users
        recommended_content = {}
        
        for similar_user_id, similarity_score in similar_users:
            user_content = self.get_user_viewed_content(similar_user_id)
            
            for content_id in user_content:
                # Skip if current user already viewed
                if self.user_has_viewed(user_id, content_id):
                    continue
                
                if content_id not in recommended_content:
                    recommended_content[content_id] = 0
                
                recommended_content[content_id] += similarity_score
        
        # Convert to recommendation format
        recommendations = []
        for content_id, score in recommended_content.items():
            content = self.content_metadata.get(content_id)
            if content:
                recommendations.append({
                    'id': content_id,
                    'title': content['title'],
                    'space': content['space'],
                    'score': score,
                    'reason': 'Users like you also viewed'
                })
        
        # Sort by score and return top recommendations
        recommendations.sort(key=lambda x: x['score'], reverse=True)
        return recommendations[:limit]
    
    def get_personalized_recommendations(self, user_id: str, limit: int = 20) -> List[Dict]:
        """Get personalized recommendations combining multiple strategies"""
        
        recommendations = []
        
        # Get recommendations from different strategies
        topic_recs = self.get_topic_based_recommendations(user_id, limit // 2)
        collaborative_recs = self.get_collaborative_recommendations(user_id, limit // 2)
        
        # Combine and deduplicate
        seen_content = set()
        
        for rec in topic_recs + collaborative_recs:
            if rec['id'] not in seen_content:
                recommendations.append(rec)
                seen_content.add(rec['id'])
        
        # Fill remaining slots with popular content
        if len(recommendations) < limit:
            popular_recs = self.get_popular_content(limit - len(recommendations))
            for rec in popular_recs:
                if rec['id'] not in seen_content:
                    recommendations.append(rec)
                    seen_content.add(rec['id'])
        
        return recommendations[:limit]
    
    def get_user_topic_interests(self, user_id: str) -> np.ndarray:
        """Calculate user's topic interests based on reading history"""
        
        user_content = self.get_user_viewed_content(user_id)
        if not user_content:
            return np.zeros(self.lda_model.n_components)
        
        # Get topic distributions for user's viewed content
        content_ids = list(self.content_metadata.keys())
        user_topic_interests = np.zeros(self.lda_model.n_components)
        
        for content_id in user_content:
            if content_id in self.content_metadata:
                content_index = content_ids.index(content_id)
                user_topic_interests += self.content_topics[content_index]
        
        # Normalize
        if user_topic_interests.sum() > 0:
            user_topic_interests = user_topic_interests / user_topic_interests.sum()
        
        return user_topic_interests
    
    def calculate_recency_boost(self, updated_at: str) -> float:
        """Calculate boost factor based on content recency"""
        from datetime import datetime, timedelta
        
        updated_date = datetime.fromisoformat(updated_at.replace('Z', '+00:00'))
        days_old = (datetime.now() - updated_date).days
        
        # Exponential decay with 30-day half-life
        return np.exp(-days_old / 30.0)
    
    def calculate_popularity_boost(self, views: int) -> float:
        """Calculate boost factor based on content popularity"""
        # Logarithmic scaling to prevent popular content from dominating
        return 1.0 + np.log(1 + views) / 10.0
    
    def find_similar_users(self, user_id: str, limit: int = 50) -> List[Tuple[str, float]]:
        """Find users with similar content consumption patterns"""
        # This would typically use collaborative filtering algorithms
        # For now, return mock data
        return [('user123', 0.8), ('user456', 0.7)]
    
    def get_user_viewed_content(self, user_id: str) -> List[str]:
        """Get list of content IDs viewed by user"""
        # This would query the user activity database
        return []
    
    def user_has_viewed(self, user_id: str, content_id: str) -> bool:
        """Check if user has already viewed content"""
        # This would query the user activity database
        return False
    
    def get_popular_content(self, limit: int = 10) -> List[Dict]:
        """Get popular content as fallback recommendations"""
        
        content_list = list(self.content_metadata.values())
        content_list.sort(key=lambda x: x.get('views', 0), reverse=True)
        
        return [{
            'id': content['id'],
            'title': content['title'],
            'space': content['space'],
            'score': content.get('views', 0),
            'reason': 'Popular content'
        } for content in content_list[:limit]]
```

## 9. Security & Permissions

### 9.1 Fine-Grained Permission System

#### Permission Model Implementation
```java
// Permission Service Implementation
@Service
public class PermissionService {
    
    private final PermissionRepository permissionRepository;
    private final UserService userService;
    private final GroupService groupService;
    private final RedisTemplate<String, Object> cacheTemplate;
    
    // Permission levels
    public enum Permission {
        VIEW("view"),
        CREATE("create"),
        EDIT("edit"),
        DELETE("delete"),
        ADMIN("admin"),
        EXPORT("export");
        
        private final String value;
        
        Permission(String value) {
            this.value = value;
        }
    }
    
    // Resource types
    public enum ResourceType {
        SPACE("space"),
        PAGE("page"),
        COMMENT("comment"),
        ATTACHMENT("attachment");
        
        private final String value;
        
        ResourceType(String value) {
            this.value = value;
        }
    }
    
    public boolean hasPermission(String userId, String resourceId, 
                               ResourceType resourceType, Permission permission) {
        
        // Check cache first
        String cacheKey = String.format("permission:%s:%s:%s:%s", 
            userId, resourceId, resourceType.value, permission.value);
        
        Boolean cachedResult = (Boolean) cacheTemplate.opsForValue().get(cacheKey);
        if (cachedResult != null) {
            return cachedResult;
        }
        
        // Evaluate permission
        boolean hasPermission = evaluatePermission(userId, resourceId, resourceType, permission);
        
        // Cache result for 5 minutes
        cacheTemplate.opsForValue().set(cacheKey, hasPermission, Duration.ofMinutes(5));
        
        return hasPermission;
    }
    
    private boolean evaluatePermission(String userId, String resourceId, 
                                     ResourceType resourceType, Permission permission) {
        
        // System admin has all permissions
        if (userService.isSystemAdmin(userId)) {
            return true;
        }
        
        // Get resource hierarchy for inheritance
        List<String> resourceHierarchy = getResourceHierarchy(resourceId, resourceType);
        
        // Check permissions at each level (most specific first)
        for (String currentResourceId : resourceHierarchy) {
            
            // Check direct user permissions
            if (hasDirectPermission(userId, currentResourceId, resourceType, permission)) {
                return true;
            }
            
            // Check group permissions
            List<String> userGroups = userService.getUserGroups(userId);
            for (String groupId : userGroups) {
                if (hasGroupPermission(groupId, currentResourceId, resourceType, permission)) {
                    return true;
                }
            }
            
            // Check role-based permissions
            if (hasRoleBasedPermission(userId, currentResourceId, resourceType, permission)) {
                return true;
            }
        }
        
        // Check for anonymous/authenticated user permissions
        return hasPublicPermission(resourceId, resourceType, permission);
    }
    
    private List<String> getResourceHierarchy(String resourceId, ResourceType resourceType) {
        List<String> hierarchy = new ArrayList<>();
        hierarchy.add(resourceId);
        
        switch (resourceType) {
            case PAGE:
                // Add parent pages and space
                Page page = pageService.getPage(resourceId);
                if (page != null) {
                    // Add parent pages
                    Page currentPage = page;
                    while (currentPage.getParentId() != null) {
                        currentPage = pageService.getPage(currentPage.getParentId());
                        hierarchy.add(currentPage.getId());
                    }
                    // Add space
                    hierarchy.add(page.getSpaceId());
                }
                break;
                
            case COMMENT:
                // Add parent page and space
                Comment comment = commentService.getComment(resourceId);
                if (comment != null) {
                    hierarchy.add(comment.getPageId());
                    Page parentPage = pageService.getPage(comment.getPageId());
                    if (parentPage != null) {
                        hierarchy.add(parentPage.getSpaceId());
                    }
                }
                break;
                
            case ATTACHMENT:
                // Add parent page and space
                Attachment attachment = attachmentService.getAttachment(resourceId);
                if (attachment != null) {
                    hierarchy.add(attachment.getPageId());
                    Page parentPage = pageService.getPage(attachment.getPageId());
                    if (parentPage != null) {
                        hierarchy.add(parentPage.getSpaceId());
                    }
                }
                break;
                
            case SPACE:
                // Space is top-level, no hierarchy
                break;
        }
        
        return hierarchy;
    }
    
    private boolean hasDirectPermission(String userId, String resourceId, 
                                      ResourceType resourceType, Permission permission) {
        
        return permissionRepository.existsByUserIdAndResourceIdAndResourceTypeAndPermission(
            userId, resourceId, resourceType.value, permission.value
        );
    }
    
    private boolean hasGroupPermission(String groupId, String resourceId, 
                                     ResourceType resourceType, Permission permission) {
        
        return permissionRepository.existsByGroupIdAndResourceIdAndResourceTypeAndPermission(
            groupId, resourceId, resourceType.value, permission.value
        );
    }
    
    private boolean hasRoleBasedPermission(String userId, String resourceId, 
                                         ResourceType resourceType, Permission permission) {
        
        // Check if user has a role that grants this permission
        List<String> userRoles = userService.getUserRoles(userId, resourceId);
        
        for (String role : userRoles) {
            if (roleHasPermission(role, resourceType, permission)) {
                return true;
            }
        }
        
        return false;
    }
    
    private boolean roleHasPermission(String role, ResourceType resourceType, Permission permission) {
        // Define role-based permissions
        Map<String, Set<Permission>> rolePermissions = Map.of(
            "space-admin", Set.of(Permission.VIEW, Permission.CREATE, Permission.EDIT, 
                                Permission.DELETE, Permission.ADMIN, Permission.EXPORT),
            "space-editor", Set.of(Permission.VIEW, Permission.CREATE, Permission.EDIT),
            "space-viewer", Set.of(Permission.VIEW),
            "page-owner", Set.of(Permission.VIEW, Permission.EDIT, Permission.DELETE),
            "contributor", Set.of(Permission.VIEW, Permission.CREATE, Permission.EDIT)
        );
        
        Set<Permission> permissions = rolePermissions.get(role);
        return permissions != null && permissions.contains(permission);
    }
    
    private boolean hasPublicPermission(String resourceId, ResourceType resourceType, Permission permission) {
        // Check if resource allows anonymous/public access
        return permissionRepository.existsByResourceIdAndResourceTypeAndSubjectTypeAndPermission(
            resourceId, resourceType.value, "anonymous", permission.value
        );
    }
    
    @Transactional
    public void grantPermission(String subjectId, SubjectType subjectType, 
                              String resourceId, ResourceType resourceType, 
                              Permission permission, String grantedBy) {
        
        PermissionEntity permissionEntity = PermissionEntity.builder()
            .subjectId(subjectId)
            .subjectType(subjectType.value)
            .resourceId(resourceId)
            .resourceType(resourceType.value)
            .permission(permission.value)
            .grantedBy(grantedBy)
            .grantedAt(Instant.now())
            .build();
        
        permissionRepository.save(permissionEntity);
        
        // Clear cache
        clearPermissionCache(subjectId, resourceId, resourceType, permission);
        
        // Log permission grant
        auditService.logPermissionGrant(subjectId, subjectType, resourceId, 
                                      resourceType, permission, grantedBy);
    }
    
    @Transactional
    public void revokePermission(String subjectId, SubjectType subjectType, 
                               String resourceId, ResourceType resourceType, 
                               Permission permission, String revokedBy) {
        
        permissionRepository.deleteBySubjectIdAndResourceIdAndResourceTypeAndPermission(
            subjectId, resourceId, resourceType.value, permission.value
        );
        
        // Clear cache
        clearPermissionCache(subjectId, resourceId, resourceType, permission);
        
        // Log permission revocation
        auditService.logPermissionRevoke(subjectId, subjectType, resourceId, 
                                       resourceType, permission, revokedBy);
    }
    
    public List<PermissionSummary> getResourcePermissions(String resourceId, ResourceType resourceType) {
        List<PermissionEntity> permissions = permissionRepository
            .findByResourceIdAndResourceType(resourceId, resourceType.value);
        
        return permissions.stream()
            .map(this::mapToPermissionSummary)
            .collect(Collectors.toList());
    }
    
    public List<String> getAccessibleResources(String userId, ResourceType resourceType, Permission permission) {
        // Get resources user has direct access to
        List<String> directAccess = permissionRepository
            .findResourceIdsByUserIdAndResourceTypeAndPermission(
                userId, resourceType.value, permission.value
            );
        
        // Get resources user has access to through groups
        List<String> userGroups = userService.getUserGroups(userId);
        List<String> groupAccess = permissionRepository
            .findResourceIdsByGroupIdsAndResourceTypeAndPermission(
                userGroups, resourceType.value, permission.value
            );
        
        // Get public resources
        List<String> publicAccess = permissionRepository
            .findResourceIdsBySubjectTypeAndResourceTypeAndPermission(
                "anonymous", resourceType.value, permission.value
            );
        
        // Combine and deduplicate
        Set<String> allAccess = new HashSet<>();
        allAccess.addAll(directAccess);
        allAccess.addAll(groupAccess);
        allAccess.addAll(publicAccess);
        
        return new ArrayList<>(allAccess);
    }
    
    private void clearPermissionCache(String subjectId, String resourceId, 
                                    ResourceType resourceType, Permission permission) {
        String pattern = String.format("permission:%s:%s:%s:%s", 
            subjectId, resourceId, resourceType.value, permission.value);
        cacheTemplate.delete(pattern);
    }
    
    private PermissionSummary mapToPermissionSummary(PermissionEntity entity) {
        return PermissionSummary.builder()
            .subjectId(entity.getSubjectId())
            .subjectType(entity.getSubjectType())
            .permission(entity.getPermission())
            .grantedBy(entity.getGrantedBy())
            .grantedAt(entity.getGrantedAt())
            .build();
    }
}

// Permission Entity
@Entity
@Table(name = "permissions")
@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PermissionEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(name = "subject_id", nullable = false)
    private String subjectId; // User ID, Group ID, or special values like "anonymous"
    
    @Column(name = "subject_type", nullable = false)
    private String subjectType; // "user", "group", "anonymous", "authenticated"
    
    @Column(name = "resource_id", nullable = false)
    private String resourceId;
    
    @Column(name = "resource_type", nullable = false)
    private String resourceType;
    
    @Column(name = "permission", nullable = false)
    private String permission;
    
    @Column(name = "granted_by", nullable = false)
    private String grantedBy;
    
    @Column(name = "granted_at", nullable = false)
    private Instant grantedAt;
    
    // Composite unique constraint
    @Table(uniqueConstraints = {
        @UniqueConstraint(columnNames = {
            "subject_id", "resource_id", "resource_type", "permission"
        })
    })
    public static class Constraints {}
}
```

### 9.2 Content Security & Data Protection

#### Content Sanitization and Validation
```java
@Service
public class ContentSecurityService {
    
    private final Sanitizer htmlSanitizer;
    private final ObjectMapper objectMapper;
    private final VirusScanService virusScanService;
    
    public ContentSecurityService() {
        // Configure HTML sanitizer with allowed tags and attributes
        this.htmlSanitizer = Sanitizer.newBuilder()
            .allowElements("p", "br", "strong", "em", "u", "s", "h1", "h2", "h3", 
                          "h4", "h5", "h6", "ul", "ol", "li", "blockquote", 
                          "pre", "code", "a", "img", "table", "thead", "tbody", 
                          "tr", "th", "td", "div", "span")
            .allowAttributes("href").onElements("a")
            .allowAttributes("src", "alt", "width", "height").onElements("img")
            .allowAttributes("class", "id").globally()
            .allowUrlProtocols("http", "https", "mailto")
            .build();
    }
    
    public String sanitizeHtmlContent(String htmlContent) {
        if (htmlContent == null || htmlContent.trim().isEmpty()) {
            return "";
        }
        
        // Remove potentially dangerous
        // Remove potentially dangerous content
        String sanitized = htmlSanitizer.sanitize(htmlContent);
        
        // Additional security checks
        sanitized = removeScriptTags(sanitized);
        sanitized = removeEventHandlers(sanitized);
        sanitized = validateUrls(sanitized);
        
        return sanitized;
    }
    
    public Object sanitizeAdfContent(Object adfContent) {
        try {
            String jsonContent = objectMapper.writeValueAsString(adfContent);
            
            // Parse and validate ADF structure
            JsonNode rootNode = objectMapper.readTree(jsonContent);
            JsonNode sanitizedNode = sanitizeAdfNode(rootNode);
            
            return objectMapper.treeToValue(sanitizedNode, Object.class);
        } catch (Exception e) {
            throw new ContentSecurityException("Failed to sanitize ADF content", e);
        }
    }
    
    private JsonNode sanitizeAdfNode(JsonNode node) {
        if (node.isObject()) {
            ObjectNode objectNode = (ObjectNode) node;
            
            // Check node type
            String nodeType = objectNode.path("type").asText();
            if (!isAllowedAdfNodeType(nodeType)) {
                return objectMapper.createObjectNode(); // Return empty node
            }
            
            // Sanitize attributes
            if (objectNode.has("attrs")) {
                JsonNode attrs = objectNode.get("attrs");
                JsonNode sanitizedAttrs = sanitizeAdfAttributes(attrs, nodeType);
                objectNode.set("attrs", sanitizedAttrs);
            }
            
            // Recursively sanitize content
            if (objectNode.has("content")) {
                ArrayNode contentArray = (ArrayNode) objectNode.get("content");
                ArrayNode sanitizedContent = objectMapper.createArrayNode();
                
                for (JsonNode childNode : contentArray) {
                    JsonNode sanitizedChild = sanitizeAdfNode(childNode);
                    if (!sanitizedChild.isEmpty()) {
                        sanitizedContent.add(sanitizedChild);
                    }
                }
                
                objectNode.set("content", sanitizedContent);
            }
        }
        
        return node;
    }
    
    private boolean isAllowedAdfNodeType(String nodeType) {
        Set<String> allowedTypes = Set.of(
            "doc", "paragraph", "text", "heading", "bulletList", "orderedList",
            "listItem", "blockquote", "codeBlock", "rule", "hardBreak",
            "mention", "emoji", "link", "strong", "em", "underline", "strike",
            "code", "table", "tableRow", "tableCell", "tableHeader",
            "media", "mediaGroup", "mediaSingle"
        );
        
        return allowedTypes.contains(nodeType);
    }
    
    private JsonNode sanitizeAdfAttributes(JsonNode attrs, String nodeType) {
        ObjectNode sanitizedAttrs = objectMapper.createObjectNode();
        
        switch (nodeType) {
            case "link":
                if (attrs.has("href")) {
                    String href = attrs.get("href").asText();
                    if (isValidUrl(href)) {
                        sanitizedAttrs.put("href", href);
                    }
                }
                break;
                
            case "mention":
                if (attrs.has("id") && attrs.has("text")) {
                    sanitizedAttrs.put("id", attrs.get("id").asText());
                    sanitizedAttrs.put("text", attrs.get("text").asText());
                }
                break;
                
            case "media":
                if (attrs.has("id") && attrs.has("type")) {
                    String mediaType = attrs.get("type").asText();
                    if (isAllowedMediaType(mediaType)) {
                        sanitizedAttrs.put("id", attrs.get("id").asText());
                        sanitizedAttrs.put("type", mediaType);
                    }
                }
                break;
                
            default:
                // Copy safe attributes
                attrs.fieldNames().forEachRemaining(fieldName -> {
                    if (isSafeAttribute(fieldName)) {
                        sanitizedAttrs.set(fieldName, attrs.get(fieldName));
                    }
                });
        }
        
        return sanitizedAttrs;
    }
    
    public AttachmentSecurityResult validateAttachment(MultipartFile file) {
        AttachmentSecurityResult result = new AttachmentSecurityResult();
        
        // Check file size
        if (file.getSize() > MAX_FILE_SIZE) {
            result.addViolation("File size exceeds maximum allowed size");
            return result;
        }
        
        // Check file type
        String contentType = file.getContentType();
        String filename = file.getOriginalFilename();
        
        if (!isAllowedFileType(contentType, filename)) {
            result.addViolation("File type not allowed");
            return result;
        }
        
        // Scan for viruses
        try {
            VirusScanResult scanResult = virusScanService.scanFile(file.getInputStream());
            if (scanResult.isInfected()) {
                result.addViolation("File contains malware: " + scanResult.getThreatName());
                return result;
            }
        } catch (Exception e) {
            result.addViolation("Unable to scan file for viruses");
            return result;
        }
        
        // Additional content-specific validation
        if (isImageFile(contentType)) {
            result = validateImageFile(file, result);
        } else if (isDocumentFile(contentType)) {
            result = validateDocumentFile(file, result);
        }
        
        return result;
    }
    
    private AttachmentSecurityResult validateImageFile(MultipartFile file, AttachmentSecurityResult result) {
        try {
            BufferedImage image = ImageIO.read(file.getInputStream());
            if (image == null) {
                result.addViolation("Invalid image file");
                return result;
            }
            
            // Check image dimensions
            if (image.getWidth() > MAX_IMAGE_WIDTH || image.getHeight() > MAX_IMAGE_HEIGHT) {
                result.addViolation("Image dimensions exceed maximum allowed size");
            }
            
            // Check for embedded metadata that might contain sensitive information
            if (hasEmbeddedMetadata(file)) {
                result.addWarning("Image contains metadata that will be stripped");
            }
            
        } catch (Exception e) {
            result.addViolation("Unable to validate image file");
        }
        
        return result;
    }
    
    private boolean isValidUrl(String url) {
        try {
            URI uri = new URI(url);
            String scheme = uri.getScheme();
            
            // Only allow http, https, and mailto
            if (!"http".equals(scheme) && !"https".equals(scheme) && !"mailto".equals(scheme)) {
                return false;
            }
            
            // Block internal/private IP addresses
            if ("http".equals(scheme) || "https".equals(scheme)) {
                String host = uri.getHost();
                if (isPrivateOrLocalAddress(host)) {
                    return false;
                }
            }
            
            return true;
        } catch (URISyntaxException e) {
            return false;
        }
    }
    
    private boolean isPrivateOrLocalAddress(String host) {
        try {
            InetAddress address = InetAddress.getByName(host);
            return address.isLoopbackAddress() || 
                   address.isLinkLocalAddress() || 
                   address.isSiteLocalAddress();
        } catch (UnknownHostException e) {
            return false;
        }
    }
}

// Data Loss Prevention Service
@Service
public class DataLossPreventionService {
    
    private final List<Pattern> sensitiveDataPatterns;
    private final RedisTemplate<String, Object> cacheTemplate;
    
    public DataLossPreventionService() {
        this.sensitiveDataPatterns = initializeSensitiveDataPatterns();
    }
    
    private List<Pattern> initializeSensitiveDataPatterns() {
        return Arrays.asList(
            // Credit card numbers
            Pattern.compile("\\b(?:\\d{4}[-\\s]?){3}\\d{4}\\b"),
            
            // Social Security Numbers
            Pattern.compile("\\b\\d{3}-\\d{2}-\\d{4}\\b"),
            
            // Email addresses (in certain contexts)
            Pattern.compile("\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"),
            
            // Phone numbers
            Pattern.compile("\\b(?:\\+?1[-\\s]?)?\\(?\\d{3}\\)?[-\\s]?\\d{3}[-\\s]?\\d{4}\\b"),
            
            // API keys (generic pattern)
            Pattern.compile("(?i)(?:api[_-]?key|access[_-]?token|secret[_-]?key)\\s*[:=]\\s*['\"]?([a-zA-Z0-9_-]{20,})['\"]?"),
            
            // AWS Access Keys
            Pattern.compile("AKIA[0-9A-Z]{16}"),
            
            // Private keys
            Pattern.compile("-----BEGIN\\s+(?:RSA\\s+)?PRIVATE\\s+KEY-----")
        );
    }
    
    public DlpScanResult scanContent(String content, String userId, String resourceId) {
        DlpScanResult result = new DlpScanResult();
        
        if (content == null || content.trim().isEmpty()) {
            return result;
        }
        
        // Scan for sensitive data patterns
        for (Pattern pattern : sensitiveDataPatterns) {
            Matcher matcher = pattern.matcher(content);
            while (matcher.find()) {
                SensitiveDataMatch match = SensitiveDataMatch.builder()
                    .pattern(pattern.pattern())
                    .matchedText(matcher.group())
                    .startPosition(matcher.start())
                    .endPosition(matcher.end())
                    .confidence(calculateConfidence(pattern, matcher.group()))
                    .build();
                
                result.addMatch(match);
            }
        }
        
        // Log potential violations
        if (result.hasViolations()) {
            auditService.logDlpViolation(userId, resourceId, result);
        }
        
        return result;
    }
    
    public String redactSensitiveData(String content, DlpScanResult scanResult) {
        if (!scanResult.hasViolations()) {
            return content;
        }
        
        StringBuilder redactedContent = new StringBuilder(content);
        
        // Sort matches by position (descending) to avoid offset issues
        List<SensitiveDataMatch> matches = scanResult.getMatches()
            .stream()
            .sorted((a, b) -> Integer.compare(b.getStartPosition(), a.getStartPosition()))
            .collect(Collectors.toList());
        
        for (SensitiveDataMatch match : matches) {
            if (match.getConfidence() > 0.8) { // High confidence matches
                String redaction = generateRedaction(match.getMatchedText());
                redactedContent.replace(match.getStartPosition(), match.getEndPosition(), redaction);
            }
        }
        
        return redactedContent.toString();
    }
    
    private String generateRedaction(String originalText) {
        // Keep first and last character, redact middle
        if (originalText.length() <= 4) {
            return "*".repeat(originalText.length());
        }
        
        return originalText.charAt(0) + "*".repeat(originalText.length() - 2) + 
               originalText.charAt(originalText.length() - 1);
    }
    
    private double calculateConfidence(Pattern pattern, String match) {
        // Simple confidence calculation based on pattern type and match characteristics
        String patternStr = pattern.pattern();
        
        if (patternStr.contains("AKIA")) { // AWS Access Key
            return 0.95;
        } else if (patternStr.contains("PRIVATE KEY")) { // Private Key
            return 0.98;
        } else if (patternStr.contains("\\d{3}-\\d{2}-\\d{4}")) { // SSN
            return 0.85;
        } else if (patternStr.contains("@")) { // Email
            return 0.7; // Lower confidence as emails are common
        }
        
        return 0.8; // Default confidence
    }
}
```

## 10. Deployment & Infrastructure

### 10.1 Kubernetes Deployment Configuration

#### Confluence Application Deployment
```yaml
# Confluence Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: confluence-app
  namespace: confluence-prod
  labels:
    app: confluence
    component: application
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: confluence
      component: application
  template:
    metadata:
      labels:
        app: confluence
        component: application
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      serviceAccountName: confluence-app
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: confluence
        image: confluence/app:1.0.0
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 8081
          name: management
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: DATABASE_USERNAME
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
        - name: ELASTICSEARCH_URL
          valueFrom:
            configMapKeyRef:
              name: confluence-config
              key: elasticsearch.url
        - name: FILE_STORAGE_BUCKET
          valueFrom:
            configMapKeyRef:
              name: confluence-config
              key: storage.bucket
        resources:
          requests:
            cpu: 1000m
            memory: 2Gi
          limits:
            cpu: 4000m
            memory: 8Gi
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8081
          initialDelaySeconds: 120
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
          readOnly: true
        - name: temp-storage
          mountPath: /tmp
        - name: logs-volume
          mountPath: /app/logs
      volumes:
      - name: config-volume
        configMap:
          name: confluence-config
      - name: temp-storage
        emptyDir:
          sizeLimit: 1Gi
      - name: logs-volume
        emptyDir:
          sizeLimit: 2Gi
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - confluence
              topologyKey: kubernetes.io/hostname

---
# Confluence Service
apiVersion: v1
kind: Service
metadata:
  name: confluence-service
  namespace: confluence-prod
  labels:
    app: confluence
spec:
  selector:
    app: confluence
    component: application
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: management
    port: 8081
    targetPort: 8081
    protocol: TCP
  type: ClusterIP

---
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: confluence-hpa
  namespace: confluence-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: confluence-app
  minReplicas: 3
  maxReplicas: 20
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
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
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
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: confluence-config
  namespace: confluence-prod
data:
  application.yml: |
    server:
      port: 8080
      compression:
        enabled: true
        mime-types: text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json
        min-response-size: 1024
    
    spring:
      datasource:
        hikari:
          maximum-pool-size: 50
          minimum-idle: 10
          connection-timeout: 30000
          idle-timeout: 600000
          max-lifetime: 1800000
      
      jpa:
        hibernate:
          ddl-auto: validate
        properties:
          hibernate:
            dialect: org.hibernate.dialect.PostgreSQLDialect
            jdbc:
              batch_size: 25
            order_inserts: true
            order_updates: true
            batch_versioned_data: true
      
      cache:
        type: redis
        redis:
          time-to-live: 600000
      
      servlet:
        multipart:
          max-file-size: 100MB
          max-request-size: 100MB
    
    management:
      endpoints:
        web:
          exposure:
            include: health,info,metrics,prometheus
      endpoint:
        health:
          show-details: when-authorized
      metrics:
        export:
          prometheus:
            enabled: true
    
    logging:
      level:
        com.confluence: INFO
        org.springframework.security: DEBUG
      pattern:
        console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
        file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
      file:
        name: /app/logs/confluence.log
        max-size: 100MB
        max-history: 30
  
  elasticsearch.url: "http://elasticsearch:9200"
  storage.bucket: "confluence-attachments"
  websocket.url: "ws://collaboration-service:8080/ws"
```

### 10.2 Database Configuration

#### PostgreSQL Setup for High Availability
```yaml
# PostgreSQL Primary-Replica Setup
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: confluence-postgres
  namespace: confluence-prod
spec:
  instances: 3
  
  postgresql:
    parameters:
      max_connections: "200"
      shared_buffers: "256MB"
      effective_cache_size: "1GB"
      maintenance_work_mem: "64MB"
      checkpoint_completion_target: "0.9"
      wal_buffers: "16MB"
      default_statistics_target: "100"
      random_page_cost: "1.1"
      effective_io_concurrency: "200"
      work_mem: "4MB"
      min_wal_size: "1GB"
      max_wal_size: "4GB"
      max_worker_processes: "8"
      max_parallel_workers_per_gather: "4"
      max_parallel_workers: "8"
      max_parallel_maintenance_workers: "4"
      
  bootstrap:
    initdb:
      database: confluence
      owner: confluence_user
      secret:
        name: postgres-credentials
      
  storage:
    size: 100Gi
    storageClass: fast-ssd
    
  monitoring:
    enabled: true
    
  backup:
    retentionPolicy: "30d"
    barmanObjectStore:
      destinationPath: "s3://confluence-backups/postgres"
      s3Credentials:
        accessKeyId:
          name: backup-credentials
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: backup-credentials
          key: SECRET_ACCESS_KEY
      wal:
        retention: "7d"
      data:
        retention: "30d"

---
# Database Connection Pooler
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgbouncer
  namespace: confluence-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pgbouncer
  template:
    metadata:
      labels:
        app: pgbouncer
    spec:
      containers:
      - name: pgbouncer
        image: pgbouncer/pgbouncer:1.18.0
        ports:
        - containerPort: 5432
        env:
        - name: DATABASES_HOST
          value: "confluence-postgres-rw"
        - name: DATABASES_PORT
          value: "5432"
        - name: DATABASES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: username
        - name: DATABASES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: password
        - name: DATABASES_DBNAME
          value: "confluence"
        - name: POOL_MODE
          value: "transaction"
        - name: MAX_CLIENT_CONN
          value: "1000"
        - name: DEFAULT_POOL_SIZE
          value: "25"
        - name: MIN_POOL_SIZE
          value: "5"
        - name: RESERVE_POOL_SIZE
          value: "5"
        - name: SERVER_RESET_QUERY
          value: "DISCARD ALL"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

## 11. Performance & Scalability

### 11.1 Caching Strategy Implementation

#### Multi-Level Caching
```java
@Configuration
@EnableCaching
public class CacheConfiguration {
    
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(redisConnectionFactory)
            .cacheDefaults(config)
            .withCacheConfiguration("pages", config.entryTtl(Duration.ofHours(1)))
            .withCacheConfiguration("spaces", config.entryTtl(Duration.ofHours(2)))
            .withCacheConfiguration("users", config.entryTtl(Duration.ofMinutes(30)))
            .withCacheConfiguration("permissions", config.entryTtl(Duration.ofMinutes(5)))
            .withCacheConfiguration("search-results", config.entryTtl(Duration.ofMinutes(15)))
            .build();
    }
    
    @Bean
    public Caffeine<Object, Object> caffeineConfig() {
        return Caffeine.newBuilder()
            .maximumSize(10000)
            .expireAfterWrite(Duration.ofMinutes(5))
            .recordStats();
    }
    
    @Bean
    public CacheManager localCacheManager(Caffeine<Object, Object> caffeine) {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeine(caffeine);
        return cacheManager;
    }
}

@Service
public class ContentCacheService {
    
    @Cacheable(value = "pages", key = "#pageId", unless = "#result == null")
    public Page getPage(String pageId) {
        return pageRepository.findById(pageId).orElse(null);
    }
    
    @Cacheable(value = "pages", key = "'rendered:' + #pageId + ':' + #version", unless = "#result == null")
    public String getRenderedContent(String pageId, int version) {
        Page page = getPage(pageId);
        if (page == null || page.getVersion() != version) {
            return null;
        }
        
        return contentRenderingService.renderToHtml(page.getContent());
    }
    
    @CacheEvict(value = "pages", key = "#pageId")
    public void evictPage(String pageId) {
        // Cache will be evicted automatically
    }
    
    @CacheEvict(value = "pages", allEntries = true)
    public void evictAllPages() {
        // Clear all page cache entries
    }
    
    @Cacheable(value = "search-results", key = "#query + ':' + #filters.hashCode()")
    public SearchResults searchContent(String query, SearchFilters filters) {
        return searchService.search(query, filters);
    }
}
```

### 11.2 Performance Monitoring

#### Application Performance Monitoring
```java
@Component
public class PerformanceMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Timer pageLoadTimer;
    private final Counter pageViewCounter;
    private final Gauge activeUsersGauge;
    
    public PerformanceMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        this.pageLoadTimer = Timer.builder("confluence.page.load.duration")
            .description("Time taken to load a page")
            .register(meterRegistry);
            
        this.pageViewCounter = Counter.builder("confluence.page.views")
            .description("Number of page views")
            .register(meterRegistry);
            
        this.activeUsersGauge = Gauge.builder("confluence.users.active")
            .description("Number of active users")
            .register(meterRegistry, this, PerformanceMetrics::getActiveUserCount);
    }
    
    @EventListener
    public void handlePageView(PageViewEvent event) {
        pageViewCounter.increment(
            Tags.of(
                "space", event.getSpaceKey(),
                "page_type", event.getPageType()
            )
        );
        
        Timer.Sample sample = Timer.start(meterRegistry);
        sample.stop(pageLoadTimer.tag("space", event.getSpaceKey()));
    }
    
    @Scheduled(fixedRate = 60000) // Every minute
    public void recordSystemMetrics() {
        // Record JVM metrics
        Runtime runtime = Runtime.getRuntime();
        
        Gauge.builder("confluence.jvm.memory.used")
            .register(meterRegistry, runtime, r -> r.totalMemory() - r.freeMemory());
            
        Gauge.builder("confluence.jvm.memory.free")
            .register(meterRegistry, runtime, Runtime::freeMemory);
            
        // Record database connection pool metrics
        recordConnectionPoolMetrics();
        
        // Record cache metrics
        recordCacheMetrics();
    }
    
    private void recordConnectionPoolMetrics() {
        HikariDataSource dataSource = (HikariDataSource) this.dataSource;
        HikariPoolMXBean poolBean = dataSource.getHikariPoolMXBean();
        
        Gauge.builder("confluence.db.connections.active")
            .register(meterRegistry, poolBean, HikariPoolMXBean::getActiveConnections);
            
        Gauge.builder("confluence.db.connections.idle")
            .register(meterRegistry, poolBean, HikariPoolMXBean::getIdleConnections);
            
        Gauge.builder("confluence.db.connections.total")
            .register(meterRegistry, poolBean, HikariPoolMXBean::getTotalConnections);
    }
    
    private void recordCacheMetrics() {
        CacheManager cacheManager = this.cacheManager;
        
        for (String cacheName : cacheManager.getCacheNames()) {
            Cache cache = cacheManager.getCache(cacheName);
            if (cache instanceof CaffeineCache) {
                com.github.benmanes.caffeine.cache.Cache<Object, Object> nativeCache = 
                    ((CaffeineCache) cache).getNativeCache();
                
                CacheStats stats = nativeCache.stats();
                
                Gauge.builder("confluence.cache.size")
                    .tag("cache", cacheName)
                    .register(meterRegistry, nativeCache, c -> c.estimatedSize());
                    
                Counter.builder("confluence.cache.hits")
                    .tag("cache", cacheName)
                    .register(meterRegistry)
                    .increment(stats.hitCount());
                    
                Counter.builder("confluence.cache.misses")
                    .tag("cache", cacheName)
                    .register(meterRegistry)
                    .increment(stats.missCount());
            }
        }
    }
    
    private double getActiveUserCount() {
        // This would query the session store or user activity service
        return userActivityService.getActiveUserCount();
    }
}
```

## 12. Implementation Roadmap

### 12.1 Development Phases

#### Phase 1: Foundation (Months 1-3)
**Core Infrastructure & Basic Features**
- Set up development environment and CI/CD pipelines
- Implement user authentication and basic authorization
- Create basic space and page management
- Develop simple rich text editor
- Set up database schema and basic API endpoints
- Implement basic search functionality

**Deliverables:**
- User registration and login
- Create/edit/delete spaces and pages
- Basic WYSIWYG editor
- Simple permission system
- REST API for core operations

#### Phase 2: Collaboration Features (Months 4-6)
**Real-Time Collaboration & Advanced Editing**
- Implement real-time collaborative editing
- Add comment system with threading
- Develop advanced editor features (tables, media, macros)
- Create template system
- Implement version history and page comparison
- Add notification system

**Deliverables:**
- Multi-user real-time editing
- Inline and page comments
- Rich content support (images, tables, code blocks)
- Page templates and blueprints
- Email and in-app notifications
- Version control
#### Phase 3: Advanced Features & Integration (Months 7-9)
**Search, Analytics & Third-Party Integration**
- Implement advanced search with Elasticsearch
- Add content analytics and insights
- Develop macro system and marketplace
- Create export/import functionality
- Implement advanced permissions and compliance features
- Add mobile applications

**Deliverables:**
- Full-text search with filters and facets
- Usage analytics and reporting
- Custom macros and extensions
- PDF/Word export, space backup/restore
- Fine-grained permissions, audit logging
- iOS and Android apps

#### Phase 4: Scale & Enterprise Features (Months 10-12)
**Performance Optimization & Enterprise Readiness**
- Optimize for high-scale deployments
- Implement advanced caching strategies
- Add enterprise security features
- Create admin tools and monitoring
- Implement disaster recovery
- Performance testing and optimization

**Deliverables:**
- Support for 10,000+ concurrent users
- Multi-region deployment capability
- SSO integration, advanced security
- Admin dashboard, system monitoring
- Automated backup and recovery
- Load testing results and optimizations

### 12.2 Success Metrics

#### Technical KPIs
- **Performance**: Page load times < 2 seconds, API response times < 500ms
- **Availability**: 99.9% uptime with < 4 hours monthly maintenance
- **Scalability**: Support 10,000+ concurrent users, 1M+ pages
- **Security**: Zero critical vulnerabilities, SOC 2 compliance

#### Business KPIs
- **User Adoption**: 80% monthly active user rate
- **Content Creation**: 1000+ pages created per day
- **Collaboration**: 50% of pages have multiple contributors
- **Customer Satisfaction**: 4.5+ star rating, NPS > 50

#### Operational KPIs
- **Deployment Frequency**: Daily deployments with zero downtime
- **Mean Time to Recovery**: < 30 minutes for critical issues
- **Error Rate**: < 0.1% of requests result in errors
- **Cache Hit Rate**: > 90% for frequently accessed content

### 12.3 Risk Assessment & Mitigation

#### Technical Risks
**Risk**: Real-time collaboration conflicts and data loss
- **Mitigation**: Implement operational transforms, comprehensive testing, automatic conflict resolution
- **Contingency**: Manual merge tools, version rollback capabilities

**Risk**: Search performance degradation with large content volumes
- **Mitigation**: Elasticsearch optimization, incremental indexing, search result caching
- **Contingency**: Search service scaling, alternative search backends

**Risk**: Database performance bottlenecks
- **Mitigation**: Read replicas, connection pooling, query optimization
- **Contingency**: Database sharding, alternative storage solutions

#### Business Risks
**Risk**: Slow user adoption due to complexity
- **Mitigation**: Intuitive UI/UX design, comprehensive onboarding, user training
- **Contingency**: Simplified interface options, guided tutorials

**Risk**: Competition from established players
- **Mitigation**: Focus on unique features, superior performance, competitive pricing
- **Contingency**: Rapid feature development, strategic partnerships

**Risk**: Security breaches affecting customer trust
- **Mitigation**: Security-first development, regular audits, compliance certifications
- **Contingency**: Incident response plan, customer communication strategy

### 12.4 Technology Stack Summary

#### Frontend Technologies
- **Web Application**: React 18+ with TypeScript
- **Mobile Apps**: React Native for cross-platform development
- **Real-time Communication**: Socket.io for WebSocket connections
- **State Management**: Redux Toolkit for complex state
- **UI Components**: Custom design system with accessibility support

#### Backend Technologies
- **Application Services**: Node.js with Express.js, Java with Spring Boot
- **Real-time Services**: Node.js with Socket.io and Y.js for collaboration
- **Search Service**: Python with FastAPI and Elasticsearch
- **API Gateway**: Kong or Istio service mesh
- **Message Queue**: Apache Kafka for event streaming

#### Data Storage
- **Primary Database**: PostgreSQL 14+ with read replicas
- **Document Store**: MongoDB for flexible content storage
- **Search Engine**: Elasticsearch 8+ with cluster setup
- **Cache Layer**: Redis Cluster for distributed caching
- **File Storage**: AWS S3 or compatible object storage

#### Infrastructure & DevOps
- **Container Platform**: Kubernetes with Istio service mesh
- **Cloud Provider**: Multi-cloud support (AWS, GCP, Azure)
- **CI/CD**: GitLab CI or GitHub Actions with automated testing
- **Monitoring**: Prometheus, Grafana, Jaeger for observability
- **Security**: Vault for secrets management, Falco for runtime security

## Conclusion

This comprehensive requirements and architecture document provides a detailed blueprint for building a modern, scalable team collaboration and documentation platform comparable to Atlassian Confluence. The architecture emphasizes:

### Key Architectural Principles
- **Microservices Architecture**: Scalable, maintainable services with clear boundaries
- **Event-Driven Design**: Asynchronous communication for better performance and resilience
- **Real-Time Collaboration**: Advanced conflict resolution and operational transforms
- **Security-First Approach**: Comprehensive security controls and compliance frameworks
- **Cloud-Native Design**: Kubernetes-based deployment with auto-scaling capabilities

### Competitive Advantages
- **Superior Real-Time Collaboration**: Advanced operational transforms and conflict resolution
- **AI-Powered Features**: Intelligent content recommendations and search
- **Modern Architecture**: Cloud-native, microservices-based for better scalability
- **Developer-Friendly**: Comprehensive APIs and extensibility options
- **Enterprise-Ready**: Built-in compliance, security, and audit capabilities

### Implementation Success Factors
- **Phased Approach**: Incremental delivery with early user feedback
- **Performance Focus**: Sub-2-second page loads and real-time responsiveness
- **Security Priority**: Security controls integrated from day one
- **Scalability Planning**: Architecture designed for 10,000+ concurrent users
- **User Experience**: Intuitive interface with powerful functionality

The platform is designed to serve organizations from small teams to large enterprises, providing a centralized knowledge hub that enhances collaboration, improves information sharing, and accelerates decision-making across teams.

With this architecture and implementation plan, the platform can achieve market competitiveness while providing unique value through superior real-time collaboration, intelligent content discovery, and enterprise-grade security and compliance features.