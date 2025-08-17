# Technical Design - Stage 1: Basic Document Analysis

## Overview
Stage 1 implements a minimal viable document analysis system using FastAPI, OpenAI integration, and a simple web interface. The design prioritizes rapid delivery while establishing architectural patterns for future expansion. The system processes individual documents through a streamlined pipeline: upload → text extraction → AI analysis → results display.

**Design Philosophy**: Deliver core value quickly while building a foundation that scales gracefully to Stage 2's multi-format support and Stage 3's batch processing capabilities.

## Requirements Traceability Matrix

| Requirement | Design Component | Implementation Details |
|-------------|------------------|------------------------|
| REQ-1: Document Upload | UploadFile endpoint, MultiPart handler | FastAPI multipart/form-data with file validation |
| REQ-2: Text Extraction | DocumentProcessor service, ExtractionEngine | pdfplumber for PDFs, direct read for TXT files |
| REQ-3: AI Summarization | OpenAIService, SummarizationEngine | OpenAI GPT-4 with custom prompt templates |
| REQ-4: Results Display | ResultsRenderer, WebUI templates | HTML/CSS/JS with AJAX for dynamic updates |
| REQ-5: Error Handling | ExceptionMiddleware, ErrorHandler | Centralized error processing with user-friendly messages |
| REQ-6: Security | FileValidator, SecurityMiddleware | File type validation, content scanning, secure headers |
| REQ-7: Performance | AsyncHandlers, MemoryManager | Streaming file processing, efficient memory usage |

## System Architecture

### High-Level Component Design
```
┌─────────────────┐    HTTP     ┌─────────────────┐    API     ┌─────────────────┐
│   Web Browser   │ ────────▶  │   FastAPI App   │ ────────▶  │   OpenAI API    │
│                 │            │                 │            │                 │
│ - Upload Form   │            │ - File Upload   │            │ - GPT-4         │
│ - Results View  │            │ - Text Extract  │            │ - Summarization │
│ - Progress UI   │            │ - AI Integration │            │                 │
└─────────────────┘            └─────────────────┘            └─────────────────┘
                                        │
                                        ▼
                               ┌─────────────────┐
                               │  File System    │
                               │                 │
                               │ - Temp Storage  │
                               │ - Session Cache │
                               └─────────────────┘
```

### Detailed Architecture Layers

#### 1. Presentation Layer
**Components**: Static HTML/CSS/JS files, Upload form, Results display
**Responsibilities**: User interface, file selection, progress indication, results presentation
**Technology**: Vanilla HTML/CSS/JavaScript with modern browser APIs

#### 2. API Layer  
**Components**: FastAPI endpoints, Request validation, Response formatting
**Responsibilities**: HTTP request handling, multipart data processing, API response structure
**Technology**: FastAPI with Pydantic models, automatic OpenAPI documentation

#### 3. Service Layer
**Components**: DocumentProcessor, OpenAIService, FileValidator, ResultsFormatter
**Responsibilities**: Business logic, external API integration, data transformation
**Technology**: Python services with dependency injection pattern

#### 4. Infrastructure Layer
**Components**: File storage, Configuration management, Logging
**Responsibilities**: Temporary file handling, environment configuration, error tracking
**Technology**: Python pathlib, pydantic-settings, structured logging

## Data Flow Design

### Primary Processing Pipeline
```
1. File Upload Request
   ├─ Multipart form data received
   ├─ File validation (type, size, content)
   ├─ Temporary storage creation
   └─ Processing job initiation

2. Text Extraction Phase
   ├─ File type detection
   ├─ Appropriate extractor selection
   │  ├─ TXT: Direct encoding detection & read
   │  └─ PDF: pdfplumber extraction with layout preservation
   ├─ Content validation (minimum length)
   └─ Text preprocessing

3. AI Analysis Phase
   ├─ OpenAI API client initialization
   ├─ Prompt template application
   ├─ GPT-4 API call with error handling
   ├─ Response validation
   └─ Result formatting

4. Response Generation
   ├─ Results compilation
   ├─ Metadata addition (filename, timestamp, stats)
   ├─ Download file generation
   └─ Cleanup (temporary files, memory)
```

### Error Flow Handling
```
Error Detection → Error Classification → User-Friendly Message → Recovery Options
     │                    │                      │                    │
     ├─ Validation        ├─ Client Error        ├─ Specific Guidance ├─ Retry Upload
     ├─ Processing        ├─ Server Error        ├─ Alternative Action ├─ Contact Support  
     ├─ API Failure       ├─ External Error      ├─ Status Explanation ├─ Troubleshooting
     └─ System Error      └─ Configuration Error └─ Next Steps        └─ Error Reporting
```

