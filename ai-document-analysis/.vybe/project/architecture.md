# Technical Architecture - Document Analysis AI App

## System Architecture

### High-Level Architecture
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Web UI    │────▶│   FastAPI   │────▶│   OpenAI    │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                    ┌──────┼──────┐
                    ▼      ▼      ▼
             ┌─────────┐ ┌─────────┐ ┌─────────┐
             │ Celery  │ │  Redis  │ │Postgres │
             └─────────┘ └─────────┘ └─────────┘
                    │
             ┌──────┴──────┐
             │  Supabase   │
             └─────────────┘
```

### Component Architecture
- **Presentation Layer**: Web UI (HTML/JS/CSS)
- **API Layer**: FastAPI REST endpoints
- **Processing Layer**: Celery workers for async tasks
- **Data Layer**: PostgreSQL + Redis
- **Integration Layer**: OpenAI API, Supabase services
- **Infrastructure Layer**: Docker containers

## Technology Stack

### Core Technologies
| Component | Technology | Version | Purpose |
|-----------|-----------|---------|----------|
| Language | Python | 3.12+ | Primary development language |
| Framework | FastAPI | 0.115.12+ | Web framework and API |
| Task Queue | Celery | 5.5.3+ | Background job processing |
| Database | PostgreSQL | 15+ | Primary data storage |
| Cache | Redis | 7+ | Caching and queue broker |
| AI/ML | OpenAI API | Latest | Document analysis engine |

### Supporting Technologies
| Component | Technology | Purpose |
|-----------|-----------|----------|
| Package Manager | uv | Fast Python package management |
| Server | Uvicorn | ASGI server |
| ORM | SQLAlchemy | Database abstraction |
| Validation | Pydantic | Data validation |
| Authentication | Supabase Auth | User management |
| Storage | Supabase Storage | Document storage |
| API Gateway | Kong | Rate limiting, routing |
| Monitoring | Vector | Log aggregation |

## Data Architecture

### Database Schema
```sql
-- Core Tables
documents (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  filename VARCHAR(255),
  file_type VARCHAR(50),
  file_size INTEGER,
  storage_url TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

analyses (
  id UUID PRIMARY KEY,
  document_id UUID REFERENCES documents,
  analysis_type VARCHAR(50),
  status VARCHAR(20),
  result JSONB,
  metadata JSONB,
  created_at TIMESTAMP,
  completed_at TIMESTAMP
)

users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  api_key VARCHAR(255),
  quota_limit INTEGER,
  created_at TIMESTAMP
)

-- Managed by Supabase
auth.users (Supabase Auth)
storage.objects (Supabase Storage)
```

### Data Flow
1. **Upload**: Client → API → Supabase Storage → Database
2. **Processing**: Database → Celery → OpenAI → Database
3. **Retrieval**: Database → API → Client

### Caching Strategy
- **Redis Cache Layers**:
  - API response cache (TTL: 5 minutes)
  - Document analysis cache (TTL: 1 hour)
  - User session cache (TTL: 24 hours)
  - OpenAI response cache (TTL: 1 hour)

## API Design

### RESTful Endpoints
```
POST   /api/v1/documents/upload
GET    /api/v1/documents/{id}
DELETE /api/v1/documents/{id}
GET    /api/v1/documents/list

POST   /api/v1/analyze/{document_id}
GET    /api/v1/analyses/{id}
GET    /api/v1/analyses/status/{id}

POST   /api/v1/batch/upload
GET    /api/v1/batch/{batch_id}/status
GET    /api/v1/batch/{batch_id}/results

GET    /api/v1/user/profile
PUT    /api/v1/user/settings
GET    /api/v1/user/usage
```

### API Authentication
- **Methods**: 
  - Bearer token (JWT via Supabase)
  - API Key (for programmatic access)
- **Rate Limiting**: 
  - 100 requests/minute (standard)
  - 1000 requests/minute (premium)

## Security Architecture

### Security Layers
1. **Network Security**
   - HTTPS only (Caddy auto-SSL)
   - API Gateway (Kong)
   - Container network isolation

2. **Application Security**
   - Input validation (Pydantic)
   - SQL injection prevention (ORM)
   - XSS protection
   - CORS configuration

3. **Data Security**
   - Encryption at rest (PostgreSQL)
   - Encryption in transit (TLS)
   - Document sanitization
   - PII detection and masking

4. **Access Control**
   - JWT authentication
   - Role-based access (RBAC)
   - API key management
   - Audit logging

## Deployment Architecture

### Container Structure
```yaml
services:
  app:           # FastAPI application
  postgres:      # PostgreSQL database
  redis:         # Redis cache/broker
  celery_worker: # Background workers
  celery_beat:   # Scheduled tasks
  supabase:      # Supabase stack
  kong:          # API Gateway
  vector:        # Log aggregation
```

### Scaling Strategy
- **Horizontal Scaling**:
  - Add Celery workers for processing
  - Increase Uvicorn workers for API
  - Redis cluster for high throughput
  
- **Vertical Scaling**:
  - Increase container resources
  - Optimize database queries
  - Implement connection pooling

### Environment Configuration
```
# Development
- Hot reload enabled
- Debug logging
- Local services
- Mock data available

# Staging
- Production-like setup
- Integration testing
- Performance monitoring
- Limited access

# Production
- High availability
- Load balancing
- Full monitoring
- Backup strategies
```

## Integration Patterns

### OpenAI Integration
```python
# Structured extraction pattern
instructor_client = instructor.from_openai(OpenAI())
result = instructor_client.extract(
    model="gpt-4",
    schema=DocumentAnalysis,
    text=document_content
)
```

### Workflow Patterns
- **Event-Driven**: Document upload triggers analysis
- **Queue-Based**: Celery manages processing pipeline
- **Async Processing**: Non-blocking API responses
- **Retry Logic**: Automatic retries with exponential backoff

## Performance Considerations

### Optimization Strategies
1. **Document Processing**
   - Chunk large documents (> 10MB)
   - Parallel processing for batches
   - Smart caching of results

2. **Database Performance**
   - Indexed queries
   - Connection pooling
   - Materialized views for analytics

3. **API Performance**
   - Response pagination
   - Async request handling
   - CDN for static assets

### Performance Targets
- API latency: < 100ms (p50), < 500ms (p99)
- Document processing: < 30s average
- Batch processing: 100+ docs/hour
- Concurrent users: 1000+
- Database connections: 100 pooled

## Monitoring & Observability

### Logging Strategy
- **Application Logs**: FastAPI/Uvicorn
- **Task Logs**: Celery workers
- **System Logs**: Docker containers
- **Aggregation**: Vector → Centralized logging

### Metrics Collection
- Request/response times
- Processing queue depth
- Error rates and types
- Resource utilization
- User activity patterns

### Health Checks
```
GET /health          # Application health
GET /health/db       # Database connectivity
GET /health/redis    # Redis connectivity
GET /health/celery   # Worker status
```

## Disaster Recovery

### Backup Strategy
- **Database**: Daily automated backups
- **Documents**: Supabase Storage replication
- **Configuration**: Git version control
- **Secrets**: Encrypted vault storage

### Recovery Procedures
- RTO (Recovery Time Objective): 4 hours
- RPO (Recovery Point Objective): 24 hours
- Automated failover for critical services
- Manual intervention for data recovery