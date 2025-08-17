---
description: Initialize or update Vybe project structure with intelligent analysis
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS
---

# /vybe:init - Smart Project Initialization

Create intelligent project foundation for new or existing projects with AI-generated documentation.

## Platform Compatibility

### Supported Platforms
- [OK] **Linux**: All distributions with bash 4.0+
- [OK] **macOS**: 10.15+ (Catalina and later)
- [OK] **WSL2**: Windows Subsystem for Linux 2
- [OK] **Git Bash**: Windows with Git Bash installed
- [OK] **Cloud IDEs**: GitHub Codespaces, Gitpod, Cloud9

### Not Supported
- [NO] **Windows CMD**: Native Windows Command Prompt
- [NO] **PowerShell**: Without WSL or Git Bash
- [NO] **Windows batch**: .bat/.cmd scripts

### Required Tools
```bash
# Check prerequisites
bash --version    # Bash 4.0 or higher
git --version     # Git 2.0 or higher
find --version    # GNU find or BSD find
grep --version    # GNU grep or BSD grep
```

### Platform-Specific Notes
- **macOS**: Uses BSD versions of find/grep (slightly different syntax)
- **WSL2**: Ensure line endings are LF, not CRLF
- **Git Bash**: Some commands may need adjustment for Windows paths

## Usage
```
/vybe:init [project-description] [--template=template-name]
```

## Parameters
- `project-description`: Optional description for new projects or documentation updates
- `--template=template-name`: Optional template to use as architectural DNA (NEW)

## Pre-Initialization Check

### Current State Analysis
- Vybe status: !`[ -d ".vybe" ] && echo "[OK] Vybe already initialized - will update" || echo "[NEW] Ready for new initialization"`
- Git repository: !`[ -d ".git" ] && echo "[OK] Git repository detected" || echo "[WARN] Not a git repository"`
- Project type: !`find . -maxdepth 2 \( -name "package.json" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml" -o -name "pom.xml" -o -name "Gemfile" \) 2>/dev/null | head -5`
- Existing README: !`ls README* 2>/dev/null || echo "No README found"`
- Code files: !`find . -path ./node_modules -prune -o -path ./.git -prune -o -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rs" \) -print 2>/dev/null | head -5`

### Existing Vybe Documents (if updating)
- Overview: !`[ -f ".vybe/project/overview.md" ] && echo "[OK] EXISTS - will preserve custom content" || echo "[NEW] Will create"`
- Architecture: !`[ -f ".vybe/project/architecture.md" ] && echo "[OK] EXISTS - will update tech stack" || echo "[NEW] Will create"`
- Conventions: !`[ -f ".vybe/project/conventions.md" ] && echo "[OK] EXISTS - will update patterns" || echo "[NEW] Will create"`
- Backlog: !`[ -f ".vybe/backlog.md" ] && echo "[OK] EXISTS - will preserve" || echo "[NEW] Will create"`

## Task 0: Parse Parameters & Template Validation

### Template Parameter Processing
```bash
echo "[INIT] PARAMETER PROCESSING"
echo "=========================="
echo ""

# Parse command line arguments
project_description=""
template_name=""

# Process arguments
for arg in "$@"; do
    case $arg in
        --template=*)
            template_name="${arg#*=}"
            shift
            ;;
        *)
            if [ -z "$project_description" ]; then
                project_description="$arg"
            fi
            shift
            ;;
    esac
done

echo "Project Description: ${project_description:-'Not provided'}"
echo "Template: ${template_name:-'None'}"
echo ""

# Validate template if specified
if [ -n "$template_name" ]; then
    echo "[TEMPLATE] Validating template: $template_name"
    
    # Check if template exists
    if [ ! -d ".vybe/templates/$template_name" ]; then
        echo "[ERROR] Template '$template_name' not found"
        echo "Available templates:"
        ls .vybe/templates/ 2>/dev/null || echo "  No templates found"
        echo ""
        echo "Import a template first:"
        echo "  /vybe:template import github.com/user/repo $template_name"
        echo "  /vybe:template generate $template_name"
        exit 1
    fi
    
    # Check if template is analyzed/generated
    if [ -f ".vybe/templates/$template_name/metadata.yml" ]; then
        analyzed=$(grep "^analyzed:" ".vybe/templates/$template_name/metadata.yml" | sed 's/^analyzed: *//' | tr -d '"')
        if [ "$analyzed" != "true" ]; then
            echo "[ERROR] Template '$template_name' not yet analyzed"
            echo "Generate template structures first:"
            echo "  /vybe:template generate $template_name"
            exit 1
        fi
        echo "[OK] Template validated and ready"
    else
        echo "[ERROR] Template '$template_name' corrupted (missing metadata)"
        exit 1
    fi
    
    echo ""
fi
```

