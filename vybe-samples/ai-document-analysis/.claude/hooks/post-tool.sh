#!/bin/bash
# Vybe Post-Tool Hook - Context State Management
# This runs after every Claude Code tool execution

set -e

VYBE_ROOT=".vybe"
CONTEXT_DIR="$VYBE_ROOT/context"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"

# Ensure context directories exist
mkdir -p "$CONTEXT_DIR/sessions"
mkdir -p "$CONTEXT_DIR/tasks"
mkdir -p "$CONTEXT_DIR/dependencies"

# Update session state
SESSION_FILE="$CONTEXT_DIR/sessions/session-$SESSION_ID.json"
if [ -f "$SESSION_FILE" ]; then
    # Create temp file for updated session
    TEMP_FILE=$(mktemp)
    
    # Read existing session and add post-hook data
    jq --arg timestamp "$TIMESTAMP" \
       --arg tool_exit_code "${CLAUDE_TOOL_EXIT_CODE:-0}" \
       --arg post_timestamp "$TIMESTAMP" \
       '. + {
         "post_hook_timestamp": $post_timestamp,
         "tool_exit_code": $tool_exit_code,
         "post_hook_completed": true
       }' "$SESSION_FILE" > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$SESSION_FILE"
else
    # Create new session file if pre-hook didn't run
    echo "{" > "$SESSION_FILE"
    echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$SESSION_FILE"
    echo "  \"tool\": \"${CLAUDE_TOOL_NAME:-unknown}\"," >> "$SESSION_FILE"
    echo "  \"session_id\": \"$SESSION_ID\"," >> "$SESSION_FILE"
    echo "  \"post_hook_only\": true," >> "$SESSION_FILE"
    echo "  \"post_hook_completed\": true" >> "$SESSION_FILE"
    echo "}" >> "$SESSION_FILE"
fi

# Update git state if available
if [ -d ".git" ]; then
    git status --porcelain > "$CONTEXT_DIR/sessions/git-status-post-$SESSION_ID.txt"
    
    # Check if there are changes to commit
    if [ -n "$(git status --porcelain)" ]; then
        echo "Git changes detected after tool execution" >> "$CONTEXT_DIR/session.log"
    fi
fi

# Update task status if this was a task delegation
if [[ "${CLAUDE_TOOL_NAME:-}" == *"task-delegate"* ]] || [[ "${CLAUDE_TOOL_NAME:-}" == *"task-continue"* ]]; then
    # Extract task info from tool args if available
    TASK_INFO="${CLAUDE_TOOL_ARGS:-}"
    if [ -n "$TASK_INFO" ]; then
        echo "[$TIMESTAMP] TASK-UPDATE: $TASK_INFO completed" >> "$CONTEXT_DIR/task-updates.log"
    fi
fi

# Update dependency tracking
if [ -f "$CONTEXT_DIR/dependencies/dependency-graph.json" ]; then
    # Check for completed tasks and update dependent tasks
    .claude/hooks/context/update-dependencies.sh 2>/dev/null || true
fi

# Get member info from session file
MEMBER_ROLE="solo"
MEMBER_STATUS="solo_mode"
if [ -f "$SESSION_FILE" ]; then
    MEMBER_ROLE=$(jq -r '.member_role // "solo"' "$SESSION_FILE" 2>/dev/null || echo "solo")
    MEMBER_STATUS=$(jq -r '.member_status // "solo_mode"' "$SESSION_FILE" 2>/dev/null || echo "solo_mode")
fi

# Check for and display conflicts
if [ "$MEMBER_STATUS" = "assigned" ]; then
    CONFLICT_FILE="$CONTEXT_DIR/sessions/member-conflicts-$SESSION_ID.txt"
    if [ -f "$CONFLICT_FILE" ] && [ -s "$CONFLICT_FILE" ]; then
        echo ""
        echo "WARNING: Member coordination conflicts detected:"
        cat "$CONFLICT_FILE"
        echo ""
        echo "Consider coordinating with other team members or using:"
        echo "  /vybe:status members  # Check current member assignments"
        echo "  /vybe:audit members   # Analyze member coordination"
        echo ""
    fi
    
    # Update member-specific log
    echo "[$TIMESTAMP] SESSION-END: Tool=${CLAUDE_TOOL_NAME:-unknown}, Session=$SESSION_ID, Exit=${CLAUDE_TOOL_EXIT_CODE:-0}" >> "$CONTEXT_DIR/members/$MEMBER_ROLE.log"
fi

# Display role warnings
if [ "$MEMBER_STATUS" = "no_role_specified" ]; then
    echo ""
    echo "WARNING: Multiple members configured but no role specified"
    echo "Set your developer role with: export VYBE_MEMBER=dev-1"
    echo "Or use: /vybe:execute my-feature --role=dev-1"
    echo ""
elif [ "$MEMBER_STATUS" = "invalid_role" ]; then
    echo ""
    echo "ERROR: Invalid developer role: $MEMBER_ROLE"
    echo "Valid roles: dev-1, dev-2, dev-3, dev-4, dev-5"
    echo "Set valid role with: export VYBE_MEMBER=dev-1"
    echo ""
fi

# Log to main session log with member info
echo "[$TIMESTAMP] POST-HOOK: Tool=${CLAUDE_TOOL_NAME:-unknown}, Session=$SESSION_ID, Member=$MEMBER_ROLE, Exit=${CLAUDE_TOOL_EXIT_CODE:-0}" >> "$CONTEXT_DIR/session.log"

exit 0