#!/bin/bash

# Document Analysis AI - Stage 1 Demo Script
# Interactive demonstration of the working application
#
# NOTE: Run this script from the project root directory:
# cd /path/to/my-ai-app && ./demo/demo.sh

set -e

echo "🚀 Document Analysis AI - Stage 1 Demonstration"
echo "================================================="
echo ""

# Check if required tools are available
check_requirements() {
    echo "📋 Checking requirements..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3 is required but not installed"
        exit 1
    fi
    
    # Check uv (optional, will use pip as fallback)
    if command -v uv &> /dev/null; then
        PACKAGE_MANAGER="uv"
        echo "✅ Found uv package manager"
    else
        PACKAGE_MANAGER="pip"
        echo "✅ Using pip package manager (uv not found)"
    fi
    
    # Check curl for health checks
    if ! command -v curl &> /dev/null; then
        echo "❌ curl is required for health checks"
        exit 1
    fi
    
    echo "✅ All requirements satisfied"
    echo ""
}

# Setup virtual environment and install dependencies
setup_environment() {
    echo "🔧 Setting up environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        echo "📦 Creating virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    echo "🔌 Activating virtual environment..."
    source .venv/bin/activate
    
    # Install dependencies
    echo "📥 Installing dependencies..."
    if [ "$PACKAGE_MANAGER" = "uv" ]; then
        pip install uv
        uv pip install -e .
    else
        pip install -e .
    fi
    
    echo "✅ Environment setup complete"
    echo ""
}

# Check environment configuration
check_configuration() {
    echo "⚙️  Checking configuration..."
    
    # Check for .env file
    if [ ! -f ".env" ]; then
        echo "📝 Creating .env file from template..."
        cp .env.example .env
        echo ""
        echo "🔑 IMPORTANT: Please configure your OpenAI API key in .env file"
        echo "   Edit .env and set: OPENAI_API_KEY=sk-your-actual-key-here"
        echo ""
        read -p "Press Enter after you've configured your API key, or 'c' to continue with demo mode: " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Cc]$ ]]; then
            echo "⚠️  Continuing in demo mode (some features may not work without API key)"
        fi
    else
        echo "✅ Found .env configuration file"
        
        # Check if API key is configured
        if grep -q "sk-your-openai-api-key-here" .env 2>/dev/null; then
            echo "⚠️  OpenAI API key appears to be using default template value"
            echo "   For full functionality, please configure a real API key in .env"
        elif grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
            echo "✅ OpenAI API key appears to be configured"
        else
            echo "⚠️  OpenAI API key configuration not detected"
        fi
    fi
    echo ""
}

