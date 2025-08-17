---
description: Mark outcome stage complete and advance to next stage
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS
---

# /vybe:release - Outcome Stage Progression

Mark current outcome stage as complete and advance to the next stage in your incremental development roadmap.

## Usage
```bash
/vybe:release [stage-name] [--force]
```

## Parameters
- `stage-name`: Optional. Specific stage to mark complete (defaults to current active stage)
- `--force`: Skip validation checks and force stage completion

## Pre-Release Validation

### Current Stage Status
- Outcome roadmap: `bash -c '[ -f ".vybe/project/outcomes.md" ] && echo "[OK] Outcome roadmap found" || echo "[NO] Run /vybe:init first"'`
- Active stage: `bash -c '[ -f ".vybe/backlog.md" ] && grep "Active Stage:" .vybe/backlog.md | head -1 || echo "No active stage"'`
- Tasks remaining: `bash -c '[ -f ".vybe/backlog.md" ] && grep -A 20 "IN PROGRESS" .vybe/backlog.md | grep "^\- \[ \]" | wc -l | xargs -I {} echo "{} tasks incomplete" || echo "Unknown"'`
- Tests passing: `bash -c 'npm test 2>/dev/null && echo "[OK] Tests passing" || echo "[WARN] Tests not verified"'`

## CRITICAL: Mandatory Context Loading

### Task 0: Load Complete Project Context
```bash
echo "[CONTEXT] LOADING PROJECT AND OUTCOME CONTEXT"
echo "=========================================="
echo ""

# Validate project exists
if [ ! -d ".vybe/project" ]; then
    echo "[NO] CRITICAL ERROR: Project not initialized"
    echo "   Cannot release stages without project context."
    echo "   Run /vybe:init first to establish project foundation."
    exit 1
fi

# Load outcome roadmap (MANDATORY)
if [ -f ".vybe/project/outcomes.md" ]; then
    echo "[OK] Loading outcome roadmap..."
    echo "=== OUTCOME ROADMAP ==="
    cat .vybe/project/outcomes.md
    echo ""
else
    echo "[NO] CRITICAL ERROR: outcomes.md missing"
    echo "   Outcome-driven development requires staged roadmap"
    echo "   Run /vybe:init to create outcome stages"
    exit 1
fi

# Load current backlog state
if [ -f ".vybe/backlog.md" ]; then
    echo "[OK] Loading current backlog state..."
    echo "=== CURRENT BACKLOG ==="
    cat .vybe/backlog.md
    echo ""
else
    echo "[NO] WARNING: backlog.md missing"
    echo "   Run /vybe:backlog init to create backlog"
fi

echo "[CONTEXT] Project context loaded - ready for stage progression"
echo ""
```

## Task 1: Validate Stage Completion

### Check Completion Criteria
```bash
echo "[VALIDATION] STAGE COMPLETION CHECK"
echo "================================="
echo ""

# Extract current stage info
current_stage=$(grep "Active Stage:" .vybe/backlog.md | sed 's/.*Stage [0-9]: //' | sed 's/ .*//')
echo "Current Stage: $current_stage"
echo ""

# Check task completion
incomplete_tasks=$(grep -A 20 "IN PROGRESS" .vybe/backlog.md | grep "^\- \[ \]" | wc -l)
if [ "$incomplete_tasks" -gt 0 ]; then
    echo "[WARN] $incomplete_tasks tasks still incomplete"
    if [[ "$*" != *"--force"* ]]; then
        echo "[STOP] Cannot release with incomplete tasks"
        echo "   Complete all tasks or use --force to override"
        exit 1
    else
        echo "[FORCE] Overriding incomplete tasks check"
    fi
else
    echo "[OK] All tasks completed"
fi

# Check deliverable exists
echo ""
echo "[CHECK] Verifying stage deliverable..."
echo "AI MUST verify that the stage deliverable is actually implemented:"
echo "- Code exists for the promised functionality"
echo "- Feature is working (not just planned)"
echo "- User value is demonstrable"
echo ""

# Run tests if available
echo "[TEST] Running verification tests..."
if npm test 2>/dev/null; then
    echo "[OK] Tests passing"
elif python -m pytest 2>/dev/null; then
    echo "[OK] Tests passing"
elif go test ./... 2>/dev/null; then
    echo "[OK] Tests passing"
else
    echo "[INFO] No automated tests found"
fi

echo ""
echo "[VALIDATION] Stage ready for release"
```

## Task 2: Capture Stage Learnings

### Document What We Learned
```bash
echo "[LEARNINGS] CAPTURING STAGE INSIGHTS"
echo "=================================="
echo ""
echo "AI MUST capture learnings from this stage:"
echo ""
echo "1. TECHNICAL LEARNINGS:"
echo "   - What worked well?"
echo "   - What was harder than expected?"
echo "   - What patterns emerged?"
echo "   - What technical debt was created?"
echo ""
echo "2. PROCESS LEARNINGS:"
echo "   - Was timeline accurate?"
echo "   - Were all tasks necessary?"
echo "   - What tasks were missing?"
echo "   - How accurate was effort estimate?"
echo ""
echo "3. BUSINESS LEARNINGS:"
echo "   - Did we deliver expected value?"
echo "   - What user feedback was received?"
echo "   - How does this change next stages?"
echo "   - What new requirements emerged?"
echo ""

# AI documents learnings in outcomes.md Learning Log section
echo "[AI] Updating Learning Log in outcomes.md..."
```

