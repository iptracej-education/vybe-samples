"""Document text extraction service."""

import chardet
import pdfplumber
from pathlib import Path
from typing import Tuple, Dict, Any
from ..core.exceptions import ProcessingError


class DocumentProcessor:
    """Handles text extraction from uploaded documents."""
    
    MIN_CONTENT_LENGTH = 50
    
    @staticmethod
    async def extract_text(file_path: Path, file_type: str) -> Tuple[str, Dict[str, Any]]:
        """
        Extract text with metadata from document.
        
        Args:
            file_path: Path to the document file
            file_type: Type of file ("txt" or "pdf")
            
        Returns:
            Tuple of (extracted_text, metadata)
            
        Raises:
            ProcessingError: If text extraction fails
        """
        try:
            if file_type == "txt":
                return await DocumentProcessor._extract_text_file(file_path)
            elif file_type == "pdf":
                return await DocumentProcessor._extract_pdf_file(file_path)
            else:
                raise ProcessingError(f"Unsupported file type: {file_type}")
        except Exception as e:
            if isinstance(e, ProcessingError):
                raise
            raise ProcessingError(f"Text extraction failed: {str(e)}")
    
    @staticmethod
    async def _extract_text_file(file_path: Path) -> Tuple[str, Dict[str, Any]]:
        """
        Extract text from plain text file with encoding detection.
        
        Args:
            file_path: Path to text file
            
        Returns:
            Tuple of (text_content, metadata)
            
        Raises:
            ProcessingError: If text extraction fails
        """
        try:
            # Detect encoding
            with open(file_path, "rb") as file:
                raw_data = file.read()
                
            if not raw_data:
                raise ProcessingError("File is empty")
            
            # Detect encoding
            encoding_result = chardet.detect(raw_data)
            encoding = encoding_result.get("encoding", "utf-8")
            confidence = encoding_result.get("confidence", 0.0)
            
            # If confidence is low, try common encodings
            if confidence < 0.7:
                for fallback_encoding in ["utf-8", "ascii", "latin-1", "cp1252"]:
                    try:
                        text_content = raw_data.decode(fallback_encoding)
                        encoding = fallback_encoding
                        break
                    except UnicodeDecodeError:
                        continue
                else:
                    raise ProcessingError(
                        "Unable to decode file. Please ensure file is in UTF-8, ASCII, or Latin-1 encoding."
                    )
            else:
                try:
                    text_content = raw_data.decode(encoding)
                except UnicodeDecodeError:
                    # Fallback to UTF-8 with error handling
                    text_content = raw_data.decode("utf-8", errors="replace")
                    encoding = "utf-8 (with replacements)"
            
            # Validate content length
            if len(text_content.strip()) < DocumentProcessor.MIN_CONTENT_LENGTH:
                raise ProcessingError(
                    f"Document content too short (minimum {DocumentProcessor.MIN_CONTENT_LENGTH} characters required)"
                )
            
            # Calculate metadata
            metadata = {
                "encoding": encoding,
                "confidence": confidence,
                "file_size": len(raw_data),
                "line_count": len(text_content.splitlines()),
                "word_count": len(text_content.split()),
                "character_count": len(text_content)
            }
            
            return text_content, metadata
            
        except Exception as e:
            if isinstance(e, ProcessingError):
                raise
            raise ProcessingError(f"Failed to extract text from file: {str(e)}")
    
    @staticmethod
    async def _extract_pdf_file(file_path: Path) -> Tuple[str, Dict[str, Any]]:
        """
        Extract text from PDF using pdfplumber for layout preservation.
        
        Args:
            file_path: Path to PDF file
            
        Returns:
            Tuple of (text_content, metadata)
            
        Raises:
            ProcessingError: If PDF extraction fails
        """
        try:
            text_content = ""
            page_count = 0
            
            with pdfplumber.open(file_path) as pdf:
                page_count = len(pdf.pages)
                
                if page_count == 0:
                    raise ProcessingError("PDF has no pages")
                
                # Extract text from all pages
                for page_num, page in enumerate(pdf.pages, 1):
                    try:
                        page_text = page.extract_text()
                        if page_text:
                            text_content += f"\n--- Page {page_num} ---\n"
                            text_content += page_text + "\n"
                    except Exception as e:
                        # Continue with other pages if one fails
                        text_content += f"\n--- Page {page_num} (extraction failed) ---\n"
                        continue
                
                # Get PDF metadata
                metadata_dict = pdf.metadata or {}
                
            # Clean up text content
            text_content = text_content.strip()
            
            # Validate content
            if len(text_content) < DocumentProcessor.MIN_CONTENT_LENGTH:
                if page_count > 0:
                    raise ProcessingError(
                        "Could not extract sufficient text from PDF. "
                        "This may be an image-based PDF or contain primarily non-text content. "
                        "Please try a text-based PDF or convert to text format."
                    )
                else:
                    raise ProcessingError("PDF appears to be empty or corrupted")
            
            # Calculate metadata
            metadata = {
                "pages": page_count,
                "pdf_title": metadata_dict.get("Title", ""),
                "pdf_author": metadata_dict.get("Author", ""),
                "pdf_subject": metadata_dict.get("Subject", ""),
                "pdf_creator": metadata_dict.get("Creator", ""),
                "word_count": len(text_content.split()),
                "character_count": len(text_content),
                "file_size": file_path.stat().st_size
            }
            
            return text_content, metadata
            
        except pdfplumber.PDFError as e:
            raise ProcessingError(f"Invalid PDF file: {str(e)}")
        except Exception as e:
            if isinstance(e, ProcessingError):
                raise
            raise ProcessingError(f"Failed to extract text from PDF: {str(e)}")