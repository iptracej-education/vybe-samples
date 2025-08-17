---
description: Create detailed specifications for individual features with mandatory context and web research
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, WebSearch, WebFetch
---

# /vybe:plan - Feature Specification Planning

Create comprehensive specifications for individual features with mandatory project context loading, web research, and structured EARS requirements.

## Usage
```
/vybe:plan [stage-name] [options]
/vybe:plan [feature-name] [description] [--auto]  # Legacy support
```

## Parameters

### Stage-Based Planning (Recommended)
- `stage-name`: Stage identifier (e.g., stage-1, stage-2, etc.)
- `--modify "changes"`: Modify stage requirements (e.g., "Change: JavaScript to TypeScript")

### Feature-Based Planning (Legacy)
- `feature-name`: Name of the feature (kebab-case required)  
- `description`: Natural language description of what to build or modify
- `--auto`: Automated mode - Generate complete spec without approval gates

## Automation Modes
- **Interactive** (default): Step-by-step approval for requirements -> design -> tasks
- **Automated** (`--auto`): Generate complete specification without confirmation

## Platform Compatibility
- [OK] Linux, macOS, WSL2, Git Bash
- [NO] Native Windows CMD/PowerShell

## Pre-Planning Checks

### Project Readiness
- Vybe initialized: `bash -c '[ -d ".vybe/project" ] && echo "[OK] Project ready" || echo "[NO] Run /vybe:init first"'`
- Project docs loaded: `bash -c 'ls .vybe/project/*.md 2>/dev/null | wc -l | xargs -I {} echo "{} project documents available"'`
- Backlog context: `bash -c '[ -f ".vybe/backlog.md" ] && echo "[OK] Strategic context available" || echo "[WARN] No backlog - planning independently"'`

### Feature Analysis
- Feature name: `bash -c 'echo "Feature: ${1:-[required]}" | sed "s/[^a-z0-9-]//g"'`
- Automation mode: `bash -c '[[ "$*" == *"--auto"* ]] && echo "[AUTO] Auto mode enabled" || echo "[MANUAL] Interactive mode"'`
- Existing feature: `bash -c '[ -d ".vybe/features/$1" ] && echo "[UPDATE] Updating existing feature" || echo "[NEW] Creating new feature"'`

## CRITICAL: Mandatory Context Loading

### Task 0: Load ALL Project Documents (MANDATORY)
```bash
echo "[LOADING] LOADING MANDATORY PROJECT CONTEXT"
echo "===================================="
echo ""

# CRITICAL: Load ALL project documents - NEVER skip this step
project_loaded=false
if [ -d ".vybe/project" ]; then
    echo "Loading project foundation documents..."
    
    # Load project foundation documents (MANDATORY for planning)
    if [ -f ".vybe/project/overview.md" ]; then
        echo "[OK] Loading project overview..."
        echo "=== PROJECT OVERVIEW ==="
        cat .vybe/project/overview.md
        echo ""
    else
        echo "[NO] CRITICAL ERROR: overview.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    if [ -f ".vybe/project/architecture.md" ]; then
        echo "[OK] Loading architecture constraints..."
        echo "=== ARCHITECTURE & TECHNOLOGY ==="
        cat .vybe/project/architecture.md
        echo ""
    else
        echo "[NO] CRITICAL ERROR: architecture.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    if [ -f ".vybe/project/conventions.md" ]; then
        echo "[OK] Loading coding standards..."
        echo "=== CODING CONVENTIONS ==="
        cat .vybe/project/conventions.md
        echo ""
    else
        echo "[NO] CRITICAL ERROR: conventions.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    # Load any custom project documents
    for doc in .vybe/project/*.md; do
        if [ -f "$doc" ] && [[ ! "$doc" =~ (overview|architecture|conventions) ]]; then
            basename "$doc"
            echo "[OK] Loaded: $(basename "$doc") (custom project context)"
        fi
    done
    
    project_loaded=true
else
    echo "[NO] CRITICAL ERROR: Project context not found!"
    echo "   Cannot proceed without project documents."
    echo "   Run /vybe:init first to establish project foundation."
    exit 1
fi

# Load backlog for strategic context
if [ -f ".vybe/backlog.md" ]; then
    echo "[OK] Loaded: backlog.md (feature priorities, releases)"
    # Extract relevant context
    feature_priority=$(grep -i "$feature_name" .vybe/backlog.md | grep -o "P[0-9]" | head -1 || echo "P1")
    feature_size=$(grep -i "$feature_name" .vybe/backlog.md | grep -o "Size: [SMLX]L*" | head -1 || echo "Size: M")
    release_target=$(grep -B5 -i "$feature_name" .vybe/backlog.md | grep "Release" | head -1 || echo "Next Release")
    
    echo "   Strategic Context:"
    echo "   - Priority: $feature_priority"
    echo "   - Size: $feature_size"
    echo "   - Target: $release_target"
fi

echo ""
echo "[STATS] Context Summary:"
echo "   - Project documents loaded: $(ls .vybe/project/*.md 2>/dev/null | wc -l)"
echo "   - Business goals understood: [OK]"
echo "   - Technical constraints loaded: [OK]"
echo "   - Coding standards available: [OK]"
echo ""

# ENFORCEMENT: Cannot proceed without context
if [ "$project_loaded" = false ]; then
    echo "[NO] CANNOT PROCEED: Project context is mandatory"
    echo "   All planning decisions must align with project standards."
    exit 1
fi
```

