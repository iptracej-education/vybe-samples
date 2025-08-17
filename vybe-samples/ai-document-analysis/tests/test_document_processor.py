"""Tests for document processing functionality."""

import pytest
import tempfile
from pathlib import Path
from app.services.document_processor import DocumentProcessor
from app.core.exceptions import ProcessingError


class TestDocumentProcessor:
    """Test suite for document processing functionality."""
    
    @pytest.mark.asyncio
    async def test_txt_extraction_success(self):
        """Test successful text file extraction."""
        # Create temporary text file
        content = "This is a test document with some content for testing purposes."
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(content)
            temp_path = Path(f.name)
        
        try:
            text, metadata = await DocumentProcessor.extract_text(temp_path, "txt")
            
            assert text == content
            assert metadata["encoding"] in ["utf-8", "ascii"]
            assert metadata["word_count"] == len(content.split())
            assert metadata["character_count"] == len(content)
        finally:
            temp_path.unlink()
    
    @pytest.mark.asyncio
    async def test_txt_extraction_empty_file(self):
        """Test handling of empty text files."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            temp_path = Path(f.name)
        
        try:
            with pytest.raises(ProcessingError, match="File is empty"):
                await DocumentProcessor.extract_text(temp_path, "txt")
        finally:
            temp_path.unlink()
    
    @pytest.mark.asyncio
    async def test_txt_extraction_too_short(self):
        """Test handling of files with insufficient content."""
        content = "Short"  # Less than 50 characters
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(content)
            temp_path = Path(f.name)
        
        try:
            with pytest.raises(ProcessingError, match="Document content too short"):
                await DocumentProcessor.extract_text(temp_path, "txt")
        finally:
            temp_path.unlink()
    
    @pytest.mark.asyncio
    async def test_unsupported_file_type(self):
        """Test handling of unsupported file types."""
        with tempfile.NamedTemporaryFile(suffix='.docx', delete=False) as f:
            temp_path = Path(f.name)
        
        try:
            with pytest.raises(ProcessingError, match="Unsupported file type"):
                await DocumentProcessor.extract_text(temp_path, "docx")
        finally:
            temp_path.unlink()


if __name__ == "__main__":
    pytest.main([__file__])