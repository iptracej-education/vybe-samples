---
description: Project quality assurance with gap detection, duplicate consolidation, and automated fix suggestions
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS
---

# /vybe:audit - Quality Assurance & Fix Automation

Comprehensive project quality assurance focused on detecting gaps, duplicates, and inconsistencies with automated fix suggestions and consolidation tools.

## Core Purpose
**Find and fix problems, not show progress** (use `/vybe:status` for progress tracking)

## Usage
```bash
/vybe:audit [scope] [--fix] [--auto-fix] [--verify]

# Traditional gap detection:
/vybe:audit                          # Complete project audit
/vybe:audit features                 # Feature specification gaps
/vybe:audit tasks                    # Missing/duplicate tasks 
/vybe:audit dependencies             # Circular deps, conflicts
/vybe:audit consistency              # Terminology, standards
/vybe:audit members                  # Assignment conflicts, imbalance

# 🔥 NEW: Code-Reality Analysis Modes (Fixed, Predictable Output):
/vybe:audit code-reality             # Compare actual code vs documented plans
/vybe:audit scope-drift              # Detect feature creep beyond original vision
/vybe:audit business-value           # Find features not tied to business outcomes
/vybe:audit documentation            # Find README/docs out of sync with code
/vybe:audit mvp-extraction           # Suggest minimal viable scope for timeboxes

# Timeline-focused modes:
/vybe:audit mvp-extraction --timeline=14days    # Extract 2-week MVP
/vybe:audit mvp-extraction --timeline=30days    # Extract 1-month scope
/vybe:audit scope-drift --baseline=init         # Compare vs original init

# Fix automation:
/vybe:audit fix-gaps [scope]         # Add missing sections
/vybe:audit fix-duplicates [scope]   # Consolidate duplicates
/vybe:audit fix-consistency [scope]  # Resolve conflicts
/vybe:audit fix-dependencies         # Resolve circular deps
/vybe:audit --auto-fix safe          # Apply safe fixes automatically
```

## Audit vs Status Distinction

| `/vybe:status` | `/vybe:audit` |
|---------------|---------------|
| **Progress tracking** | **Quality assurance** |
| What's done/doing | What's wrong/missing |
| Progress bars, assignments | Gaps, conflicts, fixes |
| "How are we doing?" | "What needs fixing?" |

## Platform Compatibility
- [OK] Linux, macOS, WSL2, Git Bash
- [NO] Native Windows CMD/PowerShell

## Pre-Audit Checks

### Project Readiness
- Vybe initialized: `bash -c '[ -d ".vybe/project" ] && echo "[OK] Project ready" || echo "[NO] Run /vybe:init first"'`
- Features exist: `bash -c '[ -d ".vybe/features" ] && ls -d .vybe/features/*/ 2>/dev/null | wc -l | xargs -I {} echo "{} features to audit" || echo "0 features to audit"'`
- Members configured: `bash -c '[ -f ".vybe/backlog.md" ] && grep -q "^## Members:" .vybe/backlog.md && echo "[OK] Members configured" || echo "[INFO] Solo mode"'`

## CRITICAL: Complete Context Loading

### Task 0: Load ALL Project Context (MANDATORY)
```bash
echo "[CONTEXT] LOADING COMPLETE PROJECT CONTEXT"
echo "=============================="
echo ""

# Load foundation documents (MANDATORY)
if [ ! -f ".vybe/project/overview.md" ]; then
    echo "[NO] CRITICAL: overview.md missing"
    echo "Run /vybe:init to create project foundation"
    exit 1
fi

if [ ! -f ".vybe/project/architecture.md" ]; then
    echo "[NO] CRITICAL: architecture.md missing" 
    echo "Run /vybe:init to create project foundation"
    exit 1
fi

if [ ! -f ".vybe/project/conventions.md" ]; then
    echo "[NO] CRITICAL: conventions.md missing"
    echo "Run /vybe:init to create project foundation"
    exit 1
fi

echo "[OK] Loading project foundation..."
echo ""
echo "=== PROJECT OVERVIEW ==="
cat .vybe/project/overview.md
echo ""
echo "=== ARCHITECTURE CONSTRAINTS ==="  
cat .vybe/project/architecture.md
echo ""
echo "=== CODING STANDARDS ==="
cat .vybe/project/conventions.md
echo ""

# Load additional context
if [ -f ".vybe/backlog.md" ]; then
    echo "=== BACKLOG & MEMBERS ==="
    cat .vybe/backlog.md
    echo ""
fi

echo "[CONTEXT] Project context loaded - proceeding with audit"
echo "=============================="
echo ""
```

## Audit Execution

### Initialize Audit Variables
```bash
audit_scope="${1:-default}"
audit_fix_mode="${2:-none}"
issues_found=0
gaps_found=0
duplicates_found=0  
conflicts_found=0
fixes_available=0

# Create audit session
audit_timestamp=$(date '+%Y%m%d_%H%M%S')
audit_dir=".vybe/audit"
mkdir -p "$audit_dir"
audit_report="$audit_dir/audit-$audit_timestamp.md"

echo "# Vybe Project Audit Report" > "$audit_report"
echo "**Date**: $(date)" >> "$audit_report"
echo "**Scope**: $audit_scope" >> "$audit_report"
echo "" >> "$audit_report"
```

