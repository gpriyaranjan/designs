# API Contracts and Service Specifications

## Table of Contents
1. [API Design Principles](#1-api-design-principles)
2. [Authentication and Authorization](#2-authentication-and-authorization)
3. [User Management Service API](#3-user-management-service-api)
4. [Project Management Service API](#4-project-management-service-api)
5. [Issue Management Service API](#5-issue-management-service-api)
6. [Workflow Engine Service API](#6-workflow-engine-service-api)
7. [Notification Service API](#7-notification-service-api)
8. [Reporting Service API](#8-reporting-service-api)
9. [File Storage Service API](#9-file-storage-service-api)
10. [Search Service API](#10-search-service-api)
11. [Error Handling](#11-error-handling)
12. [Rate Limiting](#12-rate-limiting)
13. [API Versioning](#13-api-versioning)

## 1. API Design Principles

### 1.1 RESTful Design
- Use HTTP methods appropriately (GET, POST, PUT, DELETE, PATCH)
- Use meaningful resource URLs
- Return appropriate HTTP status codes
- Use JSON for request/response bodies
- Follow consistent naming conventions

### 1.2 Response Format
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "uuid"
  },
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### 1.3 Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "uuid"
  }
}
```

## 2. Authentication and Authorization

### 2.1 JWT Token Structure
```json
{
  "header": {
    "alg": "RS256",
    "typ": "JWT",
    "kid": "key-id"
  },
  "payload": {
    "sub": "user-uuid",
    "iss": "project-manager-auth",
    "aud": "project-manager-api",
    "exp": 1643723400,
    "iat": 1643719800,
    "jti": "token-uuid",
    "roles": ["user", "project_admin"],
    "permissions": ["read:issues", "write:issues", "admin:projects"],
    "tenant_id": "tenant-uuid"
  }
}
```

### 2.2 Authorization Header
```
Authorization: Bearer <jwt-token>
```

### 2.3 Permission Scopes
```yaml
user_permissions:
  - read:profile
  - write:profile
  - read:notifications
  - write:notifications

project_permissions:
  - read:projects
  - write:projects
  - admin:projects
  - read:project_members
  - write:project_members

issue_permissions:
  - read:issues
  - write:issues
  - admin:issues
  - read:comments
  - write:comments

workflow_permissions:
  - read:workflows
  - write:workflows
  - admin:workflows
  - execute:workflows

reporting_permissions:
  - read:reports
  - write:reports
  - admin:reports
  - export:data
```

## 3. User Management Service API

### 3.1 Authentication Endpoints

#### POST /api/v1/auth/login
**Description:** Authenticate user and return JWT token

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "jwt-token",
    "refresh_token": "refresh-token",
    "expires_in": 3600,
    "token_type": "Bearer",
    "user": {
      "id": "user-uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "first_name": "John",
      "last_name": "Doe",
      "avatar_url": "https://example.com/avatar.jpg",
      "roles": ["user"]
    }
  }
}
```

#### POST /api/v1/auth/refresh
**Description:** Refresh access token using refresh token

**Request:**
```json
{
  "refresh_token": "refresh-token"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "new-jwt-token",
    "expires_in": 3600,
    "token_type": "Bearer"
  }
}
```

#### POST /api/v1/auth/logout
**Description:** Invalidate user session

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Successfully logged out"
  }
}
```

### 3.2 User Management Endpoints

#### GET /api/v1/users/{id}
**Description:** Get user by ID

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "user@example.com",
    "username": "johndoe",
    "first_name": "John",
    "last_name": "Doe",
    "avatar_url": "https://example.com/avatar.jpg",
    "is_active": true,
    "roles": ["user", "project_admin"],
    "created_at": "2025-01-29T19:50:00Z",
    "updated_at": "2025-01-29T19:50:00Z"
  }
}
```

#### PUT /api/v1/users/{id}
**Description:** Update user profile

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "avatar_url": "https://example.com/new-avatar.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "user@example.com",
    "username": "johndoe",
    "first_name": "John",
    "last_name": "Doe",
    "avatar_url": "https://example.com/new-avatar.jpg",
    "updated_at": "2025-01-29T19:50:00Z"
  }
}
```

#### POST /api/v1/users
**Description:** Create new user (admin only)

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "email": "newuser@example.com",
  "username": "newuser",
  "password": "password123",
  "first_name": "New",
  "last_name": "User",
  "roles": ["user"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-user-uuid",
    "email": "newuser@example.com",
    "username": "newuser",
    "first_name": "New",
    "last_name": "User",
    "is_active": true,
    "roles": ["user"],
    "created_at": "2025-01-29T19:50:00Z"
  }
}
```

## 4. Project Management Service API

### 4.1 Project Endpoints

#### GET /api/v1/projects
**Description:** Get list of projects

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20, max: 100)
- `search` (optional): Search term
- `status` (optional): Project status filter

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "project-uuid",
      "key": "PROJ",
      "name": "Project Alpha",
      "description": "Main project for alpha features",
      "project_type": "software",
      "status": "active",
      "lead": {
        "id": "user-uuid",
        "username": "johndoe",
        "display_name": "John Doe"
      },
      "created_at": "2025-01-29T19:50:00Z",
      "updated_at": "2025-01-29T19:50:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 50,
    "total_pages": 3
  }
}
```

#### POST /api/v1/projects
**Description:** Create new project

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "key": "NEWPROJ",
  "name": "New Project",
  "description": "Description of the new project",
  "project_type": "software",
  "lead_id": "user-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-project-uuid",
    "key": "NEWPROJ",
    "name": "New Project",
    "description": "Description of the new project",
    "project_type": "software",
    "status": "active",
    "lead": {
      "id": "user-uuid",
      "username": "johndoe",
      "display_name": "John Doe"
    },
    "created_at": "2025-01-29T19:50:00Z"
  }
}
```

#### GET /api/v1/projects/{id}
**Description:** Get project by ID

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "project-uuid",
    "key": "PROJ",
    "name": "Project Alpha",
    "description": "Main project for alpha features",
    "project_type": "software",
    "status": "active",
    "lead": {
      "id": "user-uuid",
      "username": "johndoe",
      "display_name": "John Doe"
    },
    "settings": {
      "issue_types": ["Bug", "Task", "Story", "Epic"],
      "priorities": ["Low", "Medium", "High", "Critical"],
      "statuses": ["Open", "In Progress", "Done", "Closed"]
    },
    "statistics": {
      "total_issues": 150,
      "open_issues": 45,
      "in_progress_issues": 30,
      "closed_issues": 75
    },
    "created_at": "2025-01-29T19:50:00Z",
    "updated_at": "2025-01-29T19:50:00Z"
  }
}
```

#### PUT /api/v1/projects/{id}
**Description:** Update project

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "name": "Updated Project Name",
  "description": "Updated description",
  "lead_id": "new-lead-uuid"
}
```

#### DELETE /api/v1/projects/{id}
**Description:** Delete project (admin only)

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Project deleted successfully"
  }
}
```

### 4.2 Project Members Endpoints

#### GET /api/v1/projects/{id}/members
**Description:** Get project members

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "user": {
        "id": "user-uuid",
        "username": "johndoe",
        "display_name": "John Doe",
        "avatar_url": "https://example.com/avatar.jpg"
      },
      "role": "admin",
      "joined_at": "2025-01-29T19:50:00Z"
    }
  ]
}
```

