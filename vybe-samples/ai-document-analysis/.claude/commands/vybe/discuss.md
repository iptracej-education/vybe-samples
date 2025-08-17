---
description: Natural language assistant with smart audit routing that translates requests into specific Vybe command sequences and automatically runs specialized analysis modes
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, WebSearch, WebFetch
---

# /vybe:discuss - Natural Language Assistant with Smart Audit Routing

Transform natural language requests into specific Vybe command sequences with intelligent routing to specialized audit analysis modes. Describe what you want to accomplish in plain English, and get both command sequences AND automated code-reality analysis.

## Usage
```bash
/vybe:discuss "[your request in natural language]"
```

## Core Capabilities

### 1. Command Translation
```bash
/vybe:discuss "We need to add mobile support to our web app"
/vybe:discuss "Switch from REST to GraphQL for better performance"  
/vybe:discuss "Add analytics dashboard and email notifications"
/vybe:discuss "We're behind schedule, need to redistribute work"
```

### 2. Code-Reality Analysis (🔥 POWERFUL)
```bash
# Project reshaping and scope analysis
/vybe:discuss "reshape this project to fit 2 weeks, prefer MVP, keep security, limit WIP to 2"
/vybe:discuss "analyze if we can ship this in 1 month with current team"
/vybe:discuss "what features can we cut to hit our deadline?"

# Documentation synchronization
/vybe:discuss "read discussion.md and add requirements to README.md, then adjust project scope"
/vybe:discuss "our README.md is outdated, sync it with actual implemented features"
/vybe:discuss "compare what we promise in docs vs what code actually does"

# Business outcome alignment
/vybe:discuss "find features not tied to business outcomes and suggest what to do"
/vybe:discuss "which implemented features don't match our original vision?"
/vybe:discuss "audit if our code supports the user stories in README.md"
```

### 3. Scope & Architecture Evolution
```bash
/vybe:discuss "analyze current code and suggest how to split into microservices"
/vybe:discuss "we added too many features, help us extract MVP"
/vybe:discuss "recommend what to refactor before adding [new feature]"
/vybe:discuss "evaluate if current architecture can handle 10x user growth"
```

### 4. Project Health Analysis
```bash
/vybe:discuss "find inconsistencies between backlog, README, and actual code"
/vybe:discuss "detect scope creep - what did we build beyond original plan?"
/vybe:discuss "which features have no tests and pose biggest risk?"
/vybe:discuss "analyze technical debt and suggest prioritization"
```

## How It Works

### Standard Command Translation
1. **Load complete project context** - Understanding current state
2. **Parse your natural language request** - What you want to accomplish
3. **Generate specific Vybe command sequence** - Step-by-step instructions
4. **Provide context and explanations** - Why each command is needed

### Code-Reality Analysis Process
1. **Multi-source analysis** - Read Vybe docs + actual source code + README/docs
2. **Gap detection** - Compare documented intentions vs implemented reality
3. **Business alignment check** - Verify features serve documented business outcomes
4. **Scope analysis** - Detect feature creep, missing features, orphaned code
5. **Actionable recommendations** - Specific fixes, updates, and scope adjustments

## Platform Compatibility
- [OK] Linux, macOS, WSL2, Git Bash
- [NO] Native Windows CMD/PowerShell

## Pre-Discussion Checks

### Project Status
- Vybe initialized: `bash -c '[ -d ".vybe/project" ] && echo "[OK] Project ready" || echo "[NO] Run /vybe:init first"'`
- Project context: `bash -c 'ls .vybe/project/*.md 2>/dev/null | wc -l | xargs -I {} echo "{} project documents available"'`
- Members configured: `bash -c '[ -f ".vybe/backlog.md" ] && grep -q "^## Members:" .vybe/backlog.md && echo "[OK] Members configured" || echo "[INFO] No members configured"'`

### Current State
- Features planned: `bash -c '[ -d ".vybe/features" ] && ls -d .vybe/features/*/ 2>/dev/null | wc -l | xargs -I {} echo "{} features planned" || echo "0 features planned"'`
- Backlog items: `bash -c '[ -f ".vybe/backlog.md" ] && grep -c "^- \[" .vybe/backlog.md || echo "0"'`

## CRITICAL: Complete Context Loading

