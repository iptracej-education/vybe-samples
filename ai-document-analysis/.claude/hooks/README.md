# Vybe Hook System Documentation

## Overview

The Vybe hook system provides automatic context management for multi-agent workflows. Hooks run before and after every Claude Code tool execution to maintain state, track progress, and enable seamless handoffs between agents.

## Configuration

### Automatic Setup
Hooks are included when you copy the Vybe framework files to your project. No additional configuration is required for basic functionality.

### Claude Code Settings (Required for Full Features)
For full integration with Claude Code, add to your settings:
```json
{
  "hooks": {
    "pre_tool": ".claude/hooks/pre-tool.sh",
    "post_tool": ".claude/hooks/post-tool.sh",
    "precompact": ".claude/hooks/precompact.py"
  }
}
```

**Note**: The PreCompact hook is essential for automatic context management and preventing work loss during compaction.

### Environment Variables
- `CLAUDE_SESSION_ID`: Unique session identifier
- `CLAUDE_TOOL_NAME`: Currently executing tool
- `CLAUDE_TOOL_ARGS`: Tool arguments
- `CLAUDE_TOOL_EXIT_CODE`: Tool execution result

## Hook Files

### precompact.py
**Most Important**: Runs before Claude Code compacts context:
- Automatically saves complete context state
- Preserves all work and progress
- Generates continuation instructions
- Enables seamless session handoffs
- **Prevents work loss during compaction**

### pre-tool.sh
Runs before each tool execution:
- Saves current session state
- Captures git status and changes
- Records active tasks and specifications
- Creates session tracking files

### post-tool.sh
Runs after each tool execution:
- Updates session state with results
- Tracks task completion status
- Updates dependency graph
- Logs execution outcomes

### context/dependency-tracker.sh
Manages task dependencies:
- Tracks task relationships
- Resolves dependency chains
- Updates task readiness
- Detects circular dependencies

### context/update-dependencies.sh
Automatic dependency resolution:
- Checks completed tasks
- Updates waiting tasks
- Triggers dependency cascades

## Context Storage

### Directory Structure
```
.vybe/context/
├── precompact/         # PreCompact hook saves (most important)
│   ├── checkpoint-*.json     # Complete context snapshots
│   ├── diff-*.patch         # Git changes at compaction
│   ├── transcript-*.txt     # Full conversation history
│   └── instructions-*.md    # Continuation instructions
├── sessions/           # Session state files
│   ├── session-*.json  # Session metadata
│   └── git-status-*.txt # Git state snapshots
├── tasks/              # Task-specific context
│   └── [feature-task].json
├── dependencies/       # Dependency tracking
│   └── dependency-graph.json
├── manual/             # Manual pause saves
│   ├── pause-*.json    # Manual checkpoint data
│   └── continue-*.md   # Resume instructions
└── *.log              # Various log files
```

### Session Files
Each session creates:
- `session-[id].json`: Session metadata and state
- `git-status-[id].txt`: Git working tree status
- `modified-files-[id].txt`: Changed file list
- `active-specs-[id].txt`: Active specifications

### Dependency Graph
Tracks relationships between tasks:
```json
{
  "dependencies": {
    "user-auth-4": ["user-auth-1", "user-auth-2"],
    "user-auth-5": ["user-auth-1"]
  },
  "tasks": {
    "user-auth-1": {
      "status": "completed",
      "agent": "backend",
      "session": "abc123",
      "updated": "2025-01-15T10:30:00Z"
    }
  }
}
```

## Validation

### Check Hook System
Run validation before using task delegation:
```bash
/vybe:validate-hooks
```

### Manual Validation
```bash
# Check hook files
ls -la .claude/hooks/*.sh

# Test hook execution
.claude/hooks/pre-tool.sh
echo $?  # Should return 0

# Check context directory
ls -la .vybe/context/
```

## Fallback Mode

When hooks are not available or configured, the system automatically falls back to manual context management.

### Manual Context Management
Without hooks, context is managed through:
1. Git commits for state preservation
2. File-based state tracking
3. Manual session management

### Enabling Fallback
```bash
# Force fallback mode
export VYBE_MANUAL_HOOKS=1

# Check if in fallback mode
/vybe:validate-hooks --status
```

## Integration with Task Delegation

### Automatic Hook Usage
When using `/vybe:task-delegate`, hooks automatically:
1. Save pre-delegation context
2. Inject task-specific context to subagent
3. Capture subagent results
4. Update task and dependency status

### Multi-Session Support
For `/vybe:task-continue`, hooks:
1. Restore previous session state
2. Accumulate context across sessions
3. Maintain continuity of work
4. Preserve debugging trails

## Troubleshooting

### Common Issues

#### Hooks Not Running
- Check file permissions: `chmod +x .claude/hooks/*.sh`
- Verify Claude Code settings include hook paths
- Ensure bash is available: `which bash`

#### Context Not Saving
- Check directory permissions: `chmod 755 .vybe/context`
- Verify disk space: `df -h .`
- Check for write permissions: `touch .vybe/context/test`

#### Dependencies Not Resolving
- Validate dependency graph: `.claude/hooks/context/dependency-tracker.sh check-circular`
- Check task status: `.claude/hooks/context/dependency-tracker.sh get-status [task]`
- Manual resolution: `.claude/hooks/context/dependency-tracker.sh resolve [task]`

### Debug Mode
Enable detailed logging:
```bash
# Set debug mode
export VYBE_DEBUG=1

# Run with verbose output
bash -x .claude/hooks/pre-tool.sh
```

## Manual Hook Management

### Running Hooks Manually
```bash
# Save context before work
.claude/hooks/pre-tool.sh

# Update after work
.claude/hooks/post-tool.sh

# Check dependencies
.claude/hooks/context/dependency-tracker.sh list-deps

# Update task status
.claude/hooks/context/dependency-tracker.sh update-status user-auth-1 completed backend session-123
```

### Direct Context Manipulation
```bash
# Add dependency
.claude/hooks/context/dependency-tracker.sh add-dep user-auth-4 user-auth-1

# Remove dependency
.claude/hooks/context/dependency-tracker.sh remove-dep user-auth-4 user-auth-1

# Get tasks by status
.claude/hooks/context/dependency-tracker.sh get-by-status pending
```

## Best Practices

1. **Regular Validation**: Run `/vybe:validate-hooks` periodically
2. **Clean Context**: Remove old session files periodically
3. **Monitor Logs**: Check `.vybe/context/*.log` for issues
4. **Commit Frequently**: Hooks work best with clean git state
5. **Test Fallback**: Ensure manual mode works in your environment

## Performance Considerations

### Context Size Management
- Session files accumulate over time
- Archive old sessions: `find .vybe/context/sessions -mtime +30 -delete`
- Compress large logs: `gzip .vybe/context/*.log`

### Optimization
- Hooks add minimal overhead (<100ms per execution)
- Context injection is selective based on task needs
- Dependency resolution is incremental

## Security Notes

- Hooks run with user permissions
- No sensitive data is logged by default
- Session IDs are non-guessable
- Context files respect git ignores

## Extending the Hook System

### Custom Hooks
Add custom logic to existing hooks:
```bash
# In pre-tool.sh
source .claude/hooks/custom/pre-tool-custom.sh 2>/dev/null || true

# In post-tool.sh  
source .claude/hooks/custom/post-tool-custom.sh 2>/dev/null || true
```

### Additional Tracking
Extend dependency tracker for custom fields:
- Add project-specific metadata
- Track additional relationships
- Custom status types
- Performance metrics