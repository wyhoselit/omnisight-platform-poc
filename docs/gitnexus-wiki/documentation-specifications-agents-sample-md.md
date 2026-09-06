# Documentation & Specifications — AGENTS.sample.md

# AGENTS.sample.md

## Purpose

Template for OpenCode-compatible agent instructions. Defines project configuration, commands, conventions, and tooling workflows.

## Structure

### Project Overview Section
- **Name**: Project identifier
- **Stack**: Technology stack (e.g., Vue 3 + Python FastAPI)
- **Package manager**: Package manager used (pnpm/npm/bun/uv/poetry)
- **Default branch**: Primary branch name (main/master)

### Commands Section
Standard development lifecycle commands:
- **Install**: Dependency installation
- **Dev**: Development server
- **Build**: Production build
- **Test**: Test execution
- **Lint / typecheck**: Code quality checks
- **Format**: Code formatting
- **Useful one-liners**: Combined workflow commands

### Conventions Section
- Change granularity guidelines
- Style consistency rules
- Language/type system constraints
- Test organization patterns
- Commit message conventions
- Branch/PR workflow

### Tooling Priority Section
Defines tool selection hierarchy:

| Need | Prefer | Fallback |
|------|--------|----------|
| Spec/change lifecycle | OpenSpec | — |
| Alignment/TDD/review | mattpocock skills | — |
| Call graph/symbol search | codebase-memory MCP | GitNexus |
| Architecture/process flows | GitNexus MCP | codebase-memory |
| Narrative docs | OpenWiki | GitNexus generate_map |

## Key Components

### OpenSpec (Change Spine)
- Non-trivial features: explore → propose/new → accept → apply → verify → archive
- Tiny fixes may skip OpenSpec

### mattpocock Skills
Available skills:
- `grill-with-docs` — alignment + CONTEXT.md/ADRs
- `tdd` — red-green-refactor
- `code-review` — standards + spec review
- `improve-codebase-architecture` — periodic deepening
- `diagnosing-bugs` — hard bug investigation
- `ask-matt` — skill/flow selection
- `setup-matt-pocock-skills` — initial setup

### codebase-memory MCP
- After large refactors: "Index this project"
- Everyday use: `search_graph`, `trace_path`, `get_architecture`, `detect_changes`

### GitNexus MCP
- Indexed with repo-specific ID
- Stale index: `node .gitnexus/run.cjs analyze`
- Pre-edit impact: run upstream analysis
- Pre-commit: `detect_changes()`
- Graph-aware renames: GitNexus rename tool

### OpenWiki
- Source: `openwiki/quickstart.md`
- Auto-generated documentation
- CI workflow refreshes wiki
- Update source docs, let OpenWiki regenerate

## Feature Workflow

```text
1. Fuzzy idea → opsx explore or grill-with-docs + graph explore
2. OpenSpec → propose/new → review proposal/design/tasks/specs
3. Implement → apply + tdd; use codebase-memory/GitNexus
4. Verify → opsx verify + change impact + code-review
5. Close out → archive → refresh indexes → OpenWiki update
```

## Checklist
- [ ] Explore/grill if problem fuzzy
- [ ] OpenSpec artifacts accepted (non-trivial)
- [ ] Impact checked (non-trivial symbol edits)
- [ ] Tests green (new tests for new behavior)
- [ ] detect_changes/review_change_impact before commit
- [ ] Archive + index/docs refresh when done

## Safety Rules
- No secrets/.env with real credentials
- No destructive git commands without explicit request
- Prefer feature branches + PRs for shared work
- Ask before CI/release/prod config changes

## Domain References
- Shared vocabulary: `CONTEXT.md` and `docs/adr/`
- OpenSpec source: `openspec/specs/` and `openspec/changes/`
- Workflow detail: `docs/feature-dev-workflow.md` (if present)

## Template Status
Contains `TODO` placeholders requiring project-specific values.