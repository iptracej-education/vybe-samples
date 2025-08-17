#!/usr/bin/env python3
"""
Vybe PreCompact Hook - Automatic Context Management
Triggers before Claude Code compacts to save state and provide continuation instructions
"""

import json
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path

def save_context_state(session_id, transcript_path):
    """Save complete context state before compaction"""
    
    vybe_context = Path(".vybe/context")
    vybe_context.mkdir(parents=True, exist_ok=True)
    
    # Create precompact checkpoint
    checkpoint_dir = vybe_context / "precompact"
    checkpoint_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().isoformat()
    
    # Save checkpoint metadata
    checkpoint_data = {
        "session_id": session_id,
        "timestamp": timestamp,
        "transcript_path": transcript_path,
        "event": "PreCompact",
        "vybe_version": "1.0",
        "context_saved": True
    }
    
    # Get current git state
    try:
        git_branch = subprocess.check_output(
            ["git", "branch", "--show-current"], 
            cwd=".", 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        git_commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], 
            cwd=".", 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        # Get modified files
        git_status = subprocess.check_output(
            ["git", "status", "--porcelain"], 
            cwd=".", 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        checkpoint_data["git_state"] = {
            "branch": git_branch,
            "commit": git_commit,
            "has_changes": bool(git_status),
            "modified_files": git_status.split('\n') if git_status else []
        }
        
        # Save git diff
        git_diff = subprocess.check_output(
            ["git", "diff"], 
            cwd=".", 
            stderr=subprocess.DEVNULL
        ).decode()
        
        with open(checkpoint_dir / f"diff-{session_id}.patch", "w") as f:
            f.write(git_diff)
            
    except subprocess.CalledProcessError:
        checkpoint_data["git_state"] = {"error": "Git not available"}
    
    # Find active tasks
    active_tasks = []
    vybe_specs = Path(".vybe/specs")
    if vybe_specs.exists():
        for spec_dir in vybe_specs.iterdir():
            if spec_dir.is_dir():
                tasks_file = spec_dir / "tasks.md"
                if tasks_file.exists():
                    try:
                        content = tasks_file.read_text()
                        if "in_progress" in content:
                            active_tasks.append(spec_dir.name)
                    except:
                        pass
    
    checkpoint_data["active_tasks"] = active_tasks
    
    # Find current agent and task from context
    current_agent = os.environ.get("VYBE_AGENT_TYPE", "unknown")
    current_task = os.environ.get("VYBE_TASK_RANGE", "unknown")
    
    checkpoint_data["current_work"] = {
        "agent_type": current_agent,
        "task_range": current_task,
        "context_mode": os.environ.get("VYBE_CONTEXT_MODE", "hooks")
    }
    
    # Save checkpoint file
    checkpoint_file = checkpoint_dir / f"checkpoint-{session_id}.json"
    with open(checkpoint_file, "w") as f:
        json.dump(checkpoint_data, f, indent=2)
    
    # Copy transcript if available
    if transcript_path and os.path.exists(transcript_path):
        import shutil
        shutil.copy2(transcript_path, checkpoint_dir / f"transcript-{session_id}.txt")
    
    return checkpoint_file

def generate_continuation_instructions(checkpoint_file, session_id):
    """Generate instructions for continuing work after compaction"""
    
    with open(checkpoint_file) as f:
        checkpoint_data = json.load(f)
    
    current_work = checkpoint_data.get("current_work", {})
    agent_type = current_work.get("agent_type", "unknown")
    task_range = current_work.get("task_range", "unknown")
    active_tasks = checkpoint_data.get("active_tasks", [])
    
    instructions = []
    instructions.append("# Context Restored After Compaction")
    instructions.append("")
    instructions.append(f"Session {session_id} was automatically saved before compaction.")
    instructions.append("")
    
    if agent_type != "unknown" and task_range != "unknown":
        instructions.append("## Resume Current Work")
        instructions.append(f"You were working as: **{agent_type}** agent")
        instructions.append(f"On task range: **{task_range}**")
        instructions.append("")
        instructions.append("To continue exactly where you left off:")
        instructions.append(f"```")
        instructions.append(f"/vybe:task-continue {agent_type} {task_range} {session_id}")
        instructions.append(f"```")
        instructions.append("")
    
    if active_tasks:
        instructions.append("## Active Features")
        for task in active_tasks:
            instructions.append(f"- {task}")
        instructions.append("")
        instructions.append("Check status with: `/vybe:task-status`")
        instructions.append("")
    
    # Git status
    git_state = checkpoint_data.get("git_state", {})
    if git_state.get("has_changes"):
        instructions.append("## Git Status")
        instructions.append("You have uncommitted changes that were preserved.")
        instructions.append("Run `git status` to see current state.")
        instructions.append("")
    
    instructions.append("## Context Recovery")
    instructions.append("All work has been preserved in `.vybe/context/precompact/`")
    instructions.append(f"- Checkpoint: `checkpoint-{session_id}.json`")
    instructions.append(f"- Git diff: `diff-{session_id}.patch`")
    instructions.append(f"- Transcript: `transcript-{session_id}.txt`")
    instructions.append("")
    instructions.append("The Vybe framework ensures no work is lost during compaction.")
    
    return "\n".join(instructions)

def main():
    """Main PreCompact hook handler"""
    
    # Read hook data from stdin
    try:
        hook_data = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        print("Error: Invalid JSON input", file=sys.stderr)
        sys.exit(1)
    
    session_id = hook_data.get("session_id", "unknown")
    transcript_path = hook_data.get("transcript_path")
    trigger = hook_data.get("trigger", "auto")
    
    print(f"🔄 PreCompact triggered ({trigger}) - Saving Vybe context...")
    
    # Save context state
    try:
        checkpoint_file = save_context_state(session_id, transcript_path)
        print(f"✅ Context saved: {checkpoint_file}")
        
        # Generate continuation instructions
        instructions = generate_continuation_instructions(checkpoint_file, session_id)
        
        # Display instructions
        print("\n" + "="*60)
        print("VYBE CONTEXT PRESERVED")
        print("="*60)
        print(instructions)
        print("="*60)
        
        # Save instructions to file for later reference
        instructions_file = Path(".vybe/context/precompact") / f"instructions-{session_id}.md"
        with open(instructions_file, "w") as f:
            f.write(instructions)
        
        print(f"\nInstructions saved to: {instructions_file}")
        
    except Exception as e:
        print(f"❌ Error saving context: {e}", file=sys.stderr)
        sys.exit(1)
    
    print("\n🚀 Ready for compaction - context is safe!")

if __name__ == "__main__":
    main()