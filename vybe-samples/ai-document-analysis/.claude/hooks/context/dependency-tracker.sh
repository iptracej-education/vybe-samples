#!/bin/bash
# Dependency Tracking System for Vybe Tasks

VYBE_ROOT=".vybe"
CONTEXT_DIR="$VYBE_ROOT/context"
DEPS_FILE="$CONTEXT_DIR/dependencies/dependency-graph.json"

# Ensure dependencies file exists
if [ ! -f "$DEPS_FILE" ]; then
    mkdir -p "$CONTEXT_DIR/dependencies"
    echo '{
  "dependencies": {},
  "tasks": {},
  "last_updated": "'$(date -Iseconds)'",
  "schema_version": "1.0"
}' > "$DEPS_FILE"
fi

# Function to add task dependency
add_dependency() {
    local task="$1"
    local depends_on="$2"
    
    # Update dependency graph using jq
    jq --arg task "$task" \
       --arg dep "$depends_on" \
       '.dependencies[$task] = (.dependencies[$task] // []) + [$dep] | .dependencies[$task] |= unique' \
       "$DEPS_FILE" > "$DEPS_FILE.tmp" && mv "$DEPS_FILE.tmp" "$DEPS_FILE"
    
    echo "Added dependency: $task depends on $depends_on"
}

# Function to remove task dependency
remove_dependency() {
    local task="$1"
    local depends_on="$2"
    
    jq --arg task "$task" \
       --arg dep "$depends_on" \
       '.dependencies[$task] = (.dependencies[$task] // []) - [$dep]' \
       "$DEPS_FILE" > "$DEPS_FILE.tmp" && mv "$DEPS_FILE.tmp" "$DEPS_FILE"
    
    echo "Removed dependency: $task no longer depends on $depends_on"
}

# Function to update task status
update_task_status() {
    local task="$1"
    local status="$2"
    local agent="${3:-unknown}"
    local session="${4:-}"
    local member="${5:-${VYBE_MEMBER:-solo}}"
    
    jq --arg task "$task" \
       --arg status "$status" \
       --arg agent "$agent" \
       --arg session "$session" \
       --arg member "$member" \
       --arg timestamp "$(date -Iseconds)" \
       '.tasks[$task] = {
         "status": $status,
         "agent": $agent,
         "session": $session,
         "member": $member,
         "updated": $timestamp
       }' \
       "$DEPS_FILE" > "$DEPS_FILE.tmp" && mv "$DEPS_FILE.tmp" "$DEPS_FILE"
    
    echo "Updated task status: $task = $status (member: $member)"
    
    # Check for dependency resolution
    resolve_dependencies "$task"
}

