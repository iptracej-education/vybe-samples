# Development Conventions - Document Analysis AI App

## Code Style Guidelines

### Python Code Style
```python
# Follow PEP 8 with these specifications:
# - Line length: 88 characters (Black/Ruff default)
# - Indentation: 4 spaces
# - String quotes: Double quotes preferred

# File naming
snake_case_modules.py
snake_case_functions.py

# Class naming
class PascalCaseClasses:
    pass

# Function naming
def snake_case_functions():
    pass

# Constants
UPPER_SNAKE_CASE_CONSTANTS = "value"

# Type hints required for all functions
def process_document(file_path: str, options: dict[str, Any]) -> DocumentResult:
    pass
```

### Import Organization
```python
# Standard library imports
import os
from typing import Optional, List

# Third-party imports
import fastapi
from celery import Celery
from pydantic import BaseModel

# Local application imports
from app.core import workflow
from app.services import document_service
```

### Docstring Standards
```python
def analyze_document(content: str, analysis_type: str) -> dict:
    """
    Analyze document content using specified analysis type.
    
    Args:
        content: The document text content to analyze
        analysis_type: Type of analysis ('summary', 'entities', 'sentiment')
    
    Returns:
        Dictionary containing analysis results
        
    Raises:
        ValueError: If analysis_type is not supported
        OpenAIError: If API call fails
    """
    pass
```

## Project Structure

### Directory Organization
```
app/
├── api/                 # API endpoints
│   ├── v1/
│   │   ├── documents.py
│   │   ├── analyses.py
│   │   └── users.py
│   └── dependencies.py
├── core/               # Core business logic
│   ├── workflow.py     # Workflow definitions
│   ├── validate.py     # Validation logic
│   └── commands/       # CLI commands
├── services/           # Service layer
│   ├── document_service.py
│   ├── ai_service.py
│   └── storage_service.py
├── models/            # Database models
│   ├── document.py
│   ├── analysis.py
│   └── user.py
├── schemas/           # Pydantic schemas
│   ├── document.py
│   ├── analysis.py
│   └── response.py
├── worker/            # Celery tasks
│   ├── tasks.py
│   └── celery_app.py
├── utils/             # Utility functions
│   ├── file_processing.py
│   └── text_helpers.py
└── main.py           # Application entry point
```

### File Naming Conventions
- **API Routes**: `{resource}_routes.py` (e.g., `document_routes.py`)
- **Services**: `{domain}_service.py` (e.g., `ai_service.py`)
- **Models**: Singular nouns (e.g., `document.py`)
- **Schemas**: Match model names (e.g., `document.py`)
- **Tests**: `test_{module}.py` (e.g., `test_document_service.py`)

## API Design Standards

### Endpoint Naming
```
# RESTful resource naming
GET    /api/v1/documents        # List
POST   /api/v1/documents        # Create
GET    /api/v1/documents/{id}   # Retrieve
PUT    /api/v1/documents/{id}   # Update
DELETE /api/v1/documents/{id}   # Delete

# Action endpoints
POST   /api/v1/documents/{id}/analyze
POST   /api/v1/documents/{id}/export
GET    /api/v1/documents/{id}/status
```

### Response Format
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "result": "..."
  },
  "message": "Operation successful",
  "metadata": {
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
  }
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid document format",
    "details": {
      "field": "file_type",
      "reason": "Unsupported format"
    }
  },
  "request_id": "uuid"
}
```

## Database Conventions

### Model Conventions
```python
class Document(Base):
    __tablename__ = "documents"
    
    # Primary key always 'id' as UUID
    id = Column(UUID, primary_key=True, default=uuid4)
    
    # Timestamps on all tables
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
    
    # Soft deletes where applicable
    deleted_at = Column(DateTime, nullable=True)
    
    # Foreign keys with explicit naming
    user_id = Column(UUID, ForeignKey("users.id"))
```

### Migration Standards
```bash
# Naming: {timestamp}_{verb}_{description}.py
# Example: 20240101_create_documents_table.py