#### POST /api/v1/projects/{id}/members
**Description:** Add member to project

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "user_id": "user-uuid",
  "role": "member"
}
```

## 5. Issue Management Service API

### 5.1 Issue Endpoints

#### GET /api/v1/issues
**Description:** Get list of issues

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `project_id` (optional): Filter by project
- `assignee_id` (optional): Filter by assignee
- `status` (optional): Filter by status
- `priority` (optional): Filter by priority
- `issue_type` (optional): Filter by issue type
- `search` (optional): Search term
- `page` (optional): Page number
- `per_page` (optional): Items per page

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "issue-uuid",
      "key": "PROJ-123",
      "summary": "Fix login bug",
      "description": "Users cannot login with special characters in password",
      "issue_type": "Bug",
      "status": "In Progress",
      "priority": "High",
      "project": {
        "id": "project-uuid",
        "key": "PROJ",
        "name": "Project Alpha"
      },
      "assignee": {
        "id": "user-uuid",
        "username": "johndoe",
        "display_name": "John Doe"
      },
      "reporter": {
        "id": "reporter-uuid",
        "username": "janedoe",
        "display_name": "Jane Doe"
      },
      "created_at": "2025-01-29T19:50:00Z",
      "updated_at": "2025-01-29T19:50:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

#### POST /api/v1/issues
**Description:** Create new issue

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "project_id": "project-uuid",
  "summary": "New issue summary",
  "description": "Detailed description of the issue",
  "issue_type": "Bug",
  "priority": "Medium",
  "assignee_id": "user-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-issue-uuid",
    "key": "PROJ-124",
    "summary": "New issue summary",
    "description": "Detailed description of the issue",
    "issue_type": "Bug",
    "status": "Open",
    "priority": "Medium",
    "project": {
      "id": "project-uuid",
      "key": "PROJ",
      "name": "Project Alpha"
    },
    "assignee": {
      "id": "user-uuid",
      "username": "johndoe",
      "display_name": "John Doe"
    },
    "reporter": {
      "id": "current-user-uuid",
      "username": "currentuser",
      "display_name": "Current User"
    },
    "created_at": "2025-01-29T19:50:00Z"
  }
}
```

