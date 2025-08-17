---
description: Import and analyze external templates with AI-driven architectural analysis
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, WebFetch
---

# /vybe:template - AI-Driven Template Analysis System

Import external templates and let AI intelligently analyze their architecture, patterns, and conventions to create comprehensive enforcement structures.

## Platform Compatibility

### Supported Platforms
- [OK] **Linux**: All distributions with bash 4.0+
- [OK] **macOS**: 10.15+ (Catalina and later)
- [OK] **WSL2**: Windows Subsystem for Linux 2
- [OK] **Git Bash**: Windows with Git Bash installed
- [OK] **Cloud IDEs**: GitHub Codespaces, Gitpod, Cloud9

### Required Tools
```bash
bash --version    # Bash 4.0 or higher
git --version     # Git 2.0 or higher (for GitHub imports)
find --version    # GNU find or BSD find
```

## Usage
```
/vybe:template [action] [params]
```

## Actions & Parameters

### import [source] [name]
Import template from external source
- `source`: GitHub URL or local path
- `name`: Template identifier (kebab-case)

### generate [name]
AI analyzes template and generates Vybe structures
- `name`: Previously imported template name

### list
Show all available templates

### validate [name]
Check template completeness
- `name`: Template to validate

## Pre-Command Analysis

### Current State Check
- Templates: !`[ -d ".vybe/templates" ] && ls .vybe/templates/ | wc -l | xargs echo "templates found:" || echo "No templates directory"`
- Project: !`[ -f ".vybe/project/overview.md" ] && echo "[OK] Vybe project" || echo "[INFO] Not a Vybe project"`

## Action: import [source] [name]

### Task 1: Import Validation & Setup
```bash
echo "[IMPORT] TEMPLATE IMPORT INITIATED"
echo "================================="
echo ""

# Validate parameters
if [ -z "$2" ] || [ -z "$3" ]; then
    echo "[ERROR] Usage: /vybe:template import [source] [name]"
    echo "Examples:"
    echo "  /vybe:template import github.com/user/repo template-name"
    echo "  /vybe:template import ./local-dir template-name"
    exit 1
fi

source_param="$2"
template_name="$3"

# Validate template name
if [[ ! "$template_name" =~ ^[a-zA-Z0-9-]+$ ]]; then
    echo "[ERROR] Template name must be alphanumeric with dashes only"
    exit 1
fi

# Check for existing template
if [ -d ".vybe/templates/$template_name" ]; then
    echo "[ERROR] Template '$template_name' already exists"
    exit 1
fi

echo "Importing: $source_param → $template_name"
echo ""
```

### Task 2: Smart Source Detection & Import
```bash
echo "[IMPORT] INTELLIGENT SOURCE PROCESSING"
echo "====================================="
echo ""

# Create template structure
mkdir -p ".vybe/templates/$template_name/source"
mkdir -p ".vybe/templates/$template_name/generated"

# Determine source type and handle appropriately
if [[ "$source_param" =~ ^github\.com/ ]] || [[ "$source_param" =~ ^https://github\.com/ ]]; then
    echo "[GITHUB] Processing GitHub repository"
    
    # Normalize GitHub URL
    if [[ "$source_param" =~ ^github\.com/ ]]; then
        repo_url="https://$source_param"
    else
        repo_url="$source_param"
    fi
    
    echo "Repository: $repo_url"
    
    # Clone repository
    git clone "$repo_url" ".vybe/templates/$template_name/source" --depth 1 --quiet
    
    if [ $? -eq 0 ]; then
        rm -rf ".vybe/templates/$template_name/source/.git"
        echo "[OK] GitHub repository cloned"
        source_type="github"
        actual_source="$repo_url"
    else
        echo "[ERROR] Failed to clone repository"
        rm -rf ".vybe/templates/$template_name"
        exit 1
    fi
    
elif [ -d "$source_param" ]; then
    echo "[LOCAL] Processing local directory"
    echo "Source: $source_param"
    
    # Copy local directory contents
    cp -r "$source_param"/* ".vybe/templates/$template_name/source/" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "[OK] Local directory copied"
        source_type="local"
        actual_source="$(cd "$source_param" && pwd)"
    else
        echo "[ERROR] Failed to copy local directory"
        rm -rf ".vybe/templates/$template_name"
        exit 1
    fi
    
else
    echo "[ERROR] Invalid source: $source_param"
    echo "Must be GitHub URL or existing local directory"
    rm -rf ".vybe/templates/$template_name"
    exit 1
fi

echo ""
```