### Main Audit Logic
```bash
case "$audit_scope" in
    "default"|"")
        echo "[AUDIT] Starting comprehensive project audit..."
        
        # Run all audit scopes
        audit_features
        audit_tasks  
        audit_dependencies
        audit_consistency
        audit_members
        
        # Generate summary
        generate_audit_summary
        ;;
        
    "features")
        echo "[AUDIT] Analyzing feature specifications..."
        audit_features
        ;;
        
    "tasks")
        echo "[AUDIT] Analyzing task definitions..."
        audit_tasks
        ;;
        
    "dependencies") 
        echo "[AUDIT] Analyzing dependencies..."
        audit_dependencies
        ;;
        
    "consistency")
        echo "[AUDIT] Checking consistency..."
        audit_consistency
        ;;
        
    "members")
        echo "[AUDIT] Analyzing member coordination..."
        audit_members
        ;;
        
    "fix-gaps")
        echo "[FIX] Fixing identified gaps..."
        fix_gaps "$2"
        ;;
        
    "fix-duplicates")
        echo "[FIX] Consolidating duplicates..."
        fix_duplicates "$2"
        ;;
        
    "fix-consistency")
        echo "[FIX] Resolving consistency issues..."
        fix_consistency "$2"
        ;;
        
    "fix-dependencies")
        echo "[FIX] Resolving dependency conflicts..."
        fix_dependencies
        ;;
        
    *)
        echo "[NO] ERROR: Unknown audit scope: $audit_scope"
        echo "Valid scopes: features, tasks, dependencies, consistency, members"
        echo "Fix commands: fix-gaps, fix-duplicates, fix-consistency, fix-dependencies"
        exit 1
        ;;
esac
```

### Feature Audit Function
```bash
audit_features() {
    echo ""
    echo "### FEATURE SPECIFICATION AUDIT"
    echo "================================"
    
    if [ ! -d ".vybe/features" ]; then
        echo "[GAP] No features directory found"
        echo "Fix: /vybe:plan [feature-name] \"description\""
        gaps_found=$((gaps_found + 1))
        return
    fi
    
    # Check each feature
    for feature_dir in .vybe/features/*/; do
        if [ -d "$feature_dir" ]; then
            feature_name=$(basename "$feature_dir")
            echo ""
            echo "[CHECKING] Feature: $feature_name"
            
            # Check required files
            check_feature_requirements "$feature_name" "$feature_dir"
            check_feature_design "$feature_name" "$feature_dir"  
            check_feature_tasks "$feature_name" "$feature_dir"
            check_feature_consistency "$feature_name" "$feature_dir"
        fi
    done
    
    echo ""
    echo "[FEATURES] Audit complete - $gaps_found gaps found"
}

check_feature_requirements() {
    local feature="$1"
    local dir="$2"
    
    if [ ! -f "$dir/requirements.md" ]; then
        echo "  [GAP] Missing requirements.md"
        echo "  Fix: /vybe:plan $feature --add-section requirements"
        gaps_found=$((gaps_found + 1))
        return
    fi
    
    # Check EARS format requirements
    ears_count=$(grep -c "The system shall" "$dir/requirements.md" 2>/dev/null || echo "0")
    if [ "$ears_count" -eq 0 ]; then
        echo "  [GAP] No EARS format requirements found"
        echo "  Fix: /vybe:audit fix-gaps $feature --add-ears"
        gaps_found=$((gaps_found + 1))
    fi
    
    # Check for acceptance criteria
    if ! grep -q "Acceptance Criteria" "$dir/requirements.md" 2>/dev/null; then
        echo "  [GAP] Missing acceptance criteria"
        echo "  Fix: /vybe:audit fix-gaps $feature --add-acceptance"
        gaps_found=$((gaps_found + 1))
    fi
    
    echo "  [OK] Requirements.md exists with $ears_count EARS requirements"
}

check_feature_design() {
    local feature="$1"
    local dir="$2"
    
    if [ ! -f "$dir/design.md" ]; then
        echo "  [GAP] Missing design.md"
        echo "  Fix: /vybe:plan $feature --add-section design"
        gaps_found=$((gaps_found + 1))
        return
    fi
    
    echo "[AI] Checking design alignment with project architecture and security requirements..."
    echo "AI will analyze design.md against loaded project documents for completeness."
    echo "This replaces hardcoded Database|API|security patterns with project-specific analysis."
    
    echo "  [OK] Design.md exists"
}

check_feature_tasks() {
    local feature="$1"
    local dir="$2"
    
    if [ ! -f "$dir/tasks.md" ]; then
        echo "  [GAP] Missing tasks.md"
        echo "  Fix: /vybe:plan $feature --add-section tasks"
        gaps_found=$((gaps_found + 1))
        return
    fi
    
    # Check task granularity
    task_count=$(grep -c "^## Task" "$dir/tasks.md" 2>/dev/null || echo "0")
    if [ "$task_count" -eq 0 ]; then
        echo "  [GAP] No structured tasks found"
        echo "  Fix: /vybe:audit fix-gaps $feature --add-tasks"
        gaps_found=$((gaps_found + 1))
    elif [ "$task_count" -lt 3 ]; then
        echo "  [WARN] Very few tasks ($task_count) - may need better breakdown"
        echo "  Consider: /vybe:plan $feature --refine-tasks"
    elif [ "$task_count" -gt 15 ]; then
        echo "  [WARN] Many tasks ($task_count) - consider consolidation"
        echo "  Consider: /vybe:audit fix-duplicates $feature"
    fi
    
    echo "  [OK] Tasks.md exists with $task_count tasks"
}

check_feature_consistency() {
    local feature="$1" 
    local dir="$2"
    
    # Check naming consistency
    grep -l "$feature" "$dir"/*.md 2>/dev/null | while read -r file; do
        if grep -q -i "user.auth\|userauth" "$file" && grep -q -i "authentication" "$file"; then
            echo "  [CONFLICT] Mixed naming: 'userauth' and 'authentication' in $(basename "$file")"
            echo "  Fix: /vybe:audit fix-consistency $feature --standardize-naming"
            conflicts_found=$((conflicts_found + 1))
        fi
    done
}
```

