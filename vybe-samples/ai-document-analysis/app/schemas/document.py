"""Pydantic schemas for document processing."""

from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field


class DocumentMetadata(BaseModel):
    """Document metadata model."""
    filename: str
    file_size: int
    file_type: str
    encoding: Optional[str] = None
    pages: Optional[int] = None
    processing_time: Optional[float] = None


class DocumentAnalysisResult(BaseModel):
    """Document analysis result model."""
    summary: str = Field(description="AI-generated summary")
    word_count: int = Field(description="Number of words in document")
    character_count: int = Field(description="Number of characters in document")
    confidence_score: Optional[float] = Field(description="Analysis confidence (0-1)")


class DocumentUploadResponse(BaseModel):
    """Response model for document upload and analysis."""
    success: bool
    filename: str
    metadata: DocumentMetadata
    analysis: DocumentAnalysisResult
    processing_time: float = Field(description="Total processing time in seconds")
    timestamp: datetime
    download_url: Optional[str] = Field(
        default=None, 
        description="URL for downloading results"
    )


class ErrorResponse(BaseModel):
    """Standard error response model."""
    success: bool = False
    error_code: str
    message: str
    details: Optional[Dict[str, Any]] = None
    suggestion: Optional[str] = None


class HealthCheckResponse(BaseModel):
    """Health check response model."""
    status: str
    stage: str
    capabilities: list[str]
    timestamp: datetime
    openai_configured: bool