### Task 3: Generate Basic Metadata
```bash
echo "[METADATA] CREATING IMPORT METADATA"
echo "==================================="
echo ""

# Create initial metadata (AI will enhance during generation)
cat > ".vybe/templates/$template_name/metadata.yml" << EOF
name: $template_name
source: $actual_source
source_type: $source_type
imported: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
status: imported

# Analysis status
analyzed: false
structures_generated: false

# Will be populated by AI during analysis
analysis: {}
EOF

echo "[OK] Template '$template_name' imported successfully"
echo ""
echo "Next step: /vybe:template generate $template_name"
echo ""
```

## Action: generate [name]

### Task 1: Generation Setup & Validation
```bash
echo "[GENERATE] AI TEMPLATE ANALYSIS & GENERATION"
echo "==========================================="
echo ""

# Validate template exists
if [ -z "$2" ]; then
    echo "[ERROR] Usage: /vybe:template generate [name]"
    exit 1
fi

template_name="$2"
template_dir=".vybe/templates/$template_name"

if [ ! -d "$template_dir/source" ]; then
    echo "[ERROR] Template '$template_name' not found or corrupted"
    exit 1
fi

echo "Template: $template_name"
echo "Source: $template_dir/source/"
echo ""
```

### Task 2: AI Comprehensive Template Analysis
```bash
echo "[AI] INTELLIGENT TEMPLATE ANALYSIS"
echo "=================================="
echo ""
echo "AI MUST perform deep analysis of the template:"
echo ""
echo "PHASE 1: DISCOVERY & UNDERSTANDING"
echo "- Read and analyze ALL files in template"
echo "- Understand project structure and organization"
echo "- Identify primary languages, frameworks, tools"
echo "- Detect architectural patterns and design decisions"
echo "- Analyze configuration files and dependencies"
echo ""
echo "PHASE 2: PATTERN EXTRACTION"
echo "- Extract reusable code patterns and templates"
echo "- Identify component/module organization strategies"
echo "- Understand API design and data flow patterns"
echo "- Detect testing, security, and deployment patterns"
echo "- Map template concepts to development workflows"
echo ""
echo "PHASE 3: CONVENTION IDENTIFICATION"
echo "- File naming and directory organization rules"
echo "- Code style and formatting conventions"
echo "- Import/dependency management patterns"
echo "- Documentation and commenting standards"
echo ""
echo "AI WILL analyze the actual template and generate results..."
echo ""

# AI performs comprehensive analysis here
# The AI reads all template files and understands the architecture
```

### Task 3: AI-Generated Template Mapping
```bash
echo "[MAPPING] AI TEMPLATE-TO-VYBE MAPPING"
echo "===================================="
echo ""
echo "AI MUST create intelligent mapping from template concepts to Vybe workflow"
echo "This mapping will be stored in: $template_dir/mapping.yml"
echo ""
echo "AI will analyze the template and create mappings for:"
echo "- How template modules/components become Vybe features"
echo "- How template work organization maps to Vybe tasks"
echo "- How template can be built in incremental stages"
echo "- What patterns should be enforced during development"
echo ""

# AI creates mapping.yml based on actual template analysis
# This file connects template architecture to Vybe workflow
```