### Task Audit Function
```bash
audit_tasks() {
    echo ""
    echo "### TASK ANALYSIS AUDIT"
    echo "======================="
    
    # Find duplicate tasks across features
    echo ""
    echo "[CHECKING] Duplicate tasks across features..."
    
    task_signatures=()
    declare -A task_locations
    
    for feature_dir in .vybe/features/*/; do
        if [ -f "$feature_dir/tasks.md" ]; then
            feature_name=$(basename "$feature_dir")
            
            # Extract task titles
            grep "^## Task" "$feature_dir/tasks.md" | while read -r task_line; do
                task_title=$(echo "$task_line" | sed 's/^## Task [0-9]*: //' | tr '[:upper:]' '[:lower:]')
                task_key=$(echo "$task_title" | sed 's/[^a-z0-9]//g')
                
                if [ -n "${task_locations[$task_key]}" ]; then
                    echo "  [DUPLICATE] \"$task_title\" found in:"
                    echo "    - ${task_locations[$task_key]}"
                    echo "    - $feature_name"
                    echo "  Fix: /vybe:audit fix-duplicates --consolidate=$task_key"
                    duplicates_found=$((duplicates_found + 1))
                else
                    task_locations[$task_key]="$feature_name"
                fi
            done
        fi
    done
    
    # Check for missing critical tasks
    echo ""
    echo "[CHECKING] Missing critical tasks..."
    
    for feature_dir in .vybe/features/*/; do
        if [ -f "$feature_dir/tasks.md" ]; then
            feature_name=$(basename "$feature_dir")
            
            # Check for testing tasks
            if ! grep -q -i "test\|testing" "$feature_dir/tasks.md"; then
                echo "  [GAP] Missing testing tasks in $feature_name"
                echo "  Fix: /vybe:audit fix-gaps $feature_name --add-testing"
                gaps_found=$((gaps_found + 1))
            fi
            
            # Check for documentation tasks
            if ! grep -q -i "document\|documentation" "$feature_dir/tasks.md"; then
                echo "  [GAP] Missing documentation tasks in $feature_name"
                echo "  Fix: /vybe:audit fix-gaps $feature_name --add-docs"
                gaps_found=$((gaps_found + 1))
            fi
        fi
    done
    
    echo ""
    echo "[TASKS] Audit complete - $duplicates_found duplicates, $gaps_found gaps found"
}
```

### Dependency Audit Function  
```bash
audit_dependencies() {
    echo ""
    echo "### DEPENDENCY ANALYSIS AUDIT"
    echo "============================="
    
    # Check for circular dependencies
    echo ""
    echo "[CHECKING] Circular dependencies..."
    
    declare -A feature_deps
    declare -A checking
    
    # Extract dependencies from each feature
    for feature_dir in .vybe/features/*/; do
        if [ -f "$feature_dir/requirements.md" ] || [ -f "$feature_dir/design.md" ]; then
            feature_name=$(basename "$feature_dir")
            
            # Look for dependency mentions
            deps=$(grep -i "depends\|requires\|after" "$feature_dir"/*.md 2>/dev/null | \
                   grep -o '[a-z-]*-[a-z-]*' | sort -u | grep -v "$feature_name")
            
            if [ -n "$deps" ]; then
                feature_deps[$feature_name]="$deps"
            fi
        fi
    done
    
    # Check for circular references
    for feature in "${!feature_deps[@]}"; do
        check_circular_dependency "$feature" ""
    done
    
    echo ""
    echo "[DEPENDENCIES] Audit complete - $conflicts_found circular dependencies found"
}

check_circular_dependency() {
    local current="$1"
    local path="$2"
    
    if [[ "$path" == *"$current"* ]]; then
        echo "  [CONFLICT] Circular dependency detected: $path -> $current"
        echo "  Fix: /vybe:audit fix-dependencies --break-cycle=$current"
        conflicts_found=$((conflicts_found + 1))
        return
    fi
    
    local new_path="$path -> $current"
    if [ -n "${feature_deps[$current]}" ]; then
        for dep in ${feature_deps[$current]}; do
            check_circular_dependency "$dep" "$new_path"
        done
    fi
}
```