### Task 0: Load ALL Project Context (MANDATORY)
```bash
echo "[CONTEXT] LOADING COMPLETE PROJECT CONTEXT"
echo "=============================="
echo ""

request="$*"
if [ -z "$request" ]; then
    echo "[NO] ERROR: Request required"
    echo "Usage: /vybe:discuss \"describe what you want to accomplish\""
    echo ""
    echo "Examples:"
    echo "  /vybe:discuss \"add mobile support\""
    echo "  /vybe:discuss \"switch to GraphQL\""
    echo "  /vybe:discuss \"need security audit\""
    exit 1
fi

echo "Request: $request"
echo ""

# CRITICAL: Load ALL project documents - NEVER skip this step
project_loaded=false
if [ -d ".vybe/project" ]; then
    echo "[CONTEXT] Loading project foundation..."
    
    # Load overview (business context, goals, constraints)
    if [ -f ".vybe/project/overview.md" ]; then
        echo "[OK] Loaded: overview.md (business goals, users, constraints)"
        # AI MUST read and understand project context
    else
        echo "[NO] CRITICAL ERROR: overview.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    # Load architecture (technical decisions, patterns)
    if [ -f ".vybe/project/architecture.md" ]; then
        echo "[OK] Loaded: architecture.md (tech stack, patterns, decisions)"
        # AI MUST read and understand technical constraints
    else
        echo "[NO] CRITICAL ERROR: architecture.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    # Load conventions (coding standards, practices)
    if [ -f ".vybe/project/conventions.md" ]; then
        echo "[OK] Loaded: conventions.md (standards, patterns, practices)"
        # AI MUST read and understand coding standards
    else
        echo "[NO] CRITICAL ERROR: conventions.md missing"
        echo "   Run /vybe:init to create missing project documents"
        exit 1
    fi
    
    # Load any custom project documents
    for doc in .vybe/project/*.md; do
        if [ -f "$doc" ] && [[ ! "$doc" =~ (overview|architecture|conventions) ]]; then
            echo "[OK] Loaded: $(basename "$doc") (custom project context)"
        fi
    done
    
    project_loaded=true
else
    echo "[NO] CRITICAL ERROR: Project context not found!"
    echo "   Cannot provide recommendations without project context."
    echo "   Run /vybe:init first to establish project foundation."
    exit 1
fi

# Load backlog and member information
members_configured=false
member_count=0
if [ -f ".vybe/backlog.md" ]; then
    echo "[CONTEXT] Loading backlog and member information..."
    
    # Check if members are configured
    if grep -q "^## Members:" .vybe/backlog.md; then
        members_configured=true
        member_count=$(grep "^## Members:" .vybe/backlog.md | grep -o "[0-9]*" | head -1)
        echo "[OK] Members configured: $member_count developer(s)"
        
        # Load member assignments
        echo "[OK] Member assignments loaded"
    else
        echo "[INFO] No members configured (solo developer mode)"
    fi
    
    # Count backlog items
    backlog_count=$(grep -c "^- \[" .vybe/backlog.md)
    completed_count=$(grep -c "^- \[x\]" .vybe/backlog.md)
    active_count=$((backlog_count - completed_count))
    
    echo "[OK] Backlog loaded: $backlog_count total features ($active_count active, $completed_count completed)"
else
    echo "[INFO] No backlog found - recommendations will include backlog creation"
fi

# Load feature specifications
feature_count=0
if [ -d ".vybe/features" ]; then
    feature_count=$(ls -d .vybe/features/*/ 2>/dev/null | wc -l)
    echo "[CONTEXT] Features with specifications: $feature_count"
    
    # Load feature statuses for context
    for feature_dir in .vybe/features/*/; do
        if [ -d "$feature_dir" ]; then
            feature_name=$(basename "$feature_dir")
            echo "[OK] Feature loaded: $feature_name"
        fi
    done
else
    echo "[INFO] No feature specifications found"
fi

echo ""
echo "[SUMMARY] PROJECT CONTEXT SUMMARY:"
echo "   - Project documents loaded: $(ls .vybe/project/*.md 2>/dev/null | wc -l)"
echo "   - Members configured: $([ "$members_configured" = true ] && echo "Yes ($member_count developers)" || echo "No")"
echo "   - Backlog items: $backlog_count"
echo "   - Planned features: $feature_count"
echo ""

# ENFORCEMENT: Cannot proceed without context
if [ "$project_loaded" = false ]; then
    echo "[NO] CANNOT PROCEED: Project context is mandatory"
    echo "   All recommendations must align with project goals and constraints."
    exit 1
fi
```

## Task 1: Multi-Source Context Analysis

