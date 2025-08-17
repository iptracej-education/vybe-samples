#!/bin/bash
# Manual Task Pause - Create checkpoint for continuation

REASON="${1:-manual pause}"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SESSION_ID="${CLAUDE_SESSION_ID:-manual-$TIMESTAMP}"

VYBE_ROOT=".vybe"
CONTEXT_DIR="$VYBE_ROOT/context"
MANUAL_DIR="$CONTEXT_DIR/manual"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Task Pause Initiated${NC}"
echo "======================"
echo ""

# Ensure directories exist
mkdir -p "$MANUAL_DIR"

# Get current work context
CURRENT_AGENT="${VYBE_AGENT_TYPE:-unknown}"
CURRENT_TASK="${VYBE_TASK_RANGE:-unknown}"
CURRENT_MODE="${VYBE_CONTEXT_MODE:-manual}"

echo "Current Work:"
echo "- Agent: $CURRENT_AGENT"
echo "- Task: $CURRENT_TASK"
echo "- Reason: $REASON"
echo ""

# Create pause checkpoint
PAUSE_FILE="$MANUAL_DIR/pause-$SESSION_ID.json"

cat > "$PAUSE_FILE" << EOF
{
  "session_id": "$SESSION_ID",
  "timestamp": "$(date -Iseconds)",
  "reason": "$REASON",
  "agent_type": "$CURRENT_AGENT",
  "task_range": "$CURRENT_TASK",
  "context_mode": "$CURRENT_MODE",
  "pause_type": "manual",
  "pwd": "$(pwd)",
  "git_state": {
    "branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
    "commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
    "has_changes": false
  },
  "environment": {
    "VYBE_AGENT_TYPE": "$VYBE_AGENT_TYPE",
    "VYBE_TASK_RANGE": "$VYBE_TASK_RANGE",
    "VYBE_CONTEXT_MODE": "$VYBE_CONTEXT_MODE"
  }
}
EOF

# Handle git state
echo "Git Status:"
if [ -d ".git" ]; then
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
        
        # Ask user preference or auto-commit
        read -p "Commit changes before pause? [Y/n]: " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            # Save diff without committing
            git diff > "$MANUAL_DIR/diff-$SESSION_ID.patch"
            git status --porcelain > "$MANUAL_DIR/status-$SESSION_ID.txt"
            echo "✓ Changes saved as diff (not committed)"
        else
            # Commit changes
            git add -A
            COMMIT_MSG="WIP: $REASON (session $SESSION_ID)"
            git commit -m "$COMMIT_MSG"
            echo -e "${GREEN}✓ Changes committed: \"$COMMIT_MSG\"${NC}"
            
            # Update pause file to reflect commit
            jq '.git_state.has_changes = false | .git_state.committed = true' "$PAUSE_FILE" > "$PAUSE_FILE.tmp"
            mv "$PAUSE_FILE.tmp" "$PAUSE_FILE"
        fi
    else
        echo -e "${GREEN}✓ No uncommitted changes${NC}"
    fi
else
    echo "ℹ️  Not a git repository"
fi

echo ""

# Save current working files list
find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.md" 2>/dev/null | \
    grep -v node_modules | grep -v .git | head -20 > "$MANUAL_DIR/working-files-$SESSION_ID.txt"

# Create continuation instructions
INSTRUCTIONS_FILE="$MANUAL_DIR/continue-$SESSION_ID.md"

cat > "$INSTRUCTIONS_FILE" << EOF
# Resume Work Instructions

## Session Details
- **Session ID**: $SESSION_ID
- **Paused**: $(date)
- **Reason**: $REASON
- **Agent**: $CURRENT_AGENT
- **Task**: $CURRENT_TASK

## To Resume

\`\`\`bash
/vybe:task-continue $CURRENT_AGENT $CURRENT_TASK $SESSION_ID
\`\`\`

## Context Location
- Pause file: \`.vybe/context/manual/pause-$SESSION_ID.json\`
- Instructions: \`.vybe/context/manual/continue-$SESSION_ID.md\`
$([ -f "$MANUAL_DIR/diff-$SESSION_ID.patch" ] && echo "- Git diff: \`.vybe/context/manual/diff-$SESSION_ID.patch\`")

## Current State
$(git log --oneline -n 3 2>/dev/null || echo "No git history available")

Ready to exit session safely.
EOF

# Display results
echo -e "${GREEN}Task Paused Successfully${NC}"
echo "========================"
echo ""
echo "Context Saved:"
echo "- Pause file: $PAUSE_FILE"
echo "- Instructions: $INSTRUCTIONS_FILE"
echo ""

if [ "$CURRENT_AGENT" != "unknown" ] && [ "$CURRENT_TASK" != "unknown" ]; then
    echo -e "${YELLOW}To Resume:${NC}"
    echo "/vybe:task-continue $CURRENT_AGENT $CURRENT_TASK $SESSION_ID"
    echo ""
fi

echo "Ready to exit session safely."
echo ""

# Update task status if using dependency tracker
if [ -f ".claude/hooks/context/dependency-tracker.sh" ] && [ "$CURRENT_TASK" != "unknown" ]; then
    .claude/hooks/context/dependency-tracker.sh update-status "$CURRENT_TASK" "paused" "$CURRENT_AGENT" "$SESSION_ID" 2>/dev/null || true
fi

exit 0