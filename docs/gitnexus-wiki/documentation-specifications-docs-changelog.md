# Documentation & Specifications — docs-changelog

# Documentation & Specifications — docs-changelog

## Purpose
Track codebase changes, API surface impacts, test validation records. Provide historical audit trail for backend updates, core infrastructure modifications, documentation rebuilds.

## Directory Structure
```
docs/changelog/
├── updates.md                                         # Chronological summary index
├── 2026-08-22-add-docstrings-to-admin-and-core.md     # Detailed change record
└── 2026-08-22-add-docstrings-to-rag-ingestion-service.md # Detailed change record
```

## Core Files

### 1. Cumulative Summary Index (`updates.md`)
Single running list of high-level changes. Reverse-chronological or date-grouped bullet list.
* Format: `- YYYY-MM-DD: <Short summary of change>`
* Tracks cross-cutting updates (core modules, AI services, bug fixes, workflow docs).

### 2. Granular Change Logs (`YYYY-MM-DD-<topic>.md`)
Detailed documentation per significant change set. 

Standard sections:
* `# YYYY-MM-DD: <Title>`: Scope and target component.
* `## Changes`: List of affected files, methods, modules.
* `## API Impact`: OpenAPI schema modifications, doc rebuilding notes, breaking change warnings.
* `## Testing`: Test suite pass counts, verification criteria, build status.

## Contribution Workflow

1. Create detail file: `docs/changelog/YYYY-MM-DD-<slug>.md`.
2. Fill standard sections (`Changes`, `API Impact`, `Testing`).
3. Append summary line to `docs/changelog/updates.md`.
4. Run test suite and docs build to verify documented state.