#### GET /api/v1/issues/{id}
**Description:** Get issue by ID

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "issue-uuid",
    "key": "PROJ-123",
    "summary": "Fix login bug",
    "description": "Users cannot login with special characters in password",
    "issue_type": "Bug",
    "status": "In Progress",
    "priority": "High",
    "project": {
      "id": "project-uuid",
      "key": "PROJ",
      "name": "Project Alpha"
    },
    "assignee": {
      "id": "user-uuid",
      "username": "johndoe",
      "display_name": "John Doe"
    },
    "reporter": {
      "id": "reporter-uuid",
      "username": "janedoe",
      "display_name": "Jane Doe"
    },
    "custom_fields": {
      "story_points": 5,
      "sprint": "Sprint 1"
    },
    "attachments": [
      {
        "id": "attachment-uuid",
        "filename": "screenshot.png",
        "size": 1024,
        "url": "https://example.com/files/screenshot.png"
      }
    ],
    "links": [
      {
        "type": "blocks",
        "issue": {
          "id": "linked-issue-uuid",
          "key": "PROJ-122",
          "summary": "Related issue"
        }
      }
    ],
    "created_at": "2025-01-29T19:50:00Z",
    "updated_at": "2025-01-29T19:50:00Z"
  }
}
```

#### PUT /api/v1/issues/{id}
**Description:** Update issue

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "summary": "Updated issue summary",
  "description": "Updated description",
  "status": "Done",
  "assignee_id": "new-assignee-uuid"
}
```

#### DELETE /api/v1/issues/{id}
**Description:** Delete issue

**Headers:**
```
Authorization: Bearer <jwt-token>
```

### 5.2 Issue Comments Endpoints

#### GET /api/v1/issues/{id}/comments
**Description:** Get issue comments

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "comment-uuid",
      "content": "This is a comment on the issue",
      "author": {
        "id": "user-uuid",
        "username": "johndoe",
        "display_name": "John Doe"
      },
      "created_at": "2025-01-29T19:50:00Z",
      "updated_at": "2025-01-29T19:50:00Z"
    }
  ]
}
```

#### POST /api/v1/issues/{id}/comments
**Description:** Add comment to issue

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "content": "This is a new comment"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-comment-uuid",
    "content": "This is a new comment",
    "author": {
      "id": "current-user-uuid",
      "username": "currentuser",
      "display_name": "Current User"
    },
    "created_at": "2025-01-29T19:50:00Z"
  }
}
```

## 6. Workflow Engine Service API

### 6.1 Workflow Endpoints