## CRITICAL: Mandatory Context Loading

### Task 1: Load Existing Project Context (if available)
```bash
echo "[CONTEXT] LOADING PROJECT CONTEXT"
echo "=========================="
echo ""

# Check if project is already initialized
if [ -d ".vybe/project" ]; then
    echo "[FOUND] Existing Vybe project detected"
    echo ""
    
    # CRITICAL: Load ALL project documents - NEVER skip this step
    project_loaded=false
    
    echo "[LOADING] Loading existing project foundation documents..."
    
    # Load overview (business context, goals, constraints)
    if [ -f ".vybe/project/overview.md" ]; then
        echo "[OK] Loaded: overview.md (business goals, users, constraints)"
        # AI MUST read and understand project context
    else
        echo "[MISSING] overview.md - will be created"
    fi
    
    # Load architecture (technical decisions, patterns)
    if [ -f ".vybe/project/architecture.md" ]; then
        echo "[OK] Loaded: architecture.md (tech stack, patterns, decisions)"
        # AI MUST read and understand technical constraints
    else
        echo "[MISSING] architecture.md - will be created"
    fi
    
    # Load conventions (coding standards, practices)
    if [ -f ".vybe/project/conventions.md" ]; then
        echo "[OK] Loaded: conventions.md (standards, patterns, practices)"
        # AI MUST read and understand coding standards
    else
        echo "[MISSING] conventions.md - will be created"
    fi
    
    # Load any custom project documents
    for doc in .vybe/project/*.md; do
        if [ -f "$doc" ] && [[ ! "$doc" =~ (overview|architecture|conventions) ]]; then
            echo "[OK] Loaded: $(basename "$doc") (custom project context)"
        fi
    done
    
    project_loaded=true
    
    echo ""
    echo "[CONTEXT] Project context loaded - will enhance existing foundation"
    echo ""
else
    echo "[NEW] New Vybe project initialization"
    echo ""
fi
```

## Task 1: Analyze Project State

### Actions
1. **Detect project type** from configuration files
2. **Scan codebase** for languages, frameworks, patterns
3. **Analyze git history** for commit conventions and workflow
4. **Check existing documentation** for project information
5. **Identify test frameworks** and build tools

### For Existing Projects
```bash
# Detect primary language (cross-platform)
find . -type f \( -name "*.js" -o -name "*.py" -o -name "*.go" \) 2>/dev/null | head -10

# Analyze package managers
ls package*.json requirements.txt go.mod Cargo.toml pom.xml 2>/dev/null

# Check test structure (works on BSD and GNU find)
find . -type d \( -name "__tests__" -o -name "test" -o -name "tests" -o -name "spec" \) 2>/dev/null | head -5

# Extract git conventions
git log --oneline -20 2>/dev/null || echo "No git history"
git branch -a 2>/dev/null || echo "No git branches"

# Platform-safe grep (works on both BSD and GNU)
grep -E "test|spec" package.json 2>/dev/null || true
```

### For New Projects
- Parse project description for technology hints
- Suggest appropriate stack based on use case
- Set up standard directory structure

## Task 2: Create Directory Structure

### Commands (Cross-Platform)
```bash
# Create Vybe directories (POSIX-compliant)
mkdir -p .vybe/project
mkdir -p .vybe/features

# Create initial files if not exist (works on all platforms)
test -f ".vybe/backlog.md" || touch .vybe/backlog.md
test -f ".vybe/project/overview.md" || touch .vybe/project/overview.md
test -f ".vybe/project/architecture.md" || touch .vybe/project/architecture.md
test -f ".vybe/project/conventions.md" || touch .vybe/project/conventions.md

# Add to .gitignore if needed (cross-platform)
if [ -f .gitignore ]; then
    grep -q "^\.vybe/" .gitignore 2>/dev/null || echo ".vybe/" >> .gitignore
else
    echo ".vybe/" > .gitignore
fi

# Handle Windows line endings in WSL2/Git Bash
if [ -n "$WINDIR" ] || [ -n "$WSL_DISTRO_NAME" ]; then
    # Ensure LF line endings for generated files
    git config core.autocrlf false 2>/dev/null || true
fi
```

