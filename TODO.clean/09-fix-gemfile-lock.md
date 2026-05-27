# 09 - Fix Gemfile.lock gitignore inconsistency

Gemfile.lock is gitignored but the file exists and Gemfile has dependencies.
Commit the lock file for reproducible builds.
