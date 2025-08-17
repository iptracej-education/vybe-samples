"""OpenAI integration service for document analysis."""

import asyncio
import time
from typing import Dict, Any
from openai import AsyncOpenAI
from ..core.config import settings
from ..core.exceptions import OpenAIError, ConfigurationError


class OpenAIService:
    """Handles AI analysis using OpenAI GPT-4."""
    
    def __init__(self):
        """Initialize OpenAI service with configuration validation."""
        if not settings.openai_api_key or settings.openai_api_key == "sk-your-openai-api-key-here":
            raise ConfigurationError(
                "OpenAI API key not configured. Please set OPENAI_API_KEY environment variable."
            )
        
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model
        self.max_retries = 3
        self.retry_delay = 1  # seconds
    
    async def test_connection(self) -> bool:
        """Test OpenAI API connection and key validity."""
        try:
            # Simple test request to validate API key
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": "Test"}],
                max_tokens=5
            )
            return True
        except Exception:
            return False
    
    async def generate_summary(self, content: str, filename: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generate document summary with structured output.
        
        Args:
            content: Document text content
            filename: Original filename
            metadata: Document metadata
            
        Returns:
            Dictionary containing summary and analysis metadata
            
        Raises:
            OpenAIError: If API call fails
        """
        start_time = time.time()
        
        try:
            prompt = self._create_summary_prompt(content, filename, metadata)
            
            # Retry logic with exponential backoff
            last_exception = None
            for attempt in range(self.max_retries):
                try:
                    response = await self.client.chat.completions.create(
                        model=self.model,
                        messages=[{"role": "user", "content": prompt}],
                        max_tokens=800,
                        temperature=0.3,
                        timeout=settings.request_timeout
                    )
                    
                    summary_text = response.choices[0].message.content.strip()
                    
                    # Validate response quality
                    if len(summary_text) < 100:
                        raise OpenAIError("Generated summary too short (minimum 100 characters)")
                    
                    processing_time = time.time() - start_time
                    
                    return self._format_response(summary_text, response, processing_time)
                    
                except Exception as e:
                    last_exception = e
                    if attempt < self.max_retries - 1:
                        # Exponential backoff
                        delay = self.retry_delay * (2 ** attempt)
                        await asyncio.sleep(delay)
                        continue
                    else:
                        break
            
            # If we get here, all retries failed
            raise OpenAIError(f"OpenAI API failed after {self.max_retries} attempts: {str(last_exception)}")
            
        except OpenAIError:
            raise
        except Exception as e:
            raise OpenAIError(f"Unexpected error during AI analysis: {str(e)}")
    
    def _create_summary_prompt(self, content: str, filename: str, metadata: Dict[str, Any]) -> str:
        """Create optimized prompt for document summarization."""
        
        # Truncate content if too long (roughly 3000 tokens = 12000 characters)
        max_content_length = 12000
        if len(content) > max_content_length:
            content = content[:max_content_length] + "\n\n[Content truncated...]"
        
        # Extract relevant metadata for context
        pages_info = f" ({metadata.get('pages', 'unknown')} pages)" if metadata.get('pages') else ""
        word_count = metadata.get('word_count', 'unknown')
        
        prompt = f"""
Please analyze and summarize the following document:

**Document Information:**
- Filename: {filename}
- Word Count: {word_count}{pages_info}

**Document Content:**
{content}

**Instructions:**
Please provide a comprehensive summary that includes:

1. **Main Topic & Purpose**: What is this document about and what is its primary purpose?

2. **Key Points**: The 3-5 most important points, findings, or arguments presented.

3. **Important Details**: Specific facts, numbers, dates, or context that are crucial to understanding.

4. **Actionable Insights**: Any recommendations, conclusions, or next steps mentioned.

5. **Overall Assessment**: Brief evaluation of the document's scope and significance.

Please write the summary in clear, professional language that would be useful for someone who needs to quickly understand the document's content and importance. Aim for 200-400 words.

**Summary:**
"""
        
        return prompt
    
    def _format_response(self, summary_text: str, response: Any, processing_time: float) -> Dict[str, Any]:
        """Format AI response with metadata."""
        
        # Calculate basic metrics
        summary_word_count = len(summary_text.split())
        summary_char_count = len(summary_text)
        
        # Extract usage information if available
        usage_info = {}
        if hasattr(response, 'usage') and response.usage:
            usage_info = {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            }
        
        # Calculate confidence score based on response characteristics
        confidence_score = self._calculate_confidence_score(summary_text, usage_info)
        
        return {
            "summary": summary_text,
            "summary_word_count": summary_word_count,
            "summary_char_count": summary_char_count,
            "confidence_score": confidence_score,
            "processing_time": processing_time,
            "model_used": self.model,
            "usage": usage_info
        }
    
    def _calculate_confidence_score(self, summary: str, usage_info: Dict[str, Any]) -> float:
        """Calculate confidence score for the generated summary."""
        score = 0.8  # Base confidence
        
        # Adjust based on summary length (ideal range: 200-600 words)
        word_count = len(summary.split())
        if 200 <= word_count <= 600:
            score += 0.1
        elif word_count < 100:
            score -= 0.3
        
        # Adjust based on structure (look for key indicators)
        structure_indicators = ["main topic", "key points", "important", "conclusion", "summary"]
        if any(indicator in summary.lower() for indicator in structure_indicators):
            score += 0.05
        
        # Adjust based on token efficiency
        if usage_info.get("completion_tokens", 0) > 0:
            if usage_info["completion_tokens"] < 1000:  # Efficient response
                score += 0.05
        
        return min(max(score, 0.0), 1.0)  # Clamp between 0 and 1