### Final Structure
```
.vybe/
|-- project/
|   |-- overview.md      # Business context and goals
|   |-- architecture.md  # Technical decisions
|   `-- conventions.md   # Development standards
|-- tech/               # Technology stack registry (NEW)
|   |-- languages.yml   # Primary language and package manager
|   |-- frameworks.yml  # Web/API/database frameworks
|   |-- testing.yml     # Testing frameworks and commands
|   |-- build.yml       # Build tools and development server
|   |-- tools.yml       # Development tools and utilities
|   |-- deployment.yml  # Deployment configuration
|   `-- stages.yml      # Progressive tool installation plan
|-- backlog.md          # Feature planning
`-- features/           # Feature specifications (empty initially)
```

## Task 2.5: Capture Incremental Outcome Stages

### Interactive Outcome Definition
```bash
echo "[OUTCOMES] INCREMENTAL STAGED OUTCOME CAPTURE"
echo "============================================="
echo ""
echo "Project Description: $project_description"
echo ""

echo "[PHILOSOPHY] Baby Steps to Success"
echo "=================================="
echo "Real software development is incremental, not big bang."
echo "Each outcome stage will deliver working units in 1-3 days."
echo ""

echo "[INTERACTIVE] Capturing Your Outcome Stages"
echo "==========================================="
echo ""
echo "AI MUST interactively capture three critical elements:"
echo ""
echo "1. FIRST MINIMAL OUTCOME (What can ship in 1-2 days?)"
echo "   Example: 'Show COVID numbers on a webpage'"
echo "   - Must be minimal but functional"
echo "   - Must deliver immediate user value"
echo "   - Must be completable quickly"
echo ""
echo "2. FINAL VISION (Where are we ultimately going?)"
echo "   Example: 'Real-time dashboard with multiple visualizations'"
echo "   - The complete dream state"
echo "   - Can be ambitious and complex"
echo "   - Will be reached incrementally"
echo ""
echo "3. INITIAL OUTCOME STAGES (Flexible roadmap)"
echo "   Example stages (each on its own line):"
echo "   - Stage 1: Show data (Day 1)"
echo "   - Stage 2: Add layout (Day 3)"
echo "   - Stage 3: Add charts (Day 5)"
echo "   - Stage 4: Make real-time (Day 8)"
echo ""
echo "AI MUST ask these questions interactively and capture responses."
echo "IMPORTANT: Format each stage on its own line with proper line breaks."
echo ""

echo "[OUTCOME PRINCIPLES]"
echo "==================="
echo "- Each stage builds on the previous"
echo "- Each stage delivers working units"
echo "- Each stage provides user value"
echo "- UI examples requested only when needed"
echo "- Learning from each stage informs the next"
echo ""
```

## Task 2.6: Performance-Optimized Intelligent Analysis

### Two-Phase Approach: Fast Setup + Deep Research
```bash
echo "[AI] PERFORMANCE-OPTIMIZED INTELLIGENT PROJECT SETUP"
echo "================================================"
echo ""

echo "[PHASE 1] IMMEDIATE OUTCOME-DRIVEN ANALYSIS (Fast - 30 seconds)"
echo "============================================================"
echo ""
echo "AI MUST perform immediate analysis based on captured outcomes:"
echo "- Extract project type from first minimal outcome"
echo "- Identify core technology needs for staged delivery"
echo "- Infer user types from outcome descriptions"
echo "- Determine architecture for incremental growth"
echo "- Apply patterns that support staged development"
echo ""
echo "This provides outcome-focused foundation documents immediately."
echo ""