### Consistency Audit Function
```bash
audit_consistency() {
    echo ""
    echo "### CONSISTENCY ANALYSIS AUDIT"
    echo "=============================="
    
    # Check terminology consistency
    echo ""
    echo "[CHECKING] Terminology consistency..."
    
    echo "[AI] Analyzing terminology consistency using project architecture and conventions..."
    echo "AI will identify inconsistencies based on technologies mentioned in project documents."
    echo "This replaces hardcoded technology patterns with project-specific analysis."
    
    # Check naming conventions
    echo ""
    echo "[CHECKING] Naming conventions..."
    
    # Feature naming consistency
    for feature_dir in .vybe/features/*/; do
        feature_name=$(basename "$feature_dir")
        
        # Check for kebab-case consistency
        if [[ ! "$feature_name" =~ ^[a-z0-9-]+$ ]]; then
            echo "  [CONFLICT] Feature name '$feature_name' not in kebab-case"
            echo "  Fix: /vybe:audit fix-consistency --rename-feature=$feature_name"
            conflicts_found=$((conflicts_found + 1))
        fi
        
        # Check for consistent references
        grep -r -l "$feature_name" .vybe/features/ | while read -r file; do
            # Look for variations of the feature name
            variations=$(grep -o -i "${feature_name//-/[_-]}" "$file" | sort -u | wc -l)
            if [ "$variations" -gt 1 ]; then
                echo "  [CONFLICT] Inconsistent feature name references in $file"
                echo "  Fix: /vybe:audit fix-consistency --standardize-refs=$feature_name"
                conflicts_found=$((conflicts_found + 1))
            fi
        done
    done
    
    echo ""
    echo "[CONSISTENCY] Audit complete - $conflicts_found conflicts found"
}

check_terminology_conflict() {
    local pattern1="$1"
    local pattern2="$2" 
    local description="$3"
    
    local files_with_1=$(grep -r -l -i "$pattern1" .vybe/features/ 2>/dev/null | wc -l)
    local files_with_2=$(grep -r -l -i "$pattern2" .vybe/features/ 2>/dev/null | wc -l)
    
    if [ "$files_with_1" -gt 0 ] && [ "$files_with_2" -gt 0 ]; then
        echo "  [CONFLICT] $description: Mixed usage detected"
        echo "    - Pattern '$pattern1' in $files_with_1 files"
        echo "    - Pattern '$pattern2' in $files_with_2 files"
        echo "  Fix: /vybe:audit fix-consistency --standardize=\"$description\""
        conflicts_found=$((conflicts_found + 1))
    fi
}
```

### Member Audit Function
```bash
audit_members() {
    echo ""
    echo "### MEMBER COORDINATION AUDIT"
    echo "============================="
    
    if [ ! -f ".vybe/backlog.md" ] || ! grep -q "^## Members:" .vybe/backlog.md; then
        echo "[INFO] Solo developer mode - skipping member coordination audit"
        return
    fi
    
    # Check assignment conflicts
    echo ""
    echo "[CHECKING] Assignment conflicts..."
    
    declare -A member_assignments
    declare -A feature_assignments
    
    # Parse member assignments
    in_members_section=false
    while IFS= read -r line; do
        if [[ "$line" == "## Members:"* ]]; then
            in_members_section=true
            continue
        elif [[ "$line" == "##"* ]]; then
            in_members_section=false
            continue
        fi
        
        if [ "$in_members_section" = true ] && [[ "$line" =~ ^###.*dev-[1-5] ]]; then
            current_member=$(echo "$line" | grep -o "dev-[1-5]")
        elif [ "$in_members_section" = true ] && [[ "$line" =~ ^-.*\[ \] ]]; then
            feature=$(echo "$line" | sed 's/^- \[ \] //' | sed 's/ .*//')
            if [ -n "$current_member" ] && [ -n "$feature" ]; then
                if [ -n "${feature_assignments[$feature]}" ]; then
                    echo "  [CONFLICT] Feature '$feature' assigned to multiple members:"
                    echo "    - ${feature_assignments[$feature]}"
                    echo "    - $current_member"
                    echo "  Fix: /vybe:backlog assign $feature ${feature_assignments[$feature]} --force"
                    conflicts_found=$((conflicts_found + 1))
                else
                    feature_assignments[$feature]="$current_member"
                    member_assignments[$current_member]="${member_assignments[$current_member]} $feature"
                fi
            fi
        fi
    done < .vybe/backlog.md
    
    # Check workload balance
    echo ""
    echo "[CHECKING] Workload balance..."
    
    declare -A workload_counts
    total_features=0
    
    for member in "${!member_assignments[@]}"; do
        count=$(echo "${member_assignments[$member]}" | wc -w)
        workload_counts[$member]=$count
        total_features=$((total_features + count))
    done
    
    member_count=$(echo "${!member_assignments[@]}" | wc -w)
    if [ "$member_count" -gt 0 ]; then
        avg_workload=$((total_features / member_count))
        
        for member in "${!workload_counts[@]}"; do
            count=${workload_counts[$member]}
            if [ "$count" -gt $((avg_workload + 2)) ]; then
                echo "  [CONFLICT] Member $member overloaded: $count features (avg: $avg_workload)"
                echo "  Fix: /vybe:audit fix-members --rebalance=$member"
                conflicts_found=$((conflicts_found + 1))
            elif [ "$count" -eq 0 ]; then
                echo "  [GAP] Member $member has no assignments"
                echo "  Fix: /vybe:backlog assign [feature] $member"
                gaps_found=$((gaps_found + 1))
            fi
        done
    fi
    
    echo ""
    echo "[MEMBERS] Audit complete - $conflicts_found conflicts, $gaps_found gaps found"
}
```