## Component Specifications

### 1. FastAPI Application Structure
```python
# app/main.py
from fastapi import FastAPI, UploadFile, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Document Analysis AI - Stage 1",
    description="Basic document upload and AI summarization",
    version="1.0.0"
)

# Middleware configuration
app.add_middleware(CORSMiddleware, allow_origins=["*"])
app.mount("/static", StaticFiles(directory="static"), name="static")

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "stage": "1", "capabilities": ["txt", "pdf"]}
```

### 2. Document Processing Service
```python
# app/services/document_processor.py
from typing import Union, Tuple
import pdfplumber
from pathlib import Path

class DocumentProcessor:
    """Handles text extraction from uploaded documents"""
    
    @staticmethod
    async def extract_text(file_path: Path, file_type: str) -> Tuple[str, dict]:
        """Extract text with metadata from document"""
        if file_type == "txt":
            return await DocumentProcessor._extract_text_file(file_path)
        elif file_type == "pdf":
            return await DocumentProcessor._extract_pdf_file(file_path)
        else:
            raise ValueError(f"Unsupported file type: {file_type}")
    
    @staticmethod
    async def _extract_pdf_file(file_path: Path) -> Tuple[str, dict]:
        """Extract text from PDF using pdfplumber for layout preservation"""
        # Implementation details follow research findings on pdfplumber best practices
```

### 3. OpenAI Integration Service
```python
# app/services/openai_service.py
from openai import AsyncOpenAI
from app.core.config import settings

class OpenAIService:
    """Handles AI analysis using OpenAI GPT-4"""
    
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = "gpt-4"
    
    async def generate_summary(self, content: str, filename: str) -> dict:
        """Generate document summary with structured output"""
        prompt = self._create_summary_prompt(content, filename)
        
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=500,
                temperature=0.3
            )
            return self._format_response(response)
        except Exception as e:
            raise OpenAIError(f"API call failed: {str(e)}")
```

### 4. File Upload Endpoint Design
```python
# app/api/v1/documents.py
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.document_processor import DocumentProcessor
from app.services.openai_service import OpenAIService

router = APIRouter()

@router.post("/upload")
async def upload_document(
    file: UploadFile = File(..., description="Document file (TXT or PDF, max 10MB)")
):
    """Upload and analyze a single document"""
    
    # File validation
    await validate_upload_file(file)
    
    # Process document
    processor = DocumentProcessor()
    openai_service = OpenAIService()
    
    try:
        # Extract text
        text_content, metadata = await processor.extract_text(file)
        
        # Generate AI summary
        summary_result = await openai_service.generate_summary(text_content, file.filename)
        
        # Format response
        return {
            "success": True,
            "filename": file.filename,
            "metadata": metadata,
            "summary": summary_result,
            "processing_time": calculate_processing_time(),
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        handle_processing_error(e)
```

## Data Models

### Request/Response Schemas
```python
# app/schemas/document.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class DocumentUploadResponse(BaseModel):
    """Response model for document upload and analysis"""
    success: bool
    filename: str
    metadata: dict = Field(description="File metadata (size, pages, etc.)")
    summary: str = Field(description="AI-generated summary")
    processing_time: float = Field(description="Time taken in seconds")
    timestamp: datetime
    download_url: Optional[str] = Field(description="URL for downloading results")

class ErrorResponse(BaseModel):
    """Standard error response model"""
    success: bool = False
    error_code: str
    message: str
    details: Optional[dict] = None
    suggestion: Optional[str] = None
```

## Security Implementation

### File Validation Strategy
```python
# app/core/security.py
import magic
from pathlib import Path

class FileValidator:
    """Comprehensive file validation and security checks"""
    
    ALLOWED_MIME_TYPES = {
        "text/plain": "txt",
        "application/pdf": "pdf"
    }
    MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
    
    @staticmethod
    async def validate_file(file: UploadFile) -> str:
        """Validate uploaded file for security and compatibility"""
        
        # Size validation
        if file.size > FileValidator.MAX_FILE_SIZE:
            raise ValidationError("File exceeds 10MB limit")
        
        # MIME type validation using python-magic
        file_content = await file.read(1024)  # Read first 1KB for detection
        await file.seek(0)  # Reset file pointer
        
        mime_type = magic.from_buffer(file_content, mime=True)
        if mime_type not in FileValidator.ALLOWED_MIME_TYPES:
            raise ValidationError(f"Unsupported file type: {mime_type}")
        
        return FileValidator.ALLOWED_MIME_TYPES[mime_type]
```