#### GET /api/v1/workflows
**Description:** Get list of workflows

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `project_id` (optional): Filter by project
- `active` (optional): Filter by active status

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "workflow-uuid",
      "name": "Bug Workflow",
      "description": "Workflow for bug issues",
      "project_id": "project-uuid",
      "issue_types": ["Bug"],
      "is_active": true,
      "states": [
        {
          "id": "state-uuid",
          "name": "Open",
          "type": "initial"
        },
        {
          "id": "state-uuid-2",
          "name": "In Progress",
          "type": "intermediate"
        },
        {
          "id": "state-uuid-3",
          "name": "Done",
          "type": "final"
        }
      ],
      "transitions": [
        {
          "id": "transition-uuid",
          "name": "Start Progress",
          "from_state": "Open",
          "to_state": "In Progress",
          "conditions": [],
          "validators": []
        }
      ],
      "created_at": "2025-01-29T19:50:00Z"
    }
  ]
}
```

#### POST /api/v1/workflows
**Description:** Create new workflow

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "name": "New Workflow",
  "description": "Description of the new workflow",
  "project_id": "project-uuid",
  "issue_types": ["Task"],
  "states": [
    {
      "name": "To Do",
      "type": "initial"
    },
    {
      "name": "Done",
      "type": "final"
    }
  ],
  "transitions": [
    {
      "name": "Complete",
      "from_state": "To Do",
      "to_state": "Done"
    }
  ]
}
```

#### POST /api/v1/workflows/{id}/execute
**Description:** Execute workflow transition

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "issue_id": "issue-uuid",
  "transition_id": "transition-uuid",
  "comment": "Moving to next state"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "issue_id": "issue-uuid",
    "from_state": "Open",
    "to_state": "In Progress",
    "executed_at": "2025-01-29T19:50:00Z",
    "executed_by": {
      "id": "user-uuid",
      "username": "johndoe"
    }
  }
}
```

## 7. Notification Service API

### 7.1 Notification Endpoints

#### GET /api/v1/notifications
**Description:** Get user notifications

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `unread` (optional): Filter unread notifications
- `type` (optional): Filter by notification type
- `page` (optional): Page number
- `per_page` (optional): Items per page

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "notification-uuid",
      "type": "issue_assigned",
      "title": "Issue assigned to you",
      "message": "PROJ-123 has been assigned to you",
      "data": {
        "issue_id": "issue-uuid",
        "issue_key": "PROJ-123"
      },
      "is_read": false,
      "created_at": "2025-01-29T19:50:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 25,
    "total_pages": 2
  }
}
```

#### PUT /api/v1/notifications/{id}/read
**Description:** Mark notification as read

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "notification-uuid",
    "is_read": true,
    "read_at": "2025-01-29T19:50:00Z"
  }
}
```

#### GET /api/v1/notifications/preferences
**Description:** Get notification preferences

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "email_notifications": {
      "issue_assigned": true,
      "issue_updated": false,
      "comment_added": true
    },
    "push_notifications": {
      "issue_assigned": true,
      "issue_updated": true,
      "comment_added": false
    },
    "in_app_notifications": {
      "issue_assigned": true,
      "issue_updated": true,
      "comment_added": true
    }
  }
}
```

#### PUT /api/v1/notifications/preferences
**Description:** Update notification preferences

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "email_notifications": {
    "issue_assigned": true,
    "issue_updated": false,
    "comment_added": true
  },
  "push_notifications": {
    "issue_assigned": true,
    "issue_updated": true,
    "comment_added": false
  }
}
```

## 8. Reporting Service API

### 8.1 Report Endpoints

#### GET /api/v1/reports
**Description:** Get available reports

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "report-uuid",
      "name": "Issue Summary Report",
      "description": "Summary of issues by status and priority",
      "type": "summary",
      "parameters": [
        {
          "name": "project_id",
          "type": "string",
          "required": true
        },
        {
          "name": "date_range",
          "type": "date_range",
          "required": false
        }
      ]
    }
  ]
}
```

