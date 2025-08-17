# Document Analysis AI - Stage 1

An AI-powered document analysis application that processes text and PDF documents to generate intelligent summaries using OpenAI GPT-4. Built with FastAPI and designed for rapid deployment and easy usage.

## 🚀 Quick Start

### Automated Demo
```bash
# Run the complete demonstration
./demo/demo.sh
```

### Manual Setup
```bash
# 1. Install dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -e .

# 2. Configure environment
cp .env.example .env
# Edit .env and set your OpenAI API key

# 3. Start application
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 4. Open browser
# Visit: http://localhost:8000
```

## 📋 Features

### ✅ **Current Capabilities (Stage 1)**
- **Document Upload**: Drag-and-drop interface for TXT and PDF files (up to 10MB)
- **Text Extraction**: Intelligent text extraction with encoding detection
- **AI Summarization**: GPT-4 powered document summarization
- **Web Interface**: Clean, responsive web interface
- **Progress Tracking**: Real-time upload and processing progress
- **Error Handling**: Comprehensive error messages and recovery guidance
- **Security**: File validation and malicious content protection
- **API Access**: RESTful API with automatic documentation

### 🔄 **Processing Flow**
1. **Upload** → User uploads TXT or PDF document
2. **Validate** → System validates file type, size, and content
3. **Extract** → Text extracted using pdfplumber (PDF) or encoding detection (TXT)
4. **Analyze** → OpenAI GPT-4 generates comprehensive summary
5. **Display** → Results shown with metadata and download option

## 🛠️ Requirements

### System Requirements
- **Python**: 3.12 or higher
- **Operating System**: Linux, macOS, or WSL2
- **Memory**: 4GB RAM minimum
- **Storage**: 500MB for dependencies

### API Requirements
- **OpenAI API Key**: Required for document summarization
  - Sign up at: https://platform.openai.com/
  - Set in `.env` file: `OPENAI_API_KEY=sk-your-key-here`

## 📦 Installation

### Option 1: Direct Installation
```bash
# Clone repository
git clone <repository-url>
cd document-analysis-ai

# Install with uv (recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv
source .venv/bin/activate
uv pip install -e .

# Or install with pip
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### Option 2: Docker Installation
```bash
# Build and run with Docker Compose
docker-compose up --build

# Or build manually
docker build -t document-analysis-ai .
docker run -p 8000:8000 -e OPENAI_API_KEY=your-key document-analysis-ai
```

## ⚙️ Configuration

### Environment Variables
Create a `.env` file with the following configuration:

```env
# Required
OPENAI_API_KEY=sk-your-openai-api-key-here

# Optional (with defaults)
MAX_FILE_SIZE=10485760          # 10MB in bytes
TEMP_DIR=/tmp                   # Temporary file directory
REQUEST_TIMEOUT=30              # Request timeout in seconds
HOST=0.0.0.0                   # Server host
PORT=8000                      # Server port
ENVIRONMENT=development         # Environment name
```

### OpenAI Configuration
1. **Create Account**: Sign up at https://platform.openai.com/
2. **Generate API Key**: Go to API Keys section and create new key
3. **Add Credit**: Ensure account has sufficient credit for API calls
4. **Set Environment**: Add key to `.env` file

## 🌐 Usage

### Web Interface
1. **Start Application**: Run `./demo/demo.sh` or manually start server
2. **Open Browser**: Navigate to http://localhost:8000
3. **Upload Document**: Drag and drop or click to select TXT/PDF file
4. **Wait for Analysis**: Processing typically takes 10-30 seconds
5. **Review Results**: View summary, metadata, and download option
6. **Upload Another**: Use "Analyze Another Document" button

### API Usage
```bash
# Upload and analyze document
curl -X POST -F "file=@document.pdf" http://localhost:8000/api/v1/documents/upload

# Check health
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/documents/health

