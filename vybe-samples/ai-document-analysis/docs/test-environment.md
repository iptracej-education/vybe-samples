# Test Environment Guide - Document Analysis AI Stage 1

## Overview
This guide provides comprehensive instructions for testing the Document Analysis AI Stage 1 implementation. Follow these steps to validate all functionality and ensure the system meets the specified requirements.

## Prerequisites

### System Requirements
- **Python**: 3.12 or higher
- **Operating System**: Linux, macOS, or WSL2
- **Memory**: Minimum 4GB RAM
- **Disk Space**: 500MB for dependencies and temp files
- **Network**: Internet connection for OpenAI API calls

### Required Tools
- `curl` - For API testing
- `python3` - Python interpreter
- `pip` or `uv` - Package manager
- Web browser - For testing the web interface

### API Key Requirements
- **OpenAI API Key**: Required for document summarization
  - Sign up at: https://platform.openai.com/
  - Minimum credit balance recommended: $5
  - API key format: `sk-...` (starts with "sk-")

## Quick Start

### 1. Environment Setup
```bash
# Clone or navigate to project directory
cd document-analysis-ai

# Run automated verification
./verify-stage.sh

# Run interactive demo
./demo.sh
```

### 2. Manual Setup (if automated scripts fail)
```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -e .

# Configure environment
cp .env.example .env
# Edit .env and set your OpenAI API key:
# OPENAI_API_KEY=sk-your-actual-key-here

# Start application
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Testing Procedures

### Test 1: Application Startup
**Objective**: Verify the application starts correctly and all services are healthy.

**Steps**:
1. Start the application:
   ```bash
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. Check health endpoints:
   ```bash
   curl http://localhost:8000/health
   curl http://localhost:8000/api/v1/documents/health
   ```

**Expected Results**:
- Application starts without errors
- Health endpoints return `{"status": "healthy"}`
- OpenAI configuration status indicates API key validity

**Troubleshooting**:
- **Port in use**: Change port with `--port 8001`
- **Import errors**: Reinstall dependencies with `pip install -e .`
- **OpenAI errors**: Verify API key in `.env` file

### Test 2: Web Interface Access
**Objective**: Verify the web interface loads and is functional.

**Steps**:
1. Open web browser and navigate to: `http://localhost:8000`
2. Verify page loads completely
3. Check that upload area is visible and interactive

**Expected Results**:
- Web page loads without errors
- Upload area displays with drag-and-drop functionality
- JavaScript console shows no errors

**Troubleshooting**:
- **Page not loading**: Check if server is running
- **Styling issues**: Verify static files are served from `/static/`
- **JavaScript errors**: Check browser console for details

### Test 3: Document Upload - Text Files
**Objective**: Test text file upload and processing functionality.

**Steps**:
1. Create a test text file:
   ```bash
   echo "This is a comprehensive test document with sufficient content to meet the minimum character requirements for processing. The document contains multiple sentences and provides enough text for meaningful AI analysis and summarization." > test_document.txt
   ```

2. **Web Interface Test**:
   - Drag and drop `test_document.txt` onto the upload area
   - OR click upload area and select the file
   - Wait for processing to complete

3. **API Test**:
   ```bash
   curl -X POST -F "file=@test_document.txt" http://localhost:8000/api/v1/documents/upload
   ```

**Expected Results**:
- File uploads successfully
- Processing completes within 30 seconds
- Returns JSON response with:
  - `"success": true`
  - Document metadata (filename, size, word count)
  - AI-generated summary
  - Processing time information

**Troubleshooting**:
- **File too large**: Ensure file is under 10MB
- **Processing timeout**: Check OpenAI API key and network connection
- **Upload failed**: Verify file encoding (UTF-8, ASCII)

### Test 4: Document Upload - PDF Files
**Objective**: Test PDF file upload and text extraction.

**Steps**:
1. Use a sample PDF file or create one with text content
2. Upload via web interface or API:
   ```bash
   curl -X POST -F "file=@sample.pdf" http://localhost:8000/api/v1/documents/upload
   ```

**Expected Results**:
- PDF text extraction works correctly
- Metadata includes page count
- Summary reflects PDF content accurately

**Troubleshooting**:
- **Text extraction failed**: PDF may be image-based or corrupted
- **Empty response**: PDF may not contain extractable text
- **Processing error**: Check PDF file integrity

### Test 5: File Validation and Error Handling
**Objective**: Verify proper error handling for invalid files.