### Load Complete Project Reality
```bash
echo "[REALITY] COMPREHENSIVE PROJECT ANALYSIS"
echo "======================================"
echo ""

# Load Vybe documentation context (existing)
# ... existing project context loading ...

# NEW: Load actual source code reality
echo "[SOURCE] Analyzing actual implemented features..."
echo ""

# Detect implemented features from source code
echo "[CODE] Scanning source code for implemented features:"
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" \) -not -path "./node_modules/*" -not -path "./.git/*" 2>/dev/null | head -20

# Load project documentation files
echo ""
echo "[DOCS] Loading project documentation:"
for doc in README.md CHANGELOG.md package.json requirements.txt docs/*.md; do
    if [ -f "$doc" ]; then
        echo "   Found: $doc"
    fi
done

echo ""
echo "[ANALYSIS] AI MUST perform multi-source comparison:"
echo "1. Compare Vybe outcomes.md vs actual source code features"
echo "2. Compare README.md promises vs implemented functionality" 
echo "3. Compare backlog.md planned features vs existing code"
echo "4. Identify gaps, inconsistencies, and scope drift"
echo "5. Detect features without business outcome alignment"
echo ""
```

## Task 2: Natural Language Request Analysis

### Parse and Categorize Request
```bash
echo "[ANALYSIS] REQUEST ANALYSIS"
echo "======================"
echo ""
echo "Analyzing request: \"$request\""
echo ""

# AI ANALYSIS PHASE
# The AI should categorize the request and understand the intent:
# 1. What type of request is this? (scope change, feature addition, technical decision, etc.)
# 2. What's the current project state relevant to this request?
# 3. What are the implications and dependencies?
# 4. What's the best sequence of Vybe commands to accomplish this?

# Request categorization
request_type=""
request_scope=""
request_urgency=""
request_complexity=""

# Analyze request type
if echo "$request" | grep -qi "add\|new\|create\|build"; then
    request_type="addition"
    echo "[TYPE] Request type: Feature/capability addition"
elif echo "$request" | grep -qi "change\|switch\|migrate\|replace\|update"; then
    request_type="modification"
    echo "[TYPE] Request type: Technical modification/migration"
elif echo "$request" | grep -qi "remove\|delete\|stop\|cancel"; then
    request_type="removal"
    echo "[TYPE] Request type: Feature/capability removal"
elif echo "$request" | grep -qi "members\|assign\|distribute\|workload\|schedule"; then
    request_type="management"
    echo "[TYPE] Request type: Members/project management"
elif echo "$request" | grep -qi "security\|audit\|review\|quality\|test"; then
    request_type="quality"
    echo "[TYPE] Request type: Quality assurance/security"
elif echo "$request" | grep -qi "help\|how\|what\|explain\|guide"; then
    request_type="guidance"
    echo "[TYPE] Request type: Guidance/explanation"
else
    request_type="general"
    echo "[TYPE] Request type: General project discussion"
fi

# Analyze scope
if echo "$request" | grep -qi "project\|architecture\|stack\|framework"; then
    request_scope="project"
    echo "[SCOPE] Scope: Project-level changes"
elif echo "$request" | grep -qi "feature\|functionality\|capability"; then
    request_scope="feature"
    echo "[SCOPE] Scope: Feature-level changes"
elif echo "$request" | grep -qi "task\|bug\|issue\|fix"; then
    request_scope="task"
    echo "[SCOPE] Scope: Task-level changes"
elif echo "$request" | grep -qi "members\|developer\|assignment"; then
    request_scope="members"
    echo "[SCOPE] Scope: Member coordination"
else
    request_scope="mixed"
    echo "[SCOPE] Scope: Multiple areas affected"
fi

# Analyze urgency
if echo "$request" | grep -qi "urgent\|asap\|immediately\|critical\|emergency"; then
    request_urgency="high"
    echo "[URGENCY] Urgency: High - immediate action needed"
elif echo "$request" | grep -qi "soon\|quickly\|fast\|behind.*schedule"; then
    request_urgency="medium"
    echo "[URGENCY] Urgency: Medium - timely action needed"
else
    request_urgency="normal"
    echo "[URGENCY] Urgency: Normal - standard planning process"
fi

echo ""
echo "[ANALYSIS] Request categorized as: $request_type ($request_scope scope, $request_urgency urgency)"
echo ""
```

## Task 2: Context-Aware Command Generation

