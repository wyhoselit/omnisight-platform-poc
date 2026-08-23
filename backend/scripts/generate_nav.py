#!/usr/bin/env python3
"""Auto-generate MkDocs nav from app/modules/ directory structure."""

import re
from pathlib import Path


def generate_nav():
    modules_dir = Path("app/modules")
    
    nav_items = {}
    for module_path in sorted(modules_dir.iterdir()):
        if module_path.is_dir() and not module_path.name.startswith("_"):
            module_name = module_path.name
            md_dir = Path(f"docs/modules/{module_name}")
            
            if md_dir.exists():
                files = sorted(md_dir.glob("*.md"))
                subsections = []
                for f in files:
                    if f.name != "index.md":
                        subsections.append(f"- {f.stem.replace('_', ' ').title()}: modules/{module_name}/{f.name}")
                
                nav_items[module_name] = (md_dir / "index.md", subsections)
    
    output = []
    output.append("nav:")
    output.append("  - Home: index.md")
    output.append("  - API Reference:")
    output.append("      - Overview: api/index.md")
    output.append("      - OpenAPI Spec: api/openapi.md")
    output.append("  - Internal Modules:")
    output.append("      - Overview: modules/index.md")
    
    for module, (index_md, subsections) in nav_items.items():
        module_title = module.replace("_", " ").title()
        output.append(f"      - {module_title}:")
        output.append(f"          - Overview: modules/{module}/index.md")
        for line in subsections:
            output.append(f"          {line}")
    
    output.append("")
    
    return "\n".join(output)


def main():
    mkdocs_path = Path("mkdocs.yml")
    
    content = mkdocs_path.read_text()
    
    nav_match = re.search(r'^nav:.*?^(?=^[^ \n]|\Z)', content, re.MULTILINE | re.DOTALL)
    
    if nav_match:
        new_nav = generate_nav()
        new_content = content[:nav_match.start()] + new_nav + content[nav_match.end():]
        mkdocs_path.write_text(new_content)
        print("Updated mkdocs.yml nav section")
    else:
        print("Could not find nav section in mkdocs.yml")


if __name__ == "__main__":
    main()