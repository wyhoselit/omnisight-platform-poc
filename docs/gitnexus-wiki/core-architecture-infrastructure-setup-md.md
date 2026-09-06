# Core Architecture & Infrastructure — setup.md

# Core Architecture & Infrastructure — Setup Guide

## Purpose

This document defines the initial environment setup for the `vuetify-fastapi-ai-demo` project. It installs and configures the toolchain required for specification-driven development, AI-assisted documentation, and agentic skill management.

## Prerequisites

- Node.js ≥ 18 (for npm packages)
- Git
- Bash-compatible shell

## Toolchain Overview

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| **OpenSpec CLI** | Specification-driven development, code generation from specs | `npm install -g @fission-ai/openspec@latest` |
| **OpenWiki (LLM Wiki 2.0)** | Personal knowledge base + codebase documentation generator | `sudo npm install -g openwiki` |
| **Understand Anything** | Codebase analysis and explanation plugin for opencode | `curl -fsSL https://raw.githubusercontent.com/Egonex-AI/Understand-Anything/main/install.sh \| bash` |
| **Agentic Awesome Skills** | Curated agent skills for development tasks | `npx agentic-awesome-skills --path .agents/skills --category development,backend --risk safe,none` |

## Setup Procedure

### 1. Initialize Project Repository

```bash
mkdir vuetify-fastapi-ai-demo
cd vuetify-fastapi-ai-demo
git init
```

### 2. Install OpenSpec CLI

```bash
npm install -g @fission-ai/openspec@latest
openspec --version  # verify
```

### 3. Initialize OpenSpec Project

```bash
openspec init
```

This creates the OpenSpec configuration and directory structure for specification files.

### 4. Configure OpenWiki

**Personal mode** (local knowledge base at `~/.openwiki/wiki`):
```bash
openwiki personal --init
openwiki personal --update
```
Sources: local repos, Gmail, Notion, Web Search, Hacker News, X/Twitter.

**Code mode** (repository documentation at `./openwiki/`):
```bash
openwiki --init
openwiki --update
```
Generates documentation from the current codebase.

Environment config: `~/.openwiki/.env`

### 5. Install Understand Anything (opencode plugin)

```bash
curl -fsSL https://raw.githubusercontent.com/Egonex-AI/Understand-Anything/main/install.sh | bash
# or via opencode:
opencode plugin marketplace add Egonex-AI/Understand-Anything
opencode plugin install understand-anything
```

### 6. Install Agentic Awesome Skills

```bash
npx agentic-awesome-skills --path .agents/skills --category development,backend --risk safe,none
```
Installs curated skills into `.agents/skills/` for use with agentic workflows.

## Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| OpenSpec config | Project root (created by `openspec init`) | Spec-driven development settings |
| OpenWiki env | `~/.openwiki/.env` | API keys, source configuration |
| Agent skills | `.agents/skills/` | Installed skill definitions |

## Verification Checklist

- [ ] `openspec --version` returns version string
- [ ] `openwiki --version` returns version string
- [ ] `opencode plugin list` shows `understand-anything`
- [ ] `.agents/skills/` contains development/backend skills
- [ ] `openwiki --update` generates docs in `./openwiki/`
- [ ] `openwiki personal --update` populates `~/.openwiki/wiki/`

## Integration Points

- **OpenSpec** drives the specification → code workflow for the FastAPI + Vuetify stack
- **OpenWiki code mode** produces living documentation consumed by LLMs and developers
- **Understand Anything** enables natural-language codebase queries in opencode
- **Agentic Skills** provide reusable automation for backend/frontend tasks

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| `openspec` command not found | Ensure npm global bin is in PATH (`npm config get prefix`) |
| OpenWiki personal init fails | Check `~/.openwiki/.env` for valid API keys |
| Agent skills install fails | Run with `--risk safe,none` to avoid elevated-permission skills |
| Understand Anything not loading | Restart opencode after plugin install |

## Next Steps

After setup complete:
1. Define project specifications in OpenSpec format
2. Run `openspec generate` to scaffold FastAPI/Vuetify structure
3. Use `openwiki --update` to maintain living docs
4. Leverage agent skills for repetitive development tasks