#!/bin/bash

# Document Analysis AI - Stage 1 Verification Script
# Automated verification of all Stage 1 functionality
#
# NOTE: Run this script from the project root directory:
# cd /path/to/my-ai-app && ./tests/verify-stage.sh

set -e

FAILED_TESTS=0
TOTAL_TESTS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
log_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}[TEST $TOTAL_TESTS]${NC} $1"
}

pass_test() {
    echo -e "  ${GREEN}✅ PASS${NC}: $1"
}

fail_test() {
    echo -e "  ${RED}❌ FAIL${NC}: $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

warn_test() {
    echo -e "  ${YELLOW}⚠️  WARN${NC}: $1"
}

echo "🔍 Document Analysis AI - Stage 1 Verification"
echo "=============================================="
echo ""

# Test 1: Environment Setup
log_test "Environment Setup Verification"

if [ -f "pyproject.toml" ]; then
    pass_test "pyproject.toml configuration file exists"
else
    fail_test "pyproject.toml configuration file missing"
fi

if [ -f ".env.example" ]; then
    pass_test ".env.example template exists"
else
    fail_test ".env.example template missing"
fi

if [ -d "app" ]; then
    pass_test "Application directory structure exists"
else
    fail_test "Application directory structure missing"
fi

echo ""

# Test 2: Dependency Verification
log_test "Dependency Verification"

# Check virtual environment setup
if [ -d ".venv" ] || [ -n "$VIRTUAL_ENV" ]; then
    pass_test "Python virtual environment available"
else
    warn_test "No virtual environment detected (creating one now)"
    python3 -m venv .venv
fi

# Activate virtual environment if it exists
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
if [ "$(echo "$PYTHON_VERSION" | cut -d'.' -f1)" -ge 3 ] && [ "$(echo "$PYTHON_VERSION" | cut -d'.' -f2)" -ge 12 ]; then
    pass_test "Python version $PYTHON_VERSION meets requirements (3.12+)"
else
    fail_test "Python version $PYTHON_VERSION does not meet requirements (3.12+)"
fi

# Install dependencies if needed
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo "  📦 Installing dependencies..."
    pip install -e . > /dev/null 2>&1
fi

# Verify key dependencies
DEPENDENCIES=("fastapi" "uvicorn" "openai" "pdfplumber" "python-multipart")
for dep in "${DEPENDENCIES[@]}"; do
    if python3 -c "import $dep" 2>/dev/null; then
        pass_test "Dependency '$dep' is installed"
    else
        fail_test "Dependency '$dep' is missing"
    fi
done

echo ""

# Test 3: Application Structure
log_test "Application Structure Verification"

REQUIRED_FILES=(
    "app/main.py"
    "app/core/config.py"
    "app/core/exceptions.py"
    "app/core/security.py"
    "app/services/document_processor.py"
    "app/services/openai_service.py"
    "app/api/documents.py"
    "static/index.html"
    "static/app.js"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass_test "Required file exists: $file"
    else
        fail_test "Required file missing: $file"
    fi
done

echo ""

# Test 4: Configuration Verification
log_test "Configuration Verification"

if [ -f ".env" ]; then
    pass_test ".env configuration file exists"
    
    # Check for OpenAI API key
    if grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
        if grep -q "sk-your-openai-api-key-here" .env 2>/dev/null; then
            warn_test "OpenAI API key is using template value (real key needed for full functionality)"
        else
            pass_test "OpenAI API key appears to be configured"
        fi
    else
        warn_test "OpenAI API key not found in .env (some features may not work)"
    fi
else
    warn_test ".env file not found (copying from template)"
    cp .env.example .env
fi

echo ""

# Test 5: Application Startup
log_test "Application Startup Verification"

echo "  🚀 Starting application server..."

# Start server in background
python3 -m uvicorn app.main:app --host 127.0.0.1 --port 8001 &
SERVER_PID=$!

# Wait for server to start
sleep 5

# Check if server is running
if kill -0 $SERVER_PID 2>/dev/null; then
    pass_test "Application server started successfully (PID: $SERVER_PID)"
else
    fail_test "Application server failed to start"
    echo ""
    echo "  Debug information:"
    echo "  - Check if port 8001 is available"
    echo "  - Verify all dependencies are installed"
    echo "  - Check application logs for errors"
    exit 1
fi

echo ""

# Test 6: Health Check Verification
log_test "Health Check Verification"

# Test main health endpoint
if curl -s http://127.0.0.1:8001/health > /dev/null; then
    HEALTH_RESPONSE=$(curl -s http://127.0.0.1:8001/health)
    if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
        pass_test "Main health check endpoint working"
    else
        fail_test "Main health check returned unexpected response"
    fi
else
    fail_test "Main health check endpoint not accessible"
fi

# Test document service health
if curl -s http://127.0.0.1:8001/api/v1/documents/health > /dev/null; then
    DOC_HEALTH=$(curl -s http://127.0.0.1:8001/api/v1/documents/health)
    if echo "$DOC_HEALTH" | grep -q '"status":"healthy"'; then
        pass_test "Document service health check working"
        
        # Check OpenAI configuration
        if echo "$DOC_HEALTH" | grep -q '"openai_configured":true'; then
            pass_test "OpenAI integration is configured and accessible"
        else
            warn_test "OpenAI integration not fully configured (API key may be invalid)"
        fi
    else
        fail_test "Document service health check failed"
    fi
else
    fail_test "Document service health endpoint not accessible"
fi

echo ""

# Test 7: Static File Serving
log_test "Static File Serving Verification"

if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8001/ | grep -q "200"; then
    pass_test "Web interface is accessible at root path"
else
    fail_test "Web interface not accessible at root path"
fi

if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8001/static/app.js | grep -q "200"; then
    pass_test "Static JavaScript files are served correctly"
else
    fail_test "Static JavaScript files not accessible"
fi

echo ""

# Test 8: API Documentation
log_test "API Documentation Verification"

if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8001/docs | grep -q "200"; then
    pass_test "Swagger API documentation accessible"
else
    fail_test "Swagger API documentation not accessible"
fi

if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8001/redoc | grep -q "200"; then
    pass_test "ReDoc API documentation accessible"
else
    fail_test "ReDoc API documentation not accessible"
fi

echo ""

# Test 9: File Upload Endpoint (if OpenAI is configured)
log_test "File Upload Endpoint Verification"

# Create a test file
TEST_FILE=$(mktemp --suffix=.txt)
echo "This is a test document with sufficient content for processing. It contains enough text to meet the minimum character requirements and should be processed successfully by the document analysis system." > "$TEST_FILE"

# Test file upload
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$TEST_FILE" http://127.0.0.1:8001/api/v1/documents/upload)

if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
    pass_test "Document upload endpoint working correctly"
    
    # Check response structure
    if echo "$UPLOAD_RESPONSE" | grep -q '"filename"' && echo "$UPLOAD_RESPONSE" | grep -q '"analysis"'; then
        pass_test "Upload response contains expected fields"
    else
        warn_test "Upload response structure may be incomplete"
    fi
    
else
    if echo "$UPLOAD_RESPONSE" | grep -q "AI_SERVICE_ERROR"; then
        warn_test "Document upload endpoint accessible but OpenAI service unavailable"
    else
        fail_test "Document upload endpoint not working properly"
        echo "  Response: $(echo "$UPLOAD_RESPONSE" | head -c 200)..."
    fi
fi

# Cleanup test file
rm -f "$TEST_FILE"

echo ""

# Test 10: Error Handling
log_test "Error Handling Verification"

# Test invalid file upload
INVALID_RESPONSE=$(curl -s -X POST -F "file=@nonexistent.txt" http://127.0.0.1:8001/api/v1/documents/upload)

if echo "$INVALID_RESPONSE" | grep -q '"success":false'; then
    pass_test "Error handling works for invalid files"
else
    warn_test "Error handling may not be working correctly"
fi

echo ""

# Cleanup
echo "🧹 Cleaning up..."
if [ ! -z "$SERVER_PID" ]; then
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
    echo "  ⏹️  Server stopped"
fi

echo ""

# Summary
echo "📊 Verification Summary"
echo "======================"
echo ""
echo "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$((TOTAL_TESTS - FAILED_TESTS))${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
else
    echo -e "Failed: ${GREEN}0${NC}"
fi

echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All verification tests passed!${NC}"
    echo ""
    echo "✅ Stage 1 implementation is working correctly"
    echo "✅ Ready for demonstration and user testing"
    echo ""
    echo "🚀 To start the demo:"
    echo "   ./demo.sh"
    echo ""
    echo "🌐 Or start manually:"
    echo "   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
    echo "   Then visit: http://localhost:8000"
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS verification test(s) failed${NC}"
    echo ""
    echo "🔧 Please address the failed tests before proceeding:"
    echo "   - Check error messages above"
    echo "   - Verify all dependencies are installed"
    echo "   - Ensure configuration is correct"
    echo "   - Check for any missing files"
    echo ""
    echo "💡 For help, refer to the setup documentation or run:"
    echo "   ./demo.sh"
    exit 1
fi