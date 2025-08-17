"""Application configuration management."""

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings with environment variable support."""
    
    # API Configuration
    openai_api_key: str = Field(..., description="OpenAI API key")
    openai_model: str = Field(default="gpt-4", description="OpenAI model to use")
    
    # File Processing
    max_file_size: int = Field(default=10485760, description="Max file size in bytes (10MB)")
    temp_dir: str = Field(default="/tmp", description="Temporary file directory")
    
    # Performance
    request_timeout: int = Field(default=30, description="Request timeout in seconds")
    
    # Server
    host: str = Field(default="0.0.0.0", description="Server host")
    port: int = Field(default=8000, description="Server port")
    reload: bool = Field(default=True, description="Enable hot reload")
    
    # Environment
    environment: str = Field(default="development", description="Environment name")
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()