**Steps**:
1. **Test oversized file**:
   ```bash
   # Create file larger than 10MB
   dd if=/dev/zero of=large_file.txt bs=1M count=15
   curl -X POST -F "file=@large_file.txt" http://localhost:8000/api/v1/documents/upload
   ```

2. **Test unsupported file type**:
   ```bash
   echo "test" > test.xyz
   curl -X POST -F "file=@test.xyz" http://localhost:8000/api/v1/documents/upload
   ```

3. **Test empty file**:
   ```bash
   touch empty.txt
   curl -X POST -F "file=@empty.txt" http://localhost:8000/api/v1/documents/upload
   ```

**Expected Results**:
- Each test returns appropriate error messages
- HTTP status codes are correct (400, 422)
- Error responses include helpful suggestions

### Test 6: AI Analysis Quality
**Objective**: Verify AI summarization quality and accuracy.

**Steps**:
1. Upload documents with different characteristics:
   - **Short document** (100-500 words)
   - **Medium document** (500-2000 words)
   - **Long document** (2000+ words)
   - **Technical content**
   - **Meeting notes**
   - **Research paper**

2. Evaluate summaries for:
   - Accuracy to original content
   - Completeness of key points
   - Appropriate length (200-400 words typically)
   - Professional language and clarity

**Expected Results**:
- Summaries capture main topics accurately
- Key information is preserved
- Language is clear and professional
- Processing time stays under 30 seconds

### Test 7: Performance Testing
**Objective**: Verify performance under various conditions.

**Steps**:
1. **Response Time Test**:
   ```bash
   time curl -X POST -F "file=@test_document.txt" http://localhost:8000/api/v1/documents/upload
   ```

2. **Concurrent Upload Test**:
   ```bash
   # Run multiple uploads simultaneously
   for i in {1..5}; do
     curl -X POST -F "file=@test_document.txt" http://localhost:8000/api/v1/documents/upload &
   done
   wait
   ```

3. **Memory Usage Monitor**:
   ```bash
   # Monitor while processing large files
   top -p $(pgrep -f uvicorn)
   ```

**Expected Results**:
- Single document processing: < 30 seconds
- Concurrent requests handled gracefully
- Memory usage remains stable
- No memory leaks during extended use

### Test 8: API Documentation
**Objective**: Verify API documentation is accessible and accurate.

**Steps**:
1. Access Swagger UI: `http://localhost:8000/docs`
2. Access ReDoc: `http://localhost:8000/redoc`
3. Test API endpoints directly from documentation interface

**Expected Results**:
- Documentation loads correctly
- All endpoints are documented
- Example requests and responses are provided
- Interactive testing works from documentation

## Acceptance Criteria Validation

### Stage 1 Requirements Checklist

#### ✅ Requirement 1: Document Upload and Processing
- [ ] Clean upload form with drag-and-drop capability
- [ ] Accepts TXT files (≤10MB) with encoding validation
- [ ] Accepts PDF files (≤10MB) with format validation
- [ ] Clear error messages for unsupported file types
- [ ] File size limit enforcement with guidance
- [ ] Upload progress and confirmation display
- [ ] Specific feedback for processing errors

#### ✅ Requirement 2: Text Extraction and Content Preparation
- [ ] Full text extraction from TXT files preserving structure
- [ ] PDF text extraction using pdfplumber with layout preservation
- [ ] Fallback error messages for extraction failures
- [ ] Content validation (minimum 50 characters)
- [ ] Graceful encoding issue handling with UTF-8 conversion
- [ ] Token counting and length validation for API limits

#### ✅ Requirement 3: AI-Powered Document Summarization
- [ ] OpenAI API integration for summarization
- [ ] GPT-4 model usage with appropriate prompt templates
- [ ] Clear error messages for API unavailability
- [ ] Exponential backoff retry strategy for rate limits
- [ ] Summary content validation (minimum 100 characters)
- [ ] Progress indicators during API processing
- [ ] User-friendly error messages for API failures

#### ✅ Requirement 4: Results Display and User Experience
- [ ] Clean, readable summary format display
- [ ] Filename, file size, and processing timestamp shown
- [ ] Download option for summary results
- [ ] Progress indicators for processing > 5 seconds
- [ ] 30-second processing target confirmation
- [ ] Clear navigation to upload another document
- [ ] Responsive interface performance maintenance

#### ✅ Requirement 5: Error Handling and System Reliability
- [ ] User-friendly error messages with specific guidance
- [ ] Retry options for file upload failures
- [ ] Distinction between temporary and configuration issues
- [ ] Clear configuration error messages for invalid API keys
- [ ] Detailed error logging for debugging without sensitive data exposure
- [ ] Alternative actions provided when processing fails