echo "[PHASE 2] DEEP RESEARCH ENHANCEMENT (Background - 2-5 minutes)"
echo "============================================================="
echo ""
echo "AI WILL enhance foundation with outcome-specific research:"
echo ""
echo "2A. STAGED DELIVERY RESEARCH:"
echo "   - Best practices for incremental development"
echo "   - Technology choices that support evolution"
echo "   - Patterns for adding complexity gradually"
echo "   - Migration strategies between stages"
echo ""
echo "2B. OUTCOME VALIDATION RESEARCH:"
echo "   - Success metrics for each stage"
echo "   - Testing strategies for incremental features"
echo "   - User feedback collection methods"
echo "   - Performance benchmarks per stage"
echo ""
echo "2C. ARCHITECTURE EVOLUTION RESEARCH:"
echo "   - Patterns that grow with requirements"
echo "   - Refactoring strategies between stages"
echo "   - Technical debt management"
echo "   - Scalability preparation"
echo ""
echo "This research enhances documents with stage-specific insights."
echo ""

echo "[APPROACH] OUTCOME-DRIVEN INTELLIGENCE:"
echo "- Phase 1 creates outcome roadmap immediately"
echo "- Phase 2 enhances with stage-specific research"
echo "- Focus on shipping working units quickly"
echo "- Adapt based on learnings from each stage"
echo ""
```

## Task 3: Load Template Context (if template specified)

### Template-Based Foundation Loading
```bash
if [ -n "$template_name" ]; then
    echo "[TEMPLATE] LOADING TEMPLATE CONTEXT"
    echo "==================================="
    echo ""
    
    template_dir=".vybe/templates/$template_name"
    
    # Load template metadata for context
    if [ -f "$template_dir/metadata.yml" ]; then
        echo "[TEMPLATE] Loading template metadata and analysis..."
        # AI MUST read template metadata to understand:
        # - Detected technologies and frameworks
        # - Template type and complexity
        # - Architectural patterns
        # - Generated enforcement structures
    fi
    
    # Load template-generated Vybe documents as foundation
    if [ -d "$template_dir/generated" ]; then
        echo "[TEMPLATE] Loading template-generated Vybe documents..."
        # AI MUST read generated documents as starting point:
        # - overview.md template (business context from template)
        # - architecture.md template (tech stack from template)
        # - conventions.md template (coding standards from template)
    fi
    
    # Load template mapping for Vybe integration
    if [ -f "$template_dir/mapping.yml" ]; then
        echo "[TEMPLATE] Loading template-to-Vybe mapping..."
        # AI MUST understand how template concepts map to Vybe workflow
    fi
    
    echo "[OK] Template context loaded - will merge with project analysis"
    echo ""
else
    echo "[NO TEMPLATE] Proceeding with standard project analysis"
    echo ""
fi
```

## Task 3.5: Complete Technology Stack Capture and Planning

### Interactive Technology Stack Definition
```bash
echo "[TECH] COMPLETE TECHNOLOGY STACK CAPTURE"
echo "========================================"
echo ""
echo "Project Description: $project_description"
echo "Template: $([ "$template_exists" = true ] && echo "$template_name" || echo "None")"
echo ""

if [ "$template_exists" = true ]; then
    echo "[TEMPLATE] Using template-defined technology stack"
    echo "AI MUST:"
    echo "1. READ template source code to extract exact technologies used"
    echo "2. ANALYZE template dependencies and requirements"
    echo "3. CREATE complete tech stack registry from template"
    echo "4. MAP template tools to stage-by-stage installation plan"
    echo ""
else
    echo "[INTERACTIVE] Capturing complete technology roadmap"
    echo "AI MUST interactively determine:"
    echo ""
    echo "1. PRIMARY PROGRAMMING LANGUAGE:"
    echo "   - What language best fits the project requirements?"
    echo "   - Version requirements and constraints"
    echo "   - Package manager and tooling"
    echo ""
    echo "2. APPLICATION ARCHITECTURE:"
    echo "   - Web application? API? Desktop? Mobile? CLI?"
    echo "   - Frontend framework needs (if web app)"
    echo "   - Backend framework requirements (if needed)"
    echo "   - Database requirements and type"
    echo ""
    echo "3. DEVELOPMENT TOOLS:"
    echo "   - Build system and bundlers"
    echo "   - Development server setup"
    echo "   - Code quality tools (linting, formatting)"
    echo "   - IDE/editor configuration"
    echo ""
    echo "4. TESTING STRATEGY:"
    echo "   - Unit testing framework"
    echo "   - Integration testing approach"
    echo "   - End-to-end testing tools (if needed)"
    echo "   - Code coverage requirements"
    echo ""
    echo "5. DEPLOYMENT PIPELINE:"
    echo "   - Build process and artifacts"
    echo "   - Environment management"
    echo "   - Deployment targets and methods"
    echo "   - CI/CD pipeline requirements"
    echo ""