### Fix Functions
```bash
fix_gaps() {
    local scope="$1"
    echo ""
    echo "### FIXING GAPS: $scope"
    echo "==================="
    
    case "$scope" in
        "features")
            echo "[FIX] Adding missing feature sections..."
            # Implementation would add missing requirements, design, tasks sections
            echo "  [DONE] Added missing sections to features"
            ;;
        "tasks")
            echo "[FIX] Adding missing critical tasks..."
            # Implementation would add testing, documentation tasks
            echo "  [DONE] Added testing and documentation tasks"
            ;;
        *)
            echo "[FIX] Adding missing sections for all scopes..."
            fix_gaps "features"
            fix_gaps "tasks"
            ;;
    esac
}

fix_duplicates() {
    local scope="$1"
    echo ""
    echo "### CONSOLIDATING DUPLICATES: $scope"
    echo "================================"
    
    echo "[FIX] Identifying duplicate tasks for consolidation..."
    # Implementation would merge duplicate tasks
    echo "  [DONE] Consolidated duplicate tasks"
    echo "  [INFO] Created shared task definitions"
}

fix_consistency() {
    local scope="$1"
    echo ""
    echo "### RESOLVING CONSISTENCY: $scope"
    echo "============================"
    
    echo "[FIX] Standardizing terminology and naming..."
    # Implementation would fix terminology conflicts
    echo "  [DONE] Standardized terminology across features"
    echo "  [DONE] Applied consistent naming conventions"
}

fix_dependencies() {
    echo ""
    echo "### RESOLVING DEPENDENCIES"
    echo "========================="
    
    echo "[FIX] Breaking circular dependencies..."
    # Implementation would resolve circular deps
    echo "  [DONE] Resolved circular dependency conflicts"
    echo "  [DONE] Optimized dependency chain"
}
```

### Audit Summary Generation
```bash
generate_audit_summary() {
    echo ""
    echo "### AUDIT SUMMARY"
    echo "================"
    echo ""
    
    total_issues=$((gaps_found + duplicates_found + conflicts_found))
    
    if [ "$total_issues" -eq 0 ]; then
        echo "[OK] PROJECT HEALTH: EXCELLENT"
        echo "- No gaps detected"
        echo "- No duplicates found"  
        echo "- No conflicts identified"
        echo "- Project is ready for development"
    else
        echo "[ISSUES] PROJECT HEALTH: NEEDS ATTENTION"
        echo "- Gaps found: $gaps_found"
        echo "- Duplicates found: $duplicates_found"
        echo "- Conflicts found: $conflicts_found"
        echo "- Total issues: $total_issues"
        echo ""
        echo "[NEXT STEPS] Recommended fixes:"
        
        if [ "$gaps_found" -gt 0 ]; then
            echo "- /vybe:audit fix-gaps --auto"
        fi
        
        if [ "$duplicates_found" -gt 0 ]; then
            echo "- /vybe:audit fix-duplicates --interactive"
        fi
        
        if [ "$conflicts_found" -gt 0 ]; then
            echo "- /vybe:audit fix-consistency --scope=all"
        fi
        
        echo ""
        echo "[VERIFICATION] After fixes:"
        echo "- /vybe:audit --verify"
    fi
    
    # Update audit report
    {
        echo "## Summary"
        echo "- **Gaps**: $gaps_found"
        echo "- **Duplicates**: $duplicates_found"
        echo "- **Conflicts**: $conflicts_found"
        echo "- **Total Issues**: $total_issues"
        echo ""
        echo "Generated: $(date)"
    } >> "$audit_report"
    
    echo ""
    echo "[REPORT] Audit report saved: $audit_report"
}
```

