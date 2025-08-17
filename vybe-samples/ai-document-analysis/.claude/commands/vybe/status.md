---
description: Member-aware progress tracking with assignment visibility and project health monitoring
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS
---

# /vybe:status - Member Progress Tracking

Track progress and provide visibility into project health with member assignment awareness and multi-session coordination.

## Usage
```bash
/vybe:status [scope] [options]

# Examples:
/vybe:status                    # Overall project status
/vybe:status members            # Member assignments and workload
/vybe:status dev-1              # Specific member's assignments and progress
/vybe:status user-auth          # Specific feature status
/vybe:status blockers           # Show current blockers
```

## Scope Options
- **Default**: Overall project health and outcome progression
- **outcomes**: Staged outcome progression and timeline
- **members**: Member assignments, workload distribution, and coordination
- **dev-1, dev-2, dev-3, dev-4, dev-5**: Specific member's assignments and progress (fixed member names)
- **[feature-name]**: Detailed progress for specific feature
- **blockers**: Current blockers and dependencies
- **releases**: Release progress and planning

## Member Names (Fixed)
Member names are always `dev-1`, `dev-2`, `dev-3`, `dev-4`, `dev-5` (up to 5 members max).
- These are **fixed identifiers**, not customizable
- `dev-1` = First project member
- `dev-2` = Second project member  
- etc.

## Examples: Member Status Workflow

### Setup 2-Member Project
```bash
# Setup project with 2 members
/vybe:backlog member-count 2

# Assign features to specific members (by fixed names)
/vybe:backlog assign user-auth dev-1
/vybe:backlog assign payment-processing dev-1  
/vybe:backlog assign product-catalog dev-2
/vybe:backlog assign shopping-cart dev-2
```

### Check Status Views
```bash
# Overall project status
/vybe:status

# All member assignments 
/vybe:status members

# Check what dev-1 is working on
/vybe:status dev-1

# Check what dev-2 is working on  
/vybe:status dev-2

# Check specific feature progress
/vybe:status user-auth

# Check for project blockers
/vybe:status blockers
```

### Individual Member Work
```bash
# Terminal 1 (Member working as dev-1):
export VYBE_MEMBER=dev-1
/vybe:execute my-feature
/vybe:status dev-1           # Check my own progress

# Terminal 2 (Member working as dev-2):
export VYBE_MEMBER=dev-2  
/vybe:execute my-feature
/vybe:status dev-2           # Check my own progress
```

## Member Coordination
- Shows assignments across all project members
- Git-based progress from multiple sessions
- Real-time status from shared files
- Workload balance visualization

## Platform Compatibility
- [OK] Linux, macOS, WSL2, Git Bash
- [NO] Native Windows CMD/PowerShell

## Pre-Status Checks

### Project Readiness
- Vybe initialized: `bash -c '[ -d ".vybe/project" ] && echo "[OK] Project ready" || echo "[NO] Run /vybe:init first"'`
- Features planned: `bash -c '[ -d ".vybe/features" ] && ls -d .vybe/features/*/ 2>/dev/null | wc -l | xargs -I {} echo "{} features planned" || echo "0 features planned"'`
- Members configured: `bash -c '[ -f ".vybe/backlog.md" ] && grep -q "^## Members:" .vybe/backlog.md && echo "[OK] Members configured" || echo "[INFO] Solo mode"'`

### Status Sources
- Git commits: `bash -c '[ -d ".git" ] && echo "[OK] Git repository for progress tracking" || echo "[WARN] No git history"'`
- Session files: `bash -c '[ -d ".vybe/sessions" ] && ls .vybe/sessions/*.json 2>/dev/null | wc -l | xargs -I {} echo "{} execution sessions" || echo "0 execution sessions"'`

## CRITICAL: Context Loading for Status

### Task 0: Load Complete Project State (MANDATORY)
```bash
echo "[STATUS] LOADING PROJECT STATUS"
echo "=========================="
echo ""

scope="$1"
options="$*"

# Default to overall status if no scope specified
if [ -z "$scope" ]; then
    scope="overall"
fi

echo "Status scope: $scope"
echo ""

# Validate project exists
if [ ! -d ".vybe/project" ]; then
    echo "[NO] ERROR: Project not initialized"
    echo "Run /vybe:init first to set up project structure"
    exit 1
fi

# Load status-relevant documents for progress tracking
echo "[STATUS] Loading current work and assignment documents..."

# Load backlog for member assignments and priorities
if [ -f ".vybe/backlog.md" ]; then
    echo "[OK] Loading member assignments and feature priorities..."
    echo "=== BACKLOG & ASSIGNMENTS ==="
    cat .vybe/backlog.md
    echo ""
else
    echo "[INFO] No backlog found - solo project mode"
fi

# Load session context for multi-session coordination
if [ -d ".vybe/context/sessions" ]; then
    echo "[OK] Loading session coordination context..."
    echo "=== SESSION COORDINATION ==="
    ls -la .vybe/context/sessions/ 2>/dev/null || echo "No active sessions"
    echo ""
fi

echo ""
echo "[STATUS] Status-relevant context loaded - ready for progress tracking"
echo ""

# Load member configuration
members_configured=false
member_count=0
members=()

if [ -f ".vybe/backlog.md" ] && grep -q "^## Members:" .vybe/backlog.md; then
    members_configured=true
    member_count=$(grep "^## Members:" .vybe/backlog.md | grep -o "[0-9]*" | head -1)
    
    # Extract member roles
    for i in $(seq 1 $member_count); do
        members+=("dev-$i")
    done
    
    echo "[MEMBERS] Members configured: $member_count developer(s)"
else
    echo "[MEMBERS] Solo developer mode"
fi

# Load features and calculate metrics
total_features=0
completed_features=0
active_features=0
blocked_features=0

if [ -d ".vybe/features" ]; then
    total_features=$(ls -d .vybe/features/*/ 2>/dev/null | wc -l)
    
    # Count feature completion status
    for feature_dir in .vybe/features/*/; do
        if [ -d "$feature_dir" ]; then
            feature_name=$(basename "$feature_dir")
            
            # Check if feature is marked complete in backlog
            if [ -f ".vybe/backlog.md" ] && grep -q "^- \[x\] $feature_name" .vybe/backlog.md; then
                completed_features=$((completed_features + 1))
            elif [ -f "$feature_dir/status.md" ]; then
                # Check feature status file
                if grep -q "Status.*[Cc]omplete" "$feature_dir/status.md"; then
                    completed_features=$((completed_features + 1))
                elif grep -q "Status.*[Bb]locked" "$feature_dir/status.md"; then
                    blocked_features=$((blocked_features + 1))
                else
                    active_features=$((active_features + 1))
                fi
            else
                active_features=$((active_features + 1))
            fi
        fi
    done
fi

# Calculate progress percentage
if [ $total_features -gt 0 ]; then
    progress_percent=$((completed_features * 100 / total_features))
else
    progress_percent=0
fi

echo "[FEATURES] $total_features total features ($completed_features completed, $active_features active, $blocked_features blocked)"
echo "[PROGRESS] Overall: $progress_percent%"
echo ""

# Status loading complete
echo "[OK] Status context loaded"
echo ""
```