fi

echo "[AI ANALYSIS] AI MUST intelligently analyze and recommend:"
echo "========================================================"
echo ""
echo "1. PARSE PROJECT DESCRIPTION:"
echo "   - Extract explicitly mentioned technologies (python, fastapi, etc.)"
echo "   - Identify application type (task management, web app, API, etc.)"
echo "   - Understand requirements (quick development, production-ready, etc.)"
echo ""
echo "2. RESEARCH & RECOMMEND MISSING PIECES:"
echo "   - For task management app: Does it need a database? What type?"
echo "   - What testing approach works best for this stack?"
echo "   - What development tools enhance this workflow?"
echo "   - What deployment options fit the requirements?"
echo ""
echo "3. PRESENT COMPLETE TECHNOLOGY STACK RECOMMENDATION:"
echo "   - Show user what was specified vs what is recommended"
echo "   - Explain WHY each technology is recommended"
echo "   - Provide alternatives for user consideration"
echo "   - Ask for user approval or modification"
echo ""
echo "4. CREATE TECHNOLOGY REGISTRY:"
echo "   After user approval, create .vybe/tech/ structure with:"
echo "   - languages.yml - Primary language, version, package manager"
echo "   - frameworks.yml - Web/API/DB frameworks and versions"
echo "   - testing.yml - Test frameworks, commands, and requirements"
echo "   - build.yml - Build tools, scripts, and processes"
echo "   - tools.yml - Development tools and utilities"
echo "   - deployment.yml - Deployment configuration and targets"
echo "   - stages.yml - Stage-by-stage tool installation plan"
echo ""
echo "5. HANDLE USER FEEDBACK:"
echo "   - If user rejects recommendations: Ask for more specific requirements"
echo "   - If user wants changes: Guide them to re-run with more detail"
echo "   - If user approves: Proceed with technology registry creation"
echo ""
```

### Create Technology Registry Structure
```bash
echo "[SETUP] Creating technology registry structure..."
mkdir -p .vybe/tech

# Create technology registry files
echo "[CREATE] Creating complete technology stack registry..."

# IMPORTANT: AI must now create actual technology files based on the analysis
# This replaces the placeholder approach with real implementation

echo "[AI] NOW CREATING ACTUAL TECHNOLOGY REGISTRY FILES..."
echo "===================================================="
echo ""
echo "Based on project analysis: $project_description"
echo ""
echo "AI MUST NOW:"
echo "1. Parse the project description and extract technology requirements"
echo "2. Create specific .yml files with actual technology decisions"
echo "3. Base decisions on the technology analysis already performed"
echo "4. Include specific versions, commands, and configurations"
echo ""
echo "CREATING TECHNOLOGY REGISTRY WITH REAL DATA..."

# Critical: Stage-by-stage installation plan
cat > .vybe/tech/stages.yml << 'EOF'
# Stage-by-Stage Technology Preparation Plan
# AI MUST populate with progressive tool installation

stages:
  stage-1:
    name: "Basic Development Setup"
    description: "Core language and basic development tools"
    required_tools: []  # AI MUST fill
    install_commands: []  # AI MUST fill
    validation_commands: []  # AI MUST fill
    
  stage-2:
    name: "Framework and Testing Setup"
    description: "Web frameworks and testing infrastructure"
    required_tools: []  # AI MUST fill
    install_commands: []  # AI MUST fill
    validation_commands: []  # AI MUST fill
    
  stage-3:
    name: "Database and Integration"
    description: "Database setup and integration testing"
    required_tools: []  # AI MUST fill
    install_commands: []  # AI MUST fill
    validation_commands: []  # AI MUST fill
    
  stage-final:
    name: "Production Readiness"
    description: "Deployment tools and production validation"
    required_tools: []  # AI MUST fill
    install_commands: []  # AI MUST fill
    validation_commands: []  # AI MUST fill

# AI MUST customize stages based on project requirements
EOF

echo "[OK] Technology registry base structure created"
echo ""