# Always include:
# - Upgrade and downgrade functions
# - Clear description in migration
# - Data migration if schema changes affect existing data
```

## Testing Standards

### Test Structure
```python
# tests/unit/test_document_service.py
import pytest
from app.services import document_service

class TestDocumentService:
    """Test cases for document service."""
    
    @pytest.fixture
    def sample_document(self):
        """Fixture providing sample document."""
        return {"content": "test", "type": "txt"}
    
    def test_process_document_success(self, sample_document):
        """Test successful document processing."""
        result = document_service.process(sample_document)
        assert result.status == "success"
    
    def test_process_document_invalid_type(self):
        """Test handling of invalid document type."""
        with pytest.raises(ValueError):
            document_service.process({"type": "invalid"})
```

### Test Coverage Requirements
- Minimum coverage: 80%
- Critical paths: 100%
- New features: Must include tests
- Bug fixes: Must include regression tests

## Git Workflow

### Branch Naming
```
main                    # Production branch
develop                 # Development branch
feature/stage-1-upload  # Feature branches
fix/document-parsing    # Bug fix branches
hotfix/security-patch   # Emergency fixes
```

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>

# Examples:
feat(documents): add PDF parsing support
fix(api): handle large file uploads correctly
docs(readme): update installation instructions
refactor(services): extract common validation logic
test(documents): add integration tests for upload
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Build/tooling changes

## Environment Configuration

### Environment Variables
```bash
# .env file structure
# Application
APP_NAME=document-analyzer
APP_ENV=development
DEBUG=true

# Database
DATABASE_URL=postgresql://user:pass@localhost/dbname
REDIS_URL=redis://localhost:6379

# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4

# Supabase
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=...

# Security
SECRET_KEY=...
JWT_ALGORITHM=HS256
JWT_EXPIRATION=3600
```

### Configuration Management
```python
# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application settings."""
    
    app_name: str = "Document Analyzer"
    debug: bool = False
    database_url: str
    openai_api_key: str
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

## Code Quality Tools

### Linting & Formatting
```bash
# Ruff configuration (pyproject.toml)
[tool.ruff]
line-length = 88
target-version = "py312"
select = ["E", "F", "I", "N", "UP", "S", "B", "A", "C4", "T20"]
ignore = ["E501"]
exclude = [".venv", "alembic"]

# Format code
ruff format .

# Check linting
ruff check .
```

### Type Checking
```bash
# Pyright configuration (pyrightconfig.json)
{
  "include": ["app"],
  "exclude": [".venv"],
  "typeCheckingMode": "strict",
  "pythonVersion": "3.12"
}

# Run type checking
pyright
```

## Documentation Standards

### Code Documentation
- All public functions must have docstrings
- Complex logic must have inline comments
- TODO comments must include ticket reference
- No commented-out code in production

### API Documentation
- OpenAPI/Swagger auto-generated from FastAPI
- Additional endpoint descriptions required
- Example requests/responses for all endpoints
- Postman collection maintained

### Project Documentation
- README.md with setup instructions
- Architecture decisions documented
- Deployment guide maintained
- Troubleshooting guide available

## Security Best Practices

### Input Validation
- Always validate user input
- Use Pydantic models for validation
- Sanitize file uploads
- Limit file sizes

### Authentication & Authorization
- JWT tokens for session management
- API keys for programmatic access
- Role-based access control
- Audit logging for sensitive operations

### Data Protection
- Never log sensitive data
- Encrypt passwords and tokens
- Use environment variables for secrets
- Regular security audits

## Performance Guidelines

### Optimization Principles
- Profile before optimizing
- Async operations where beneficial
- Cache expensive operations
- Batch database operations

### Resource Management
- Close database connections
- Limit concurrent operations
- Implement request timeouts
- Monitor memory usage

## Review Checklist

### Before Committing
- [ ] Code passes linting (ruff)
- [ ] Type hints added (pyright)
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No hardcoded secrets
- [ ] Performance impact considered

### Pull Request Requirements
- [ ] Clear description of changes
- [ ] Linked to issue/ticket
- [ ] Tests cover new code
- [ ] Documentation updated
- [ ] Reviewed by team member
- [ ] CI/CD pipeline passing