## Task 1: Overall Project Status

### Display Project Dashboard
```bash
if [ "$scope" = "overall" ]; then
    echo "[DASHBOARD] PROJECT STATUS DASHBOARD"
    echo "============================"
    echo ""
    
    # Project header
    echo "[TARGET] Project: $project_name"
    
    # Progress bar visualization
    progress_bar=""
    filled_blocks=$((progress_percent / 5))  # Each block represents 5%
    for i in $(seq 1 20); do
        if [ $i -le $filled_blocks ]; then
            progress_bar="${progress_bar}="
        else
            progress_bar="${progress_bar}-"
        fi
    done
    
    echo "[PROGRESS] Overall Progress: $progress_bar $progress_percent%"
    echo ""
    
    # Outcome progression
    echo "[OUTCOMES] Staged Outcome Progress:"
    if [ -f ".vybe/project/outcomes.md" ] && [ -f ".vybe/backlog.md" ]; then
        current_stage=$(grep "Active Stage:" .vybe/backlog.md 2>/dev/null | sed 's/.*Stage \([0-9]*\).*/\1/')
        total_stages=$(grep "^### Stage" .vybe/project/outcomes.md 2>/dev/null | wc -l)
        completed_stages=$(grep "COMPLETED" .vybe/backlog.md 2>/dev/null | grep "^### Stage" | wc -l)
        
        if [ -n "$current_stage" ]; then
            echo "   Current: Stage $current_stage (IN PROGRESS)"
            echo "   Completed: $completed_stages of $total_stages stages"
            
            # Show current stage tasks
            current_tasks=$(grep -A 20 "IN PROGRESS" .vybe/backlog.md 2>/dev/null | grep "^\- \[.\]" | wc -l)
            completed_tasks=$(grep -A 20 "IN PROGRESS" .vybe/backlog.md 2>/dev/null | grep "^\- \[x\]" | wc -l)
            incomplete_tasks=$(grep -A 20 "IN PROGRESS" .vybe/backlog.md 2>/dev/null | grep "^\- \[ \]" | wc -l)
            
            if [ $current_tasks -gt 0 ]; then
                echo "   Stage Tasks: $completed_tasks/$current_tasks completed"
            fi
            
            # Show timeline
            echo "   Timeline: Each stage targets 1-3 days delivery"
        else
            echo "   [INFO] No staged outcomes configured"
            echo "   Run /vybe:init with outcome stages for incremental delivery"
        fi
    else
        echo "   [NONE] Outcome-driven development not configured"
        echo "   Next: /vybe:init to set up staged outcomes"
    fi
    echo ""
    
    # Feature summary
    echo "[FEATURES] Features Summary:"
    if [ $total_features -gt 0 ]; then
        echo "   [OK] Completed: $completed_features"
        echo "   [ACTIVE] Active: $active_features"
        if [ $blocked_features -gt 0 ]; then
            echo "   [BLOCKED] Blocked: $blocked_features"
        fi
    else
        echo "   [NONE] No features planned yet"
        echo "   Next: /vybe:plan [feature-name] to get started"
    fi
    echo ""
    
    # Member summary
    if [ "$members_configured" = true ]; then
        echo "[MEMBERS] Member Status:"
        echo "   Project size: $member_count developer(s)"
        
        # Show member workload
        for dev in "${members[@]}"; do
            assigned_count=$(sed -n "/^### $dev/,/^### /p" .vybe/backlog.md 2>/dev/null | grep "^- \[" | wc -l)
            completed_count=$(sed -n "/^### $dev/,/^### /p" .vybe/backlog.md 2>/dev/null | grep "^- \[x\]" | wc -l)
            active_count=$((assigned_count - completed_count))
            
            if [ $assigned_count -gt 0 ]; then
                echo "   $dev: $assigned_count features ($completed_count done, $active_count active)"
            else
                echo "   $dev: No assignments"
            fi
        done
    else
        echo "[DEV] Solo Developer Mode"
        echo "   Consider: /vybe:backlog member-count 2 for multi-developer coordination"
    fi
    echo ""
    
    # Recent activity
    echo "[ACTIVITY] Recent Activity:"
    if [ -d ".vybe/sessions" ]; then
        recent_sessions=$(ls -t .vybe/sessions/*.json 2>/dev/null | head -3)
        if [ -n "$recent_sessions" ]; then
            echo "$recent_sessions" | while read session_file; do
                if [ -f "$session_file" ]; then
                    session_id=$(basename "$session_file" .json)
                    task_id=$(grep '"task_id"' "$session_file" | cut -d'"' -f4)
                    status=$(grep '"status"' "$session_file" | cut -d'"' -f4)
                    timestamp=$(grep '"completed"' "$session_file" | cut -d'"' -f4 2>/dev/null || grep '"started"' "$session_file" | cut -d'"' -f4)
                    
                    if [ -n "$task_id" ]; then
                        echo "   - $task_id ($status) - $timestamp"
                    fi
                fi
            done
        else
            echo "   No recent execution sessions"
        fi
    else
        echo "   No execution history yet"
    fi
    echo ""
    
    # Next actions
    echo "[TARGET] Recommended Next Actions:"
    if [ $total_features -eq 0 ]; then
        echo "   1. /vybe:plan [feature-name] - Plan your first feature"
        echo "   2. /vybe:backlog - Set up project backlog"
    elif [ $blocked_features -gt 0 ]; then
        echo "   1. /vybe:status blockers - Review blocked items"
        echo "   2. Resolve blockers before continuing"
    elif [ "$team_configured" = true ]; then
        echo "   1. /vybe:execute my-feature --role=dev-1 - Continue assigned work"
        echo "   2. /vybe:status members - Check member coordination"
    else
        echo "   1. /vybe:execute [next-task] - Continue implementation"
        echo "   2. /vybe:audit - Check project health"
    fi
    echo ""
fi
```