#### POST /api/v1/reports/generate
**Description:** Generate report

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "report_id": "report-uuid",
  "parameters": {
    "project_id": "project-uuid",
    "date_range": {
      "start": "2025-01-01",
      "end": "2025-01-31"
    }
  },
  "format": "json"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "report_id": "generated-report-uuid",
    "status": "generating",
    "estimated_completion": "2025-01-29T19:55:00Z"
  }
}
```

#### GET /api/v1/reports/{id}
**Description:** Get generated report

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "generated-report-uuid",
    "name": "Issue Summary Report",
    "status": "completed",
    "generated_at": "2025-01-29T19:52:00Z",
    "data": {
      "summary": {
        "total_issues": 150,
        "open_issues": 45,
        "in_progress_issues": 30,
        "closed_issues": 75
      },
      "by_priority": {
        "critical": 5,
        "high": 15,
        "medium": 80,
        "low": 50
      }
    },
    "download_url": "https://example.com/reports/report.pdf"
  }
}
```

## 9. File Storage Service API

### 9.1 File Endpoints

#### POST /api/v1/files/upload
**Description:** Upload file

**Headers:**
```
Authorization: Bearer <jwt-token>
Content-Type: multipart/form-data
```

**Request:**
```
file: <binary-data>
metadata: {
  "issue_id": "issue-uuid",
  "description": "Screenshot of the bug"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "file-uuid",
    "filename": "screenshot.png",
    "size": 1024,
    "mime_type": "image/png",
    "url": "https://example.com/files/screenshot.png",
    "thumbnail_url": "https://example.com/files/thumbnails/screenshot.png",
    "uploaded_at": "2025-01-29T19:50:00Z"
  }
}
```

#### GET /api/v1/files/{id}
**Description:** Get file information

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "file-uuid",
    "filename": "screenshot.png",
    "size": 1024,
    "mime_type": "image/png",
    "url": "https://example.com/files/screenshot.png",
    "metadata": {
      "issue_id": "issue-uuid",
      "description": "Screenshot of the bug"
    },
    "uploaded_by": {
      "id": "user-uuid",
      "username": "johndoe"
    },
    "uploaded_at": "2025-01-29T19:50:00Z"
  }
}
```

#### DELETE /api/v1/files/{id}
**Description:** Delete file

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "File deleted successfully"
  }
}
```

## 10. Search Service API

### 10.1 Search Endpoints

#### GET /api/v1/search
**Description:** Global search

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `q` (required): Search query
- `type` (optional): Entity type (issues, projects, users)
- `project_id` (optional): Filter by project
- `page` (optional): Page number
- `per_page` (optional): Items per page

**Response:**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "type": "issue",
        "id": "issue-uuid",
        "key": "PROJ-123",
        "title": "Fix login bug",
        "description": "Users cannot login with special characters...",
        "project": {
          "id": "project-uuid",
          "key": "PROJ",
          "name": "Project Alpha"
        },
        "score": 0.95
      }
    ],
    "aggregations": {
      "by_type": {
        "issues": 45,
        "projects": 3,
        "users": 2
      },
      "by_project": {
        "PROJ": 30,
        "OTHER": 15
      }
    }
  },
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 50,
    "total_pages": 3
  }
}
```

#### GET /api/v1/search/suggestions
**Description:** Get search suggestions

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `q` (required): Partial search query
- `type` (optional): Entity type

**Response:**
```json
{
  "success": true,
  "data": {
    "suggestions": [
      {
        "text": "login bug",
        "type": "issue",
        "count": 5
      },
      {
        "text": "login feature",
        "type": "issue",
        "count": 3
      }
    ]
  }
}
```

## 11. Error Handling

### 11.1 HTTP Status Codes
- `200 OK`: Successful GET, PUT, PATCH requests
- `201 Created`: Successful POST requests
- `204 No Content`: Successful DELETE requests
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict
- `422 Unprocessable Entity`: Validation errors
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

### 11.2 Error Codes
```yaml
authentication_errors:
  - INVALID_CREDENTIALS: "Invalid email or password"
  - TOKEN_EXPIRED: "Access token has expired"
  - TOKEN_INVALID: "Invalid access token"
  - REFRESH_TOKEN_EXPIRED: "Refresh token has expired"