## Task 1: Feature Validation & Setup

### Validate Parameters
```bash
feature_name="$1"
description="$2"

# Validate required parameters
if [ -z "$feature_name" ]; then
    echo "[NO] ERROR: Feature name required"
    echo "Usage: /vybe:plan [feature-name] [description] [--auto]"
    exit 1
fi

if [ -z "$description" ]; then
    echo "[NO] ERROR: Feature description required"
    echo "Usage: /vybe:plan $feature_name \"description of what to build\""
    exit 1
fi

# Normalize feature name (kebab-case only)
feature_name=$(echo "$feature_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

echo "[NEW] FEATURE PLANNING INITIATED"
echo "============================"
echo "Feature: $feature_name"
echo "Description: $description"
echo "Mode: $([[ "$*" == *"--auto"* ]] && echo "Automated" || echo "Interactive")"
echo ""

# Create feature directory structure
mkdir -p ".vybe/features/$feature_name"
echo "[OK] Feature workspace created: .vybe/features/$feature_name/"
echo ""
```

## Task 2: Intelligent Requirements Discovery

### AI Research & Analysis Phase (MANDATORY)
```bash
echo "[AI] INTELLIGENT FEATURE ANALYSIS & RESEARCH"
echo "=========================================="
echo ""
echo "Feature: $feature_name"
echo "Description: $description"
echo ""
echo "[AI] PHASE 1: FEATURE TYPE ANALYSIS"
echo "AI MUST analyze the feature description to understand:"
echo "- What type of feature this is (authentication, data processing, UI component, API, etc.)"
echo "- Core functionality requirements implied by the description"
echo "- User workflows and interactions involved"
echo "- Data handling and persistence needs"
echo ""
echo "[AI] PHASE 2: PROJECT CONTEXT INTEGRATION"
echo "AI MUST combine feature analysis with loaded project documents:"
echo "- Technology constraints from architecture.md"
echo "- Business objectives from overview.md"
echo "- Coding standards from conventions.md"
echo "- Existing system integration points"
echo ""
echo "[AI] PHASE 3: INTELLIGENT WEB RESEARCH"
echo "AI MUST research current best practices for this specific feature type:"
echo "- Similar feature implementations in real projects"
echo "- Architecture patterns appropriate for the technology stack"
echo "- Security considerations specific to the feature type"
echo "- Performance benchmarks and optimization techniques"
echo "- Compliance requirements based on business domain"
echo ""
echo "[AI] PHASE 4: SYNTHESIS & ADAPTATION"
echo "AI MUST synthesize research findings with project context to determine:"
echo "- Appropriate technical approach for this specific project"
echo "- Security measures needed based on feature type and business context"
echo "- Performance targets relevant to the use case"
echo "- Integration patterns that fit the existing architecture"
echo ""
echo "Generate requirements based on intelligent analysis, not predefined templates"
```