## Task 2: Outcome Progression Status

### Display Outcome Dashboard
```bash
if [ "$scope" = "outcomes" ]; then
    echo "[OUTCOMES] STAGED OUTCOME DASHBOARD"
    echo "================================="
    echo ""
    
    if [ ! -f ".vybe/project/outcomes.md" ]; then
        echo "[NO] Outcome roadmap not configured"
        echo ""
        echo "To enable outcome-driven development:"
        echo "   /vybe:init [project] - Set up staged outcomes"
        echo ""
        exit 0
    fi
    
    # Load outcome data
    current_stage=$(grep "Active Stage:" .vybe/backlog.md 2>/dev/null | sed 's/.*: Stage //' | sed 's/ -.*//')
    total_stages=$(grep "^### Stage" .vybe/project/outcomes.md | wc -l)
    completed_stages=$(grep "COMPLETED" .vybe/backlog.md | grep "^### Stage" | wc -l)
    
    echo "[ROADMAP] Outcome Progression:"
    echo ""
    
    # Visual progress indicator
    echo "Progress: "
    for i in $(seq 1 $total_stages); do
        if [ $i -le $completed_stages ]; then
            echo -n "[✅] "
        elif [ $i -eq $((completed_stages + 1)) ]; then
            echo -n "[🔄] "
        else
            echo -n "[⏳] "
        fi
    done
    echo ""
    echo ""
    
    # Stage details
    echo "[STAGES] Detailed Status:"
    echo ""
    
    # Show each stage with status
    stage_num=1
    while IFS= read -r line; do
        if [[ "$line" =~ ^###\ Stage ]]; then
            stage_name=$(echo "$line" | sed 's/### Stage [0-9]*: //' | sed 's/ .*//')
            
            if [ $stage_num -le $completed_stages ]; then
                status="✅ COMPLETED"
                echo "Stage $stage_num: $stage_name - $status"
                
                # Show completion details from learning log
                completion_date=$(grep -A 2 "Stage $stage_num Completion" .vybe/project/outcomes.md | grep "Date:" | sed 's/.*: //')
                if [ -n "$completion_date" ]; then
                    echo "   Completed: $completion_date"
                fi
            elif [ $stage_num -eq $((completed_stages + 1)) ]; then
                status="🔄 IN PROGRESS"
                echo "Stage $stage_num: $stage_name - $status"
                
                # Show current progress
                tasks_done=$(grep -A 20 "Stage $stage_num" .vybe/backlog.md | grep "^\- \[x\]" | wc -l)
                tasks_total=$(grep -A 20 "Stage $stage_num" .vybe/backlog.md | grep "^\- \[.\]" | wc -l)
                if [ $tasks_total -gt 0 ]; then
                    echo "   Tasks: $tasks_done/$tasks_total completed"
                fi
                
                # Show timeline
                timeline=$(grep -A 5 "Stage $stage_num" .vybe/project/outcomes.md | grep "Timeline:" | sed 's/.*: //')
                if [ -n "$timeline" ]; then
                    echo "   Timeline: $timeline"
                fi
            else
                status="⏳ PLANNED"
                echo "Stage $stage_num: $stage_name - $status"
                
                # Show dependencies
                deps=$(grep -A 10 "Stage $stage_num" .vybe/project/outcomes.md | grep "Dependencies:" | sed 's/.*: //')
                if [ -n "$deps" ]; then
                    echo "   Depends on: $deps"
                fi
            fi
            
            # Show deliverable
            deliverable=$(grep -A 3 "Stage $stage_num" .vybe/project/outcomes.md | grep "Deliverable:" | sed 's/.*: //')
            if [ -n "$deliverable" ]; then
                echo "   Deliverable: $deliverable"
            fi
            
            echo ""
            stage_num=$((stage_num + 1))
        fi
    done < .vybe/project/outcomes.md
    
    # Value delivered summary
    echo "[VALUE] Delivered So Far:"
    if [ $completed_stages -gt 0 ]; then
        echo "   ✅ $completed_stages stages completed"
        echo "   📦 $completed_stages working deliverables shipped"
        echo "   🎯 Incremental value delivered at each stage"
    else
        echo "   Starting Stage 1 - First minimal outcome"
    fi
    echo ""
    
    # Next actions
    echo "[NEXT] Recommended Actions:"
    if [ $completed_stages -lt $total_stages ]; then
        current_stage_name=$(grep -A 1 "IN PROGRESS" .vybe/backlog.md | head -1 | sed 's/.*: //' | sed 's/ .*//')
        echo "   Continue Stage $((completed_stages + 1)): $current_stage_name"
        echo "   /vybe:execute [task] - Work on current stage"
        echo "   /vybe:release - Mark stage complete when done"
    else
        echo "   All planned stages completed!"
        echo "   Consider adding new stages to outcomes.md"
    fi
    echo ""
fi
```