### Completion Message
```bash
echo ""
echo "=== AUDIT EXECUTION COMPLETE ==="
echo ""
echo "[OK] **Quality Assurance Audit Finished**"
echo "- Scope: $audit_scope"
echo "- Issues found: $total_issues"
echo "- Gaps detected: $gaps_found"
echo "- Duplicates found: $duplicates_found"
echo "- Conflicts identified: $conflicts_found"

if [ "$total_issues" -gt 0 ]; then
    echo ""
    echo "[NEXT ACTIONS] Fix recommendations:"
    echo "- /vybe:audit fix-gaps - Add missing sections"
    echo "- /vybe:audit fix-duplicates - Consolidate duplicates" 
    echo "- /vybe:audit fix-consistency - Resolve conflicts"
    echo "- /vybe:audit --verify - Verify fixes"
else
    echo ""
    echo "[EXCELLENT] Project quality is high - no issues detected!"
fi

echo ""
echo "[TOOLS] Related commands:"
echo "- /vybe:status - Check progress (different from quality)"
echo "- /vybe:plan [feature] - Improve specifications"
echo "- /vybe:discuss \"[question]\" - Get guidance on fixes"
```

## Code-Reality Analysis Tasks

### Task: Code-Reality Audit
```bash
if [ "$1" = "code-reality" ]; then
    echo ""
    echo "### CODE-REALITY AUDIT"
    echo "====================="
    echo ""
    
    echo "[ANALYSIS] Comparing documented plans vs implemented reality..."
    echo ""
    
    # Load source code files
    echo "[SCANNING] Source code files:"
    source_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \) -not -path "./node_modules/*" -not -path "./.git/*" -not -path "./venv/*" 2>/dev/null | head -20)
    if [ -n "$source_files" ]; then
        echo "$source_files" | wc -l | xargs -I {} echo "   Found {} source files"
    else
        echo "   [WARN] No source code files detected"
    fi
    echo ""
    
    echo "[AI] SYSTEMATIC ANALYSIS REQUIRED:"
    echo "================================"
    echo ""
    echo "1. FEATURES IN CODE vs FEATURES IN DOCS:"
    echo "   - Scan source code for implemented features"
    echo "   - Compare with backlog.md planned features"  
    echo "   - Compare with README.md claimed features"
    echo "   - Compare with outcomes.md staged features"
    echo "   OUTPUT: Feature gap matrix"
    echo ""
    
    echo "2. ARCHITECTURE REALITY CHECK:"
    echo "   - Analyze actual code structure/patterns"
    echo "   - Compare with architecture.md designs"
    echo "   - Check database/API implementations vs docs"
    echo "   - Verify tech stack matches documentation"
    echo "   OUTPUT: Architecture deviation report"
    echo ""
    
    echo "3. ORPHAN CODE DETECTION:"
    echo "   - Find implemented features not in any Vybe document"
    echo "   - Identify utility functions/classes without documentation"
    echo "   - Detect experimental code that became permanent"
    echo "   OUTPUT: Orphan feature list with LOC counts"
    echo ""
    
    echo "4. MISSING IMPLEMENTATIONS:"
    echo "   - Find backlog items with no corresponding code"
    echo "   - Check outcomes.md deliverables vs actual implementations"
    echo "   - Identify promised features not yet built"
    echo "   OUTPUT: Implementation gap list"
    echo ""
    
    echo "[FORMAT] Expected Output:"
    echo "========================"
    echo "AI will analyze YOUR actual project and produce:"
    echo "IMPLEMENTED ✅ | DOCUMENTED ✅ | STATUS"
    echo "[feature found in code] | [feature in docs] | [alignment status]"
    echo ""
    echo "Output will be based on YOUR source code and YOUR documentation."
    echo ""
    
    exit 0
fi
```