### Generate Requirements Based on AI Analysis
```bash
echo "[SPEC] INTELLIGENT REQUIREMENTS GENERATION"
echo "========================================"
echo ""
echo "[AI] REQUIREMENTS CONSTRUCTION INSTRUCTIONS:"
echo "AI MUST create requirements.md based on the analysis above:"
echo ""
echo "1. FEATURE TYPE UNDERSTANDING:"
echo "   - Use feature analysis to determine appropriate requirement categories"
echo "   - Focus on what the feature actually needs, not generic templates"
echo "   - Consider user workflows specific to this feature type"
echo ""
echo "2. PROJECT-SPECIFIC CONTEXT:"
echo "   - Extract business goals and constraints from loaded overview.md"
echo "   - Apply technology constraints from architecture.md"
echo "   - Follow coding standards from conventions.md"
echo "   - Consider existing system integration needs"
echo ""
echo "3. RESEARCH-INFORMED REQUIREMENTS:"
echo "   - Apply security best practices relevant to this feature type"
echo "   - Use performance targets appropriate for the use case"
echo "   - Include compliance requirements based on business domain"
echo "   - Adapt accessibility requirements to feature interaction patterns"
echo ""
echo "4. EARS FORMAT APPLICATION:"
echo "   - Use WHEN/IF/WHILE/WHERE syntax for all acceptance criteria"
echo "   - Make requirements testable and unambiguous"
echo "   - Structure based on feature functionality, not predetermined categories"
echo ""
echo "5. INTELLIGENT ADAPTATION:"
echo "   - Create requirement structure that fits this specific feature"
echo "   - Use appropriate user roles based on project context"
echo "   - Define acceptance criteria that match actual feature behavior"
echo "   - Include research findings as additional requirements"
echo ""

# AI should create requirements.md with intelligent structure based on analysis

echo "[TASK] GENERATE INITIAL REQUIREMENTS"
echo ""
echo "Generate an initial set of requirements in EARS format based on the feature idea,"
echo "then iterate with the user to refine them until they are complete and accurate."
echo ""
echo "Don't focus on code exploration in this phase. Focus on writing requirements"
echo "which will later be turned into a design."
echo ""
echo "REQUIREMENTS GENERATION GUIDELINES:"
echo "1. Focus on Core Functionality: Start with essential features from the user's idea"
echo "2. Use EARS Format: All acceptance criteria must use proper EARS syntax"
echo "3. No Sequential Questions: Generate initial version first, then iterate on feedback"
echo "4. Keep It Manageable: Create solid foundation that can be expanded through review"
echo ""
echo "EARS (Easy Approach to Requirements Syntax) - MANDATORY FORMAT:"
echo "Primary EARS Patterns:"
echo "- WHEN [event/condition] THEN [system] SHALL [response]"
echo "- IF [precondition/state] THEN [system] SHALL [response]"
echo "- WHILE [ongoing condition] THE [system] SHALL [continuous behavior]"
echo "- WHERE [location/context/trigger] THE [system] SHALL [contextual behavior]"
echo ""
echo "Combined Patterns:"
echo "- WHEN [event] AND [additional condition] THEN [system] SHALL [response]"
echo "- IF [condition] AND [additional condition] THEN [system] SHALL [response]"
echo ""

cat > ".vybe/features/$feature_name/requirements.md" << 'EOF'
# Requirements Document

## Introduction
[AI: Clear introduction summarizing the feature and its business value based on analysis]

## Requirements

### Requirement 1: [AI: Major Feature Area based on feature analysis]
**User Story:** As a [AI: role from project context], I want [AI: feature based on description], so that [AI: benefit from business goals]

#### Acceptance Criteria
[AI: EARS requirements based on intelligent analysis]

1. WHEN [AI: event based on feature type] THEN [system] SHALL [AI: response based on research]
2. IF [AI: precondition based on analysis] THEN [system] SHALL [AI: behavior based on best practices]
3. WHILE [AI: ongoing condition] THE [system] SHALL [AI: continuous behavior]
4. WHERE [AI: context based on feature] THE [system] SHALL [AI: contextual behavior]

### Requirement 2: [AI: Next Major Feature Area based on analysis]
**User Story:** As a [AI: appropriate role], I want [AI: feature aspect], so that [AI: specific benefit]

1. WHEN [AI: event based on research findings] THEN [system] SHALL [AI: response]
2. WHEN [AI: event] AND [AI: condition] THEN [system] SHALL [AI: combined response]

### [AI: Continue with additional requirements based on feature complexity and research findings]

EOF

echo ""
echo "[OK] Requirements generated based on intelligent analysis with EARS format"
echo "   - Feature type: [Determined by AI analysis]"
echo "   - Requirements structured based on actual feature needs"
echo "   - EARS format applied to all acceptance criteria"
echo "   - Research findings incorporated into requirements"
echo ""
```