### Generate Specific Command Sequence
```bash
echo "[COMMANDS] COMMAND SEQUENCE GENERATION"
echo "=================================="
echo ""
echo "Based on your request and current project state, here's what you should do:"
echo ""

# AI COMMAND GENERATION PHASE
# Based on the request analysis and project context, generate specific commands

case $request_type in
    "addition")
        echo "## Adding New Features/Capabilities"
        echo ""
        
        # Feature addition workflow
        if echo "$request" | grep -qi "mobile\|app\|ios\|android"; then
            echo "### Mobile Support Addition"
            echo ""
            echo "**1. Update Project Architecture**"
            echo "   Add mobile considerations to your technical stack:"
            echo "   \`# Edit .vybe/project/architecture.md to include mobile strategy\`"
            echo ""
            echo "**2. Plan Mobile Features**"
            echo "   \`/vybe:plan mobile-app \"Native mobile application with API integration\"\`"
            echo "   \`/vybe:plan mobile-api \"Mobile-optimized API endpoints\"\`"
            echo ""
            echo "**3. Update Backlog**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign mobile-app dev-1\`"
                echo "   \`/vybe:backlog assign mobile-api dev-2\`"
                if [ "$member_count" -lt 3 ]; then
                    echo "   *Consider: /vybe:backlog member-count 3 (add mobile specialist)*"
                fi
            else
                echo "   \`/vybe:backlog member-count 2  # Consider adding member structure\`"
                echo "   \`/vybe:backlog assign mobile-app dev-1\`"
            fi
            echo ""
            echo "**4. Start Implementation**"
            echo "   \`/vybe:execute mobile-api-task-1  # Start with API foundation\`"
            
        elif echo "$request" | grep -qi "analytics\|dashboard\|metrics"; then
            echo "### Analytics Dashboard Addition"
            echo ""
            echo "**1. Add to Backlog**"
            echo "   \`/vybe:backlog add analytics-dashboard\`"
            echo ""
            echo "**2. Plan the Feature**"
            echo "   \`/vybe:plan analytics-dashboard \"User behavior analytics with interactive charts\"\`"
            echo ""
            echo "**3. Assign and Execute**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign analytics-dashboard dev-2\`"
                echo "   \`/vybe:execute my-feature --role=dev-2\`"
            else
                echo "   \`/vybe:execute analytics-dashboard-task-1\`"
            fi
            
        elif echo "$request" | grep -qi "email\|notification\|alert"; then
            echo "### Email/Notification System Addition"
            echo ""
            echo "**1. Add to Backlog**"
            echo "   \`/vybe:backlog add email-notifications\`"
            echo ""
            echo "**2. Plan with Dependencies**"
            echo "   \`/vybe:plan email-notifications \"Transactional and marketing email system\"\`"
            echo "   *Note: This will include email templates, delivery service integration*"
            echo ""
            echo "**3. Assign Based on Skills**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign email-notifications dev-1  # Backend-focused\`"
            fi
            
        else
            echo "### General Feature Addition"
            echo ""
            echo "**1. Add to Backlog**"
            echo "   \`/vybe:backlog add [feature-name]\`"
            echo ""
            echo "**2. Plan the Feature**"
            echo "   \`/vybe:plan [feature-name] \"[description based on your request]\"\`"
            echo ""
            echo "**3. Assign and Execute**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign [feature-name] dev-N\`"
                echo "   \`/vybe:execute my-feature --role=dev-N\`"
            else
                echo "   \`/vybe:execute [feature-name]-task-1\`"
            fi
        fi
        ;;
        
    "modification")
        echo "## Technical Modifications/Migrations"
        echo ""
        
        if echo "$request" | grep -qi "graphql\|rest\|api"; then
            echo "### API Architecture Change (REST -> GraphQL)"
            echo ""
            echo "**1. Update Architecture Documentation**"
            echo "   \`# Edit .vybe/project/architecture.md\`"
            echo "   *Document the GraphQL decision and migration strategy*"
            echo ""
            echo "**2. Plan Migration Feature**"
            echo "   \`/vybe:plan api-migration \"Migrate REST endpoints to GraphQL schema\"\`"
            echo ""
            echo "**3. Check Impact on Existing Features**"
            echo "   \`/vybe:audit --scope=features\`"
            echo "   *This will identify which features use REST APIs*"
            echo ""
            echo "**4. Update Affected Features**"
            echo "   \`/vybe:plan user-auth \"update API calls to use GraphQL\"\`"
            echo "   \`/vybe:plan [other-features] \"migrate to GraphQL\"\`"
            echo ""
            echo "**5. Execute Migration**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign api-migration dev-1  # Backend specialist\`"
                echo "   \`/vybe:execute my-feature --role=dev-1\`"
            else
                echo "   \`/vybe:execute api-migration-task-1\`"
            fi
            
        elif echo "$request" | grep -qi "database\|db\|storage"; then
            echo "### Database Migration"
            echo ""
            echo "**1. Plan Database Changes**"
            echo "   \`/vybe:plan database-migration \"[specific database change]\"\`"
            echo ""
            echo "**2. Check Feature Dependencies**"
            echo "   \`/vybe:audit --scope=dependencies\`"
            echo ""
            echo "**3. Execute with Caution**"
            echo "   \`/vybe:execute database-migration-task-1\`"
            echo "   *Note: Consider backup and rollback strategies*"
            
        else
            echo "### General Technical Change"
            echo ""
            echo "**1. Update Architecture**"
            echo "   \`# Edit .vybe/project/architecture.md\`"
            echo "   *Document the technical decision and rationale*"
            echo ""
            echo "**2. Plan Implementation**"
            echo "   \`/vybe:plan [change-name] \"[description of change]\"\`"
            echo ""
            echo "**3. Check Impact**"
            echo "   \`/vybe:audit\`"
            echo ""
            echo "**4. Execute Changes**"
            echo "   \`/vybe:execute [change-name]-task-1\`"
        fi
        ;;
        
    "management")
        echo "## Member and Project Management"
        echo ""
        
        if echo "$request" | grep -qi "behind.*schedule\|redistribute\|workload\|balance"; then
            echo "### Workload Rebalancing"
            echo ""
            echo "**1. Check Current Status**"
            echo "   \`/vybe:status members\`"
            echo "   *Shows current assignments and progress*"
            echo ""
            echo "**2. Identify Bottlenecks**"
            echo "   \`/vybe:status\`"
            echo "   *Overall project health and blockers*"
            echo ""
            echo "**3. Redistribute Work**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign [overloaded-feature] dev-2\`"
                echo "   *Move features from busy developer to available one*"
            else
                echo "   \`/vybe:backlog member-count 2  # Add member structure first\`"
                echo "   \`/vybe:backlog assign [feature] dev-2\`"
            fi
            echo ""
            echo "**4. Check Dependencies**"
            echo "   \`/vybe:audit --scope=dependencies\`"
            echo "   *Ensure reassignments don't break dependencies*"
            
        elif echo "$request" | grep -qi "add.*developer\|more.*people\|member.*count"; then
            echo "### Member Expansion"
            echo ""
            echo "**1. Expand Member Structure**"
            if [ "$members_configured" = true ]; then
                new_size=$((member_count + 1))
                echo "   \`/vybe:backlog member-count $new_size\`"
            else
                echo "   \`/vybe:backlog member-count 2\`"
            fi
            echo ""
            echo "**2. Redistribute Features**"
            echo "   \`/vybe:backlog assign [feature] dev-$((member_count + 1))\`"
            echo ""
            echo "**3. New Developer Onboarding**"
            echo "   New developer can start with:"
            echo "   \`export VYBE_MEMBER=dev-$((member_count + 1))\`"
            echo "   \`/vybe:execute my-feature\`"
            
        else
            echo "### General Member Management"
            echo ""
            echo "**1. Check Member Status**"
            echo "   \`/vybe:status members\`"
            echo ""
            echo "**2. Review Assignments**"
            echo "   \`/vybe:backlog\`"
            echo ""
            echo "**3. Adjust as Needed**"
            echo "   \`/vybe:backlog assign [feature] [dev-N]\`"
        fi
        ;;
        
    "quality")
        echo "## Quality Assurance and Security"
        echo ""
        
        if echo "$request" | grep -qi "security\|audit\|vulnerability"; then
            echo "### Security Audit and Hardening"
            echo ""
            echo "**1. Run Security Audit**"
            echo "   \`/vybe:audit --scope=security\`"
            echo "   *Identifies security gaps in existing features*"
            echo ""
            echo "**2. Add Security Features**"
            echo "   \`/vybe:backlog add security-hardening\`"
            echo "   \`/vybe:plan security-hardening \"Security headers, input validation, auth improvements\"\`"
            echo ""
            echo "**3. Update Existing Features**"
            echo "   \`/vybe:plan user-auth \"add 2FA and security improvements\"\`"
            echo "   \`/vybe:plan [data-features] \"add encryption and data protection\"\`"
            echo ""
            echo "**4. Execute Security Work**"
            if [ "$members_configured" = true ]; then
                echo "   \`/vybe:backlog assign security-hardening dev-1\`"
                echo "   \`/vybe:execute my-feature --role=dev-1\`"
            else
                echo "   \`/vybe:execute security-hardening-task-1\`"
            fi
            
        elif echo "$request" | grep -qi "test\|quality\|coverage"; then
            echo "### Testing and Quality Improvements"
            echo ""
            echo "**1. Quality Audit**"
            echo "   \`/vybe:audit\`"
            echo "   *Comprehensive project health check*"
            echo ""
            echo "**2. Add Testing Infrastructure**"
            echo "   \`/vybe:plan testing-infrastructure \"Comprehensive test suite with coverage targets\"\`"
            echo ""
            echo "**3. Execute Quality Improvements**"
            echo "   \`/vybe:execute testing-infrastructure-task-1\`"
            
        else
            echo "### General Quality Improvements"
            echo ""
            echo "**1. Run Comprehensive Audit**"
            echo "   \`/vybe:audit\`"
            echo ""
            echo "**2. Address Identified Issues**"
            echo "   \`/vybe:audit --fix\`"
            echo ""
            echo "**3. Add Quality Features as Needed**"
            echo "   Based on audit results, plan specific improvements"
        fi
        ;;
        
    "guidance")
        echo "## Guidance and Explanation"
        echo ""
        echo "For guidance on using Vybe commands:"
        echo ""
        echo "**Basic Workflow:**"
        echo "1. \`/vybe:init \"[project description]\"\` - Initialize project"
        echo "2. \`/vybe:backlog\` - Manage features and members"
        echo "3. \`/vybe:plan [feature]\` - Plan specific features"  
        echo "4. \`/vybe:execute [task]\` - Implement features"
        echo "5. \`/vybe:status\` - Track progress"
        echo "6. \`/vybe:audit\` - Maintain quality"
        echo ""
        echo "**Member Workflow:**"
        echo "1. \`/vybe:backlog member-count 2\` - Set up members"
        echo "2. \`/vybe:backlog assign [feature] dev-1\` - Assign work"
        echo "3. \`/vybe:execute my-feature --role=dev-1\` - Execute assigned work"
        echo ""
        echo "**Need specific help?** Ask more detailed questions!"
        ;;
        
    *)
        echo "## General Project Discussion"
        echo ""
        echo "Based on your request, consider these commands:"
        echo ""
        echo "**To understand current state:**"
        echo "- \`/vybe:status\` - Overall project progress"
        echo "- \`/vybe:backlog\` - Feature priorities and assignments"
        echo "- \`/vybe:audit\` - Project health check"
        echo ""
        echo "**To make changes:**"
        echo "- \`/vybe:plan [feature]\` - Plan new features"
        echo "- \`/vybe:execute [task]\` - Implement changes"
        echo "- \`/vybe:discuss \"[more specific request]\"\` - Get targeted guidance"
        ;;
esac

echo ""
echo "---"
echo ""
```

