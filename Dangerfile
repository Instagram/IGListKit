not_declared_trivial = !(github.pr_title.include? "#trivial")
has_source_changes = !git.modified_files.grep(/Source/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Changelog entries are required for changes to library files.
no_changelog_entry = !git.modified_files.include?("CHANGELOG.md")
if has_source_changes && no_changelog_entry && not_declared_trivial && git.lines_of_code > 10
  fail("Any source code changes should have an entry in CHANGELOG.md.")
end

# Docs are regenerated when releasing
has_doc_changes = !git.modified_files.grep(/docs\//).empty?
if has_doc_changes
  warn("Docs are regenerated when creating new releases.")
end

swiftlint.config_file = '.swiftlint_CI.yml'
swiftlint.lint_files
