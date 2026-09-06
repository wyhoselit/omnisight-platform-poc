# Documentation & Specifications — openspec

# Documentation & Specifications — openspec

Configuration module for OpenSpec spec-driven workflow. Defines root parameters, environment context, generation rules for AI-created project artifacts.

## File Structure

- `openspec/config.yaml`: Core configuration file.

## Configuration Schema

File use YAML. Controls artifact generation constraints.

```yaml
schema: spec-driven
context: string # Optional
rules: # Optional
  <artifact_type>:
    - string
```

### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `schema` | `string` | Yes | Workflow mode. Set to `spec-driven`. |
| `context` | `string` | No | Freeform markdown/text injected into AI prompt. Holds tech stack, repo conventions, style guides. |
| `rules` | `map[string][]string` | No | Map of artifact names (`proposal`, `tasks`, etc.) to validation and format constraints. |

## Example

```yaml
schema: spec-driven

context: |
  Tech stack: TypeScript, React, Node.js
  Git: Conventional Commits
  Domain: Core platform API

rules:
  proposal:
    - Keep proposals under 500 words
    - Always include "Non-goals" section
  tasks:
    - Break tasks into chunks of max 2 hours
```

## Integration

Module has no runtime executable code or internal call paths. External OpenSpec CLI / agent tools parse `openspec/config.yaml` before prompt compilation to enforce repo-specific rules on generated specifications.