# View API documentation
# Visit: http://localhost:8000/docs
```

### API Response Format
```json
{
  "success": true,
  "filename": "document.pdf",
  "metadata": {
    "filename": "document.pdf",
    "file_size": 245760,
    "file_type": "pdf",
    "pages": 5,
    "processing_time": 12.34
  },
  "analysis": {
    "summary": "AI-generated summary of the document...",
    "word_count": 1250,
    "character_count": 7543,
    "confidence_score": 0.92
  },
  "processing_time": 12.34,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🧪 Testing

### Automated Testing
```bash
# Run verification script
./verify-stage.sh

# Run unit tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html
```

### Manual Testing
```bash
# Test with sample documents
./demo.sh

# Test API directly
curl -X POST -F "file=@test_documents/sample_text.txt" http://localhost:8000/api/v1/documents/upload
```

### Test Documents
The demo script creates sample documents for testing:
- `test_documents/sample_text.txt` - Meeting notes
- `test_documents/research_paper.txt` - Academic paper

## 📖 Documentation

### API Documentation
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Spec**: http://localhost:8000/openapi.json

### Additional Documentation
- `test-environment.md` - Comprehensive testing guide
- `stage-validation-checklist.md` - Requirements validation checklist
- `demo.sh` - Interactive demonstration script
- `verify-stage.sh` - Automated verification script

## 🏗️ Architecture

### Project Structure
```
├── app/
│   ├── api/              # API endpoints
│   ├── core/             # Core utilities (config, security, exceptions)
│   ├── services/         # Business logic (document processing, OpenAI)
│   ├── schemas/          # Pydantic data models
│   └── main.py          # FastAPI application
├── static/              # Web interface files
├── tests/               # Test suite
├── test_documents/      # Sample documents for testing
├── .env.example         # Environment configuration template
├── pyproject.toml       # Python dependencies and project config
├── Dockerfile           # Docker container configuration
├── docker-compose.yml   # Docker Compose setup
├── demo.sh             # Interactive demonstration
├── verify-stage.sh     # Automated verification
└── README.md           # This file
```

### Technology Stack
- **Backend**: FastAPI (Python 3.12+)
- **AI Integration**: OpenAI GPT-4
- **Document Processing**: pdfplumber (PDF), chardet (encoding detection)
- **Security**: python-magic (file type detection)
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Deployment**: Docker, uvicorn
- **Testing**: pytest, curl

## 🔧 Development

### Code Quality
```bash
# Linting and formatting
ruff check .
ruff format .

# Type checking
pyright

# Run all quality checks
ruff check . && ruff format . && pyright && pytest
```

### Development Server
```bash
# Start with hot reload
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Or use the script
./demo.sh
```

## 🐳 Docker Deployment

### Docker Compose (Recommended)
```bash
# Start all services
docker-compose up --build

# Run in background
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Manual Docker
```bash
# Build image
docker build -t document-analysis-ai .

# Run container
docker run -p 8000:8000 \
  -e OPENAI_API_KEY=your-key \
  -e MAX_FILE_SIZE=10485760 \
  document-analysis-ai
```

## 🔒 Security

### Security Features
- **File Validation**: Content-based file type detection
- **Size Limits**: 10MB maximum file size
- **Malicious Content**: Basic pattern detection
- **Data Privacy**: No persistent storage of document content
- **Secure Communication**: HTTPS-only API calls
- **Input Sanitization**: Comprehensive input validation

### Security Best Practices
- Never log document content or personal information
- Automatic cleanup of temporary files
- Secure file permissions (600) for uploaded files
- API key protection through environment variables
- Error messages that don't expose system details

## 📊 Performance

### Performance Characteristics
- **Processing Time**: < 30 seconds for standard documents (1-5 pages)
- **Concurrent Users**: Handles up to 10 concurrent uploads
- **Memory Usage**: Stable consumption under 512MB
- **File Limits**: 10MB maximum upload size
- **Supported Formats**: TXT, PDF

### Performance Optimization
- Streaming file upload to prevent memory issues
- Automatic temporary file cleanup
- Efficient text processing with chunked reading
- OpenAI API retry logic with exponential backoff
- Concurrent request handling with FastAPI async support

## 🚀 Roadmap

### Stage 1 (Current) ✅
- Basic document upload and AI summarization
- TXT and PDF support
- Web interface and API
- Docker deployment

### Stage 2 (Planned)
- Additional file formats (DOCX, HTML, Markdown)
- Multiple analysis types (entity extraction, sentiment)
- Enhanced UI with analysis options
- Improved error handling

### Stage 3 (Future)
- Batch document processing
- Background job queue (Celery)
- Database persistence (PostgreSQL)
- Advanced analytics dashboard

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make changes following code style guidelines
4. Add tests for new functionality
5. Run quality checks: `ruff check . && pytest`
6. Submit pull request

### Code Style
- Follow PEP 8 guidelines
- Use type hints for all functions
- Add docstrings for public methods
- Keep functions focused and testable
- Use meaningful variable names

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🆘 Support

### Troubleshooting
1. **Server won't start**: Check Python version (3.12+) and dependencies
2. **OpenAI errors**: Verify API key in `.env` file
3. **File upload fails**: Check file size (<10MB) and format (TXT/PDF)
4. **Performance issues**: Monitor system resources and network connectivity

### Common Issues
- **Port 8000 in use**: Change port with `--port 8001`
- **Missing dependencies**: Reinstall with `pip install -e .`
- **Docker issues**: Ensure Docker daemon is running
- **API key invalid**: Check OpenAI dashboard for key status

### Getting Help
- Check the `test-environment.md` for comprehensive testing guide
- Run `./verify-stage.sh` for automated diagnostics
- Review application logs for error details
- Test with provided sample documents first

---

## 📈 Status

**Current Stage**: Stage 1 - Basic Document Analysis  
**Status**: ✅ Complete and Ready for Use  
**Last Updated**: 2024-01-15  
**Version**: 1.0.0  

This implementation successfully delivers the core value proposition of AI-powered document analysis with a focus on simplicity, reliability, and user experience.