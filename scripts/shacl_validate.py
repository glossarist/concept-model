#!/usr/bin/env python3
"""SHACL validation harness helper.

Requires: python3 with pyshacl (which brings rdflib):
    python3 -m pip install pyshacl

Called by exe/validate-shacl for each data file; prints one JSON object
on stdout summarizing the validation of that file. Exits 0 on success
(regardless of conformity — the caller reads `conforms`), 3 on tooling
errors (pyshacl/rdflib missing), 4 on unparseable input.

Usage:
    shacl_validate.py <shapes.ttl> <data.jsonld>
"""

import json
import sys

SH = "http://www.w3.org/ns/shacl#"
RDF = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
RDFS = "http://www.w3.org/2000/01/rdf-schema#"


def err(message, code=3):
    print(json.dumps({"error": message}), file=sys.stderr)
    sys.exit(code)


# Exit codes: 3 = tooling unavailable (pyshacl/rdflib missing),
# 4 = input cannot be parsed. The caller must distinguish them.


def main():
    if len(sys.argv) != 3:
        err("usage: shacl_validate.py <shapes.ttl> <data.jsonld>")

    try:
        from pyshacl import validate
        from rdflib import Graph, URIRef, BNode
    except ImportError as e:
        err(f"pyshacl/rdflib unavailable: {e}. Install with: python3 -m pip install pyshacl", 3)

    shapes_path, data_path = sys.argv[1], sys.argv[2]

    try:
        shapes = Graph().parse(shapes_path, format="turtle")
    except Exception as e:  # noqa: BLE001
        err(f"cannot parse shapes {shapes_path}: {e}", 4)

    try:
        data = Graph().parse(data_path, format="json-ld")
    except Exception as e:  # noqa: BLE001
        err(f"cannot parse data {data_path} as JSON-LD: {e}", 4)

    # Targeted-node census: how many data nodes do the shapes actually
    # reach? A conformant run with zero targeted nodes is a vacuous pass
    # — the caller surfaces this instead of hiding it.
    targeted = set()
    for target_class in shapes.objects(None, URIRef(f"{SH}targetClass")):
        targeted.update(data.subjects(URIRef(f"{RDF}type"), target_class))
        # include instances of declared subclasses, one hop deep
        for sub in data.subjects(URIRef(f"{RDFS}subClassOf"), target_class):
            targeted.update(data.subjects(URIRef(f"{RDF}type"), sub))
    for pred in shapes.objects(None, URIRef(f"{SH}targetSubjectsOf")):
        targeted.update(data.subjects(pred, None))

    conforms, results_graph, _text = validate(
        data,
        shacl_graph=shapes,
        inference="none",
        advanced=True,
    )

    violations = []
    for result in results_graph.subjects(URIRef(f"{RDF}type"), URIRef(f"{SH}ValidationResult")):
        def val(pred):
            o = results_graph.value(result, URIRef(f"{SH}{pred}"))
            return str(o) if o is not None else None

        violations.append({
            "focus_node": val("focusNode"),
            "path": val("resultPath"),
            "value": val("value"),
            "component": (val("sourceConstraintComponent") or "").replace(SH, "sh:"),
            "message": val("resultMessage"),
        })

    print(json.dumps({
        "conforms": bool(conforms),
        "targeted_nodes": len(targeted),
        "data_triples": len(data),
        "violations": violations,
    }))


if __name__ == "__main__":
    main()