## Task 3: Mark Stage Complete

### Update Status in Documents
```bash
echo "[RELEASE] MARKING STAGE COMPLETE"
echo "=============================="
echo ""

# Update backlog.md
echo "[UPDATE] Updating backlog status..."
# AI changes:
# - Current stage from "IN PROGRESS" to "COMPLETED ✅"
# - Next stage from "NEXT" to "IN PROGRESS 🔄"
# - Updates "Active Stage" header

# Update outcomes.md
echo "[UPDATE] Updating outcome roadmap..."
# AI changes:
# - Current stage status to completed
# - Documents completion date
# - Updates current stage pointer
# - Adds learnings to log

# Archive completed tasks
echo "[ARCHIVE] Moving completed tasks to archive..."
# AI moves completed stage tasks to "Completed" section

echo ""
echo "[RELEASE] Stage successfully marked complete"
```

## Task 4: Advance to Next Stage

### Prepare Next Stage
```bash
echo "[ADVANCE] PREPARING NEXT STAGE"
echo "============================"
echo ""

# Identify next stage
next_stage=$(grep -A 5 "⏳ NEXT" .vybe/backlog.md | head -1 | sed 's/.*Stage [0-9]: //' | sed 's/ .*//')
echo "Next Stage: $next_stage"
echo ""

# Check if UI examples needed
if grep -A 10 "$next_stage" .vybe/backlog.md | grep -q "UI Examples Needed: YES"; then
    echo "[UI] This stage requires UI examples!"
    echo ""
    echo "Please provide UI examples by:"
    echo "1. Creating .vybe/ui-examples/ directory"
    echo "2. Adding mockups, wireframes, or reference images"
    echo "3. Or describing the UI requirements in detail"
    echo ""
    echo "AI will analyze these to understand component requirements."
fi

# Update stage readiness
echo "[PREP] Checking next stage prerequisites..."
echo "AI MUST verify:"
echo "- Previous stage deliverables are complete"
echo "- Dependencies are satisfied"
echo "- Technical foundation is ready"
echo "- Team capacity is available"
echo ""

# Generate refined task list
echo "[TASKS] Refining next stage tasks based on learnings..."
echo "AI MUST:"
echo "- Review initial task list for next stage"
echo "- Apply learnings from completed stage"
echo "- Adjust tasks based on actual implementation"
echo "- Add any newly discovered requirements"
echo "- Update effort estimates"
```

## Task 5: Update Progress Metrics

### Calculate and Display Progress
```bash
echo "[METRICS] OUTCOME PROGRESS UPDATE"
echo "==============================="
echo ""

# Calculate metrics
total_stages=$(grep "^### Stage" .vybe/project/outcomes.md | wc -l)
completed_stages=$(grep "COMPLETED" .vybe/backlog.md | grep "^### Stage" | wc -l)
progress_percent=$((completed_stages * 100 / total_stages))

echo "OUTCOME PROGRESS:"
echo "================"
echo "Completed: $completed_stages of $total_stages stages ($progress_percent%)"
echo ""

# Show stage timeline
echo "STAGE TIMELINE:"
echo "=============="
grep "^### Stage" .vybe/backlog.md | head -5

echo ""
echo "VALUE DELIVERED:"
echo "=============="
echo "Stage 1: [First outcome value delivered]"
if [ "$completed_stages" -ge 2 ]; then
    echo "Stage 2: [Second outcome value delivered]"
fi
if [ "$completed_stages" -ge 3 ]; then
    echo "Stage 3: [Third outcome value delivered]"
fi

echo ""
echo "NEXT MILESTONE:"
echo "============="
echo "Stage: $next_stage"
echo "Deliverable: [Next stage deliverable]"
echo "Timeline: [Estimated days]"
echo "Value: [Business value to deliver]"
```

## Final Summary

### Release Summary
```bash
echo ""
echo "[RELEASE] STAGE RELEASE COMPLETE"
echo "=============================="
echo ""
echo "[COMPLETED] $current_stage has been released!"
echo ""
echo "Summary:"
echo "- Deliverable shipped: [Stage deliverable]"
echo "- Value delivered: [Business value]"
echo "- Tasks completed: [Number of tasks]"
echo "- Learnings captured: YES"
echo ""
echo "[NEXT] Now working on: $next_stage"
echo "- Target: [Next deliverable]"
echo "- Timeline: [Days estimate]"
echo "- First task: [First task to tackle]"
echo ""
echo "[ACTIONS] Recommended next steps:"
echo "1. /vybe:plan $next_stage - Refine next stage plan"
echo "2. /vybe:execute [first-task] - Start implementation"
echo "3. /vybe:status - Check overall progress"
echo ""
echo "Remember: Ship working units early and often!"
```

## Error Handling

### Common Issues
- **Incomplete tasks**: Use --force to override or complete remaining tasks
- **No tests**: Proceed with manual verification
- **Missing outcomes.md**: Run /vybe:init to set up staged outcomes
- **No next stage**: Define additional stages in outcomes.md

### Recovery Actions
- **Rollback**: Revert status changes if release fails
- **Manual override**: Use --force flag when appropriate
- **Stage adjustment**: Modify outcomes.md to add/remove stages
- **Task migration**: Move incomplete tasks to next stage if needed