## Task 3: Smart Audit Routing

### Intelligent Analysis Mode Detection
```bash
echo "[ROUTING] INTELLIGENT AUDIT ROUTING" 
echo "==================================="
echo ""

# Detect if this is an analysis request that should use audit commands
analysis_requested=false
audit_commands=()

if echo "$request" | grep -qi "analyze\|compare\|audit\|inconsisten\|gap\|sync\|reshape\|fit\|scope\|mvp\|drift\|business.value\|documentation"; then
    analysis_requested=true
    echo "[DETECTED] Analysis request - routing to specialized audit commands"
    echo ""
    
    # Route to specific audit modes based on request content
    echo "[ROUTING] Determining required audit modes..."
    
    # MVP/Timeline analysis
    if echo "$request" | grep -qi "mvp\|minimal\|2.week\|month\|deadline\|timeline\|fit.*week\|fit.*day\|reshape.*week"; then
        echo "  → MVP extraction analysis needed"
        if echo "$request" | grep -qi "2.week\|14.day"; then
            audit_commands+=("/vybe:audit mvp-extraction --timeline=14days")
        elif echo "$request" | grep -qi "1.month\|30.day"; then
            audit_commands+=("/vybe:audit mvp-extraction --timeline=30days")
        else
            audit_commands+=("/vybe:audit mvp-extraction")
        fi
    fi
    
    # Scope drift analysis  
    if echo "$request" | grep -qi "scope\|drift\|creep\|original\|vision\|grew\|larger\|smaller\|feature.*add"; then
        echo "  → Scope drift analysis needed"
        audit_commands+=("/vybe:audit scope-drift")
    fi
    
    # Business value analysis
    if echo "$request" | grep -qi "business\|value\|outcome\|align\|justif\|purpose\|why.*feature\|orphan"; then
        echo "  → Business value analysis needed"
        audit_commands+=("/vybe:audit business-value")
    fi
    
    # Documentation sync analysis
    if echo "$request" | grep -qi "documentation\|readme\|sync\|outdated\|accurate\|match.*doc\|doc.*match"; then
        echo "  → Documentation sync analysis needed"
        audit_commands+=("/vybe:audit documentation")
    fi
    
    # General code-reality analysis (fallback for complex requests)
    if echo "$request" | grep -qi "inconsisten\|gap\|compare.*code\|reality\|implement.*vs.*doc\|code.*vs.*doc"; then
        echo "  → General code-reality analysis needed"
        audit_commands+=("/vybe:audit code-reality")
    fi
    
    # If no specific routing matched but analysis was requested, default to code-reality
    if [ ${#audit_commands[@]} -eq 0 ]; then
        echo "  → General analysis - defaulting to code-reality audit"
        audit_commands+=("/vybe:audit code-reality")
    fi
    
    echo ""
    echo "[COMMANDS] Will execute the following audit commands:"
    for cmd in "${audit_commands[@]}"; do
        echo "  $cmd"
    done
    echo ""
    
    echo "[AI] EXECUTE AUDIT COMMANDS NOW:"
    echo "==============================="
    echo "AI MUST run the audit commands listed above and provide their results."
    echo "Then provide follow-up recommendations and next steps."
    echo ""
    
else
    echo "[SKIP] Standard command translation (not analysis request)"
fi
```