# AI IMPLEMENTATION: Create actual technology registry files
echo "[AI] CREATING ACTUAL TECHNOLOGY REGISTRY FILES"
echo "=============================================="
echo ""
echo "Based on project analysis and user context:"
echo "Project: $project_description"
echo ""
echo "AI is now analyzing the project description and creating specific technology registry files..."
echo ""

# This is where AI will implement the actual technology analysis and file creation
# The AI should:
# 1. Parse the project description
# 2. Extract mentioned technologies
# 3. Research and recommend missing components
# 4. Create specific .yml files with actual technology decisions
# 5. Populate stages.yml with real installation commands

echo "[CRITICAL] AI MUST NOW IMPLEMENT:"
echo "================================"
echo ""
echo "1. ANALYZE PROJECT DESCRIPTION: '$project_description'"
echo "   - Extract explicit technologies (Python, FastAPI, etc.)"
echo "   - Identify project type (expense tracker, web app, etc.)"
echo "   - Determine complexity needs (quick development, production, etc.)"
echo ""
echo "2. CREATE COMPLETE TECHNOLOGY STACK FILES:"
echo "   - languages.yml: Primary language, version, package manager"
echo "   - frameworks.yml: Web/API/database frameworks and versions"
echo "   - testing.yml: Test frameworks, commands, validation"
echo "   - build.yml: Build tools, scripts, development server"
echo "   - tools.yml: Development tools, linters, formatters"
echo "   - deployment.yml: Deployment setup, environment configuration"
echo ""
echo "3. POPULATE STAGES.YML WITH REAL INSTALLATION PLAN:"
echo "   - Stage 1: Core language and basic tools"
echo "   - Stage 2: Web framework and testing setup"
echo "   - Stage 3: Database and integration tools"
echo "   - Stage Final: Production and deployment tools"
echo ""
echo "4. USE ACTUAL COMMANDS AND VERSIONS:"
echo "   - Specific installation commands (pip install, npm install, etc.)"
echo "   - Version requirements and constraints"
echo "   - Validation commands to check installation"
echo ""
echo "AI MUST CREATE THESE FILES NOW WITH REAL TECHNOLOGY DECISIONS!"
echo ""
```

## Task 4: Generate Intelligent Project Documentation (Phase 1 - Fast)

### Generate outcomes.md with Staged Roadmap
```bash
echo "[DOCS] PHASE 1 - GENERATING OUTCOME ROADMAP"
echo "==========================================="
echo ""
echo "[AI] IMMEDIATE OUTCOMES CREATION (30 seconds):"
echo "AI MUST create outcomes.md using captured staged outcomes:"
echo ""
echo "CRITICAL: Generate CLEAN MARKDOWN without any control characters or ANSI escape codes!"
echo "   - NO color codes, NO bold/italic terminal formatting"
echo "   - NO special characters like ^D, <F3>, ESC sequences"
echo "   - PURE markdown text only for compatibility with readers like glow"
echo ""
echo "1. OUTCOME ROADMAP GENERATION:"
echo "   - Document first minimal outcome clearly"
echo "   - Map path from minimal to final vision"
echo "   - Define success metrics for each stage"
echo "   - FORMAT: Each stage on its own line with proper newlines"
echo "   - Estimate realistic timelines (1-3 days per stage)"
echo ""
echo "2. STAGE DEFINITION:"
echo "   - Each stage with clear deliverable"
echo "   - Business value for each stage"
echo "   - Technical outcomes per stage"
echo "   - Dependencies between stages"
echo ""
echo "3. ADAPTIVE PLANNING:"
echo "   - Mark stages as flexible/adjustable"
echo "   - Note where UI examples will be needed"
echo "   - Include learning checkpoints"
echo "   - Plan for iteration based on feedback"
echo ""

# Copy template and let AI customize with captured outcomes
cp .claude/templates/outcomes.template.md .vybe/project/outcomes.md