## Task 3: Member Status and Coordination

### Display Member Dashboard
```bash
if [ "$scope" = "members" ]; then
    echo "[MEMBERS] MEMBER STATUS DASHBOARD"
    echo "========================"
    echo ""
    
    if [ "$members_configured" = false ]; then
        echo "[NO] No members configured"
        echo ""
        echo "To enable multi-developer features:"
        echo "   /vybe:backlog member-count 2    # Set up 2-developer project"
        echo "   /vybe:backlog assign [feature] dev-1  # Assign features"
        echo ""
        exit 0
    fi
    
    echo "[MEMBERS] Project: $member_count Developer(s)"
    echo ""
    
    # Member workload analysis
    total_assigned=0
    total_completed=0
    
    for dev in "${developers[@]}"; do
        echo "### $dev"
        echo ""
        
        # Get assignments from backlog
        dev_section=$(sed -n "/^### $dev/,/^### /p" .vybe/backlog.md 2>/dev/null)
        assigned_features=$(echo "$dev_section" | grep "^- \[" | wc -l)
        completed_features=$(echo "$dev_section" | grep "^- \[x\]" | wc -l)
        active_features=$((assigned_features - completed_features))
        
        total_assigned=$((total_assigned + assigned_features))
        total_completed=$((total_completed + completed_features))
        
        if [ $assigned_features -gt 0 ]; then
            dev_progress=$((completed_features * 100 / assigned_features))
            
            # Progress bar for developer
            dev_progress_bar=""
            dev_filled=$((dev_progress / 10))  # Each block represents 10%
            for i in $(seq 1 10); do
                if [ $i -le $dev_filled ]; then
                    dev_progress_bar="${dev_progress_bar}="
                else
                    dev_progress_bar="${dev_progress_bar}-"
                fi
            done
            
            echo "   Progress: $dev_progress_bar $dev_progress%"
            echo "   Features: $assigned_features assigned ($completed_features done, $active_features active)"
            echo ""
            
            # List assigned features
            echo "   Assigned Features:"
            echo "$dev_section" | grep "^- \[" | while read feature_line; do
                if echo "$feature_line" | grep -q "^- \[x\]"; then
                    feature_name=$(echo "$feature_line" | sed 's/^- \[x\] //' | sed 's/ .*//')
                    echo "      [OK] $feature_name (completed)"
                elif echo "$feature_line" | grep -q "^- \[~\]"; then
                    feature_name=$(echo "$feature_line" | sed 's/^- \[~\] //' | sed 's/ .*//')
                    echo "      [ACTIVE] $feature_name (in progress)"
                else
                    feature_name=$(echo "$feature_line" | sed 's/^- \[ \] //' | sed 's/ .*//')
                    echo "      [PENDING] $feature_name (not started)"
                fi
            done
            
            # Check for recent activity
            recent_activity=""
            if [ -d ".vybe/sessions" ]; then
                recent_activity=$(grep -l "\"task_id\":.*\"$dev\"" .vybe/sessions/*.json 2>/dev/null | head -1)
                if [ -n "$recent_activity" ]; then
                    last_task=$(grep '"task_id"' "$recent_activity" | cut -d'"' -f4)
                    last_time=$(grep '"completed"' "$recent_activity" | cut -d'"' -f4 2>/dev/null)
                    if [ -n "$last_time" ]; then
                        echo "      Last activity: $last_task ($last_time)"
                    fi
                fi
            fi
            
        else
            echo "   [NONE] No features assigned"
            echo "   Next: /vybe:backlog assign [feature] $dev"
        fi
        echo ""
    done
    
    # Member coordination summary
    echo "### Member Coordination"
    echo ""
    
    if [ $total_assigned -gt 0 ]; then
        team_progress=$((total_completed * 100 / total_assigned))
        echo "   Overall member progress: $team_progress%"
        echo "   Total features assigned: $total_assigned"
        echo "   Member completion rate: $total_completed/$total_assigned"
    else
        echo "   No features assigned to members yet"
    fi
    echo ""
    
    # Workload balance analysis
    echo "### Workload Balance"
    max_assigned=0
    min_assigned=999
    
    for dev in "${developers[@]}"; do
        dev_assigned=$(sed -n "/^### $dev/,/^### /p" .vybe/backlog.md 2>/dev/null | grep "^- \[" | wc -l)
        if [ $dev_assigned -gt $max_assigned ]; then
            max_assigned=$dev_assigned
        fi
        if [ $dev_assigned -lt $min_assigned ]; then
            min_assigned=$dev_assigned
        fi
    done
    
    workload_variance=$((max_assigned - min_assigned))
    
    if [ $workload_variance -le 1 ]; then
        echo "   [OK] Well balanced workload (variance: $workload_variance)"
    elif [ $workload_variance -le 2 ]; then
        echo "   [WARN] Moderate workload imbalance (variance: $workload_variance)"
        echo "   Consider redistribution if needed"
    else
        echo "   [NO] Significant workload imbalance (variance: $workload_variance)"
        echo "   Recommendation: /vybe:backlog assign [feature] [less-busy-dev]"
    fi
    echo ""
    
    # Member coordination commands
    echo "### Member Commands"
    echo ""
    echo "   Individual work:"
    for dev in "${developers[@]}"; do
        echo "   - $dev: /vybe:execute my-feature --role=$dev"
    done
    echo ""
    echo "   Member management:"
    echo "   - /vybe:backlog assign [feature] [dev-N] - Reassign features"
    echo "   - /vybe:status my-work --role=[dev-N] - Check specific developer"
    echo "   - /vybe:audit --scope=dependencies - Check member coordination"
    echo ""
fi
```

