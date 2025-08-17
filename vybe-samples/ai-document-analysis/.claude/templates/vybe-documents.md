# Vybe Document Templates
# AI uses these as guides for generating template-based Vybe documents

## Overview.md Template Structure

```markdown
# {Project Name}

*AI-generated overview based on template analysis*

## Project Vision

### Mission Statement
{AI analyzes template purpose and generates mission aligned with template goals}

### Core Value Proposition
{AI identifies what value this template/architecture typically provides}

### Success Metrics
{AI suggests metrics appropriate for this template type:}
- **API Template**: Response time, throughput, uptime
- **Frontend Template**: User engagement, performance, accessibility
- **Fullstack Template**: End-to-end user experience, feature delivery
- **ML Template**: Model accuracy, training time, inference speed

## Product Context

### Problem Statement
{AI infers what problems this template architecture solves}

### Target Users
{AI identifies typical users for this template type:}
- **API Template**: Developers, API consumers, system integrators
- **Frontend Template**: End users, content creators, administrators
- **ML Template**: Data scientists, analysts, business stakeholders

### Technology Context
- **Industry**: {AI determines industry from template characteristics}
- **Architecture**: {AI identifies architectural pattern from template}
- **Scale**: {AI estimates scale from template complexity}

## Business Requirements

### Core Functionality
{AI extracts core capabilities from template structure}

### Business Rules
{AI identifies business logic patterns from template code}

### Compliance Requirements
{AI suggests compliance based on template type and patterns}

## Quality Standards

### Performance Expectations
{AI sets expectations based on template architecture:}
- **Response Time**: Based on template's performance patterns
- **Scalability**: Based on template's architectural choices
- **Reliability**: Based on template's error handling patterns

## Integration Requirements

### External Systems
{AI identifies integration points from template configuration}

### Data Sources
{AI identifies data patterns from template models/schemas}

---

*Generated from template analysis - customize based on specific project needs*
```

## Architecture.md Template Structure

```markdown
# Technical Architecture

*AI-generated architecture documentation based on template analysis*

## Technology Stack

### Core Technologies
{AI extracts actual technologies from template:}
- **Language**: {detected primary language}
- **Framework**: {detected frameworks from package.json/requirements.txt/etc}
- **Runtime**: {detected runtime environment}

### Dependencies
{AI analyzes package files and extracts key dependencies}

### Development Tools
{AI identifies build tools, linters, formatters from template config}

## System Architecture

### Architecture Pattern
{AI identifies pattern from template structure:}
- **Monolithic**: Single deployable unit
- **Microservices**: Distributed services
- **Serverless**: Function-based architecture
- **JAMstack**: JavaScript, APIs, Markup

### Component Organization
{AI maps template directory structure to architectural components}

### Data Flow
{AI analyzes template to understand data movement patterns}

## Infrastructure & Deployment

### Deployment Strategy
{AI identifies deployment approach from template:}
- **Container-based**: Docker/Kubernetes configs detected
- **Traditional**: Server deployment patterns
- **Cloud-native**: Cloud provider configurations
- **Static**: JAMstack deployment patterns

### Environment Configuration
{AI identifies environment handling from template config files}

### Monitoring & Observability
{AI identifies monitoring patterns from template}

## Security Architecture

### Authentication & Authorization
{AI identifies auth patterns from template code}

### Data Protection
{AI identifies security measures from template implementation}

### API Security
{AI identifies API security patterns if template has APIs}

## Performance Considerations

### Optimization Strategies
{AI identifies performance patterns from template code}

### Caching Strategy
{AI identifies caching mechanisms from template}

### Scalability Approach
{AI determines scalability patterns from template architecture}

---

*Extracted from template analysis - verify and adapt for project specifics*
```

## Conventions.md Template Structure

```markdown
# Development Conventions

*AI-extracted conventions from template analysis*

## Code Style

### Language Conventions
{AI analyzes template code to extract actual style patterns:}
- **Naming**: {detected naming patterns from template code}
- **Formatting**: {detected formatting from template files}
- **Structure**: {detected code organization patterns}

### File Organization
{AI documents template's file organization approach}

### Import/Export Patterns
{AI identifies import/export conventions from template}

## Project Structure

### Directory Layout
{AI documents template's directory structure with explanations}

### File Naming
{AI extracts naming conventions from template files}

### Module Organization
{AI identifies how template organizes modules/components}

## Development Workflow

### Git Conventions
{AI identifies git patterns from template:}
- **Branch Naming**: {patterns from .gitignore, docs}
- **Commit Messages**: {patterns from commit history if available}
- **PR Process**: {patterns from template docs}

### Testing Standards
{AI identifies testing approaches from template:}
- **Test Location**: {detected test organization}
- **Test Naming**: {detected test naming patterns}
- **Test Structure**: {detected test patterns}

### Code Review Guidelines
{AI suggests guidelines based on template complexity and patterns}

## Quality Standards

### Linting & Formatting
{AI identifies linting/formatting tools from template config}

### Documentation Requirements
{AI identifies documentation patterns from template}

### Performance Guidelines
{AI suggests performance guidelines based on template type}

## Build & Deployment

### Build Process
{AI documents build process from template scripts/config}

### Environment Management
{AI documents environment handling from template}

### Release Process
{AI suggests release process based on template structure}

---

*Derived from template code analysis - adapt based on team preferences*
```

## AI Generation Guidelines

### Analysis-Based Generation
1. **Read Template Thoroughly**: Analyze all files, not just main ones
2. **Extract Real Patterns**: Use actual code patterns, not assumptions
3. **Technology-Specific**: Generate content specific to detected technologies
4. **Template-Appropriate**: Match content to template's complexity and purpose

### Content Customization
1. **Template Type Awareness**: Adjust content based on API vs Frontend vs Fullstack
2. **Technology Adaptation**: Use terminology and patterns specific to detected tech
3. **Complexity Matching**: Simple templates → simple docs, complex → comprehensive
4. **Pattern Integration**: Reflect template's actual architectural decisions

### Quality Standards
1. **Accuracy**: Ensure generated content matches template reality
2. **Usefulness**: Create actionable, practical documentation
3. **Consistency**: Maintain consistent tone and detail level
4. **Adaptability**: Generate templates that users can easily customize

### Vybe Integration
1. **Feature Mapping**: Connect template structure to potential Vybe features
2. **Stage Planning**: Suggest incremental development stages
3. **Task Breakdown**: Identify how template can be built incrementally
4. **Pattern Reuse**: Ensure generated patterns work with Vybe workflow