#### ✅ Requirement 6: Security and Data Protection
- [ ] File content validation against malicious patterns
- [ ] No persistent storage of document content beyond processing session
- [ ] Security warnings for suspicious file patterns
- [ ] Secure HTTPS connections for API calls
- [ ] Temporary file cleanup after session ends
- [ ] No logging of document content or personal information
- [ ] Secure application boundary operation

#### ✅ Requirement 7: Performance and Scalability Foundation
- [ ] Standard document processing within 30 seconds
- [ ] Responsive performance for up to 10 concurrent users
- [ ] Graceful handling of increased system load
- [ ] Successful Docker environment startup and health checks
- [ ] Efficient memory usage with prompt resource release
- [ ] Transparent feedback for processing time overruns

## Success Metrics

### Technical Metrics
- **Processing Time**: Average < 30 seconds for documents under 5 pages
- **Accuracy**: Text extraction accuracy > 95% for standard documents
- **Reliability**: System uptime > 99% during testing period
- **Memory Usage**: Stable memory consumption under 512MB during normal operation
- **Error Rate**: < 1% of valid requests result in system errors

### User Experience Metrics
- **Upload Success Rate**: > 95% for valid files under size limit
- **Error Message Clarity**: All error conditions provide actionable guidance
- **Interface Responsiveness**: UI remains interactive during processing
- **Documentation Completeness**: All API endpoints documented with examples

## Troubleshooting Guide

### Common Issues and Solutions

#### Application Won't Start
**Symptoms**: Server fails to start, import errors, or port conflicts

**Solutions**:
1. Check Python version: `python3 --version` (needs 3.12+)
2. Reinstall dependencies: `pip install -e .`
3. Try different port: `--port 8001`
4. Check for running processes: `lsof -i :8000`

#### OpenAI Integration Not Working
**Symptoms**: AI analysis fails, configuration errors, or API timeouts

**Solutions**:
1. Verify API key format in `.env`: `OPENAI_API_KEY=sk-...`
2. Check API key validity at OpenAI platform
3. Verify internet connectivity
4. Check OpenAI service status
5. Monitor API usage and billing limits

#### File Upload Failures
**Symptoms**: Upload errors, processing failures, or timeout issues

**Solutions**:
1. Verify file size under 10MB
2. Check file format (PDF or TXT only)
3. Test with simpler documents
4. Check available disk space in temp directory
5. Verify file permissions and encoding

#### Performance Issues
**Symptoms**: Slow processing, memory issues, or timeouts

**Solutions**:
1. Check system resources (CPU, memory)
2. Reduce document size or complexity
3. Monitor network connectivity to OpenAI
4. Restart application to clear memory
5. Check for background processes consuming resources

### Getting Help

If you encounter issues not covered in this guide:

1. **Check Application Logs**: Review terminal output for error details
2. **Verify Configuration**: Ensure all environment variables are set correctly
3. **Test with Minimal Setup**: Use provided sample documents
4. **Check API Documentation**: Visit `/docs` for endpoint details
5. **Validate Environment**: Run `./verify-stage.sh` for comprehensive checks

## Test Data

### Sample Documents
The demo script creates several test documents:

1. **Meeting Notes** (`test_documents/sample_text.txt`)
   - Content: Project planning meeting notes
   - Format: Plain text with structured sections
   - Size: ~2KB, moderate complexity

2. **Research Paper** (`test_documents/research_paper.txt`)
   - Content: Academic paper on AI and document processing
   - Format: Structured academic text with sections
   - Size: ~15KB, high complexity with technical content

### Creating Custom Test Documents

For additional testing, create documents with:

**Minimum Valid Content**:
```text
This is a test document with sufficient content for analysis. It contains enough text to meet the minimum character requirements and should be processed successfully by the system.
```

**Edge Case Testing**:
- Very short documents (just above 50 character minimum)
- Very long documents (approaching API token limits)
- Documents with special characters and formatting
- Mixed-language content (if applicable)
- Technical documents with code snippets or formulas

## Conclusion

This test environment guide provides comprehensive validation procedures for the Document Analysis AI Stage 1 implementation. Following these steps ensures that all requirements are met and the system is ready for production use.

For automated testing, use the provided scripts:
- `./verify-stage.sh` - Automated verification
- `./demo.sh` - Interactive demonstration

The implementation successfully delivers the core value proposition of automated document analysis while maintaining security, performance, and user experience standards.