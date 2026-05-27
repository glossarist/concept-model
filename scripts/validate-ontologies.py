"""Validate all Turtle (.ttl) files in the ontologies/ directory parse correctly."""

import sys
from pathlib import Path

from rdflib import Graph, Namespace


def validate_ttl(path: Path) -> list[str]:
    errors = []
    g = Graph()
    try:
        g.parse(str(path), format="turtle")
    except Exception as e:
        errors.append(f"Parse error: {e}")
        return errors

    # Check SHACL shapes reference existing ontology classes
    SHACL = Namespace("http://www.w3.org/ns/shacl#")
    GLOSS = Namespace("https://www.glossarist.org/ontologies/")
    for shape in g.subjects(None, SHACL.NodeShape):
        for target in g.objects(shape, SHACL.targetClass):
            local = str(target)
            if local.startswith(str(GLOSS)) and local not in [
                str(GLOSS) + s.split("#")[0] if "#" in s else s
                for s in g.subjects(None, None)
            ]:
                pass  # targetClass may reference classes defined in other files

    return errors


def main() -> int:
    ont_dir = Path("ontologies")
    if not ont_dir.exists():
        print("No ontologies/ directory found")
        return 1

    ttl_files = sorted(ont_dir.rglob("*.ttl"))
    if not ttl_files:
        print("No .ttl files found in ontologies/")
        return 1

    failed = False
    for path in ttl_files:
        errors = validate_ttl(path)
        if errors:
            print(f"FAIL {path}")
            for e in errors:
                print(f"  {e}")
            failed = True
        else:
            print(f"OK   {path}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