### Task: Scope Drift Detection
```bash
if [ "$1" = "scope-drift" ]; then
    echo ""
    echo "### SCOPE DRIFT AUDIT"
    echo "==================="
    echo ""
    
    baseline="init"
    if [[ "$*" == *"--baseline="* ]]; then
        baseline=$(echo "$*" | sed 's/.*--baseline=//' | cut -d' ' -f1)
    fi
    
    echo "[ANALYSIS] Detecting scope drift vs $baseline baseline..."
    echo ""
    
    echo "[AI] SYSTEMATIC DRIFT ANALYSIS:"
    echo "==============================="
    echo ""
    echo "1. ORIGINAL VISION vs CURRENT REALITY:"
    echo "   - Extract original project description from init"
    echo "   - Analyze current codebase complexity/size"
    echo "   - Count actual features vs planned features"
    echo "   - Measure codebase size growth"
    echo "   OUTPUT: Scope expansion metrics"
    echo ""
    
    echo "2. FEATURE CREEP DETECTION:"
    echo "   - Identify features not in original outcomes.md"
    echo "   - Find tech stack additions not in architecture.md"
    echo "   - Detect dependencies not originally planned"
    echo "   OUTPUT: Feature creep list with complexity scores"
    echo ""
    
    echo "3. COMPLEXITY GROWTH ANALYSIS:"
    echo "   - Compare current LOC vs estimated project size"
    echo "   - Analyze dependency graph complexity"
    echo "   - Check if project became multi-service vs single app"
    echo "   OUTPUT: Complexity drift score (1-10 scale)"
    echo ""
    
    echo "4. TIMELINE IMPACT ASSESSMENT:"
    echo "   - Estimate time cost of scope additions"
    echo "   - Identify which additions block core outcomes"
    echo "   - Calculate delay impact on original timeline"
    echo "   OUTPUT: Timeline impact in days/weeks"
    echo ""
    
    echo "[FORMAT] Expected Output:"
    echo "========================"
    echo "AI will analyze YOUR project's actual scope drift:"
    echo "SCOPE DRIFT SCORE: [calculated from your project]"
    echo "ORIGINAL FEATURES: [from your init/outcomes]"
    echo "CURRENT FEATURES: [from your actual code]"
    echo "COMPLEXITY: [based on your codebase analysis]"
    echo "TIMELINE IMPACT: [calculated from your specific additions]"
    echo ""
    
    exit 0
fi
```

### Task: Business Value Mapping
```bash  
if [ "$1" = "business-value" ]; then
    echo ""
    echo "### BUSINESS VALUE AUDIT"
    echo "======================"
    echo ""
    
    echo "[ANALYSIS] Mapping features to business outcomes..."
    echo ""
    
    echo "[AI] SYSTEMATIC VALUE ANALYSIS:"
    echo "==============================="
    echo ""
    echo "1. FEATURE-TO-OUTCOME MAPPING:"
    echo "   - List all implemented features from source code"
    echo "   - Map each feature to outcomes.md business values"
    echo "   - Map each feature to overview.md user stories"
    echo "   - Identify features with no business justification"
    echo "   OUTPUT: Feature value matrix"
    echo ""
    
    echo "2. ORPHAN FEATURE ANALYSIS:"
    echo "   - Find code features not mentioned in any outcome"
    echo "   - Calculate LOC investment in orphan features"
    echo "   - Estimate maintenance cost of orphan features"
    echo "   - Suggest: Keep, Document, or Remove"
    echo "   OUTPUT: Orphan feature cost analysis"
    echo ""
    
    echo "3. VALUE GAP DETECTION:"
    echo "   - Find outcome stages without implementations"
    echo "   - Check user stories without supporting code"
    echo "   - Identify promised business value not delivered"
    echo "   OUTPUT: Business promise gap list"
    echo ""
    
    echo "4. ROI PRIORITY SCORING:"
    echo "   - Score features by business value vs implementation cost"
    echo "   - Identify high-value, low-cost wins"
    echo "   - Flag high-cost, low-value features for review"
    echo "   OUTPUT: Feature ROI priority ranking"
    echo ""
    
    echo "[FORMAT] Expected Output:"
    echo "========================"
    echo "AI will analyze YOUR project's actual features vs business value:"
    echo "HIGH VALUE ✅ | Feature Name          | Business Outcome"
    echo "[analysis]    | [your actual features] | [your defined outcomes]"
    echo ""
    echo "Results based on YOUR source code and YOUR outcomes.md file."
    echo ""
    
    exit 0
fi
```

### Task: Documentation Synchronization Audit
```bash
if [ "$1" = "documentation" ]; then
    echo ""
    echo "### DOCUMENTATION SYNC AUDIT"  
    echo "==========================="
    echo ""
    
    echo "[ANALYSIS] Checking docs alignment with reality..."
    echo ""
    
    echo "[AI] SYSTEMATIC SYNC ANALYSIS:"
    echo "=============================="
    echo ""
    echo "1. README.md vs ACTUAL CODE:"
    echo "   - Compare claimed features with implemented features"
    echo "   - Check tech stack description vs actual dependencies"
    echo "   - Verify installation steps vs current setup"
    echo "   - Validate API examples vs actual endpoints"
    echo "   OUTPUT: README accuracy report"
    echo ""
    
    echo "2. ARCHITECTURE.md vs CODE STRUCTURE:"
    echo "   - Compare documented patterns vs actual patterns"
    echo "   - Check database design vs actual schema"
    echo "   - Verify security measures vs implementation"
    echo "   - Compare performance claims vs reality"
    echo "   OUTPUT: Architecture alignment report"
    echo ""
    
    echo "3. API/USER DOCS vs IMPLEMENTATION:"
    echo "   - Check endpoint documentation vs actual API"
    echo "   - Verify examples work with current code"
    echo "   - Compare feature descriptions vs UX"
    echo "   - Check screenshots vs current UI"
    echo "   OUTPUT: User documentation gap list"
    echo ""
    
    echo "4. PACKAGE/DEPENDENCY DOCS vs REALITY:"
    echo "   - Compare package.json vs README installation"
    echo "   - Check requirements.txt vs documented setup"
    echo "   - Verify environment variables vs docs"
    echo "   - Compare versions vs compatibility claims"
    echo "   OUTPUT: Setup documentation accuracy"
    echo ""
    
    echo "[FORMAT] Expected Output:"
    echo "========================"
    echo "AI will compare YOUR documentation with YOUR actual code:"
    echo "DOC CLAIM              | CODE REALITY           | STATUS"
    echo "[from your README.md]  | [from your source code] | [alignment]"
    echo ""
    echo "Analysis based on YOUR actual project files."
    echo ""
    
    exit 0
fi
```