# Create sample test documents
create_test_documents() {
    echo "📄 Creating sample test documents..."
    
    mkdir -p demo/test_documents
    
    # Create sample text document
    cat > demo/test_documents/sample_text.txt << 'EOF'
# Project Planning Meeting Notes

## Meeting Details
Date: December 15, 2024
Attendees: Sarah Johnson (Project Manager), Mike Chen (Lead Developer), Lisa Rodriguez (Designer), Tom Wilson (QA Lead)

## Project Overview
We discussed the upcoming Document Analysis AI project, which aims to help knowledge workers process documents more efficiently using artificial intelligence. The system will allow users to upload documents and receive automated summaries.

## Key Decisions Made
1. **Technology Stack**: We decided to use FastAPI for the backend API, with Python as the primary programming language. The team agreed that this would provide the best balance of development speed and performance.

2. **AI Integration**: OpenAI's GPT-4 will be used for document summarization. This decision was made after evaluating several alternatives, considering both accuracy and cost factors.

3. **File Support**: Initially, the system will support PDF and plain text files. Additional formats like Word documents will be added in future phases.

4. **User Interface**: A simple web-based interface will be developed for the initial release. The design should be clean and intuitive, allowing users to drag and drop files for analysis.

## Timeline and Milestones
- **Phase 1** (Week 1-2): Basic infrastructure and file upload functionality
- **Phase 2** (Week 3-4): AI integration and text processing
- **Phase 3** (Week 5-6): User interface development and testing
- **Phase 4** (Week 7-8): Security enhancements and production deployment

## Risk Assessment
The main risks identified include:
- Potential delays in OpenAI API integration
- File processing challenges with various document formats
- User adoption and training requirements

## Action Items
1. Sarah to prepare detailed project requirements document by December 20
2. Mike to research and prototype the FastAPI backend architecture
3. Lisa to create UI mockups and user flow diagrams
4. Tom to define testing strategy and quality assurance processes

## Budget Considerations
Initial estimates suggest a total project cost of $75,000, including development time, API costs, and infrastructure. This will need approval from the finance team before proceeding.

## Next Steps
The next meeting is scheduled for December 22, 2024, where we will review progress on action items and finalize the project charter. All team members should come prepared with their respective deliverables.
EOF

    # Create sample PDF-like content (saved as text for demo)
    cat > demo/test_documents/research_paper.txt << 'EOF'
The Impact of Artificial Intelligence on Modern Document Processing

Abstract

This research paper examines the transformative effects of artificial intelligence technologies on document processing workflows in contemporary business environments. Through a comprehensive analysis of current AI applications, we investigate how machine learning algorithms, natural language processing, and automated text analysis are revolutionizing the way organizations handle, analyze, and extract insights from textual documents.

1. Introduction

The digital transformation of business processes has accelerated dramatically in recent years, with document processing representing one of the most significant areas of innovation. Traditional manual methods of document review, analysis, and summarization are increasingly being supplemented or replaced by sophisticated AI-driven solutions. This shift represents not merely a technological upgrade, but a fundamental reimagining of how knowledge work is performed in the modern economy.

2. Methodology

Our research employed a mixed-methods approach, combining quantitative analysis of processing efficiency metrics with qualitative assessments of user satisfaction and workflow integration. We studied 50 organizations across various industries, measuring key performance indicators before and after AI implementation. Data was collected over a 12-month period, allowing for comprehensive analysis of long-term impacts and adoption patterns.

3. Key Findings

3.1 Efficiency Improvements
Organizations implementing AI-powered document processing reported an average 78% reduction in manual processing time. The most significant improvements were observed in:
- Document summarization: 85% time reduction
- Information extraction: 72% time reduction
- Content categorization: 81% time reduction
- Quality control processes: 68% time reduction

3.2 Accuracy and Quality
Contrary to initial concerns about AI reliability, our study found that automated systems achieved higher accuracy rates than manual processing in most categories:
- Text extraction accuracy: 94.2% (vs. 89.7% manual)
- Categorization accuracy: 91.8% (vs. 87.3% manual)
- Consistency in output format: 98.1% (vs. 76.4% manual)

3.3 User Adoption and Satisfaction
Employee feedback revealed high satisfaction rates with AI integration:
- 89% reported increased job satisfaction
- 92% indicated willingness to recommend AI tools to colleagues
- 76% felt their work became more strategic and less repetitive

4. Industry-Specific Applications

4.1 Legal Sector
Law firms showed particular benefit from AI document analysis, with contract review processes showing 90% time reduction while maintaining higher accuracy in identifying key clauses and potential issues.

4.2 Healthcare
Medical institutions leveraged AI for processing patient records and research documentation, resulting in improved diagnosis support and more efficient clinical documentation workflows.

4.3 Financial Services
Banks and insurance companies utilized AI for regulatory compliance documentation, achieving 95% automation in routine compliance reporting tasks.

5. Challenges and Limitations

Despite significant benefits, several challenges were identified:
- Initial implementation costs averaging $125,000 per organization
- Training requirements for staff adaptation (average 40 hours per employee)
- Data privacy and security concerns, particularly in regulated industries
- Integration complexity with existing document management systems

6. Future Implications

The trajectory of AI development suggests even greater integration in document processing workflows. Emerging technologies such as multimodal AI, advanced reasoning capabilities, and improved language understanding promise to expand the scope of automated document analysis.

Organizations that proactively adopt these technologies are likely to maintain competitive advantages through improved efficiency, accuracy, and the ability to extract deeper insights from their document repositories.

7. Conclusion

This research demonstrates that artificial intelligence has already begun to fundamentally transform document processing workflows across industries. While challenges exist, the benefits significantly outweigh the costs for most organizations. The key to successful implementation lies in thoughtful integration, comprehensive staff training, and a phased approach that allows for gradual adoption and optimization.

The evidence strongly suggests that AI-powered document processing is not merely a technological trend but a permanent shift in how knowledge work is performed. Organizations that embrace this transformation thoughtfully and strategically will be best positioned to thrive in an increasingly information-intensive business environment.

References

[Note: In a real research paper, this would contain actual citations. For this demo document, we're using placeholder references.]

1. Smith, J. et al. (2024). "Automated Text Processing in Enterprise Environments." Journal of Business Technology, 45(3), 123-145.
2. Chen, L. & Rodriguez, M. (2024). "Machine Learning Applications in Document Management." International Conference on AI Applications, pp. 67-89.
3. Johnson, K. (2023). "The Future of Knowledge Work: AI Integration Strategies." Harvard Business Review, 98(4), 78-92.
EOF

    echo "✅ Created sample test documents:"
    echo "   - demo/test_documents/sample_text.txt (Meeting notes)"
    echo "   - demo/test_documents/research_paper.txt (Research paper)"
    echo ""
}

# Start the application
start_application() {
    echo "🚀 Starting Document Analysis AI application..."
    echo ""
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Start the server in background
    echo "🌐 Starting FastAPI server on http://localhost:8000..."
    python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
    SERVER_PID=$!
    
    # Wait for server to start
    echo "⏳ Waiting for server to start..."
    for i in {1..15}; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo "✅ Server is running!"
            break
        fi
        sleep 2
        echo "   Waiting... ($i/15)"
    done
    
    # Check if server started successfully
    if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "❌ Server failed to start. Check the logs above for errors."
        echo "💡 Common issues:"
        echo "   - Port 8000 might be in use"
        echo "   - Dependencies might not be installed correctly"
        echo "   - OpenAI API key might be invalid"
        exit 1
    fi
    
    echo ""
}

# Test API endpoints
test_api() {
    echo "🧪 Testing API endpoints..."
    
    echo "📍 Testing health check..."
    HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
    echo "   Response: $HEALTH_RESPONSE"
    
    if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed"
    fi
    
    echo ""
    echo "📍 Testing document service health..."
    DOC_HEALTH=$(curl -s http://localhost:8000/api/v1/documents/health)
    echo "   Response: $DOC_HEALTH"
    
    if echo "$DOC_HEALTH" | grep -q '"status":"healthy"'; then
        echo "✅ Document service health check passed"
        
        # Check OpenAI configuration
        if echo "$DOC_HEALTH" | grep -q '"openai_configured":true'; then
            echo "✅ OpenAI integration is configured and working"
        else
            echo "⚠️  OpenAI integration not fully configured (API key may be missing)"
        fi
    else
        echo "❌ Document service health check failed"
    fi
    echo ""
}

# Interactive demo
interactive_demo() {
    echo "🎮 Interactive Demo"
    echo "=================="
    echo ""
    echo "Your Document Analysis AI application is now running!"
    echo ""
    echo "🌐 Web Interface: http://localhost:8000"
    echo "📚 API Documentation: http://localhost:8000/docs"
    echo "📖 Alternative API Docs: http://localhost:8000/redoc"
    echo ""
    echo "🎯 Demo Instructions:"
    echo "1. Open http://localhost:8000 in your web browser"
    echo "2. Try uploading the sample documents we created:"
    echo "   - demo/test_documents/sample_text.txt"
    echo "   - demo/test_documents/research_paper.txt"
    echo "3. Watch as the AI analyzes your documents and provides summaries"
    echo ""
    echo "💡 You can also test via curl commands:"
    echo "   curl -X POST -F 'file=@demo/test_documents/sample_text.txt' http://localhost:8000/api/v1/documents/upload"
    echo ""
    
    # Offer curl demo
    echo "Would you like to see a quick curl demonstration? (y/n)"
    read -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "🔧 Curl Demo - Uploading sample document..."
        echo "Command: curl -X POST -F 'file=@demo/test_documents/sample_text.txt' http://localhost:8000/api/v1/documents/upload"
        echo ""
        
        if [ -f "demo/test_documents/sample_text.txt" ]; then
            echo "📤 Uploading sample_text.txt..."
            RESPONSE=$(curl -s -X POST -F "file=@demo/test_documents/sample_text.txt" http://localhost:8000/api/v1/documents/upload)
            
            if echo "$RESPONSE" | grep -q '"success":true'; then
                echo "✅ Upload successful!"
                echo ""
                echo "📊 Response summary:"
                echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'   Filename: {data.get(\"filename\", \"N/A\")}')
    print(f'   File Size: {data.get(\"metadata\", {}).get(\"file_size\", \"N/A\")} bytes')
    print(f'   Word Count: {data.get(\"analysis\", {}).get(\"word_count\", \"N/A\")}')
    print(f'   Processing Time: {data.get(\"processing_time\", \"N/A\"):.2f} seconds')
    print()
    print('   Summary Preview:')
    summary = data.get('analysis', {}).get('summary', 'No summary available')
    print(f'   {summary[:200]}...' if len(summary) > 200 else f'   {summary}')
except:
    print('   (Could not parse response)')
"
            else
                echo "❌ Upload failed. Response:"
                echo "$RESPONSE" | head -c 500
            fi
        else
            echo "❌ Sample file not found"
        fi
        echo ""
    fi
    
    echo ""
    echo "🎉 Demo is ready! The application will continue running until you stop it."
    echo ""
    echo "To stop the demo:"
    echo "   - Press Ctrl+C to stop this script"
    echo "   - The server will be automatically stopped"
    echo ""
    echo "📝 Demo Files Created:"
    echo "   - demo/test_documents/sample_text.txt"
    echo "   - demo/test_documents/research_paper.txt"
    echo ""
    echo "🔧 Useful Commands:"
    echo "   - View logs: Check the terminal output above"
    echo "   - Test health: curl http://localhost:8000/health"
    echo "   - API docs: http://localhost:8000/docs"
    echo ""
}

# Cleanup function
cleanup() {
    echo ""
    echo "🧹 Cleaning up..."
    if [ ! -z "$SERVER_PID" ]; then
        echo "⏹️  Stopping server (PID: $SERVER_PID)..."
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
    echo "✅ Demo stopped"
    exit 0
}

# Set up signal handling for cleanup
trap cleanup SIGINT SIGTERM

# Main execution flow
main() {
    check_requirements
    setup_environment
    check_configuration
    create_test_documents
    start_application
    test_api
    interactive_demo
    
    # Keep the script running
    echo "Press Ctrl+C to stop the demo..."
    wait
}

# Run the demo
main