## Task 3: Personal Work Status (Role-Aware)

### Display Individual Developer Status
```bash
# Check if scope is dev-N pattern or my-work
if [ "$scope" = "my-work" ] || [[ "$scope" =~ ^dev-[1-5]$ ]]; then
    echo "[PERSONAL] MY WORK STATUS"
    echo "==================="
    echo ""
    
    # Determine developer role
    developer_role=""
    
    # If scope is dev-N pattern, use that directly
    if [[ "$scope" =~ ^dev-[1-5]$ ]]; then
        developer_role="$scope"
    else
        # Check for explicit --role parameter
        for arg in "$@"; do
            if [[ "$arg" =~ ^--role=dev-[1-5]$ ]]; then
                developer_role="$(echo "$arg" | cut -d= -f2)"
                break
            fi
        done
        
        # If no explicit role, try environment variable
        if [ -z "$developer_role" ] && [ -n "$VYBE_MEMBER" ]; then
            developer_role="$VYBE_MEMBER"
        fi
    fi
    
    # If still no role, prompt or error
    if [ -z "$developer_role" ]; then
        if [ "$team_configured" = true ]; then
            echo "Which developer role are you?"
            echo "Available roles:"
            grep "^### dev-" .vybe/backlog.md | sed 's/^### /   /'
            echo ""
            echo "Usage: /vybe:status my-work --role=dev-1"
            echo "   Or: export VYBE_MEMBER=dev-1"
        else
            echo "[INFO] No members configured - showing solo developer status"
            developer_role="solo"
        fi
    fi
    
    if [ -z "$developer_role" ]; then
        exit 1
    fi
    
    echo "[DEV] Developer: $developer_role"
    echo ""
    
    if [ "$developer_role" = "solo" ] || [ "$team_configured" = false ]; then
        # Solo developer mode
        echo "### Solo Developer Status"
        echo ""
        echo "   Mode: Individual development"
        echo "   Total features: $total_features"
        echo "   Progress: $progress_percent%"
        echo ""
        
        if [ $total_features -gt 0 ]; then
            echo "   Current features:"
            for feature_dir in .vybe/features/*/; do
                if [ -d "$feature_dir" ]; then
                    feature_name=$(basename "$feature_dir")
                    
                    # Check feature status
                    if [ -f "$feature_dir/status.md" ]; then
                        feature_status=$(grep "Status:" "$feature_dir/status.md" | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')
                        echo "      - $feature_name: $feature_status"
                    else
                        echo "      - $feature_name: Planning phase"
                    fi
                fi
            done
        else
            echo "   No features planned yet"
            echo "   Next: /vybe:plan [feature-name]"
        fi
        
    else
        # Member status
        if ! grep -q "^### $developer_role" .vybe/backlog.md 2>/dev/null; then
            echo "[NO] Developer role $developer_role not found in members"
            echo "Available developers:"
            grep "^### dev-" .vybe/backlog.md | sed 's/^### /   /'
            exit 1
        fi
        
        echo "### My Assignments"
        echo ""
        
        # Get my assignments
        my_section=$(sed -n "/^### $developer_role/,/^### /p" .vybe/backlog.md 2>/dev/null)
        my_features=$(echo "$my_section" | grep "^- \[" | wc -l)
        my_completed=$(echo "$my_section" | grep "^- \[x\]" | wc -l)
        my_active=$((my_features - my_completed))
        
        if [ $my_features -gt 0 ]; then
            my_progress=$((my_completed * 100 / my_features))
            
            # My progress bar
            my_progress_bar=""
            my_filled=$((my_progress / 5))  # Each block represents 5%
            for i in $(seq 1 20); do
                if [ $i -le $my_filled ]; then
                    my_progress_bar="${my_progress_bar}="
                else
                    my_progress_bar="${my_progress_bar}-"
                fi
            done
            
            echo "   Progress: $my_progress_bar $my_progress%"
            echo "   Features: $my_features assigned ($my_completed completed, $my_active active)"
            echo ""
            
            # List my features with detailed status
            echo "   My Features:"
            echo "$my_section" | grep "^- \[" | while read feature_line; do
                if echo "$feature_line" | grep -q "^- \[x\]"; then
                    feature_name=$(echo "$feature_line" | sed 's/^- \[x\] //' | sed 's/ .*//')
                    echo "      [OK] $feature_name (completed)"
                elif echo "$feature_line" | grep -q "^- \[~\]"; then
                    feature_name=$(echo "$feature_line" | sed 's/^- \[~\] //' | sed 's/ .*//')
                    
                    # Get detailed task status for in-progress features
                    if [ -f ".vybe/features/$feature_name/status.md" ]; then
                        task_progress=$(grep "Progress:" ".vybe/features/$feature_name/status.md" | grep -o "[0-9]*%" | head -1)
                        current_task=$(grep -A 5 "Current.*Sprint" ".vybe/features/$feature_name/status.md" | grep "->" | sed 's/.*-> //' | head -1)
                        
                        echo "      [ACTIVE] $feature_name (in progress: ${task_progress:-unknown})"
                        if [ -n "$current_task" ]; then
                            echo "         Current task: $current_task"
                        fi
                    else
                        echo "      [ACTIVE] $feature_name (in progress)"
                    fi
                else
                    feature_name=$(echo "$feature_line" | sed 's/^- \[ \] //' | sed 's/ .*//')
                    echo "      [PENDING] $feature_name (not started)"
                    
                    # Check if feature is planned
                    if [ -f ".vybe/features/$feature_name/requirements.md" ]; then
                        echo "         Ready to start: /vybe:execute my-feature"
                    else
                        echo "         Needs planning: /vybe:plan $feature_name"
                    fi
                fi
            done
            echo ""
            
            # Next action recommendation
            echo "### Next Actions for $developer_role"
            next_feature=$(echo "$my_section" | grep "^- \[ \]" | head -1 | sed 's/^- \[ \] //' | sed 's/ .*//')
            current_feature=$(echo "$my_section" | grep "^- \[~\]" | head -1 | sed 's/^- \[~\] //' | sed 's/ .*//')
            
            if [ -n "$current_feature" ]; then
                echo "   Continue current work:"
                echo "   - /vybe:execute my-feature --role=$developer_role"
                echo "   - Feature: $current_feature"
            elif [ -n "$next_feature" ]; then
                echo "   Start next assignment:"
                echo "   - /vybe:execute my-feature --role=$developer_role"
                echo "   - Feature: $next_feature"
            else
                echo "   All assignments completed! [DONE]"
                echo "   - Check with project lead for new assignments"
                echo "   - Or: /vybe:status members"
            fi
            
        else
            echo "   [NONE] No features assigned to $developer_role"
            echo ""
            echo "   Next steps:"
            echo "   - Check member assignments: /vybe:status members"
            echo "   - Request assignment from project lead"
            echo "   - Or assign yourself: /vybe:backlog assign [feature] $developer_role"
        fi
    fi
    echo ""
fi
```