### Task 4: AI-Generated Enforcement Structures
```bash
echo "[ENFORCEMENT] AI STRUCTURE GENERATION"
echo "===================================="
echo ""

# Create enforcement directories
mkdir -p .vybe/enforcement
mkdir -p .vybe/patterns  
mkdir -p .vybe/validation

echo "AI MUST generate enforcement structures based on template analysis:"
echo ""
echo "1. ENFORCEMENT RULES (.vybe/enforcement/)"
echo "   AI analyzes template and creates rules for:"
echo "   - Required directory structure"
echo "   - Component organization patterns"
echo "   - Service/module creation rules"
echo "   - File placement requirements"
echo ""
echo "2. CODE PATTERNS (.vybe/patterns/)"
echo "   AI extracts reusable patterns for:"
echo "   - Component/class templates"
echo "   - API endpoint patterns"
echo "   - Test structure templates"
echo "   - Configuration patterns"
echo ""
echo "3. VALIDATION RULES (.vybe/validation/)"
echo "   AI creates validation for:"
echo "   - Structure compliance checking"
echo "   - Naming convention validation"
echo "   - Import pattern verification"
echo "   - Quality standards enforcement"
echo ""
echo "AI WILL generate all structures based on actual template analysis..."
echo ""

# AI generates these based on template analysis
# No hardcoded rules - everything derived from template
```

### Task 5: AI-Generated Vybe Documents
```bash
echo "[DOCUMENTS] AI VYBE DOCUMENT GENERATION"
echo "======================================"
echo ""
echo "AI MUST generate Vybe-compatible documents from template analysis:"
echo ""
echo "Generated in: $template_dir/generated/"
echo ""
echo "1. OVERVIEW.MD TEMPLATE"
echo "   - Business context derived from template purpose"
echo "   - User scenarios based on template target use cases"
echo "   - Success metrics appropriate for template type"
echo ""
echo "2. ARCHITECTURE.MD TEMPLATE"
echo "   - Technology stack detected from template"
echo "   - System design patterns identified in template"
echo "   - Integration points found in template"
echo ""
echo "3. CONVENTIONS.MD TEMPLATE"
echo "   - Coding standards extracted from template code"
echo "   - File organization rules from template structure"
echo "   - Development practices inferred from template"
echo ""
echo "AI WILL generate these documents based on actual template analysis..."
echo ""

# AI generates Vybe documents based on template understanding
# Documents reflect actual template architecture and patterns
```

### Task 6: Update Metadata with AI Analysis
```bash
echo "[METADATA] UPDATING WITH AI ANALYSIS RESULTS"
echo "============================================"
echo ""

# Update metadata with AI analysis results
# AI will populate this with actual discovered information
echo "AI MUST update metadata.yml with analysis results:"
echo "- Detected languages and frameworks"
echo "- Identified template type and complexity"
echo "- Number of patterns extracted"
echo "- Generated structure summary"
echo ""

# The actual metadata update happens through AI analysis
# No hardcoded values - everything based on template discovery

echo "[OK] Template '$template_name' analysis complete"
echo ""
echo "Generated structures:"
echo "  ✓ Template analysis and mapping"
echo "  ✓ Enforcement rules for project structure"
echo "  ✓ Reusable code patterns"
echo "  ✓ Validation rules for compliance"
echo "  ✓ Vybe-compatible project documents"
echo ""
echo "Ready for use: /vybe:init \"Project\" --template=$template_name"
echo ""
```

## Action: list

### Task 1: Display Available Templates
```bash
echo "[LIST] AVAILABLE TEMPLATES"
echo "========================="
echo ""

if [ ! -d ".vybe/templates" ] || [ -z "$(ls -A .vybe/templates 2>/dev/null)" ]; then
    echo "No templates found."
    echo ""
    echo "Import a template:"
    echo "  /vybe:template import github.com/user/repo template-name"
    echo "  /vybe:template import ./local-directory template-name"
    exit 0
fi

# List templates with intelligent status detection
for template_dir in .vybe/templates/*/; do
    if [ -d "$template_dir" ]; then
        template_name=$(basename "$template_dir")
        metadata_file="$template_dir/metadata.yml"
        
        echo "📦 $template_name"
        
        if [ -f "$metadata_file" ]; then
            # Extract metadata intelligently
            source=$(grep "^source:" "$metadata_file" | sed 's/^source: *//' | tr -d '"' || echo "Unknown")
            imported=$(grep "^imported:" "$metadata_file" | sed 's/^imported: *//' || echo "Unknown")
            analyzed=$(grep "^analyzed:" "$metadata_file" | sed 's/^analyzed: *//' || echo "false")
            
            echo "   Source: $source"
            echo "   Imported: $imported"
            
            if [ "$analyzed" = "true" ]; then
                echo "   Status: ✅ Ready for use"
                
                # Show AI analysis results if available
                if grep -q "^analysis:" "$metadata_file"; then
                    echo "   AI Analysis: ✓ Complete"
                fi
            else
                echo "   Status: ⏳ Needs generation"
                echo "   Next: /vybe:template generate $template_name"
            fi
        else
            echo "   Status: ❌ Corrupted (missing metadata)"
        fi
        
        echo ""
    fi
done
```