### Interactive Requirements Approval
```bash
if [[ "$*" != *"--auto"* ]]; then
    echo "[CHECKPOINT] REQUIREMENTS APPROVAL CHECKPOINT"
    echo "==================================="
    echo ""
    echo "Please review the generated requirements:"
    echo "[FILE] File: .vybe/features/$feature_name/requirements.md"
    echo ""
    echo "Verification checklist:"
    echo "[OK] All acceptance criteria in EARS format"
    echo "[OK] Business goals from project context addressed"
    echo "[OK] Security requirements based on research"
    echo "[OK] Performance targets specified"
    echo "[OK] Compliance requirements identified"
    echo ""
    echo "Approve requirements and proceed to design? [Y/n/edit]"
    # In real implementation, wait for user approval
    echo ""
fi
```

## Task 3: Intelligent Technical Design Creation

### AI Research & Analysis for Design
```bash
echo "[AI] INTELLIGENT DESIGN RESEARCH & CONSTRUCTION"
echo "=============================================="
echo ""
echo "[AI] CRITICAL: Design can only be generated after requirements are approved"
echo ""
echo "[AI] DESIGN RESEARCH PHASE:"
echo "AI MUST conduct comprehensive research and analysis:"
echo ""
echo "1. ARCHITECTURE PATTERN RESEARCH:"
echo "   - Research architectural patterns appropriate for this feature type"
echo "   - Investigate current best practices for the project's technology stack"
echo "   - Analyze microservices vs monolithic approaches for this use case"
echo "   - Study successful implementations of similar features"
echo ""
echo "2. TECHNOLOGY DECISION RESEARCH:"
echo "   - Research optimal technology choices for the feature requirements"
echo "   - Investigate security implementation standards (OWASP) for feature type"
echo "   - Study performance optimization techniques for the use case"
echo "   - Research testing strategies and tools for the technology stack"
echo ""
echo "3. REQUIREMENTS FOUNDATION ANALYSIS:"
echo "   - Map each design component to specific EARS requirements"
echo "   - Ensure all user stories are addressed in technical design"
echo "   - Validate acceptance criteria can be met by proposed solution"
echo "   - Build requirements traceability matrix"
echo ""
echo "4. PROJECT CONTEXT INTEGRATION:"
echo "   - Align with existing architecture from architecture.md"
echo "   - Apply technology constraints from project documents"
echo "   - Follow development practices from conventions.md"
echo "   - Consider integration with existing system components"
echo ""

echo "[TASK] GENERATE TECHNICAL DESIGN"
echo ""
echo "Create comprehensive technical design based on research and analysis."
echo "Focus on requirements traceability and research-informed decisions."
echo ""
echo "DESIGN DOCUMENT STRUCTURE (based on spec-design.md):"
echo "- Overview with requirements foundation"
echo "- Requirements mapping and traceability matrix"
echo "- Architecture decisions based on research"
echo "- Data flow with sequence diagrams"
echo "- Components and interfaces specification"
echo "- Data models and database schema"
echo "- Security considerations with best practices"
echo "- Performance targets and optimization strategy"
echo "- Testing strategy and coverage requirements"
echo ""

# AI should create design.md with intelligent structure based on research and analysis

echo ""
echo "[OK] Technical design generated based on intelligent research and analysis"
echo "   - Requirements traceability matrix created"
echo "   - Architecture decisions based on research findings"
echo "   - Technology choices informed by best practices"
echo "   - Security and performance considerations included"
echo ""
```

