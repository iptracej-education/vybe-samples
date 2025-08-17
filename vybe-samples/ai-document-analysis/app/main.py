"""FastAPI application main module."""

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from .api.documents import router as documents_router
from .core.exceptions import (
    validation_error_handler,
    processing_error_handler,
    openai_error_handler,
    configuration_error_handler,
    ValidationError,
    ProcessingError,
    OpenAIError,
    ConfigurationError,
)

# Create FastAPI application
app = FastAPI(
    title="Document Analysis AI - Stage 1",
    description="Basic document upload and AI summarization using OpenAI GPT-4",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Add exception handlers
app.add_exception_handler(ValidationError, validation_error_handler)
app.add_exception_handler(ProcessingError, processing_error_handler)
app.add_exception_handler(OpenAIError, openai_error_handler)
app.add_exception_handler(ConfigurationError, configuration_error_handler)

# Include API routers
app.include_router(documents_router, prefix="/api/v1/documents", tags=["documents"])


@app.get("/")
async def serve_index():
    """Serve the main web interface."""
    return FileResponse("static/index.html")


@app.get("/health")
async def health_check():
    """Application health check."""
    return {
        "status": "healthy",
        "service": "Document Analysis AI",
        "stage": "1",
        "version": "1.0.0"
    }


if __name__ == "__main__":
    import uvicorn
    from .core.config import settings
    
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.reload
    )