## Action: validate [name]

### Task 1: Intelligent Template Validation
```bash
echo "[VALIDATE] TEMPLATE VALIDATION"
echo "============================="
echo ""

if [ -z "$2" ]; then
    echo "[ERROR] Usage: /vybe:template validate [name]"
    exit 1
fi

template_name="$2"
template_dir=".vybe/templates/$template_name"

echo "Validating: $template_name"
echo ""

# Comprehensive validation
valid=true

# Check template existence
if [ ! -d "$template_dir" ]; then
    echo "❌ Template not found"
    valid=false
else
    echo "✅ Template directory exists"
fi

# Check source
if [ ! -d "$template_dir/source" ]; then
    echo "❌ Source directory missing"
    valid=false
else
    source_files=$(find "$template_dir/source" -type f | wc -l)
    echo "✅ Source directory exists ($source_files files)"
fi

# Check metadata
if [ ! -f "$template_dir/metadata.yml" ]; then
    echo "❌ Metadata file missing"
    valid=false
else
    echo "✅ Metadata file exists"
    
    # Check if analyzed
    analyzed=$(grep "^analyzed:" "$template_dir/metadata.yml" | sed 's/^analyzed: *//')
    if [ "$analyzed" = "true" ]; then
        echo "✅ Template analyzed by AI"
        
        # Check generated structures
        if [ -d ".vybe/enforcement" ] && [ "$(ls -A .vybe/enforcement 2>/dev/null)" ]; then
            echo "✅ Enforcement structures generated"
        else
            echo "⚠️  Enforcement structures missing"
        fi
        
        if [ -d ".vybe/patterns" ] && [ "$(ls -A .vybe/patterns 2>/dev/null)" ]; then
            echo "✅ Pattern templates generated"
        else
            echo "⚠️  Pattern templates missing"
        fi
        
        if [ -d ".vybe/validation" ] && [ "$(ls -A .vybe/validation 2>/dev/null)" ]; then
            echo "✅ Validation rules generated"
        else
            echo "⚠️  Validation rules missing"
        fi
        
    else
        echo "⚠️  Template not yet analyzed"
        echo "   Next: /vybe:template generate $template_name"
    fi
fi

echo ""
if [ "$valid" = "true" ]; then
    echo "✅ Template validation passed"
else
    echo "❌ Template validation failed"
fi
echo ""
```

## AI Behavior Guidelines

### Core Principles
- **Zero Hardcoding**: All analysis based on actual template content
- **Intelligent Discovery**: AI reads and understands template architecture
- **Pattern Recognition**: Identify reusable patterns and structures
- **Vybe Integration**: Map template concepts to Vybe workflow naturally

### Analysis Approach
- **Comprehensive Reading**: Analyze all template files thoroughly
- **Architecture Understanding**: Grasp overall design and patterns
- **Convention Extraction**: Identify coding and organizational standards
- **Intelligent Mapping**: Connect template structure to Vybe features

### Generation Strategy
- **Template-Specific**: Create rules specific to analyzed template
- **Quality Focus**: Generate useful, actionable enforcement structures
- **Vybe Compatible**: Ensure all outputs work with Vybe commands
- **Future-Proof**: Create structures that support project evolution

The template system provides AI-driven architectural analysis that creates intelligent enforcement structures based on actual template architecture, not hardcoded assumptions.