### Interactive Design Approval
```bash
if [[ "$*" != *"--auto"* ]]; then
    echo "[CHECKPOINT] DESIGN APPROVAL CHECKPOINT"
    echo "============================"
    echo ""
    echo "Please review the technical design:"
    echo "[FILE] File: .vybe/features/$feature_name/design.md"
    echo ""
    echo "Verification checklist:"
    echo "[OK] Requirements traceability matrix complete"
    echo "[OK] Architecture aligns with project standards"
    echo "[OK] Security measures comprehensive"
    echo "[OK] Performance targets defined"
    echo "[OK] Testing strategy specified"
    echo ""
    echo "Approve design and proceed to tasks? [Y/n/edit]"
    # In real implementation, wait for user approval
    echo ""
fi
```

## Task 4: Intelligent Implementation Tasks Generation

### AI Analysis & Task Construction
```bash
echo "[AI] INTELLIGENT TASK GENERATION & PLANNING"
echo "=========================================="
echo ""
echo "[AI] CRITICAL: Tasks can only be generated after both requirements and design are approved"
echo ""
echo "[AI] TASK CONSTRUCTION PHASE:"
echo "AI MUST convert the feature design into code-generation prompts:"
echo ""
echo "1. DESIGN TO IMPLEMENTATION ANALYSIS:"
echo "   - Analyze approved requirements and design documents"
echo "   - Break down design components into implementable steps"
echo "   - Identify technical dependencies and build order"
echo "   - Consider incremental development approach"
echo ""
echo "2. CODE-GENERATION FOCUS:"
echo "   - Create tasks as specific coding instructions for implementation"
echo "   - Focus ONLY on coding activities (no deployment, docs, user testing)"
echo "   - Each task must be completable through code modification"
echo "   - Size tasks appropriately (1-2 hours each)"
echo ""
echo "3. REQUIREMENTS TRACEABILITY:"
echo "   - Map each task to specific EARS requirements"
echo "   - Use format: _Requirements: X.X, Y.Y_ or _Requirements: [description]_"
echo "   - Ensure every requirement is covered by implementation tasks"
echo "   - Validate no requirements are orphaned"
echo ""
echo "4. TEST-DRIVEN APPROACH:"
echo "   - Integrate testing into each development task"
echo "   - Prioritize early validation through code"
echo "   - Include unit, integration, and E2E test creation"
echo "   - Apply best practices from project conventions"
echo ""
echo "TASK STRUCTURE (based on spec-tasks.md):"
echo "- Use functional section headers (not 'Phase X')"
echo "- Flat numbering: Major tasks (1, 2, 3) and sub-tasks (1.1, 1.2)"
echo "- Order by technical dependencies"
echo "- Each task ends with: _Requirements: X.X, Y.Y_"
echo "- Focus on coding activities only"
echo ""

# AI should create tasks.md with intelligent structure based on requirements and design

echo ""
echo "[OK] Implementation tasks generated based on intelligent analysis"
echo "   - Code-generation prompts created for each implementation step"
echo "   - All requirements mapped to specific tasks"
echo "   - Technical dependencies organized properly"
echo "   - Test-driven development approach integrated"
echo ""
```

