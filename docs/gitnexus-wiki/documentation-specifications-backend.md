# Documentation & Specifications — backend

Backend documentation module generates and serves API reference docs from source code and config. No runtime code. Pure static site generator.

Uses MkDocs with Material theme. Docs built from docstrings in Python files (`docstring_style: google`). Auto-generates API reference from `.py` files under `backend/`.

Key components:
- `mkdocs.yml`: configures site structure, theme, plugins
- `nav:` defines hierarchy: Home, Workflow, API Reference, Internal Modules
- `mkdocstrings` plugin: extracts docstrings → HTML
- `search` plugin: enables full-text search
- `admonition`, `superfences`, `tabbed`: enhance readability

No execution flows. No incoming/outgoing calls. This module does not run. It builds.

Docs live at `backend/docs/`. Deployed as static site. Developers edit source code docstrings. Docs auto-update on build.

`strict: true` → fails build on broken links or missing pages. Enforces completeness.

ponytail: if API grows beyond 50 endpoints, add OpenAPI validation hook. Add when CI/CD pipeline needs schema enforcement.

→ skipped: live reload server, add when local dev needs hot-reload during doc editing.