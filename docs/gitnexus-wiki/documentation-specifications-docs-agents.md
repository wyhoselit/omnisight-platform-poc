# Documentation & Specifications — docs-agents

# Documentation & Specifications — docs-agents Module

## Purpose

The `docs-agents` module defines conventions and workflows for consuming domain documentation and managing issues in this repository. It serves as a guide for engineering skills navigating the codebase and for contributors interacting with the issue tracker.

## Key Components

### 1. Domain Documentation (`docs/agents/domain.md`)

**Purpose**: Standardizes how developers explore and understand the codebase's domain model.

**Key Concepts**:

- **CONTEXT.md**: Primary entry point for understanding repository context. Located at repo root for single-context repos, or in each context directory for multi-context repos.
- **CONTEXT-MAP.md**: For multi-context repos, points to individual `CONTEXT.md` files per context.
- **ADR (Architecture Decision Records)**: Found in `docs/adr/` (system-wide) or `src/<context>/docs/adr/` (context-specific). Documents resolved decisions.

**Workflow**:
1. Read `CONTEXT.md` or `CONTEXT-MAP.md` first
2. Review relevant ADRs in `docs/adr/`
3. Use glossary terms from `CONTEXT.md` consistently
4. Flag conflicts with existing ADRs explicitly

**File Structure Patterns**:

Single-context repo:
```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo:
```
/
├── CONTEXT-MAP.md
├── docs/adr/
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

### 2. Issue Tracker (`docs/agents/issue-tracker.md`)

**Purpose**: Defines GitHub-based issue management using the `gh` CLI.

**Core Operations**:

| Operation | Command |
|-----------|---------|
| Create issue | `gh issue create --title "..." --body "..."` |
| Read issue | `gh issue view <number> --comments` |
| List issues | `gh issue list --state open --json number,title,body,labels,comments --jq '...'` |
| Comment | `gh issue comment <number> --body "..."` |
| Add label | `gh issue edit <number> --add-label "..."` |
| Remove label | `gh issue edit <number> --remove-label "..."` |
| Close | `gh issue close <number> --comment "..."` |

**Triage Labels** (from `triage-labels.md`):
- `needs-triage` - Maintainer evaluation needed
- `needs-info` - Waiting on reporter
- `ready-for-agent` - Fully specified, ready for automated agent
- `ready-for-human` - Requires human implementation
- `wontfix` - Will not be actioned

**Wayfinding Operations** (used by `/wayfinder`):

- **Map**: Single issue with label `wayfinder:map`, containing Notes/Decisions/Fog
- **Child tickets**: Issues linked as sub-issues or in task lists with `Part of #<map>`
- **Blocking**: Native GitHub dependencies via `gh api` calls
- **Frontier query**: List open, unblocked, unassigned children
- **Claim**: `gh issue edit <n> --add-assignee @me`
- **Resolve**: Comment answer, close issue, update map's Decisions-so-far

### 3. Triage Labels (`docs/agents/triage-labels.md`)

**Purpose**: Maps abstract triage roles to concrete label strings.

**Role Mapping**:

| Skills Role | Tracker Label | Meaning |
|-------------|---------------|---------|
| `needs-triage` | `needs-triage` | Maintainer needs to evaluate |
| `needs-info` | `needs-info` | Waiting on reporter |
| `ready-for-agent` | `ready-for-agent` | Ready for AFK agent |
| `ready-for-human` | `ready-for-human` | Requires human implementation |
| `wontfix` | `wontfix` | Will not be actioned |

## Integration with Codebase

### Connection Points

1. **Domain Docs → Issue Tracker**: ADRs and CONTEXT.md files are referenced when creating issues to ensure consistent terminology and decision history.

2. **Triage Labels → Wayfinding**: Labels determine issue state in the wayfinder workflow, controlling which tickets appear in frontier queries.

3. **Issue Tracker → Domain Docs**: Wayfinding maps and decisions-so-far sections link back to ADRs and CONTEXT.md for context.

### Skill Integration

Skills interact with this module through:
- `/domain-modeling` - Creates CONTEXT.md and ADRs lazily
- `/wayfinder` - Uses issue tracker operations for navigation
- Various skills - Apply triage labels based on role mappings

## Usage Patterns

### Exploring the Codebase

```bash
# Read primary context
cat CONTEXT.md

# List relevant ADRs
ls docs/adr/

# View specific ADR
cat docs/adr/0001-event-sourced-orders.md
```

### Managing Issues

```bash
# Create issue with heredoc body
gh issue create --title "Fix auth middleware" --body "$(cat <<'EOF'
Bug in auth middleware. Token expiry check use `<` not `<=`.

Fix:
- Change comparison operator
- Add test case
EOF
)"

# Query frontier tickets
gh issue list --state open --label "wayfinder:map" --json ...
```

### Wayfinding Workflow

```bash
# Create a wayfinder map
gh issue create --label wayfinder:map --title "Explore billing context"

# Add child ticket
gh issue create --title "Document billing domain" --body "Part of #123"

# Block ticket
gh api --method POST repos/owner/repo/issues/456/dependencies/blocked_by -F issue_id=123

# Claim ticket
gh issue edit 456 --add-assignee @me
```