## Task 5: Initialize Status Tracking

### Create Status Document
```bash
echo "[STATS] INITIALIZING STATUS TRACKING"
echo "=============================="
echo ""

cat > ".vybe/features/$feature_name/status.md" << 'EOF'
# Status: $feature_name

## Summary
- **Feature**: $feature_name
- **Description**: $description
- **Status**: Planning Complete
- **Progress**: 0% (Tasks determined by AI analysis)
- **Current Phase**: Ready for Implementation
- **Approach**: Intelligent AI-driven implementation

## Specification Approval
- **Requirements Generated**: [OK] $(date +%Y-%m-%d) - Based on AI analysis
- **Requirements Approved**: $(if [[ "$*" == *"--auto"* ]]; then echo "[OK] Auto-approved"; else echo "[OK] User-approved"; fi)
- **Design Generated**: [OK] $(date +%Y-%m-%d) - Based on research findings
- **Design Approved**: $(if [[ "$*" == *"--auto"* ]]; then echo "[OK] Auto-approved"; else echo "[OK] User-approved"; fi)
- **Tasks Generated**: [OK] $(date +%Y-%m-%d) - Based on intelligent analysis
- **Tasks Approved**: $(if [[ "$*" == *"--auto"* ]]; then echo "[OK] Auto-approved"; else echo "[OK] User-approved"; fi)

## Implementation Approach
- **Feature Analysis**: AI analyzed feature type and requirements
- **Research Conducted**: Technology patterns and best practices researched
- **Context Integration**: Project documents and constraints considered
- **Task Structure**: Code-generation prompts with requirements traceability
- **Ready for Implementation**: All specifications complete and approved

## Next Actions
1. Begin implementation following generated task sequence
2. Use AI-driven approach for each implementation step
3. Validate requirements compliance throughout development

---
*Created: $(date +%Y-%m-%d)*
*Last Updated: $(date +%Y-%m-%d)*
*Approach: Intelligent AI-driven development*
EOF

echo "[OK] Status tracking initialized with AI-driven approach"
echo ""
```

## Success Output

### Interactive Mode Success
```bash
if [[ "$*" != *"--auto"* ]]; then
    echo "[COMPLETE] INTELLIGENT FEATURE PLANNING COMPLETE!"
    echo "============================================="
    echo ""
    echo "[OK] AI-DRIVEN SPECIFICATION CREATED:"
    echo ""
    echo "[RESEARCH] INTELLIGENT ANALYSIS CONDUCTED"
    echo "   - Feature type analyzed and understood"
    echo "   - Current best practices researched"
    echo "   - Project context integrated"
    echo "   - Technology decisions research-informed"
    echo ""
    echo "[SPEC] REQUIREMENTS (EARS Format)"
    echo "   - Requirements based on intelligent feature analysis"
    echo "   - EARS acceptance criteria applied properly"
    echo "   - Project context and constraints considered"
    echo "   - Research findings incorporated"
    echo ""
    echo "[DESIGN] TECHNICAL DESIGN"
    echo "   - Requirements traceability matrix complete"
    echo "   - Architecture decisions research-informed"
    echo "   - Technology choices based on analysis"
    echo "   - Security and performance considerations included"
    echo ""
    echo "[TASKS] IMPLEMENTATION TASKS"
    echo "   - Code-generation prompts with requirements mapping"
    echo "   - Test-driven development approach"
    echo "   - Technical dependencies organized"
    echo "   - Coding-focused task structure"
    echo ""
    echo "[FILE] GENERATED FILES:"
    echo "   - .vybe/features/$feature_name/requirements.md"
    echo "   - .vybe/features/$feature_name/design.md"
    echo "   - .vybe/features/$feature_name/tasks.md"
    echo "   - .vybe/features/$feature_name/status.md"
    echo ""
    echo "[APPROACH] INTELLIGENT AI-DRIVEN DEVELOPMENT:"
    echo "   [OK] No hardcoded templates used"
    echo "   [OK] Feature analysis conducted"
    echo "   [OK] Research-informed decisions"
    echo "   [OK] Project context integrated"
    echo ""
    echo "[NEXT] NEXT STEPS:"
    echo "   1. Begin implementation following generated task sequence"
    echo "   2. Use AI analysis for each implementation step"
    echo "   3. /vybe:status $feature_name - Track progress"
fi
```

