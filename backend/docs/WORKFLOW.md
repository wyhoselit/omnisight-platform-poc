# Documentation Workflow

The project uses an automated documentation system with OpenAPI, MkDocs Material, and CI validation.

## Automated Updates
A script is provided to automate the documentation update process:
`./scripts/docs-update.sh "description of changes"`

This script:
1. Updates the `master` branch
2. Creates a new documentation branch
3. Regenerates the OpenAPI specification
4. Builds the documentation with `--strict` validation
5. Creates a dated changelog entry in `docs/changelog/`
6. Commits changes, pushes the branch, and creates a GitHub PR

## Continuous Integration
Documentation is validated automatically on every PR to `master`:
- **OpenAPI Breaking Change Detection**: Using `oasdiff` against the `master` baseline
- **Docstring Coverage Check**: Using `interrogate` (minimum 35%, enforced in CI)
- **Documentation Build**: Using `mkdocs build --strict`
- **Changelog Generation**: Summary of API changes added to the GitHub PR

## Docstring Coverage Policy

**Tool**: [interrogate](https://interrogate.readthedocs.io/)

**Scope**: `app/modules/admin`, `app/modules/core`, `app/modules/user`, `app/modules/ai`

**Threshold**:
- Phase 1: 35% minimum coverage (current baseline: ~36%)
- Phase 2: 50% target
- Phase 3: 80% on all public APIs

**Exclusions**: Test files (`*/tests/*`) are excluded from coverage checks.

**Local verification**:
```bash
cd backend
uv run interrogate --fail-under 35 app/modules/admin app/modules/core app/modules/user app/modules/ai --exclude "*/tests/*"
```

## Versioning Strategy

### Single Source of Truth
`backend/pyproject.toml` `version` is the only version field maintained manually.

- **FastAPI/OpenAPI version**: Auto-derived via `app.modules.core.version.get_version()` at app startup. Never hardcode version in `app/main.py`.
- **MkDocs docs**: Always "latest" — documentation tracks the current state of `master`, no separate version number.
- **OpenAPI spec**: Regenerated on every merge to `master` by CI; version field mirrors `pyproject.toml`.

### Deployment Trigger
Documentation deploys to GitHub Pages on **every merge to `master`** (continuous docs). No tag-gated releases for docs.

Rationale: internal API reference should always reflect the code that is deployed; version tags gate releases, not documentation freshness.

### Bumping a Release
1. Edit `version = "x.y.z"` in `backend/pyproject.toml`
2. Merge to `master` — OpenAPI spec, `/health` metadata, and docs all pick it up automatically

## Manual Verification
To build and verify documentation locally:
```bash
cd backend
PYTHONPATH=. uv run python scripts/update_openapi.py
uv run mkdocs build --strict
uv run mkdocs serve
```

### Auto-Generate Navigation
The `scripts/generate_nav.py` script automatically generates the MkDocs navigation from the `app/modules/` directory structure:
```bash
cd backend
python scripts/generate_nav.py
```
Update this script when adding new modules or documentation files under `docs/modules/`.

To verify version consistency:
```bash
cd backend
uv run python -c "from app.modules.core.version import get_version; print('Version from pyproject.toml:', get_version())"
# Visit http://localhost:8000/api/openapi.json and verify version field matches
```

## Team Review Guidelines

### Documentation PR Review Checklist

1. **API Contract Changes**
   - [ ] OpenAPI spec changes are intentional
   - [ ] Breaking changes properly documented and approved
   - [ ] Response shapes match consumer expectations

2. **Code Quality**
   - [ ] All public modules have docstrings (module-level `"""`)
   - [ ] All public functions/methods have docstrings
   - [ ] Docstrings follow Google/NumPy style consistently
   - [ ] Type hints present on all public APIs
   - [ ] Docstring coverage meets minimum threshold (35%)

3. **Documentation Quality**
   - [ ] Changelog entry accurate and descriptive
   - [ ] MkDocs build passes with `--strict`
   - [ ] No broken links or missing assets

4. **Review Process**
   - **Primary reviewer**: API owner or module maintainer
   - **Secondary reviewer**: Cross-team member for cross-cutting concerns
   - **Blocking**: All 162 automated tests must pass
   - **Approval required**: 1 approval minimum

### Review Labels
- `needs-docs-review`: Documentation team attention required
- `api-breaking`: Breaking change requiring extra scrutiny

## Known Issues

### OTEL Collector Unreachable During Docs Build
**Issue**: OTEL Collector endpoint (localhost:4318) occasionally unreachable during docs build, causing trace data fetch to fail.

**Impact**: Non-blocking. Documentation builds complete successfully without trace data. Trace visualization may be temporarily unavailable.

**Status**: MONITORED - No action required until blocking issue identified.

**Mitigation**: Build continues even if Collector is unreachable. No retries or fallbacks currently implemented.
