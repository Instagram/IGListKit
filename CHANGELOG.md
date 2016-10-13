# CHANGELOG

The changelog for `IGListKit`. Also see the [releases](https://github.com/instagram/IGListKit/releases) on GitHub.

## Master

- Fixed `-[IGListAdapter reloadDataWithCompletion:]` not returning early when `collectionView` or `dataSource` is nil and `completion` is nil. [Ben Asher](https://github.com/benasher44) [#51](https://github.com/Instagram/IGListKit/pull/51)
- Added `-isFirstSection` and `-isLastSection` APIs to `IGListSectionController`

1.0.0
-----

Initial release. :tada:
