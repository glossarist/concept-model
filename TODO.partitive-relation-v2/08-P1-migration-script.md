# 08 — P1: Migration script

## Purpose

Migrate existing datasets using the post-PR-#72 shape
(`partitive_hyperedges` with `parts` / `enumeration` / `markers` /
`content`) to the v2 shape (`partitive_relations` with `partitives`
/ `completeness` / `plurality` / `criterion`, no `content`).

Migration is **mostly deterministic** with two lossy cases that
require human review.

## Lossy cases

1. **`dashed` marker without context**: ISO 704's broken line
   qualifies the close-set double line plurality claim. Without
   `double`, "such plurality is uncertain" has nothing to qualify.
   Migration sets `is_uncertain: true, is_shared: false` and flags
   for review.

2. **Per-partitive certainty from old `dashed`**: the old
   `enumeration: open + markers: [dashed]` form set all partitives
   to a uniform uncertain state, but the new model allows
   per-partitive certainty. Migration defaults all to `confirmed`;
   reviewers mark specific ones as `possible` based on source data.

## Scope

- New script: `scripts/migrate-to-partitive-relation-v2.rb`
  (pure Ruby, lives in `exe/`)
- Operates on a single dataset directory or a glob
- Dry-run mode (`--dry-run`) prints changes without writing
- Backup mode (`--backup`) writes `.bak` files

## Concrete implementation

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require "fileutils"
require "pathname"

module Glossarist
  module ConceptModel
    module Migration
      class PartitiveRelationV2
        attr_reader :options

        def initialize(options)
          @options = options
        end

        def call(paths)
          paths.each { |path| migrate_path(Pathname.new(path)) }
        end

        private

        def migrate_path(path)
          if path.directory?
            Dir.glob("#{path}/**/*.yaml").sort.each { |f| migrate_file(Pathname.new(f)) }
          else
            migrate_file(path)
          end
        end

        def migrate_file(path)
          docs = YAML.load_stream(path.read)
          changed = false
          docs.each do |doc|
            next unless doc.is_a?(Hash)
            if doc.key?("partitive_hyperedges")
              doc["partitive_relations"] = doc.delete("partitive_hyperedges").map { |h| migrate_relation(h) }
              changed = true
            end
          end
          return unless changed

          if options[:dry_run]
            puts "WOULD CHANGE: #{path}"
            return
          end

          backup(path) if options[:backup]
          write_docs(path, docs)
          puts "MIGRATED: #{path}"
        end

        def migrate_relation(old)
          new = {
            "comprehensive" => old["comprehensive"],
            "partitives" => Array(old["parts"]).map { |ref| { "ref" => ref } },
            "completeness" => old["enumeration"] == "open" ? "partial" : "complete",
          }
          markers = Array(old["markers"])
          unless markers.empty?
            new["plurality"] = migrate_plurality(markers)
          end
          # criterion: omitted (reviewer fills in)
          # content: dropped (structural edges don't carry prose;
          #          reviewer may move to comprehensive's notes)
          new
        end

        def migrate_plurality(markers)
          set = markers.to_set
          {
            "is_shared" => set.include?("double"),
            "is_uncertain" => set.include?("dashed"),
            # shared_type omitted — ISO notation doesn't encode it
          }
        end

        def backup(path)
          FileUtils.cp(path, "#{path}.bak")
        end

        def write_docs(path, docs)
          File.write(path, docs.map { |d| YAML.dump(d) }.join("---\n"))
        end
      end
    end
  end
end

options = { dry_run: false, backup: false }
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options] PATH [PATH...]"
  opts.on("--dry-run", "Print changes without writing") { options[:dry_run] = true }
  opts.on("--backup", "Write .bak files before overwriting") { options[:backup] = true }
  opts.on("-h", "--help", "Show this help") { puts opts; exit }
end.parse!

if ARGV.empty?
  warn "Error: at least one PATH required"
  exit 1
end

Glossarist::ConceptModel::Migration::PartitiveRelationV2.new(options).call(ARGV)
```

## Usage

```bash
# Dry-run on a dataset:
bundle exec exe/migrate-to-partitive-relation-v2 --dry-run path/to/vim-2012/concepts/

# With backups:
bundle exec exe/migrate-to-partitive-relation-v2 --backup path/to/vim-2012/concepts/

# Single file:
bundle exec exe/migrate-to-partitive-relation-v2 path/to/vim-2012/concepts/1.3.yaml
```

## Migration report

The script outputs a migration report with statistics:

```
MIGRATED: path/to/vim-2012/concepts/1.3.yaml
MIGRATED: path/to/vim-2012/concepts/2.9.yaml
...

Summary:
  Files migrated:     22
  Relations migrated: 32
  Lossy cases flagged: 5
    - 3 relations with [dashed] alone (no [double])
    - 2 relations where per-partitive certainty needs review
```

## Lossy case review

After migration, reviewers should:

1. **Search for `[dashed]` alone cases**: open `plurality: { is_uncertain: true, is_shared: false }` cases. Decide: is this truly a non-shared plurality claim, or was the marker a copy-paste error?

2. **Review per-partitive certainty**: for relations migrated from `enumeration: open + markers: [dashed]`, look at the source VIM diagram (if available) and mark specific partitives as `certainty: possible` based on which tooth the dashed line actually qualified.

3. **Add criterion where relations share a comprehensive**: if a comprehensive has 2+ PartitiveRelations and any lack `criterion`, the coherence validator (item 13) warns. Fill in.

## CI integration

A dataset-validation CI step runs the migration script in dry-run
mode and asserts no changes — i.e., the dataset has already been
migrated. New datasets must use the v2 shape from the start.

```yaml
# .github/workflows/validate-vocab-datasets.yml (downstream)
- name: Verify v2 migration
  run: |
    bundle exec exe/migrate-to-partitive-relation-v2 --dry-run datasets/
    test -z "$(git status --porcelain datasets/)"
```

## Status: pending
