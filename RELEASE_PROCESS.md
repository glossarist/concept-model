# Release Process

This document describes how to cut a release of the Glossarist concept-model.

## When to release

Cut a tag whenever a PR merge touches `ontologies/` or `schemas/`.
Skip otherwise (CI-only changes, README tweaks, example-only updates
do not need a release).

The `release-reminder.yml` workflow posts a comment on merged PRs that
touch these paths, reminding the maintainer to cut a tag.

## Semver policy

| Bump | When |
|------|------|
| **MAJOR** (vN+1.0.0) | Removed or renamed shape, class, property, prefix binding, or enum value |
| **MINOR** (vN.N+1.0) | New shapes, classes, properties, enum values; backward-compatible additive |
| **PATCH** (vN.N.N+1) | Shape bug fixes, doc/comment-only changes, example updates |

### Prefix and IRI semantics

A prefix spelling change (e.g. `xl:` → `skosxl:`) is **MINOR** if the
underlying IRI binding is unchanged. RDF consumers operate on IRIs,
not prefix spellings.

### SHACL shape additions

Adding a new SHACL shape is **MINOR** — it validates new types but
does not reject data that was previously valid (the shape only fires
on instances claiming its target class).

Adding a new `sh:minCount` or `sh:maxCount` constraint to an existing
shape is **MAJOR** — it can reject previously valid data.

## Release checklist

1. **Verify the diff.** `git log vPREV..HEAD --oneline` — confirm all
   changes are accounted for in `CHANGELOG.md`.

2. **Update docs.**
   - Add release entry to `RELEASE_NOTES.md` (consumer-facing impact)
   - Move `[Unreleased]` entries to the new version in `CHANGELOG.md`
   - Verify the semver bump matches the policy above

3. **Commit.** Create a PR with the doc updates. Rebase-merge to main.

4. **Tag.** Cut the tag on the merged commit:
   ```bash
   git tag v3.X.Y
   git push origin v3.X.Y
   ```
   The tag push triggers the `release.yml` workflow, which creates the
   GitHub Release with auto-generated notes.

5. **Notify consumers.** Open issues in glossarist-ruby, glossarist-js,
   and concept-browser to bump their vendored pin:
   - glossarist-ruby: `rake glossarist:sync:model[v3.X.Y]`
   - glossarist-js: update the vendored copy
   - concept-browser: update `data/concept-model/`

## Consumer contract

Consumers vendor concept-model artifacts:
- `ontologies/glossarist.ttl`
- `ontologies/glossarist.context.jsonld`
- `ontologies/shapes/glossarist.shacl.ttl`
- `ontologies/prefixes.ttl`
- `ontologies/taxonomies/*.ttl`

Consumers should:
- Pin to a tag (record it in `SOURCE.json` or equivalent)
- Bump deliberately when ready for new shapes/classes
- Detect drift via the `schema_version` field
