/**
 * Document Analysis AI - Frontend JavaScript
 * Handles file upload, progress tracking, and results display
 */

class DocumentAnalyzer {
    constructor() {
        this.apiBaseUrl = '/api/v1/documents';
        this.maxFileSize = 10 * 1024 * 1024; // 10MB
        this.allowedTypes = ['.pdf', '.txt'];
        this.currentResults = null;
        
        this.initializeEventListeners();
    }
    
    initializeEventListeners() {
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const newUploadBtn = document.getElementById('newUploadBtn');
        const downloadBtn = document.getElementById('downloadBtn');
        
        // Upload area click
        uploadArea.addEventListener('click', () => {
            fileInput.click();
        });
        
        // File input change
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFileUpload(e.target.files[0]);
            }
        });
        
        // Drag and drop
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });
        
        uploadArea.addEventListener('dragleave', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
        });
        
        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            
            if (e.dataTransfer.files.length > 0) {
                this.handleFileUpload(e.dataTransfer.files[0]);
            }
        });
        
        // New upload button
        newUploadBtn.addEventListener('click', () => {
            this.resetInterface();
        });
        
        // Download button
        downloadBtn.addEventListener('click', () => {
            this.downloadSummary();
        });
    }
    
    validateFile(file) {
        // Check file size
        if (file.size > this.maxFileSize) {
            throw new Error(`File size exceeds 10MB limit. Your file is ${(file.size / (1024*1024)).toFixed(1)}MB.`);
        }
        
        // Check file type
        const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
        if (!this.allowedTypes.includes(fileExtension)) {
            throw new Error(`Unsupported file type: ${fileExtension}. Please upload PDF or TXT files only.`);
        }
        
        // Check if file is empty
        if (file.size === 0) {
            throw new Error('File is empty. Please select a valid document.');
        }
        
        return true;
    }
    
    async handleFileUpload(file) {
        try {
            // Validate file
            this.validateFile(file);
            
            // Show progress
            this.showProgress();
            this.updateProgress(0, 'Validating file...');
            
            // Create form data
            const formData = new FormData();
            formData.append('file', file);
            
            // Upload and analyze
            this.updateProgress(25, 'Uploading file...');
            
            const response = await fetch(`${this.apiBaseUrl}/upload`, {
                method: 'POST',
                body: formData
            });
            
            this.updateProgress(75, 'Analyzing document...');
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || `Server error: ${response.status}`);
            }
            
            const result = await response.json();
            
            this.updateProgress(100, 'Analysis complete!');
            
            // Show results
            setTimeout(() => {
                this.displayResults(result);
            }, 500);
            
        } catch (error) {
            this.showError(error.message);
            this.hideProgress();
        }
    }
    
    showProgress() {
        document.getElementById('progressContainer').style.display = 'block';
        document.getElementById('uploadArea').style.opacity = '0.5';
    }
    
    hideProgress() {
        document.getElementById('progressContainer').style.display = 'none';
        document.getElementById('uploadArea').style.opacity = '1';
    }
    
    updateProgress(percentage, text) {
        document.getElementById('progressFill').style.width = percentage + '%';
        document.getElementById('progressText').textContent = text;
    }
    
    displayResults(result) {
        this.currentResults = result;
        
        // Hide upload area and progress
        document.querySelector('.upload-section').style.display = 'none';
        
        // Populate file information
        const fileInfo = document.getElementById('fileInfo');
        const metadata = result.metadata;
        const analysis = result.analysis;
        
        let fileInfoHTML = `
            <div class="file-info-row">
                <span><strong>📄 Filename:</strong></span>
                <span>${metadata.filename}</span>
            </div>
            <div class="file-info-row">
                <span><strong>📊 File Size:</strong></span>
                <span>${this.formatFileSize(metadata.file_size)}</span>
            </div>
            <div class="file-info-row">
                <span><strong>📝 Word Count:</strong></span>
                <span>${analysis.word_count.toLocaleString()} words</span>
            </div>
            <div class="file-info-row">
                <span><strong>⏱️ Processing Time:</strong></span>
                <span>${result.processing_time.toFixed(2)} seconds</span>
            </div>
        `;
        
        if (metadata.pages) {
            fileInfoHTML += `
                <div class="file-info-row">
                    <span><strong>📄 Pages:</strong></span>
                    <span>${metadata.pages}</span>
                </div>
            `;
        }
        
        if (metadata.encoding) {
            fileInfoHTML += `
                <div class="file-info-row">
                    <span><strong>🔤 Encoding:</strong></span>
                    <span>${metadata.encoding}</span>
                </div>
            `;
        }
        
        fileInfo.innerHTML = fileInfoHTML;
        
        // Update results title with confidence
        const resultsTitle = document.getElementById('resultsTitle');
        let titleHTML = 'Analysis Results';
        
        if (analysis.confidence_score) {
            const confidence = analysis.confidence_score;
            let confidenceClass = 'confidence-low';
            let confidenceText = 'Low Confidence';
            
            if (confidence >= 0.8) {
                confidenceClass = 'confidence-high';
                confidenceText = 'High Confidence';
            } else if (confidence >= 0.6) {
                confidenceClass = 'confidence-medium';
                confidenceText = 'Medium Confidence';
            }
            
            titleHTML += `<span class="confidence-badge ${confidenceClass}">${confidenceText}</span>`;
        }
        
        resultsTitle.innerHTML = titleHTML;
        
        // Display summary
        const summaryContent = document.getElementById('summaryContent');
        summaryContent.innerHTML = this.formatSummary(analysis.summary);
        
        // Show results section
        document.getElementById('resultsSection').style.display = 'block';
        
        // Scroll to results
        document.getElementById('resultsSection').scrollIntoView({ 
            behavior: 'smooth' 
        });
    }
    
    formatSummary(summary) {
        // Add basic formatting to the summary
        return summary
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') // Bold
            .replace(/\n\n/g, '</p><p>') // Paragraphs
            .replace(/^/, '<p>') // Start paragraph
            .replace(/$/, '</p>'); // End paragraph
    }
    
    formatFileSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }
    
    downloadSummary() {
        if (!this.currentResults) return;
        
        const result = this.currentResults;
        const content = `Document Analysis Summary
Generated: ${new Date(result.timestamp).toLocaleString()}

DOCUMENT INFORMATION
Filename: ${result.metadata.filename}
File Size: ${this.formatFileSize(result.metadata.file_size)}
Word Count: ${result.analysis.word_count.toLocaleString()} words
Processing Time: ${result.processing_time.toFixed(2)} seconds
${result.metadata.pages ? `Pages: ${result.metadata.pages}` : ''}
${result.metadata.encoding ? `Encoding: ${result.metadata.encoding}` : ''}

SUMMARY
${result.analysis.summary}

---
Generated by Document Analysis AI - Stage 1
`;
        
        const blob = new Blob([content], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `summary_${result.metadata.filename.replace(/\.[^/.]+$/, "")}.txt`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
    
    showError(message) {
        // Remove any existing error messages
        const existingError = document.querySelector('.error-message');
        if (existingError) {
            existingError.remove();
        }
        
        // Create error message
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.innerHTML = `
            <strong>❌ Error:</strong> ${message}
            <br><small>Please try again with a different file or check the requirements.</small>
        `;
        
        // Insert after upload section
        const uploadSection = document.querySelector('.upload-section');
        uploadSection.parentNode.insertBefore(errorDiv, uploadSection.nextSibling);
        
        // Auto-remove after 10 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.remove();
            }
        }, 10000);
    }
    
    resetInterface() {
        // Hide results
        document.getElementById('resultsSection').style.display = 'none';
        
        // Show upload section
        document.querySelector('.upload-section').style.display = 'block';
        
        // Reset file input
        document.getElementById('fileInput').value = '';
        
        // Remove error messages
        const errorMessages = document.querySelectorAll('.error-message');
        errorMessages.forEach(msg => msg.remove());
        
        // Reset results
        this.currentResults = null;
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new DocumentAnalyzer();
});