# Documentation & Specifications — AGENTS.md

# AGENTS.md Documentation

`AGENTS.md` define operational rules, tool priorities, safety constraints for automated agents and developers working in `omnisight-platform-poc` repository.

## Purpose

File configure AI agent behavior. Prevent uncontrolled refactors, enforce graph-based impact checks, route queries to correct documentation subsystems.

## Tool Priority

Execute operations in order:

1. **Structure, call graph, blast radius:** `codebase-memory` first, `GitNexus` second. Avoid raw file grep.
2. **Architecture docs:** OpenWiki (`openwiki/quickstart.md`) + GitNexus map generator.
3. **Feature workflow:** OpenSpec (`opsx`).
4. **Domain alignment & TDD:** `mattpocock` skills.

```
Agent Query
  │
  ├─ Graph / Impact ──> codebase-memory ─(fallback)─> GitNexus
  ├─ Architecture   ──> OpenWiki (read-only)
  ├─ Workflow       ──> OpenSpec (opsx)
  └─ Domain / Tests ──> docs/agents/ + mattpocock skills
```

## Mandatory GitNexus Rules

Hard constraints. Do not bypass.

### Required Actions
- **Before edit symbol (function, class, method):** Run `impact({target: "symbolName", direction: "upstream"})`. Report blast radius to user.
- **High/Critical risk:** Warn user before writing edits.
- **Before commit:** Run `detect_changes()` to verify affected execution flows match expectations. For regression check: `detect_changes({scope: "compare", base_ref: "master"})`.
- **Search concepts:** Run `query({search_query: "concept"})`. Returns process-grouped call traces.
- **Symbol context:** Run `context({name: "symbolName"})` for callers, callees, flows.
- **Security audit:** Run `explain({target: "fileOrSymbol"})` for taint analysis.

### Prohibited Actions
- NEVER modify symbols without prior `impact` check.
- NEVER ignore HIGH or CRITICAL risk impact score.
- NEVER rename symbols via text search-and-replace. Use `rename` tool.
- NEVER commit changes without running `detect_changes()`.

## CLI Index Management

Refresh stale graph index:

```bash
# Auto-runner
node .gitnexus/run.cjs analyze

# Fallback
npx gitnexus analyze
```

## Related Agent References

| Context | Target Path | Notes |
|---|---|---|
| Wiki quickstart | `openwiki/quickstart.md` | Auto-generated via GitHub Actions. Do not edit manually. |
| Issues | `docs/agents/issue-tracker.md` | GitHub Issues integration rules |
| Labels | `docs/agents/triage-labels.md` | Default triage taxonomy |
| Domain specs | `docs/agents/domain.md` | Single-context repository model |
| Exploration skill | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` | System architecture navigation |
| Impact skill | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` | Blast radius calculation |
| Debug skill | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` | Error trace analysis |
| Refactor skill | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` | Graph-aware refactor workflows |