## Task 4: Contextual Recommendations and Next Steps

### Provide Additional Context and Warnings
```bash
echo "[RECOMMENDATIONS] ADDITIONAL CONSIDERATIONS"
echo "======================================"
echo ""

# Provide context-aware recommendations based on project state
echo "**Context-Aware Recommendations:**"
echo ""

# Member-specific recommendations
if [ "$members_configured" = true ]; then
    if [ "$member_count" -eq 1 ] && [ "$request_scope" = "project" ]; then
        echo "[WARN]  **Member Consideration**: Project-level changes with solo developer"
        echo "   Consider: \`/vybe:backlog member-count 2\` for better work distribution"
        echo ""
    elif [ "$member_count" -gt 3 ] && echo "$request" | grep -qi "add.*feature"; then
        echo "[INFO] **Member Consideration**: Large member count - ensure feature assignment doesn't overload"
        echo "   Check: \`/vybe:status members\` before assigning new features"
        echo ""
    fi
else
    if [ "$request_scope" = "members" ] || echo "$request" | grep -qi "assign\|distribute"; then
        echo "[INFO]  **Member Setup Required**: No members configured yet"
        echo "   First: \`/vybe:backlog member-count 2\` to enable member features"
        echo ""
    fi
fi

# Project maturity recommendations
if [ "$feature_count" -eq 0 ] && [ "$request_type" = "modification" ]; then
    echo "[WARN]  **Project Maturity**: No features planned yet"
    echo "   Consider: Plan core features first with \`/vybe:plan [core-feature]\`"
    echo ""
elif [ "$backlog_count" -gt 10 ] && [ "$request_type" = "addition" ]; then
    echo "[INFO] **Backlog Size**: Large backlog ($backlog_count features)"
    echo "   Consider: \`/vybe:backlog groom\` to prioritize before adding more"
    echo ""
fi

# Urgency-based recommendations
if [ "$request_urgency" = "high" ]; then
    echo "[URGENT] **Urgency Notice**: High priority request detected"
    echo "   Consider: Check dependencies with \`/vybe:audit --scope=dependencies\`"
    echo "   Ensure: Critical path doesn't break existing work"
    echo ""
fi

# Technical complexity warnings
if echo "$request" | grep -qi "migrate\|switch\|replace\|change.*stack"; then
    echo "[WARN]  **Technical Risk**: Major architectural change detected"
    echo "   Recommended: \`/vybe:audit\` before making changes"
    echo "   Consider: Backup current state and plan rollback strategy"
    echo ""
fi

echo ""
echo "[NEXT STEPS] IMMEDIATE ACTIONS"
echo "========================="
echo ""

# Generate immediate next steps based on analysis
case $request_urgency in
    "high")
        echo "**Immediate Action Required:**"
        echo "1. Run the first command from the sequence above"
        echo "2. Check for blockers: \`/vybe:audit --scope=dependencies\`"
        echo "3. Execute with priority"
        ;;
    "medium")
        echo "**Timely Action Recommended:**"
        echo "1. Review current progress: \`/vybe:status\`"
        echo "2. Plan the changes using the commands above"
        echo "3. Coordinate with members if needed"
        ;;
    *)
        echo "**Standard Planning Process:**"
        echo "1. Use the command sequence provided above"
        echo "2. Review impact with \`/vybe:audit\` if making major changes"
        echo "3. Proceed with implementation when ready"
        ;;
esac

echo ""
echo "**Questions?** Ask follow-up questions with /vybe:discuss for more specific guidance!"
echo ""
```