## Task 4: Feature-Specific Status

### Display Detailed Feature Progress
```bash
if [ "$scope" != "overall" ] && [ "$scope" != "members" ] && [ "$scope" != "my-work" ] && [ "$scope" != "blockers" ] && [ "$scope" != "releases" ] && ! [[ "$scope" =~ ^dev-[1-5]$ ]]; then
    # Assume scope is a feature name
    feature_name="$scope"
    feature_dir=".vybe/features/$feature_name"
    
    echo "[FEATURE] FEATURE STATUS: $feature_name"
    echo "=========================="
    echo ""
    
    if [ ! -d "$feature_dir" ]; then
        echo "[NO] Feature '$feature_name' not found"
        echo ""
        echo "Available features:"
        if [ -d ".vybe/features" ]; then
            ls .vybe/features/ | sed 's/^/   /'
        else
            echo "   No features planned yet"
        fi
        echo ""
        echo "Create feature: /vybe:plan $feature_name \"[description]\""
        exit 1
    fi
    
    echo "[FEATURE] Feature: $feature_name"
    echo ""
    
    # Feature assignment
    if [ "$team_configured" = true ] && [ -f ".vybe/backlog.md" ]; then
        assigned_to=$(grep -B 10 -A 0 ".*$feature_name.*" .vybe/backlog.md | grep "^### dev-" | tail -1 | sed 's/^### //' | sed 's/ .*//')
        if [ -n "$assigned_to" ]; then
            echo "[DEV] Assigned to: $assigned_to"
        else
            echo "[DEV] Not assigned yet"
        fi
    fi
    
    # Feature status from status.md
    if [ -f "$feature_dir/status.md" ]; then
        echo ""
        echo "### Current Status"
        
        # Extract key status information
        feature_status=$(grep "Status:" "$feature_dir/status.md" | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')
        feature_progress=$(grep "Progress:" "$feature_dir/status.md" | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')
        current_sprint=$(grep "Current Sprint:" "$feature_dir/status.md" | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')
        
        echo "   Status: ${feature_status:-Unknown}"
        echo "   Progress: ${feature_progress:-Unknown}"
        echo "   Current Sprint: ${current_sprint:-Not started}"
        echo ""
        
        # Sprint progress
        if [ -f "$feature_dir/tasks.md" ]; then
            echo "### Task Progress"
            
            total_tasks=$(grep -c "^- \[" "$feature_dir/tasks.md")
            completed_tasks=$(grep -c "^- \[x\]" "$feature_dir/tasks.md")
            active_tasks=$(grep -c "^- \[~\]" "$feature_dir/tasks.md")
            pending_tasks=$((total_tasks - completed_tasks - active_tasks))
            
            if [ $total_tasks -gt 0 ]; then
                task_progress=$((completed_tasks * 100 / total_tasks))
                
                # Task progress bar
                task_progress_bar=""
                task_filled=$((task_progress / 5))  # Each block represents 5%
                for i in $(seq 1 20); do
                    if [ $i -le $task_filled ]; then
                        task_progress_bar="${task_progress_bar}="
                    else
                        task_progress_bar="${task_progress_bar}-"
                    fi
                done
                
                echo "   Tasks: $task_progress_bar $task_progress%"
                echo "   Total: $total_tasks tasks ($completed_tasks done, $active_tasks active, $pending_tasks pending)"
                echo ""
                
                # Current tasks
                if [ $active_tasks -gt 0 ]; then
                    echo "   [ACTIVE] Active Tasks:"
                    grep -n "^- \[~\]" "$feature_dir/tasks.md" | head -3 | while read task_line; do
                        task_num=$(echo "$task_line" | cut -d: -f1)
                        task_desc=$(echo "$task_line" | cut -d: -f2- | sed 's/^- \[~\] [0-9]*\. //')
                        echo "      $task_num. $task_desc"
                    done
                    echo ""
                fi
                
                # Next tasks
                if [ $pending_tasks -gt 0 ]; then
                    echo "   [PENDING] Next Tasks:"
                    grep -n "^- \[ \]" "$feature_dir/tasks.md" | head -3 | while read task_line; do
                        task_num=$(echo "$task_line" | cut -d: -f1)
                        task_desc=$(echo "$task_line" | cut -d: -f2- | sed 's/^- \[ \] [0-9]*\. //')
                        echo "      $task_num. $task_desc"
                    done
                    echo ""
                fi
                
            else
                echo "   No tasks found in tasks.md"
            fi
        else
            echo "   [WARN] No tasks.md found - feature may not be fully planned"
        fi
        
        # Recent activity
        echo "### Recent Activity"
        if [ -d ".vybe/sessions" ]; then
            feature_sessions=$(grep -l "\"task_id\":.*\"$feature_name-" .vybe/sessions/*.json 2>/dev/null | head -3)
            if [ -n "$feature_sessions" ]; then
                echo "$feature_sessions" | while read session_file; do
                    if [ -f "$session_file" ]; then
                        task_id=$(grep '"task_id"' "$session_file" | cut -d'"' -f4)
                        status=$(grep '"status"' "$session_file" | cut -d'"' -f4)
                        timestamp=$(grep '"completed"' "$session_file" | cut -d'"' -f4 2>/dev/null || grep '"started"' "$session_file" | cut -d'"' -f4)
                        session_id=$(basename "$session_file" .json)
                        
                        echo "   - $task_id ($status) - $timestamp"
                    fi
                done
            else
                echo "   No recent execution sessions for this feature"
            fi
        else
            echo "   No execution history available"
        fi
        
    else
        echo "[WARN] No status.md found - feature may be in planning phase"
        
        # Check what's available
        echo ""
        echo "### Available Documents"
        if [ -f "$feature_dir/requirements.md" ]; then
            echo "   [OK] requirements.md"
        else
            echo "   [NO] requirements.md"
        fi
        
        if [ -f "$feature_dir/design.md" ]; then
            echo "   [OK] design.md"
        else
            echo "   [NO] design.md"
        fi
        
        if [ -f "$feature_dir/tasks.md" ]; then
            echo "   [OK] tasks.md"
        else
            echo "   [NO] tasks.md"
        fi
        
        echo ""
        echo "   Next: Complete feature planning with /vybe:plan $feature_name"
    fi
    
    # Next actions for this feature
    echo ""
    echo "### Next Actions"
    if [ -f "$feature_dir/tasks.md" ]; then
        next_task_line=$(grep "^- \[ \]" "$feature_dir/tasks.md" | head -1)
        active_task_line=$(grep "^- \[~\]" "$feature_dir/tasks.md" | head -1)
        
        if [ -n "$active_task_line" ]; then
            task_num=$(echo "$active_task_line" | sed 's/.*\([0-9]*\)\..*/\1/')
            echo "   Continue: /vybe:execute $feature_name-task-$task_num"
        elif [ -n "$next_task_line" ]; then
            task_num=$(echo "$next_task_line" | sed 's/.*\([0-9]*\)\..*/\1/')
            echo "   Start: /vybe:execute $feature_name-task-$task_num"
        else
            echo "   All tasks completed! [OK]"
        fi
        
        if [ "$team_configured" = true ] && [ -n "$assigned_to" ]; then
            echo "   Assigned developer: /vybe:execute my-feature --role=$assigned_to"
        fi
    else
        echo "   Plan tasks: /vybe:plan $feature_name"
    fi
    echo ""
fi
```

