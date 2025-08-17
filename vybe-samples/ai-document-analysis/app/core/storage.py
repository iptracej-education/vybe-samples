"""Temporary file management utilities."""

import os
import tempfile
import uuid
from pathlib import Path
from contextlib import asynccontextmanager
from fastapi import UploadFile
from .config import settings


class TemporaryFileManager:
    """Manages temporary file storage with automatic cleanup."""
    
    @staticmethod
    def generate_temp_filename(original_filename: str) -> str:
        """Generate a unique temporary filename."""
        file_extension = Path(original_filename).suffix
        unique_id = str(uuid.uuid4())
        return f"doc_analysis_{unique_id}{file_extension}"
    
    @staticmethod
    async def save_upload_file(upload_file: UploadFile) -> Path:
        """
        Save uploaded file to temporary location with streaming.
        
        Args:
            upload_file: FastAPI UploadFile object
            
        Returns:
            Path: Temporary file path
        """
        temp_filename = TemporaryFileManager.generate_temp_filename(upload_file.filename)
        temp_path = Path(settings.temp_dir) / temp_filename
        
        # Ensure temp directory exists
        temp_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Stream file to disk
        with open(temp_path, "wb") as buffer:
            while chunk := await upload_file.read(8192):  # Read in 8KB chunks
                buffer.write(chunk)
        
        # Set secure file permissions (readable only by owner)
        os.chmod(temp_path, 0o600)
        
        return temp_path
    
    @staticmethod
    def cleanup_file(file_path: Path) -> None:
        """Safely remove temporary file."""
        try:
            if file_path.exists():
                file_path.unlink()
        except Exception:
            # Log error but don't raise - cleanup failures shouldn't break the app
            pass
    
    @staticmethod
    @asynccontextmanager
    async def temporary_file_handler(upload_file: UploadFile):
        """Context manager for safe temporary file handling with automatic cleanup."""
        temp_path = None
        try:
            temp_path = await TemporaryFileManager.save_upload_file(upload_file)
            yield temp_path
        finally:
            if temp_path:
                TemporaryFileManager.cleanup_file(temp_path)