authorization_errors:
  - INSUFFICIENT_PERMISSIONS: "Insufficient permissions to access resource"
  - RESOURCE_FORBIDDEN: "Access to resource is forbidden"

validation_errors:
  - REQUIRED_FIELD_MISSING: "Required field is missing"
  - INVALID_FORMAT: "Field format is invalid"
  - VALUE_TOO_LONG: "Field value exceeds maximum length"
  - VALUE_TOO_SHORT: "Field value is below minimum length"
  - INVALID_ENUM_VALUE: "Invalid enum value"

resource_errors:
  - RESOURCE_NOT_FOUND: "Requested resource not found"
  - RESOURCE_ALREADY_EXISTS: "Resource already exists"
  - RESOURCE_CONFLICT: "Resource conflict detected"

business_logic_errors:
  - WORKFLOW_TRANSITION_INVALID: "Invalid workflow transition"
  - PROJECT_MEMBER_ALREADY_EXISTS: "User is already a project member"
  - ISSUE_CANNOT_BE_DELETED: "Issue cannot be deleted due to dependencies"

system_errors:
  - INTERNAL_SERVER_ERROR: "Internal server error occurred"
  - SERVICE_UNAVAILABLE: "Service temporarily unavailable"
  - DATABASE_CONNECTION_ERROR: "Database connection error"
```

### 11.3 Error Response Examples

#### Validation Error
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "REQUIRED_FIELD_MISSING",
        "message": "Email is required"
      },
      {
        "field": "password",
        "code": "VALUE_TOO_SHORT",
        "message": "Password must be at least 8 characters"
      }
    ]
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "req-uuid"
  }
}
```

#### Authorization Error
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You don't have permission to access this resource",
    "details": {
      "required_permission": "admin:projects",
      "user_permissions": ["read:projects", "write:projects"]
    }
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "req-uuid"
  }
}
```

## 12. Rate Limiting

### 12.1 Rate Limit Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1643723400
X-RateLimit-Window: 3600
```

### 12.2 Rate Limit Tiers
```yaml
rate_limits:
  anonymous:
    requests_per_hour: 100
    burst_limit: 10
  
  authenticated_user:
    requests_per_hour: 1000
    burst_limit: 50
  
  premium_user:
    requests_per_hour: 5000
    burst_limit: 100
  
  admin_user:
    requests_per_hour: 10000
    burst_limit: 200

endpoint_specific_limits:
  "/api/v1/auth/login":
    requests_per_hour: 10
    burst_limit: 3
  
  "/api/v1/files/upload":
    requests_per_hour: 100
    burst_limit: 5
  
  "/api/v1/search":
    requests_per_hour: 500
    burst_limit: 20
```

### 12.3 Rate Limit Exceeded Response
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again later.",
    "details": {
      "limit": 1000,
      "window": 3600,
      "reset_at": "2025-01-29T20:50:00Z"
    }
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "req-uuid"
  }
}
```

## 13. API Versioning

### 13.1 Versioning Strategy
- **URL Path Versioning**: `/api/v1/`, `/api/v2/`
- **Header Versioning**: `Accept: application/vnd.projectmanager.v1+json`
- **Backward Compatibility**: Maintain support for previous versions
- **Deprecation Policy**: 12-month notice before version retirement

### 13.2 Version Headers
```
API-Version: v1
API-Supported-Versions: v1, v2
API-Deprecated-Versions: v0
```

### 13.3 Version Migration
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2025-01-29T19:50:00Z",
    "version": "v1",
    "request_id": "req-uuid"
  },
  "migration": {
    "current_version": "v1",
    "latest_version": "v2",
    "migration_guide": "https://docs.example.com/api/v2/migration",
    "deprecation_date": "2025-12-31T23:59:59Z"
  }
}
```

## 14. Webhook API