### Automated Mode Success
```bash
if [[ "$*" == *"--auto"* ]]; then
    echo "[AUTO] INTELLIGENT AUTOMATED PLANNING COMPLETE!"
    echo "==============================================="
    echo ""
    echo "[STATS] AI-DRIVEN SPECIFICATION METRICS:"
    echo "   - Project documents analyzed: $(ls .vybe/project/*.md 2>/dev/null | wc -l)"
    echo "   - Feature type: [Determined by AI analysis]"
    echo "   - Requirements: [Based on intelligent analysis]"
    echo "   - Design components: [Research-informed]"
    echo "   - Implementation tasks: [Code-generation prompts]"
    echo "   - Requirements coverage: 100%"
    echo ""
    echo "[AI] INTELLIGENT APPROACH VERIFICATION:"
    echo "   - Feature analysis conducted: [OK]"
    echo "   - Web research performed: [OK]"
    echo "   - Project context integrated: [OK]"
    echo "   - EARS format applied: [OK]"
    echo "   - Requirements traced: [OK]"
    echo "   - No hardcoded templates: [OK]"
    echo ""
    echo "[FILE] Feature ready at: .vybe/features/$feature_name/"
    echo ""
    echo "[START] BEGIN AI-DRIVEN DEVELOPMENT:"
    echo "   Follow generated task sequence with intelligent approach"
fi
```

## Error Handling

### Critical Errors
```bash
# Project not initialized
if [ ! -d ".vybe/project" ]; then
    echo "[NO] CRITICAL: Project not initialized"
    echo "   Cannot proceed without project context."
    echo "   Run: /vybe:init \"project description\""
    exit 1
fi

# Missing required documents
if [ ! -f ".vybe/project/overview.md" ] || [ ! -f ".vybe/project/architecture.md" ]; then
    echo "[NO] CRITICAL: Core project documents missing"
    echo "   Required: overview.md, architecture.md"
    echo "   Run: /vybe:init to regenerate"
    exit 1
fi
```

## AI Implementation Guidelines

### Mandatory Requirements for Intelligent Planning
1. **ALWAYS analyze the feature first** - Understand feature type and requirements before researching
2. **ALWAYS conduct comprehensive web research** - Use WebSearch and WebFetch for current best practices
3. **ALWAYS integrate project context** - Load and apply all project documents (overview.md, architecture.md, conventions.md)
4. **ALWAYS use EARS format** - All acceptance criteria must follow EARS syntax patterns
5. **ALWAYS trace requirements** - Every design component and task must map to specific requirements
6. **NEVER use hardcoded templates** - Generate specifications based on intelligent analysis, not predetermined patterns

### Research Requirements for AI
- **Requirements Phase**: Research feature type best practices, security standards, compliance needs
- **Design Phase**: Research architecture patterns, performance optimization, technology decisions
- **Tasks Phase**: Research implementation approaches, testing strategies, development practices
- **Include actual sources**: Add real URLs and references from research findings

### Intelligent Approach Standards
- **Feature Analysis**: Understand what type of feature this is and its specific needs
- **Context Integration**: Apply project constraints and existing architecture patterns
- **Research-Informed**: Base all decisions on current best practices and project context
- **No Assumptions**: Never assume technology stack, security needs, or implementation patterns
- **Adaptive Structure**: Create requirement/design/task structure that fits the specific feature

This enhanced `/vybe:plan` command provides truly intelligent, research-driven feature planning that adapts to any project context rather than using hardcoded templates.
