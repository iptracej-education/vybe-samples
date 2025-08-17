#!/bin/bash
# Dependency tracking update script

VYBE_ROOT=".vybe"
CONTEXT_DIR="$VYBE_ROOT/context"
DEPS_FILE="$CONTEXT_DIR/dependencies/dependency-graph.json"

if [ ! -f "$DEPS_FILE" ]; then
    exit 0
fi

# Use the dependency tracker to check for updates
TRACKER_SCRIPT=".claude/hooks/context/dependency-tracker.sh"

if [ -f "$TRACKER_SCRIPT" ]; then
    # Check for circular dependencies
    "$TRACKER_SCRIPT" check-circular >> "$CONTEXT_DIR/dependency-updates.log" 2>&1
    
    # Get all pending tasks and check if they're ready
    while IFS= read -r task; do
        if [ -n "$task" ]; then
            "$TRACKER_SCRIPT" resolve "$task" >> "$CONTEXT_DIR/dependency-updates.log" 2>&1
        fi
    done < <("$TRACKER_SCRIPT" get-by-status "waiting_for_dependencies")
fi

echo "Dependency update check completed at $(date)" >> "$CONTEXT_DIR/dependency-updates.log"

exit 0