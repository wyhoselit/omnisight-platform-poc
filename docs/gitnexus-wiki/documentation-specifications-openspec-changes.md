# Documentation & Specifications — openspec-changes

# openspec-changes

Purpose: Track system changes via detailed specs.

Structure:
- Each change in dated dir under openspec/changes/archive/
- Dir name: YYYY-MM-DD-short-description
- Files per change:
  - design.md: context, goals, decisions, risks
  - proposal.md: why, what, capabilities, impact
  - specs/: requirement specs for new/modified capabilities
  - tasks.md: completed tasks checklist

Usage:
- Read design/proposal for context
- Read specs for detailed requirements
- Read tasks for implementation status
- To add change: new dir with date and desc, add design, proposal, specs, tasks files

Connection:
- No executable code
- Documents changes to main app (backend/frontend)
- Each change links to code changes in main app
- Specs used to verify implemented code

Note: Main app code lives in backend/ and frontend/ directories. openspec-changes only contains specifications.