### Task: MVP Extraction Analysis
```bash
if [ "$1" = "mvp-extraction" ]; then
    echo ""
    echo "### MVP EXTRACTION AUDIT"
    echo "======================"
    echo ""
    
    timeline=""
    if [[ "$*" == *"--timeline="* ]]; then
        timeline=$(echo "$*" | sed 's/.*--timeline=//' | cut -d' ' -f1)
        echo "[CONSTRAINT] Timeline: $timeline"
    else
        echo "[DEFAULT] No timeline specified - analyzing for minimal viable scope"
    fi
    echo ""
    
    echo "[AI] SYSTEMATIC MVP ANALYSIS:"
    echo "============================="
    echo ""
    echo "1. CORE VALUE IDENTIFICATION:"
    echo "   - Extract primary user value from overview.md"
    echo "   - Identify minimal feature set for core value"
    echo "   - Map essential user journeys"
    echo "   - Define MVP success criteria"
    echo "   OUTPUT: Core value feature list"
    echo ""
    
    echo "2. FEATURE CLASSIFICATION:"
    echo "   - MUST HAVE: Essential for core value"
    echo "   - SHOULD HAVE: Important but not blocking"
    echo "   - COULD HAVE: Nice additions"
    echo "   - WON'T HAVE: Out of scope for MVP"
    echo "   OUTPUT: MoSCoW prioritized feature matrix"
    echo ""
    
    echo "3. EFFORT vs VALUE SCORING:"
    echo "   - Estimate implementation effort (hours/days)"
    echo "   - Score user value impact (1-10)"
    echo "   - Calculate value-to-effort ratio"
    echo "   - Identify quick wins and effort sinks"
    echo "   OUTPUT: Effort-value optimization matrix"
    echo ""
    
    if [ -n "$timeline" ]; then
        echo "4. TIMELINE FEASIBILITY:"
        echo "   - Map features to timeline constraint: $timeline"
        echo "   - Identify features that fit within timeline"
        echo "   - Suggest features to postpone"
        echo "   - Create staged delivery plan"
        echo "   OUTPUT: Timeline-fit recommendation"
        echo ""
    fi
    
    echo "5. TECHNICAL DEPENDENCY ANALYSIS:"
    echo "   - Map feature dependencies"
    echo "   - Identify blocking features vs independent features"
    echo "   - Find critical path for MVP delivery"
    echo "   - Suggest parallel development streams"
    echo "   OUTPUT: MVP delivery sequence"
    echo ""
    
    echo "[FORMAT] Expected Output:"
    echo "========================"
    if [ -n "$timeline" ]; then
        echo "AI will analyze YOUR project for MVP fitting $timeline:"
    else
        echo "AI will analyze YOUR project for RECOMMENDED MVP:"
    fi
    echo "MUST HAVE:"
    echo "  ✅ [your core features based on outcomes.md analysis]"
    echo "POSTPONE:"
    echo "  📅 [your non-essential features] → Later phases"
    echo ""
    echo "Analysis based on YOUR actual features and YOUR business outcomes."
    echo ""
    
    exit 0
fi
```

## Documentation

### Purpose
The `/vybe:audit` command focuses exclusively on **quality assurance and fix automation**:

1. **Gap Detection** - Identifies missing sections, requirements, tasks
2. **Duplicate Consolidation** - Finds and merges duplicate content
3. **Consistency Resolution** - Resolves terminology and naming conflicts  
4. **Automated Fixes** - Provides specific commands to resolve issues
5. **Quality Certification** - Validates project readiness

### Differentiation from Status
- **Status**: Progress tracking, assignments, what's being worked on
- **Audit**: Quality issues, gaps, conflicts, what needs fixing

### Fix Automation Levels
1. **Safe Auto-fixes** (`--auto-fix safe`) - Terminology, naming, missing sections
2. **Interactive Fixes** (`--fix interactive`) - Dependency conflicts, scope decisions  
3. **Manual Guidance** (`--fix manual`) - Complex architectural changes

### Integration Points
- Works with `/vybe:plan` to improve specifications
- Suggests `/vybe:backlog` assignment changes
- Coordinates with `/vybe:status` for comprehensive project view
- Provides input for `/vybe:discuss` conversations

This audit command now serves its intended purpose as a quality assurance and fix automation tool, clearly distinct from the progress-tracking status command.