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

    data, tolerance = load_data(data_path)

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
        "context_tolerance": tolerance,
        "violations": violations,
    }))


def load_data(data_path):
    """Parses JSON-LD data; tolerates the rdflib parser crash on a
    `"@language": {"@container": "@language"}` context term.

    rdflib 7.6.0 raises TypeError when the context defines @language as
    a term (seen in OIML aggregates). The fallback drops that context
    entry and retries — but ONLY when no node body in the document uses
    an "@language" key (verified first), making the retry semantically
    inert. The applied tolerance is reported as `context_tolerance`.
    """
    import json as _json

    from rdflib import Graph

    def raw_doc():
        with open(data_path, encoding="utf-8") as f:
            return _json.load(f)

    try:
        return Graph().parse(data_path, format="json-ld"), None
    except TypeError:
        pass  # context "@language" term bug → tolerant retry below
    except ValueError as e:
        # orjson/json.JSONDecodeError — invalid or empty JSON
        err(f"cannot parse data {data_path} as JSON-LD: {e}", 4)

    try:
        doc = raw_doc()
    except Exception as e:  # noqa: BLE001
        err(f"cannot read data {data_path} as JSON: {e}", 4)

    def uses_language_key(obj):
        if isinstance(obj, dict):
            if "@language" in obj:
                return True
            return any(uses_language_key(v) for v in obj.values())
        if isinstance(obj, list):
            return any(uses_language_key(v) for v in obj)
        return False

    body = doc.get("@graph", doc)
    if uses_language_key(body):
        err(f"{data_path}: rdflib JSON-LD parser failed and the document "
            f"actually uses an @language key, so the context workaround "
            f"is not applicable", 4)

    context = doc.get("@context")
    if isinstance(context, dict):
        context.pop("@language", None)
    try:
        graph = Graph().parse(data=_json.dumps(doc), format="json-ld")
    except Exception as e:  # noqa: BLE001
        err(f"cannot parse data {data_path} as JSON-LD: {e}", 4)
    return graph, ("dropped unused @language container term from context "
                   "(rdflib JSON-LD parser TypeError)")


if __name__ == "__main__":
    main()
