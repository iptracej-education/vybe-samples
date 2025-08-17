# Vybe Framework - Spec-driven Agile Development

**Specification-first workflow with incremental outcome-driven development for Claude Code with multi-session coordination**

## Project Context

The Vybe Framework provides a complete agile-like development workflow through 9 core commands that support both solo development and multi-member team coordination, with a key focus on incremental outcome delivery through staged development and template-driven architecture enforcement.

## Paths & File Locations

### Framework Paths
- **Commands**: `.claude/commands/vybe/`
- **Hooks**: `.claude/hooks/`

### Project Foundation Paths
- **Project Documents**: `.vybe/project/`
- **Overview**: `.vybe/project/overview.md`
- **Architecture**: `.vybe/project/architecture.md`  
- **Conventions**: `.vybe/project/conventions.md`
- **Outcomes**: `.vybe/project/outcomes.md` - Staged outcome roadmap

### Development Paths
- **Backlog**: `.vybe/backlog.md`
- **Features**: `.vybe/features/`
- **Feature Specs**: `.vybe/features/[feature-name]/`
- **Requirements**: `.vybe/features/[feature-name]/requirements.md`
- **Design**: `.vybe/features/[feature-name]/design.md`
- **Tasks**: `.vybe/features/[feature-name]/tasks.md`

### Template System Paths (NEW)
- **Templates**: `.vybe/templates/`
- **Template Storage**: `.vybe/templates/[template-name]/`
- **Template Source**: `.vybe/templates/[template-name]/source/`
- **Template Metadata**: `.vybe/templates/[template-name]/metadata.yml`
- **Enforcement Rules**: `.vybe/enforcement/`
- **Code Patterns**: `.vybe/patterns/`
- **Validation Rules**: `.vybe/validation/`

### Coordination Paths
- **Session Context**: `.vybe/context/`
- **Session Files**: `.vybe/context/sessions/`
- **Hook Scripts**: `.claude/hooks/pre-tool.sh`, `.claude/hooks/post-tool.sh`
- **Dependency Tracker**: `.claude/hooks/context/dependency-tracker.sh`

### File Reading Priority for Claude Code
1. **ALWAYS READ FIRST**: `.vybe/project/overview.md`, `.vybe/project/architecture.md`, `.vybe/project/conventions.md`, `.vybe/project/outcomes.md`
2. **TEMPLATE ENFORCEMENT**: `.vybe/enforcement/`, `.vybe/patterns/`, `.vybe/validation/` (if template exists)
3. **BACKLOG MANAGEMENT**: `.vybe/backlog.md` 
4. **FEATURE SPECS**: `.vybe/features/[feature-name]/requirements.md`, `.vybe/features/[feature-name]/design.md`, `.vybe/features/[feature-name]/tasks.md`
5. **SESSION COORDINATION**: `.vybe/context/sessions/` files
6. **USER PROJECT**: `src/`, `docs/`, `README.md`, language-specific files

### Core Framework Structure
- **Commands**: `.claude/commands/vybe/` - 9 production-ready commands
- **Hooks**: `.claude/hooks/` - Multi-session coordination system
- **Project Foundation**: `.vybe/project/` - Overview, architecture, conventions (created by init)
- **Features**: `.vybe/features/` - Individual feature specifications (created by plan)
- **Backlog**: `.vybe/backlog.md` - Agile backlog with member assignments
- **Templates**: `.vybe/templates/` - Template storage and analysis (NEW)
- **Enforcement**: `.vybe/enforcement/` - Template pattern enforcement (NEW)
- **Patterns**: `.vybe/patterns/` - Reusable code templates (NEW)
- **Validation**: `.vybe/validation/` - Compliance checking rules (NEW)

## Development Philosophy

### Specification-First Approach
- Every feature starts with clear requirements and design
- EARS format requirements (The system shall...)
- Comprehensive task breakdown before implementation
- Living documentation that evolves with code

### Incremental Outcome-Driven Development
- Projects broken into staged outcomes (baby steps approach)
- First minimal outcome deliverable in 1-2 days
- Each stage builds on previous, delivers working units
- UI examples requested only when needed
- Learning between stages improves next stage

### Template-Driven Architecture
- Templates provide permanent architectural DNA for projects
- AI analyzes templates to extract patterns and conventions
- All development follows template-enforced structures
- Template immutable once set (requires migration to change)

### Agile-Like Methodology
- Outcome-grouped backlog management with prioritization
- Member assignment and workload balancing
- Iterative stage development with continuous delivery
- Quality assurance with gap detection

## Core Workflow - 9 Commands

### 0. Template System (NEW)
**`/vybe:template [action]`** - Import and analyze external templates
- `import [source] [name]` - Import template from GitHub or local path
- `generate [name]` - AI analyzes template and creates enforcement structures
- `list` - Show available templates
- `validate [name]` - Check template completeness

### 1. Project Initialization
**`/vybe:init [description] [--template=name]`** - Initialize project with staged outcome roadmap
- Captures first minimal outcome, final vision, and initial stages
- Creates `.vybe/project/` with overview.md, architecture.md, conventions.md, outcomes.md
- **NEW**: `--template=name` option sets project architectural DNA from template
- Establishes incremental delivery context for all future decisions
- Sets up git-based coordination infrastructure

### 2. Backlog Management
**`/vybe:backlog [action]`** - Outcome-grouped backlog with member coordination
- Groups tasks by outcome stages (not random features)
- `member-count [N]` - Configure team with 1-5 developers (dev-1, dev-2, etc.)
- `assign [stage] [dev-N]` - Assign outcome stages to specific members
- `init` - Create outcome-driven backlog structure
- `groom` - Clean duplicates, optimize stage priorities