echo "[OK] Outcome roadmap created - staged delivery plan ready"
echo ""
```

### Generate overview.md with Outcome Focus
```bash
echo "[DOCS] PHASE 1 - GENERATING OUTCOME-DRIVEN PROJECT OVERVIEW"
echo "=========================================================="
echo ""
echo "[AI] IMMEDIATE OVERVIEW CREATION (30 seconds):"
echo "AI MUST create overview.md aligned with staged outcomes:"
echo "CRITICAL: Generate CLEAN MARKDOWN - no control characters, ANSI codes, or terminal formatting!"
echo ""
echo "1. OUTCOME-ALIGNED PROJECT CONTEXT:"
echo "   - Business context supporting incremental delivery"
echo "   - Users who benefit from each stage"
echo "   - Success metrics tied to outcome stages"
echo "   - Scope that evolves with each stage"
echo ""
echo "2. INTELLIGENT TEMPLATE ADAPTATION:"
echo "   - Use comprehensive overview.md template from .claude/templates/"
echo "   - Align all sections with staged outcome approach"
echo "   - Focus on value delivery at each stage"
echo "   - Create foundation supporting incremental growth"
echo ""
echo "3. QUALITY FOUNDATION:"
echo "   - Clear connection to outcome roadmap"
echo "   - Incremental value proposition"
echo "   - Stage-based success criteria"
echo "   - Ready for enhancement with learnings"
echo ""

# Copy template and let AI customize with outcome focus
cp .claude/templates/overview.template.md .vybe/project/overview.md

echo "[OK] Outcome-driven overview created - aligned with staged delivery"
echo ""
```

### Generate architecture.md with Smart Inference
```bash
echo "[DOCS] PHASE 1 - GENERATING INTELLIGENT PROJECT ARCHITECTURE"
echo "=========================================================="
echo ""
echo "[AI] IMMEDIATE ARCHITECTURE CREATION (30 seconds):"
echo "AI MUST create intelligent architecture.md using project description analysis:"
echo "CRITICAL: Generate CLEAN MARKDOWN - no control characters, ANSI codes, or terminal formatting!"
echo ""
echo "1. SMART TECHNOLOGY INFERENCE:"
echo "   - Infer appropriate technology stack from project type and requirements"
echo "   - Select standard database solutions for identified data patterns"
echo "   - Choose common authentication approaches for application type"
echo "   - Apply proven patterns for the identified project domain"
echo ""
echo "2. ARCHITECTURE PATTERN SELECTION:"
echo "   - Apply standard architecture patterns for project type"
echo "   - Define system architecture based on inferred scalability needs"
echo "   - Establish data flow patterns appropriate for application category"
echo "   - Set integration patterns for typical external service needs"
echo ""
echo "3. INTELLIGENT TEMPLATE COMPLETION:"
echo "   - Use comprehensive architecture.md template from .claude/templates/"
echo "   - Fill in technology choices based on project type analysis"
echo "   - Customize patterns for inferred requirements"
echo "   - Create solid foundation ready for research enhancement"
echo ""

# Copy template and let AI customize immediately based on description analysis
cp .claude/templates/architecture.template.md .vybe/project/architecture.md

echo "[OK] Intelligent architecture created immediately - ready for research enhancement"
echo ""
```

### Generate conventions.md with Smart Standards
```bash
echo "[DOCS] PHASE 1 - GENERATING INTELLIGENT DEVELOPMENT CONVENTIONS"
echo "=============================================================="
echo ""
echo "[AI] IMMEDIATE CONVENTIONS CREATION (30 seconds):"
echo "AI MUST create intelligent conventions.md using project type analysis:"
echo "CRITICAL: Generate CLEAN MARKDOWN - no control characters, ANSI codes, or terminal formatting!"
echo ""
echo "1. SMART STANDARDS INFERENCE:"
echo "   - Apply standard development practices for inferred technology stack"
echo "   - Use common code style guides for identified project type"
echo "   - Set typical testing conventions for application category"
echo "   - Define standard project structure for architectural patterns"
echo ""
echo "2. INTELLIGENT BEST PRACTICES:"
echo "   - Apply common security practices for identified business domain"
echo "   - Use standard performance guidelines for application type"
echo "   - Include typical accessibility standards for target users"
echo "   - Set appropriate quality standards for project complexity"
echo ""
echo "3. SMART TEMPLATE ADAPTATION:"
echo "   - Use comprehensive conventions.md template from .claude/templates/"
echo "   - Adapt standards to inferred technology choices"
echo "   - Customize workflow for typical project team structure"
echo "   - Create solid foundation ready for research enhancement"
echo ""

# Copy template and let AI customize immediately based on project analysis
cp .claude/templates/conventions.template.md .vybe/project/conventions.md

