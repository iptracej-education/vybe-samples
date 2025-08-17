"""Custom exceptions and error handling."""

from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
import logging

logger = logging.getLogger(__name__)


class DocumentAnalysisError(Exception):
    """Base exception for document analysis errors."""
    pass


class ValidationError(DocumentAnalysisError):
    """Raised when file validation fails."""
    pass


class ProcessingError(DocumentAnalysisError):
    """Raised when document processing fails."""
    pass


class OpenAIError(DocumentAnalysisError):
    """Raised when OpenAI API integration fails."""
    pass


class ConfigurationError(DocumentAnalysisError):
    """Raised when configuration is invalid."""
    pass


async def validation_error_handler(request: Request, exc: ValidationError):
    """Handle validation errors with user-friendly messages."""
    logger.warning(f"Validation error: {str(exc)}")
    return JSONResponse(
        status_code=400,
        content={
            "success": False,
            "error_code": "VALIDATION_ERROR",
            "message": str(exc),
            "suggestion": "Please check file format and size requirements"
        }
    )


async def processing_error_handler(request: Request, exc: ProcessingError):
    """Handle processing errors with user-friendly messages."""
    logger.error(f"Processing error: {str(exc)}")
    return JSONResponse(
        status_code=422,
        content={
            "success": False,
            "error_code": "PROCESSING_ERROR",
            "message": str(exc),
            "suggestion": "Please check file content and try again"
        }
    )


async def openai_error_handler(request: Request, exc: OpenAIError):
    """Handle OpenAI API errors with user-friendly messages."""
    logger.error(f"OpenAI error: {str(exc)}")
    return JSONResponse(
        status_code=503,
        content={
            "success": False,
            "error_code": "AI_SERVICE_ERROR",
            "message": "AI analysis temporarily unavailable",
            "suggestion": "Please try again in a few moments"
        }
    )


async def configuration_error_handler(request: Request, exc: ConfigurationError):
    """Handle configuration errors."""
    logger.error(f"Configuration error: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error_code": "CONFIGURATION_ERROR",
            "message": "Service configuration error",
            "suggestion": "Please contact support"
        }
    )