#!/bin/bash
# Hook System Validation Script

# Parse arguments
SILENT=false
FALLBACK=false
STATUS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --silent)
            SILENT=true
            shift
            ;;
        --fallback)
            FALLBACK=true
            shift
            ;;
        --status)
            STATUS_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Status codes
STATUS_READY=0
STATUS_PARTIAL=1
STATUS_FAILED=2

# Current status
CURRENT_STATUS=$STATUS_READY
ISSUES=()
RECOMMENDATIONS=()

# Colors for output (only if not silent)
if [ "$SILENT" != "true" ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
else
    GREEN=''
    YELLOW=''
    RED=''
    NC=''
fi

# Quick status check
if [ "$STATUS_ONLY" = "true" ]; then
    if [ -f ".claude/hooks/pre-tool.sh" ] && [ -f ".claude/hooks/post-tool.sh" ]; then
        if [ -x ".claude/hooks/pre-tool.sh" ] && [ -x ".claude/hooks/post-tool.sh" ]; then
            echo "HOOK STATUS: READY"
            exit $STATUS_READY
        else
            echo "HOOK STATUS: PARTIAL (Permissions issue)"
            exit $STATUS_PARTIAL
        fi
    else
        echo "HOOK STATUS: FAILED (Hooks not found)"
        exit $STATUS_FAILED
    fi
fi

# Force fallback mode
if [ "$FALLBACK" = "true" ]; then
    export VYBE_MANUAL_HOOKS=1
    if [ "$SILENT" != "true" ]; then
        echo "Fallback mode enabled: VYBE_MANUAL_HOOKS=1"
    fi
    exit $STATUS_READY
fi

# Full validation
if [ "$SILENT" != "true" ]; then
    echo "Hook System Validation Report"
    echo "=============================="
    echo ""
fi

# 1. File System Checks
if [ "$SILENT" != "true" ]; then
    echo "FILE SYSTEM CHECKS:"
fi

# Check pre-tool.sh
if [ -f ".claude/hooks/pre-tool.sh" ]; then
    if [ -x ".claude/hooks/pre-tool.sh" ]; then
        [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} pre-tool.sh exists and is executable"
    else
        [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} pre-tool.sh exists but not executable"
        CURRENT_STATUS=$STATUS_PARTIAL
        ISSUES+=("pre-tool.sh not executable")
        RECOMMENDATIONS+=("chmod +x .claude/hooks/pre-tool.sh")
    fi
else
    [ "$SILENT" != "true" ] && echo -e "${RED}✗${NC} pre-tool.sh not found"
    CURRENT_STATUS=$STATUS_FAILED
    ISSUES+=("pre-tool.sh missing")
fi

# Check post-tool.sh
if [ -f ".claude/hooks/post-tool.sh" ]; then
    if [ -x ".claude/hooks/post-tool.sh" ]; then
        [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} post-tool.sh exists and is executable"
    else
        [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} post-tool.sh exists but not executable"
        CURRENT_STATUS=$STATUS_PARTIAL
        ISSUES+=("post-tool.sh not executable")
        RECOMMENDATIONS+=("chmod +x .claude/hooks/post-tool.sh")
    fi
else
    [ "$SILENT" != "true" ] && echo -e "${RED}✗${NC} post-tool.sh not found"
    CURRENT_STATUS=$STATUS_FAILED
    ISSUES+=("post-tool.sh missing")
fi

# Check context directory
if [ -d ".vybe/context" ]; then
    if [ -w ".vybe/context" ]; then
        [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} Context directory is writable"
    else
        [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} Context directory not writable"
        CURRENT_STATUS=$STATUS_PARTIAL
        ISSUES+=("Context directory not writable")
        RECOMMENDATIONS+=("chmod 755 .vybe/context")
    fi
else
    # Try to create it
    mkdir -p .vybe/context 2>/dev/null
    if [ $? -eq 0 ]; then
        [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} Context directory created"
    else
        [ "$SILENT" != "true" ] && echo -e "${RED}✗${NC} Cannot create context directory"
        CURRENT_STATUS=$STATUS_FAILED
        ISSUES+=("Cannot create context directory")
    fi
fi

# 2. Dependencies Check
if [ "$SILENT" != "true" ]; then
    echo ""
    echo "DEPENDENCIES:"
fi

# Check bash
if command -v bash &> /dev/null; then
    BASH_PATH=$(which bash)
    [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} bash: $BASH_PATH"
else
    [ "$SILENT" != "true" ] && echo -e "${RED}✗${NC} bash not found"
    CURRENT_STATUS=$STATUS_FAILED
    ISSUES+=("bash not available")
fi

# Check git
if command -v git &> /dev/null; then
    GIT_PATH=$(which git)
    [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} git: $GIT_PATH"
else
    [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} git not found (optional but recommended)"
    if [ $CURRENT_STATUS -eq $STATUS_READY ]; then
        CURRENT_STATUS=$STATUS_PARTIAL
    fi
    RECOMMENDATIONS+=("Install git for full functionality")
fi

# Check jq
if command -v jq &> /dev/null; then
    JQ_PATH=$(which jq)
    [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} jq: $JQ_PATH"
else
    [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} jq not found (required for JSON processing)"
    if [ $CURRENT_STATUS -eq $STATUS_READY ]; then
        CURRENT_STATUS=$STATUS_PARTIAL
    fi
    ISSUES+=("jq not available")
    RECOMMENDATIONS+=("Install jq: brew install jq (macOS) or apt-get install jq (Linux)")
fi

# 3. Configuration Check
if [ "$SILENT" != "true" ]; then
    echo ""
    echo "CONFIGURATION:"
fi

# Check if Claude Code settings might have hooks configured
# This is a heuristic since we can't directly check Claude Code settings
if [ -n "$CLAUDE_HOOKS_ENABLED" ]; then
    [ "$SILENT" != "true" ] && echo -e "${GREEN}✓${NC} Hooks appear to be configured"
else
    [ "$SILENT" != "true" ] && echo -e "${YELLOW}⚠️${NC} Cannot verify Claude Code hook configuration"
    if [ $CURRENT_STATUS -eq $STATUS_READY ]; then
        CURRENT_STATUS=$STATUS_PARTIAL
    fi
    RECOMMENDATIONS+=("Add hooks to Claude Code settings if not already configured")
fi

# 4. Functional Tests (only if not failed)
if [ $CURRENT_STATUS -ne $STATUS_FAILED ] && [ "$SILENT" != "true" ]; then
    echo ""
    echo "FUNCTIONAL TESTS:"
    
    # Test pre-hook execution
    if [ -x ".claude/hooks/pre-tool.sh" ]; then
        .claude/hooks/pre-tool.sh 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Pre-hook execution successful"
        else
            echo -e "${YELLOW}⚠️${NC} Pre-hook execution failed"
            CURRENT_STATUS=$STATUS_PARTIAL
        fi
    fi
    
    # Test post-hook execution
    if [ -x ".claude/hooks/post-tool.sh" ]; then
        .claude/hooks/post-tool.sh 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Post-hook execution successful"
        else
            echo -e "${YELLOW}⚠️${NC} Post-hook execution failed"
            CURRENT_STATUS=$STATUS_PARTIAL
        fi
    fi
fi

# Summary
if [ "$SILENT" != "true" ]; then
    echo ""
    case $CURRENT_STATUS in
        $STATUS_READY)
            echo -e "${GREEN}OVERALL STATUS: READY${NC}"
            echo "Mode: Full Hook Support"
            ;;
        $STATUS_PARTIAL)
            echo -e "${YELLOW}OVERALL STATUS: PARTIAL${NC}"
            echo "Mode: Fallback Available"
            echo "Context Management: Manual/Git-based"
            ;;
        $STATUS_FAILED)
            echo -e "${RED}OVERALL STATUS: FAILED${NC}"
            echo "Mode: Manual Only"
            ;;
    esac
    
    # Show recommendations
    if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
        echo ""
        echo "RECOMMENDATIONS:"
        for i in "${!RECOMMENDATIONS[@]}"; do
            echo "$((i+1)). ${RECOMMENDATIONS[$i]}"
        done
    fi
    
    # Show Claude Code settings hint if partial
    if [ $CURRENT_STATUS -eq $STATUS_PARTIAL ]; then
        echo ""
        echo "For full functionality, ensure Claude Code settings include:"
        echo '  {'
        echo '    "hooks": {'
        echo '      "pre_tool": ".claude/hooks/pre-tool.sh",'
        echo '      "post_tool": ".claude/hooks/post-tool.sh"'
        echo '    }'
        echo '  }'
    fi
fi

# Export fallback mode if needed
if [ $CURRENT_STATUS -ne $STATUS_READY ]; then
    export VYBE_MANUAL_HOOKS=1
fi

exit $CURRENT_STATUS