echo "[OK] Intelligent conventions created immediately - ready for research enhancement"
echo ""
```

## Final Initialization Steps

### Complete Project Setup - Phase 1 Complete
```bash
echo "[INIT] PHASE 1 COMPLETE - OUTCOME-DRIVEN SETUP"
echo "=============================================="
echo ""
echo "[FAST] Outcome roadmap created in ~30 seconds:"
echo "   - First minimal outcome captured"
echo "   - Final vision documented"
echo "   - Initial stages defined (flexible)"
echo "   - Ready for immediate Stage 1 development"
echo ""
echo "[FILES] Generated outcome-focused documents:"
echo "   - .vybe/project/outcomes.md (staged delivery roadmap)"
echo "   - .vybe/project/overview.md (business context aligned with outcomes)"
echo "   - .vybe/project/architecture.md (technology supporting incremental growth)"
echo "   - .vybe/project/conventions.md (standards for staged development)"
echo ""
echo "[TECHNOLOGY] Complete technology stack registry created:"
echo "   - .vybe/tech/languages.yml (primary language and package manager)"
echo "   - .vybe/tech/frameworks.yml (web/API/database frameworks)"
echo "   - .vybe/tech/testing.yml (testing frameworks and commands)"
echo "   - .vybe/tech/build.yml (build tools and development server)"
echo "   - .vybe/tech/tools.yml (development tools and utilities)"
echo "   - .vybe/tech/deployment.yml (deployment configuration)"
echo "   - .vybe/tech/stages.yml (progressive tool installation plan)"
echo ""
echo "[INCREMENTAL] Baby steps approach enabled:"
echo "   - Stage 1 can ship in 1-2 days"
echo "   - Each stage delivers working units"
echo "   - Learning between stages improves next stage"
echo "   - UI examples requested only when needed"
echo ""
echo "[ENHANCEMENT] Phase 2 research in background:"
echo "   - Best practices for incremental delivery"
echo "   - Stage-specific technology patterns"
echo "   - Success metrics refinement"
echo "   - Architecture evolution strategies"
echo ""

# Template enforcement setup (if template specified)
if [ -n "$template_name" ]; then
    echo "[TEMPLATE] TEMPLATE DNA INTEGRATION"
    echo "=================================="
    echo ""
    
    # Copy template enforcement structures to active project
    template_dir=".vybe/templates/$template_name"
    
    if [ -d "$template_dir/generated" ]; then
        echo "[TEMPLATE] Activating template enforcement structures..."
        
        # Copy enforcement rules if they exist
        if [ -d ".vybe/enforcement" ]; then
            echo "   ✓ Template enforcement rules active"
        fi
        
        # Copy pattern templates if they exist  
        if [ -d ".vybe/patterns" ]; then
            echo "   ✓ Template code patterns active"
        fi
        
        # Copy validation rules if they exist
        if [ -d ".vybe/validation" ]; then
            echo "   ✓ Template validation rules active"
        fi
        
        echo ""
        echo "[TEMPLATE DNA] Template '$template_name' is now project DNA:"
        echo "   - All future commands will follow template patterns"
        echo "   - Code generation will use template structures"
        echo "   - Validation will check template compliance"
        echo "   - Template cannot be changed (permanent DNA)"
        
        # Mark template as active in project
        echo "template: $template_name" >> .vybe/project/.template
        echo "template_set: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> .vybe/project/.template
        echo "template_immutable: true" >> .vybe/project/.template
        
        echo ""
    fi
fi
echo "[NEXT] Ready for Stage 1 development:"
echo "   - /vybe:backlog init - Generate tasks grouped by outcomes"
echo "   - /vybe:plan stage-1 - Plan first minimal outcome"
echo "   - /vybe:execute - Start delivering Stage 1"
echo "   - /vybe:release - Mark stage complete, advance to next"
```

## Error Handling

### Common Issues
- **No project description provided**: Prompt for description or analyze existing files
- **Templates not found**: Check templates/ directory exists
- **Permission denied**: Check file system permissions
- **Existing .vybe conflicts**: Offer update or abort with clear options

### Recovery Actions
- **Rollback on failure**: Preserve any existing files
- **Clear error messages**: Provide specific solutions for each error type
- **Template fallback**: Use basic templates if comprehensive ones unavailable
- **Manual guidance**: Suggest manual steps when automated approach fails