### 3. Feature Planning
**`/vybe:plan [feature-name] [description]`** - Create detailed feature specifications
- Generates requirements.md with EARS format
- Creates design.md with technical approach  
- Produces tasks.md with implementation steps
- Includes web research for best practices

### 4. Implementation Execution
**`/vybe:execute [task-name]`** - Execute specific tasks with full context
- Member-aware execution with `VYBE_MEMBER` environment variable
- Loads complete project context (overview, architecture, conventions)
- Progress tracking and status updates
- Coordinates with multi-session workflows
- **ENFORCES REAL APPLICATIONS**: Never creates mock/fake implementations

### 5. Progress Tracking
**`/vybe:status [scope]`** - "How are we doing?" - Progress and assignments
- Default: Overall project progress with outcome progression
- `outcomes` - Staged outcome timeline and completion status
- `members` - Team workload distribution
- `dev-N` - Individual developer progress
- Shows next actions and blockers

### 6. Quality Assurance & Code-Reality Analysis
**`/vybe:audit [scope]`** - "What needs fixing?" - Gap detection and code-reality analysis
- Traditional: Detects missing specifications, requirements, tasks, duplicates
- **NEW**: Code-reality analysis modes (`code-reality`, `scope-drift`, `business-value`, `documentation`, `mvp-extraction`)
- Compares actual source code vs documented plans and business outcomes
- Provides automated fix commands and structured analysis reports
- Quality scoring and actionable recommendations

### 7. Stage Release & Progression
**`/vybe:release [stage]`** - Mark outcome stage complete and advance
- Validates stage completion (tasks done, deliverable working)
- Captures learnings from completed stage
- Updates backlog and outcomes status
- Advances to next stage automatically
- Requests UI examples when needed for upcoming stages

### 8. Natural Language Help with Smart Audit Routing
**`/vybe:discuss [question]`** - Natural language assistant with automatic code-reality analysis
- Translates user requests into specific Vybe commands
- Automatically routes analysis requests to specialized audit modes
- Runs `/vybe:audit` commands and provides structured results
- Context-aware suggestions based on project state
- Provides both command sequences AND automated project analysis

## Multi-Member Coordination

### Environment Variables
- **`VYBE_MEMBER`** - Set member role: `export VYBE_MEMBER=dev-1`
- Supports dev-1 through dev-5 (up to 5 team members)
- Used for assignment tracking and conflict detection

### Git-Based Coordination
- Shared GitHub repository required for team projects
- Automatic session tracking via hooks
- Conflict detection and resolution guidance
- Member workload balancing

### Hook System
- **Pre-tool hook**: Session tracking, member role detection
- **Post-tool hook**: Conflict warnings, coordination alerts
- **Dependency tracker**: Task dependencies and member assignments

## Development Rules

### Core Principles
1. **Staged outcomes first**: Always start with `/vybe:init` to define incremental stages
2. **Outcome-driven**: Use `/vybe:backlog` for stage-grouped task management
3. **Baby steps delivery**: Each stage delivers working units in 1-3 days
4. **Continuous progression**: Use `/vybe:release` to advance through stages
5. **Member coordination**: Use `VYBE_MEMBER` for team development
6. **Progress visibility**: Regular `/vybe:status` for tracking outcomes
7. **🚫 REAL APPLICATIONS ONLY**: Never create mock/fake implementations

### Real Application Enforcement
- **FORBIDDEN**: Mock APIs, fake data, placeholder implementations
- **FORBIDDEN**: Functions named `mock_*`, `fake_*`, `dummy_*`, `placeholder_*`
- **FORBIDDEN**: Comments saying "In production, this would..." 
- **REQUIRED**: Real API integrations with proper error handling
- **REQUIRED**: Clear failure messages when APIs are unavailable
- **REQUIRED**: Documentation for obtaining real API keys

### Command Flow
```
/vybe:init → /vybe:backlog → /vybe:plan → /vybe:execute → /vybe:release → /vybe:status → /vybe:audit
                  ↑                                              ↓
                  └── /vybe:discuss (for guidance) ←-----------┘
```

### Outcome-Driven Team Workflow
1. **Setup**: Create GitHub repository, configure members, define staged outcomes
2. **Stage Planning**: Initialize outcome-grouped backlog, assign stages to members  
3. **Development**: Members execute current stage tasks with `VYBE_MEMBER` set
4. **Stage Completion**: Use `/vybe:release` to mark stages complete and advance
5. **Continuous Delivery**: Each stage ships working units with user value
4. **Coordination**: Regular status checks and quality audits
5. **Quality**: Continuous gap detection and fix automation

## Mandatory Context Loading

All commands load complete project context:
- **overview.md** - Business context and goals
- **architecture.md** - Technical decisions and constraints  
- **conventions.md** - Coding standards and practices
- **backlog.md** - Current feature assignments and priorities

This ensures consistent decision-making across all development activities.

## Repository Requirements

### Solo Development
- Local git repository sufficient
- No GitHub required for individual work

### Multi-Member Teams  
- **GitHub repository required** for coordination
- Git-based multi-session coordination
- Shared backlog and assignment tracking

## Platform Support
- **Supported**: Linux, macOS, WSL2, Git Bash
- **Not supported**: Native Windows CMD/PowerShell
- **Output**: ASCII-only (no Unicode issues)

## Success Metrics

### Framework Functionality
- All 7 commands execute without errors
- Generated specifications are useful and accurate
- Multi-session coordination works seamlessly
- Quality assurance catches real issues

### User Experience  
- Commands feel intuitive and natural
- Error messages are helpful
- Learning curve is reasonable
- Workflow feels efficient

The Vybe Framework provides a complete, production-ready system for spec-driven agile development with Claude Code.