## Task 5: Blockers and Dependencies Status

### Show Current Blockers
```bash
if [ "$scope" = "blockers" ]; then
    echo "[BLOCKERS] CURRENT BLOCKERS AND DEPENDENCIES"
    echo "=================================="
    echo ""
    
    blockers_found=false
    
    # Check for blocked features in backlog
    if [ -f ".vybe/backlog.md" ]; then
        blocked_features=$(grep "\[!\]" .vybe/backlog.md 2>/dev/null)
        if [ -n "$blocked_features" ]; then
            echo "### Blocked Features (from backlog)"
            echo "$blocked_features" | while read blocked_line; do
                feature_name=$(echo "$blocked_line" | sed 's/^- \[!\] //' | sed 's/ .*//')
                blocker_reason=$(echo "$blocked_line" | sed 's/.*) - //' | sed 's/ .*//')
                echo "   [NO] $feature_name: $blocker_reason"
            done
            echo ""
            blockers_found=true
        fi
    fi
    
    # Check for blocked tasks in feature status files
    echo "### Blocked Tasks (from features)"
    for feature_dir in .vybe/features/*/; do
        if [ -d "$feature_dir" ]; then
            feature_name=$(basename "$feature_dir")
            
            if [ -f "$feature_dir/status.md" ]; then
                # Check for blocked status
                if grep -q -i "blocked\|blocker" "$feature_dir/status.md"; then
                    blocker_info=$(grep -i "blocked\|blocker" "$feature_dir/status.md" | head -1)
                    echo "   [NO] $feature_name: $blocker_info"
                    blockers_found=true
                fi
            fi
            
            # Check for blocked tasks in tasks.md
            if [ -f "$feature_dir/tasks.md" ]; then
                blocked_tasks=$(grep "\[!\]" "$feature_dir/tasks.md" 2>/dev/null)
                if [ -n "$blocked_tasks" ]; then
                    echo "   Feature: $feature_name"
                    echo "$blocked_tasks" | while read blocked_task; do
                        task_desc=$(echo "$blocked_task" | sed 's/^- \[!\] [0-9]*\. //')
                        echo "      [NO] $task_desc"
                    done
                    blockers_found=true
                fi
            fi
        fi
    done
    
    if [ "$blockers_found" = false ]; then
        echo "   [OK] No blockers found!"
        echo ""
    else
        echo ""
    fi
    
    # Dependency analysis
    echo "### Dependency Analysis"
    dependencies_found=false
    
    for feature_dir in .vybe/features/*/; do
        if [ -d "$feature_dir" ]; then
            feature_name=$(basename "$feature_dir")
            
            # Check for dependency mentions in requirements or design
            if [ -f "$feature_dir/requirements.md" ]; then
                deps=$(grep -i "depend\|require\|prerequisite" "$feature_dir/requirements.md" 2>/dev/null)
                if [ -n "$deps" ]; then
                    echo "   Feature: $feature_name"
                    echo "      Dependencies mentioned in requirements"
                    dependencies_found=true
                fi
            fi
            
            if [ -f "$feature_dir/design.md" ]; then
                deps=$(grep -i "depend\|require\|prerequisite" "$feature_dir/design.md" 2>/dev/null)
                if [ -n "$deps" ]; then
                    if [ "$dependencies_found" = false ]; then
                        echo "   Feature: $feature_name"
                    fi
                    echo "      Dependencies mentioned in design"
                    dependencies_found=true
                fi
            fi
        fi
    done
    
    if [ "$dependencies_found" = false ]; then
        echo "   [INFO] No explicit dependencies documented"
    fi
    echo ""
    
    # Recommendations
    echo "### Recommendations"
    if [ "$blockers_found" = true ]; then
        echo "   1. Resolve blockers before continuing with affected features"
        echo "   2. Consider reassigning work to unblocked developers"
        echo "   3. Update project timeline if needed"
    else
        echo "   [OK] No blockers - project can proceed normally"
    fi
    
    if [ "$dependencies_found" = true ]; then
        echo "   - Run /vybe:audit --scope=dependencies for detailed analysis"
    fi
    echo ""
fi
```

