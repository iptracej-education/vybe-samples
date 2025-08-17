"""Document upload and analysis API endpoints."""

import time
from datetime import datetime
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from ..schemas.document import DocumentUploadResponse, DocumentMetadata, DocumentAnalysisResult
from ..core.security import FileValidator
from ..core.storage import TemporaryFileManager
from ..services.document_processor import DocumentProcessor
from ..services.openai_service import OpenAIService
from ..core.exceptions import ValidationError, ProcessingError, OpenAIError

router = APIRouter()


async def get_openai_service():
    """Dependency to get OpenAI service instance."""
    return OpenAIService()


@router.post("/upload", response_model=DocumentUploadResponse)
async def upload_document(
    file: UploadFile = File(..., description="Document file (TXT or PDF, max 10MB)"),
    openai_service: OpenAIService = Depends(get_openai_service)
):
    """
    Upload and analyze a single document.
    
    This endpoint accepts TXT or PDF files up to 10MB, extracts text content,
    and generates an AI-powered summary using OpenAI GPT-4.
    """
    start_time = time.time()
    
    try:
        # Validate filename
        FileValidator.validate_filename(file.filename)
        
        # Validate file
        file_type = await FileValidator.validate_file(file)
        
        # Process document using temporary file handler
        async with TemporaryFileManager.temporary_file_handler(file) as temp_path:
            # Reset file pointer
            await file.seek(0)
            
            # Extract text
            text_content, extraction_metadata = await DocumentProcessor.extract_text(
                temp_path, file_type
            )
            
            # Generate AI summary
            ai_result = await openai_service.generate_summary(
                text_content, file.filename, extraction_metadata
            )
        
        # Calculate total processing time
        total_processing_time = time.time() - start_time
        
        # Create metadata object
        metadata = DocumentMetadata(
            filename=file.filename,
            file_size=extraction_metadata.get("file_size", 0),
            file_type=file_type,
            encoding=extraction_metadata.get("encoding"),
            pages=extraction_metadata.get("pages"),
            processing_time=total_processing_time
        )
        
        # Create analysis result
        analysis = DocumentAnalysisResult(
            summary=ai_result["summary"],
            word_count=extraction_metadata.get("word_count", 0),
            character_count=extraction_metadata.get("character_count", 0),
            confidence_score=ai_result.get("confidence_score")
        )
        
        # Create response
        response = DocumentUploadResponse(
            success=True,
            filename=file.filename,
            metadata=metadata,
            analysis=analysis,
            processing_time=total_processing_time,
            timestamp=datetime.utcnow()
        )
        
        return response
        
    except ValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except ProcessingError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except OpenAIError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Internal server error: {str(e)}"
        )


@router.get("/health")
async def health_check():
    """Health check endpoint for the document processing service."""
    try:
        # Test OpenAI connection
        openai_service = OpenAIService()
        openai_configured = await openai_service.test_connection()
    except Exception:
        openai_configured = False
    
    return {
        "status": "healthy",
        "stage": "1",
        "capabilities": ["txt", "pdf", "ai_summary"],
        "timestamp": datetime.utcnow(),
        "openai_configured": openai_configured
    }