# Function to resolve dependencies when a task completes
resolve_dependencies() {
    local completed_task="$1"
    
    # Find tasks waiting for this one
    local waiting_tasks=$(jq -r --arg completed "$completed_task" '
        .dependencies | to_entries[] | select(.value[] == $completed) | .key
    ' "$DEPS_FILE")
    
    # Check each waiting task
    while IFS= read -r waiting_task; do
        if [ -n "$waiting_task" ]; then
            check_task_ready "$waiting_task"
        fi
    done <<< "$waiting_tasks"
}

# Function to check if a task is ready (all dependencies completed)
check_task_ready() {
    local task="$1"
    
    # Get task dependencies
    local deps=$(jq -r --arg task "$task" '.dependencies[$task] // [] | .[]' "$DEPS_FILE")
    
    local all_ready=true
    while IFS= read -r dep; do
        if [ -n "$dep" ]; then
            local dep_status=$(jq -r --arg dep "$dep" '.tasks[$dep].status // "pending"' "$DEPS_FILE")
            if [ "$dep_status" != "completed" ]; then
                all_ready=false
                break
            fi
        fi
    done <<< "$deps"
    
    # Update task status if ready
    if [ "$all_ready" = true ]; then
        local current_status=$(jq -r --arg task "$task" '.tasks[$task].status // "pending"' "$DEPS_FILE")
        if [ "$current_status" = "waiting_for_dependencies" ]; then
            update_task_status "$task" "pending"
            echo "Task $task is now ready (dependencies satisfied)"
        fi
    fi
}

# Function to get task status
get_task_status() {
    local task="$1"
    
    jq -r --arg task "$task" '.tasks[$task].status // "unknown"' "$DEPS_FILE"
}

# Function to list task dependencies
list_dependencies() {
    local task="$1"
    
    if [ -n "$task" ]; then
        jq -r --arg task "$task" '.dependencies[$task] // [] | .[]' "$DEPS_FILE"
    else
        jq -r '.dependencies | to_entries[] | "\(.key): \(.value | join(", "))"' "$DEPS_FILE"
    fi
}

# Function to check for circular dependencies
check_circular_dependencies() {
    # This is a simplified check - a full implementation would use graph algorithms
    echo "Checking for circular dependencies..."
    
    # For now, just report if any task depends on itself
    jq -r '.dependencies | to_entries[] | select(.value[] == .key) | "CIRCULAR: \(.key) depends on itself"' "$DEPS_FILE"
}

# Function to get tasks by status
get_tasks_by_status() {
    local status="$1"
    
    jq -r --arg status "$status" '.tasks | to_entries[] | select(.value.status == $status) | .key' "$DEPS_FILE"
}

# Function to get tasks by member
get_tasks_by_member() {
    local member="$1"
    
    jq -r --arg member "$member" '.tasks | to_entries[] | select(.value.member == $member) | "\(.key): \(.value.status)"' "$DEPS_FILE"
}

# Function to check for member conflicts
check_member_conflicts() {
    local task="$1"
    
    # Get all sessions working on this task
    jq -r --arg task "$task" '
        .tasks | to_entries[] | select(.key | contains($task)) | 
        "\(.key): \(.value.member) (\(.value.updated))"
    ' "$DEPS_FILE"
}

# Function to get member workload
get_member_workload() {
    local member="$1"
    
    if [ -n "$member" ]; then
        echo "Tasks for $member:"
        jq -r --arg member "$member" '
            .tasks | to_entries[] | select(.value.member == $member) | 
            "  \(.key): \(.value.status) (updated: \(.value.updated))"
        ' "$DEPS_FILE"
    else
        echo "Workload by member:"
        jq -r '.tasks | group_by(.member) | .[] | "\(.[0].member): \(length) tasks"' "$DEPS_FILE"
    fi
}

# Main command dispatcher
case "${1:-}" in
    "add-dep")
        add_dependency "$2" "$3"
        ;;
    "remove-dep")
        remove_dependency "$2" "$3"
        ;;
    "update-status")
        update_task_status "$2" "$3" "$4" "$5" "$6"
        ;;
    "get-status")
        get_task_status "$2"
        ;;
    "list-deps")
        list_dependencies "$2"
        ;;
    "check-circular")
        check_circular_dependencies
        ;;
    "get-by-status")
        get_tasks_by_status "$2"
        ;;
    "get-by-member")
        get_tasks_by_member "$2"
        ;;
    "check-conflicts")
        check_member_conflicts "$2"
        ;;
    "member-workload")
        get_member_workload "$2"
        ;;
    "resolve")
        resolve_dependencies "$2"
        ;;
    *)
        echo "Usage: $0 {add-dep|remove-dep|update-status|get-status|list-deps|check-circular|get-by-status|get-by-member|check-conflicts|member-workload|resolve}"
        echo "  add-dep TASK DEPENDS_ON"
        echo "  remove-dep TASK DEPENDS_ON"
        echo "  update-status TASK STATUS [AGENT] [SESSION] [MEMBER]"
        echo "  get-status TASK"
        echo "  list-deps [TASK]"
        echo "  check-circular"
        echo "  get-by-status STATUS"
        echo "  get-by-member MEMBER"
        echo "  check-conflicts TASK"
        echo "  member-workload [MEMBER]"
        echo "  resolve TASK"
        exit 1
        ;;
esac