### 14.1 Webhook Events
```yaml
webhook_events:
  issue_events:
    - issue.created
    - issue.updated
    - issue.deleted
    - issue.status_changed
    - issue.assigned
  
  project_events:
    - project.created
    - project.updated
    - project.deleted
    - project.member_added
    - project.member_removed
  
  user_events:
    - user.created
    - user.updated
    - user.deactivated
  
  workflow_events:
    - workflow.transition_executed
    - workflow.created
    - workflow.updated
```

### 14.2 Webhook Registration

#### POST /api/v1/webhooks
**Description:** Register webhook endpoint

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request:**
```json
{
  "url": "https://example.com/webhook",
  "events": ["issue.created", "issue.updated"],
  "secret": "webhook-secret",
  "active": true,
  "filters": {
    "project_id": "project-uuid"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "webhook-uuid",
    "url": "https://example.com/webhook",
    "events": ["issue.created", "issue.updated"],
    "active": true,
    "created_at": "2025-01-29T19:50:00Z"
  }
}
```

### 14.3 Webhook Payload
```json
{
  "event": "issue.created",
  "timestamp": "2025-01-29T19:50:00Z",
  "webhook_id": "webhook-uuid",
  "data": {
    "issue": {
      "id": "issue-uuid",
      "key": "PROJ-123",
      "summary": "New issue created",
      "project": {
        "id": "project-uuid",
        "key": "PROJ"
      }
    },
    "user": {
      "id": "user-uuid",
      "username": "johndoe"
    }
  }
}
```

### 14.4 Webhook Security
- **HMAC Signature**: `X-Hub-Signature-256: sha256=<signature>`
- **Timestamp Verification**: `X-Hub-Timestamp: <unix-timestamp>`
- **Retry Policy**: Exponential backoff with maximum 5 retries
- **Timeout**: 30 seconds per request

## 15. GraphQL API (Optional)

### 15.1 GraphQL Schema
```graphql
type Query {
  me: User
  projects(first: Int, after: String): ProjectConnection
  issues(first: Int, after: String, filters: IssueFilters): IssueConnection
  issue(id: ID!): Issue
  project(id: ID!): Project
}

type Mutation {
  createIssue(input: CreateIssueInput!): CreateIssuePayload
  updateIssue(id: ID!, input: UpdateIssueInput!): UpdateIssuePayload
  deleteIssue(id: ID!): DeleteIssuePayload
  createProject(input: CreateProjectInput!): CreateProjectPayload
}

type Subscription {
  issueUpdated(projectId: ID!): Issue
  projectUpdated(id: ID!): Project
}

type User {
  id: ID!
  username: String!
  email: String!
  displayName: String!
  avatarUrl: String
  createdAt: DateTime!
}

type Project {
  id: ID!
  key: String!
  name: String!
  description: String
  lead: User!
  issues(first: Int, after: String): IssueConnection
  members: [ProjectMember!]!
  createdAt: DateTime!
}

type Issue {
  id: ID!
  key: String!
  summary: String!
  description: String
  issueType: String!
  status: String!
  priority: String!
  project: Project!
  assignee: User
  reporter: User!
  comments(first: Int, after: String): CommentConnection
  attachments: [Attachment!]!
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### 15.2 GraphQL Endpoint
```
POST /api/v1/graphql
```

### 15.3 GraphQL Query Example
```graphql
query GetProjectIssues($projectId: ID!, $first: Int!) {
  project(id: $projectId) {
    id
    name
    issues(first: $first) {
      edges {
        node {
          id
          key
          summary
          status
          assignee {
            username
            displayName
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

---

## Conclusion

This API contracts document provides comprehensive specifications for all microservices in the project management system. The APIs follow RESTful principles with consistent error handling, authentication, and response formats. The design supports:

1. **Scalable Architecture**: Each service has well-defined boundaries and responsibilities
2. **Security**: JWT-based authentication with role-based access control
3. **Developer Experience**: Consistent API design with comprehensive documentation
4. **Extensibility**: Webhook support and optional GraphQL API for advanced use cases
5. **Reliability**: Proper error handling and rate limiting

**Document Version**: 1.0
**Last Updated**: 2025-01-29
**Next Review Date**: 2025-04-29