## Success Output

### Status Summary Complete
```bash
echo ""
echo "[COMPLETE] STATUS CHECK COMPLETE"
echo "========================"
echo ""

case $scope in
    "overall")
        echo "[OK] **Project Status Dashboard Displayed**"
        echo "   - Overall progress: $progress_percent%"
        echo "   - Features: $total_features total ($completed_features completed)"
        if [ "$team_configured" = true ]; then
            echo "   - Members: $team_size developers configured"
        fi
        ;;
    "members")
        if [ "$team_configured" = true ]; then
            echo "[OK] **Member Status Dashboard Displayed**"
            echo "   - Member count: $team_size developers"
            echo "   - Workload balance analysis completed"
            echo "   - Individual progress tracked"
        fi
        ;;
    "my-work")
        echo "[OK] **Personal Work Status Displayed**"
        if [ -n "$developer_role" ] && [ "$developer_role" != "solo" ]; then
            echo "   - Developer: $developer_role"
            echo "   - Personal assignments and progress shown"
        else
            echo "   - Solo developer mode"
        fi
        ;;
    "blockers")
        echo "[OK] **Blockers and Dependencies Analysis Complete**"
        if [ "$blockers_found" = true ]; then
            echo "   - Blockers identified - requires attention"
        else
            echo "   - No blockers found - clear to proceed"
        fi
        ;;
    *)
        echo "[OK] **Feature Status Displayed**"
        echo "   - Feature: $scope"
        echo "   - Detailed progress and next actions provided"
        ;;
esac

echo ""
echo "[TARGET] **Next Steps Available:**"
echo "   - /vybe:execute [task] - Continue implementation"
echo "   - /vybe:discuss \"[question]\" - Get guidance"
echo "   - /vybe:audit - Check project health"
echo ""
```

## Error Handling

### Common Error Cases  
```bash
# Project not initialized
if [ ! -d ".vybe/project" ]; then
    echo "[NO] ERROR: Project not initialized"
    echo "   Run: /vybe:init first"
    exit 1
fi

# Invalid scope
valid_scopes="overall members dev-N my-work blockers releases [feature-name]"
if [[ ! "$scope" =~ ^(overall|members|my-work|blockers|releases|dev-[1-5])$ ]] && [ ! -d ".vybe/features/$scope" ]; then
    echo "[NO] ERROR: Invalid scope '$scope'"
    echo "   Valid scopes: $valid_scopes"
    exit 1
fi

# Role not found (for my-work or dev-N)
if ([ "$scope" = "my-work" ] || [[ "$scope" =~ ^dev-[1-5]$ ]]) && [ -n "$developer_role" ] && [ "$developer_role" != "solo" ]; then
    if [ "$team_configured" = true ] && ! grep -q "^### $developer_role" .vybe/backlog.md; then
        echo "[NO] ERROR: Developer role $developer_role not found"
        echo "   Available roles:"
        grep "^### dev-" .vybe/backlog.md | sed 's/^### /   /'
        exit 1
    fi
fi
```

## AI Implementation Guidelines

### Status Aggregation
1. **Load complete context** - All project documents, members, backlog, features
2. **Calculate real metrics** - Based on actual file states, not estimates  
3. **Member awareness** - Show assignments, workload balance, coordination
4. **Git integration** - Track progress from commits and sessions
5. **Actionable output** - Always provide specific next steps

### Multi-Session Coordination
- Read status from shared files (backlog.md, status.md files)
- Show progress from all developer sessions
- Display member coordination and workload balance
- Provide role-specific recommendations

### Visual Progress Display
- Use progress bars for visual representation
- Color-coded status indicators ([OK][NO][ACTIVE][PENDING])
- Clear metrics and percentages
- Member workload balance analysis

This `/vybe:status` command provides comprehensive project visibility with member coordination awareness, making it easy to track progress across multiple developers and sessions.