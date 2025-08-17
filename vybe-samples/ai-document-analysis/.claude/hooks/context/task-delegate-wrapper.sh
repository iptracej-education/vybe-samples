#!/bin/bash
# Task Delegation Wrapper with Hook Validation

# This script is called by /vybe:task-delegate command
# It validates hooks and uses appropriate context management

AGENT_TYPE="$1"
TASK_RANGE="$2"
DESCRIPTION="$3"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run hook validation silently
.claude/hooks/validate.sh --silent
HOOK_STATUS=$?

# Determine context mode based on validation
if [ $HOOK_STATUS -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Hook system ready - PreCompact protection enabled"
    CONTEXT_MODE="precompact"
elif [ $HOOK_STATUS -eq 1 ]; then
    echo -e "${YELLOW}⚠️${NC} Hook system partial - using fallback mode"
    CONTEXT_MODE="fallback"
    export VYBE_MANUAL_HOOKS=1
else
    echo -e "${RED}⚠️${NC} Hook system unavailable - using manual context management"
    CONTEXT_MODE="manual"
    export VYBE_MANUAL_HOOKS=1
fi

# Inform about PreCompact protection
if [ "$CONTEXT_MODE" = "precompact" ]; then
    echo "📝 PreCompact hook will automatically save context before any /compact"
    echo "   Use '/vybe:task-pause' to manually pause at good stopping points"
fi

# Save context based on mode
save_context() {
    case $CONTEXT_MODE in
        precompact)
            # PreCompact hook will handle automatically
            echo "Context will be saved automatically by PreCompact hook when needed"
            ;;
        fallback|manual)
            # Manual context save
            echo "Saving context manually..."
            
            # Create manual context directory
            mkdir -p .vybe/context/manual
            
            # Save current state
            TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
            SESSION_ID="manual-$TIMESTAMP"
            
            # Save git state
            if [ -d ".git" ]; then
                git status --porcelain > ".vybe/context/manual/git-status-$SESSION_ID.txt"
                git diff > ".vybe/context/manual/git-diff-$SESSION_ID.txt"
                
                # Commit current work
                git add -A 2>/dev/null
                git commit -m "Context save before task delegation: $TASK_RANGE" 2>/dev/null || true
            fi
            
            # Save task info
            echo "{
  \"agent_type\": \"$AGENT_TYPE\",
  \"task_range\": \"$TASK_RANGE\",
  \"description\": \"$DESCRIPTION\",
  \"timestamp\": \"$TIMESTAMP\",
  \"session_id\": \"$SESSION_ID\",
  \"context_mode\": \"$CONTEXT_MODE\"
}" > ".vybe/context/manual/session-$SESSION_ID.json"
            
            echo "Manual context saved to session-$SESSION_ID"
            ;;
    esac
}

# Update task status based on mode
update_task_status() {
    local task="$1"
    local status="$2"
    
    case $CONTEXT_MODE in
        precompact)
            # Dependency tracker will handle
            .claude/hooks/context/dependency-tracker.sh update-status "$task" "$status" "$AGENT_TYPE" "$SESSION_ID"
            ;;
        fallback|manual)
            # Manual status update
            echo "Updating task status manually..."
            
            # Create or update status file
            STATUS_FILE=".vybe/context/manual/task-status.json"
            if [ ! -f "$STATUS_FILE" ]; then
                echo '{}' > "$STATUS_FILE"
            fi
            
            # Update status (simple append for now)
            echo "$(date '+%Y-%m-%d %H:%M:%S'): $task = $status ($AGENT_TYPE)" >> ".vybe/context/manual/task-status.log"
            ;;
    esac
}

# Parse task range and update initial status
parse_and_update_tasks() {
    # Extract feature and task numbers
    # Examples: user-auth-1, user-auth-1-3, user-auth-1,3,5
    
    echo "Processing tasks: $TASK_RANGE"
    
    # For now, just mark as in_progress
    # Full implementation would parse the range properly
    update_task_status "$TASK_RANGE" "in_progress"
}

# Main execution
echo ""
echo "Task Delegation Starting"
echo "========================"
echo "Agent Type: $AGENT_TYPE"
echo "Task Range: $TASK_RANGE"
echo "Description: $DESCRIPTION"
echo "Context Mode: $CONTEXT_MODE"
echo ""

# Save initial context
save_context

# Update task status
parse_and_update_tasks

# Prepare context injection message
echo ""
echo "Context Injection"
echo "================="

# Gather relevant files based on task
echo "Loading task specifications..."
FEATURE=$(echo "$TASK_RANGE" | cut -d'-' -f1-2)
SPEC_DIR=".vybe/specs/$FEATURE"

if [ -d "$SPEC_DIR" ]; then
    echo "✓ Found specifications for $FEATURE"
    
    # Check for required files
    [ -f "$SPEC_DIR/requirements.md" ] && echo "  - requirements.md available"
    [ -f "$SPEC_DIR/design.md" ] && echo "  - design.md available"
    [ -f "$SPEC_DIR/tasks.md" ] && echo "  - tasks.md available"
else
    echo "⚠️ No specifications found for $FEATURE"
fi

# Check dependencies
echo ""
echo "Checking dependencies..."
if [ "$CONTEXT_MODE" = "hooks" ]; then
    .claude/hooks/context/dependency-tracker.sh list-deps "$TASK_RANGE" 2>/dev/null || echo "No dependencies found"
else
    echo "Dependency checking skipped in manual mode"
fi

# Launch message
echo ""
echo "Ready to delegate to $AGENT_TYPE agent"
echo ""
echo "The subagent will:"
echo "1. Receive focused context for $TASK_RANGE"
echo "2. Work within the defined scope"
echo "3. Update progress automatically"
echo "4. Return results to the main session"
echo ""

# Export session info for subagent
export VYBE_AGENT_TYPE="$AGENT_TYPE"
export VYBE_TASK_RANGE="$TASK_RANGE"
export VYBE_CONTEXT_MODE="$CONTEXT_MODE"
export VYBE_SESSION_ID="${SESSION_ID:-$(date +%s)}"

echo "Delegation prepared. Subagent can now be launched."
echo ""

# If in manual mode, provide instructions
if [ "$CONTEXT_MODE" != "hooks" ]; then
    echo "📝 Manual Mode Instructions:"
    echo "1. After subagent completes, commit all changes"
    echo "2. Update task status manually if needed"
    echo "3. Check .vybe/context/manual/ for session details"
    echo ""
fi

# Return success
exit 0