## Success Output

### Natural Language Assistant Complete
```bash
echo ""
echo "[COMPLETE] DISCUSSION COMPLETE"
echo "======================="
echo ""
echo "[OK] **Request Analysis Complete**"
echo "   - Type: $request_type"
echo "   - Scope: $request_scope" 
echo "   - Urgency: $request_urgency"
echo ""
echo "[OK] **Command Sequence Generated**"
echo "   - Specific Vybe commands provided"
echo "   - Context-aware recommendations"
echo "   - Next steps identified"
echo ""
echo "[TARGET] **Ready to Execute**"
echo "   Start with the first command from the sequence above"
echo "   Use /vybe:discuss for follow-up questions"
echo ""
echo "[INFO] **Pro Tip**: Copy and paste the commands above, then modify as needed for your specific situation"
```

## Advanced Examples: Code-Reality Analysis

### 1. Project Scope Adjustment with Smart Routing
```bash
/vybe:discuss "reshape this project to fit 2 weeks, prefer MVP, keep security, limit WIP to 2"

# Smart Routing Output:
[DETECTED] Analysis request - routing to specialized audit commands
[ROUTING] Determining required audit modes...
  → MVP extraction analysis needed
  → Scope drift analysis needed

[COMMANDS] Will execute the following audit commands:
  /vybe:audit mvp-extraction --timeline=14days
  /vybe:audit scope-drift

[AI] EXECUTE AUDIT COMMANDS NOW:
# AI then runs the specific audit commands and provides structured results
# Based on YOUR actual project analysis, not hardcoded examples

[FOLLOW-UP] Recommended next steps:
1. Review audit results above
2. /vybe:backlog groom --mvp-focus  
3. Update outcomes.md with revised stages
4. /vybe:status outcomes - track progress
```