### Error Handling Middleware
```python
# app/core/exceptions.py
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse

class ErrorHandlingMiddleware:
    """Centralized error handling with user-friendly messages"""
    
    @staticmethod
    async def handle_validation_error(request: Request, exc: ValidationError):
        return JSONResponse(
            status_code=400,
            content={
                "success": False,
                "error_code": "VALIDATION_ERROR",
                "message": str(exc),
                "suggestion": "Please check file format and size requirements"
            }
        )
    
    @staticmethod
    async def handle_openai_error(request: Request, exc: OpenAIError):
        return JSONResponse(
            status_code=503,
            content={
                "success": False,
                "error_code": "AI_SERVICE_ERROR",
                "message": "AI analysis temporarily unavailable",
                "suggestion": "Please try again in a few moments"
            }
        )
```

## Performance Considerations

### Memory Management
- **Streaming File Processing**: Use async file operations to prevent memory issues with large files
- **Temporary File Cleanup**: Automatic cleanup of uploaded files after processing
- **Connection Pooling**: Reuse HTTP connections for OpenAI API calls
- **Response Streaming**: Stream large responses to prevent memory accumulation

### Optimization Strategies
```python
# app/core/performance.py
import asyncio
from contextlib import asynccontextmanager

class PerformanceOptimizer:
    """Performance optimization utilities"""
    
    @asynccontextmanager
    async def temporary_file_handler(self, upload_file: UploadFile):
        """Context manager for safe temporary file handling"""
        temp_path = None
        try:
            temp_path = await self.save_upload_file(upload_file)
            yield temp_path
        finally:
            if temp_path and temp_path.exists():
                temp_path.unlink()  # Clean up temporary file
    
    @staticmethod
    async def save_upload_file(upload_file: UploadFile) -> Path:
        """Save uploaded file to temporary location with streaming"""
        temp_path = Path(f"/tmp/{upload_file.filename}")
        
        with open(temp_path, "wb") as buffer:
            while chunk := await upload_file.read(8192):  # Read in 8KB chunks
                buffer.write(chunk)
        
        return temp_path
```

## Testing Strategy

### Test Coverage Requirements
1. **Unit Tests**: Individual service methods, validation logic, error handling
2. **Integration Tests**: End-to-end upload and processing workflow
3. **API Tests**: Endpoint behavior, response formatting, error scenarios
4. **Security Tests**: File validation, malicious content detection
5. **Performance Tests**: Response time validation, memory usage monitoring

### Key Test Scenarios
```python
# tests/test_document_processing.py
import pytest
from app.services.document_processor import DocumentProcessor

class TestDocumentProcessor:
    """Test suite for document processing functionality"""
    
    @pytest.mark.asyncio
    async def test_pdf_extraction_success(self, sample_pdf):
        """Test successful PDF text extraction"""
        text, metadata = await DocumentProcessor.extract_text(sample_pdf, "pdf")
        assert len(text) > 50
        assert "pages" in metadata
    
    @pytest.mark.asyncio
    async def test_txt_extraction_encoding(self, sample_txt_utf8):
        """Test text file extraction with UTF-8 encoding"""
        text, metadata = await DocumentProcessor.extract_text(sample_txt_utf8, "txt")
        assert isinstance(text, str)
        assert metadata["encoding"] == "utf-8"
```

## Configuration Management

### Environment Configuration
```python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application configuration with environment variable support"""
    
    # API Configuration
    openai_api_key: str = Field(..., description="OpenAI API key")
    openai_model: str = Field(default="gpt-4", description="OpenAI model to use")
    
    # File Processing
    max_file_size: int = Field(default=10485760, description="Max file size in bytes (10MB)")
    temp_dir: str = Field(default="/tmp", description="Temporary file directory")
    
    # Performance
    request_timeout: int = Field(default=30, description="Request timeout in seconds")
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

## Deployment Architecture

### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv pip sync uv.lock

# Copy application code
COPY app/ ./app/
COPY static/ ./static/

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose Setup
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    volumes:
      - /tmp:/tmp
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

## Migration Path to Future Stages

### Stage 2 Preparation
- **Service Layer**: Designed for easy extension to multiple file types
- **Processing Pipeline**: Modular extractors ready for DOCX, HTML, Markdown support
- **Analysis Engine**: Expandable to multiple analysis types beyond summarization

### Stage 3 Foundation
- **Async Architecture**: FastAPI async patterns ready for Celery integration
- **File Handling**: Temporary storage patterns compatible with persistent database storage
- **API Design**: Response models extensible for batch processing results

This design delivers Stage 1 requirements while establishing architectural patterns that scale smoothly to future complexity. The focus on research-informed technology choices (pdfplumber, FastAPI best practices) ensures robust foundation for growth.