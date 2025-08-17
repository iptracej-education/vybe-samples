"""File validation and security utilities."""

import magic
from pathlib import Path
from fastapi import UploadFile
from .exceptions import ValidationError
from .config import settings


class FileValidator:
    """Comprehensive file validation and security checks."""
    
    ALLOWED_MIME_TYPES = {
        "text/plain": "txt",
        "application/pdf": "pdf"
    }
    
    ALLOWED_EXTENSIONS = {".txt", ".pdf"}
    
    @staticmethod
    async def validate_file(file: UploadFile) -> str:
        """
        Validate uploaded file for security and compatibility.
        
        Returns:
            str: File type ("txt" or "pdf")
            
        Raises:
            ValidationError: If file validation fails
        """
        
        # Check if file is provided
        if not file or not file.filename:
            raise ValidationError("No file provided")
        
        # Size validation
        file_size = 0
        content_chunks = []
        
        # Read file in chunks to check size and get content for validation
        while chunk := await file.read(8192):
            content_chunks.append(chunk)
            file_size += len(chunk)
            
            if file_size > settings.max_file_size:
                raise ValidationError(f"File exceeds {settings.max_file_size // (1024*1024)}MB limit")
        
        # Reset file pointer
        await file.seek(0)
        
        if file_size == 0:
            raise ValidationError("File is empty")
        
        # Extension validation
        file_extension = Path(file.filename).suffix.lower()
        if file_extension not in FileValidator.ALLOWED_EXTENSIONS:
            raise ValidationError(
                f"Unsupported file extension: {file_extension}. "
                f"Supported formats: {', '.join(FileValidator.ALLOWED_EXTENSIONS)}"
            )
        
        # MIME type validation using first chunk
        if content_chunks:
            first_chunk = content_chunks[0]
            try:
                mime_type = magic.from_buffer(first_chunk, mime=True)
            except Exception:
                # Fallback to extension-based validation
                mime_type = "text/plain" if file_extension == ".txt" else "application/pdf"
            
            if mime_type not in FileValidator.ALLOWED_MIME_TYPES:
                raise ValidationError(
                    f"Unsupported file type: {mime_type}. "
                    f"File content doesn't match extension."
                )
            
            detected_type = FileValidator.ALLOWED_MIME_TYPES[mime_type]
            expected_type = "txt" if file_extension == ".txt" else "pdf"
            
            if detected_type != expected_type:
                raise ValidationError(
                    f"File content ({detected_type}) doesn't match extension ({file_extension})"
                )
            
            return detected_type
        
        # Fallback based on extension
        return "txt" if file_extension == ".txt" else "pdf"
    
    @staticmethod
    def validate_filename(filename: str) -> None:
        """Validate filename for security."""
        if not filename:
            raise ValidationError("Filename is required")
        
        # Check for path traversal attempts
        if ".." in filename or "/" in filename or "\\" in filename:
            raise ValidationError("Invalid filename: path traversal detected")
        
        # Check filename length
        if len(filename) > 255:
            raise ValidationError("Filename too long (max 255 characters)")
        
        # Check for suspicious patterns
        suspicious_patterns = ["script", "javascript", "vbscript", "onload", "onerror"]
        filename_lower = filename.lower()
        
        for pattern in suspicious_patterns:
            if pattern in filename_lower:
                raise ValidationError(f"Suspicious filename pattern detected: {pattern}")