### 2. Documentation Synchronization with Smart Routing
```bash
/vybe:discuss "our README.md is outdated, sync it with actual implemented features"

# Smart Routing Output:
[DETECTED] Analysis request - routing to specialized audit commands
[ROUTING] Determining required audit modes...
  → Documentation sync analysis needed
  → General code-reality analysis needed

[COMMANDS] Will execute the following audit commands:
  /vybe:audit documentation
  /vybe:audit code-reality

[AI] EXECUTE AUDIT COMMANDS NOW:
# AI runs specialized audit commands on YOUR actual files
# Compares YOUR README.md with YOUR source code
# No hardcoded assumptions about your tech stack

[FOLLOW-UP] Based on audit results:
1. Update documentation files as recommended
2. /vybe:audit --verify - confirm fixes work
3. /vybe:status - check overall project health
```

### 3. Business Outcome Alignment with Smart Routing
```bash
/vybe:discuss "find features not tied to business outcomes and suggest what to do"

# Smart Routing Output:
[DETECTED] Analysis request - routing to specialized audit commands
[ROUTING] Determining required audit modes...
  → Business value analysis needed

[COMMANDS] Will execute the following audit commands:
  /vybe:audit business-value

[AI] EXECUTE AUDIT COMMANDS NOW:
# AI analyzes YOUR actual source code features
# Maps against YOUR outcomes.md business values  
# Identifies YOUR specific orphan features with real LOC counts
# Based on YOUR project, not generic examples

[FOLLOW-UP] Recommended actions:
1. Review business value audit results
2. Update outcomes.md to justify orphan features OR remove them
3. /vybe:plan [missing-features] for unimplemented outcomes
4. /vybe:status outcomes - track business alignment
```

## Error Handling

### Common Error Cases
```bash
# No project context
if [ "$project_loaded" = false ]; then
    echo "[NO] CRITICAL: No project context found"
    echo "   Run: /vybe:init first"
    exit 1
fi

# Empty request
if [ -z "$request" ]; then
    echo "[NO] ERROR: Request required"
    echo "   Describe what you want to accomplish"
    echo "   Example: /vybe:discuss \"add mobile support\""
    exit 1
fi

# Too vague request
if echo "$request" | grep -qi "^help$\|^what\|^how$"; then
    echo "[CLARIFY] Request too general"
    echo "   Try being more specific:"
    echo "   Instead of: 'help'"
    echo "   Try: 'add user authentication feature'"
    echo "   Or: 'switch database from MySQL to PostgreSQL'"
    exit 1
fi
```

## AI Implementation Guidelines

### Natural Language Understanding
1. **Parse intent** - What does the user actually want to accomplish?
2. **Understand context** - What's the current project state?
3. **Map to commands** - Which Vybe commands achieve this goal?
4. **Provide sequence** - Step-by-step command workflow
5. **Add context** - Explain why each command is needed

### Response Quality Standards
- **Specific commands** - Always provide exact Vybe commands to run
- **Contextual awareness** - Consider current project state
- **Explain rationale** - Why each command is recommended
- **Warn of risks** - Highlight potential issues or dependencies
- **Provide alternatives** - Suggest different approaches when applicable

### Command Generation Rules
- **Load full context** - Always understand complete project state first
- **Specific over generic** - Provide exact commands, not just categories
- **Sequential workflow** - Commands in logical execution order
- **Member awareness** - Consider member count and assignments
- **Quality focus** - Include audit/validation steps for major changes

This `/vybe:discuss` command transforms natural language requests into actionable Vybe command sequences, making the framework much more accessible to users who want to describe what they need rather than remember specific command syntax.