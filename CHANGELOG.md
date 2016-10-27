# CHANGELOG

The changelog for `IGListKit`. Also see the [releases](https://github.com/instagram/IGListKit/releases) on GitHub.

2.0.0
-----

This release closes the [2.0.0 milestone](https://github.com/Instagram/IGListKit/milestone/1?closed=1).

### Breaking Changes

- Diff result method `-resultWithUpdatedMovesAsDeleteInserts` removed and replaced with `-resultForBatchUpdates`

### Enhancements

- Added support for cells created from nibs. [Sven Bacia](https://github.com/svenbacia) [(#56)](https://github.com/Instagram/IGListKit/pull/56)
- Added an additional initializer for `IGListSingleSectionController` to be able to support single sections created from nibs. An example can be found [here](Example/IGListKitExamples/ViewControllers/SingleSectionViewController.swift). 
- Fixed `-[IGListAdapter reloadDataWithCompletion:]` not returning early when `collectionView` or `dataSource` is nil and `completion` is nil. [Ben Asher](https://github.com/benasher44) [(#51)](https://github.com/Instagram/IGListKit/pull/51)
- Added `-isFirstSection` and `-isLastSection` APIs to `IGListSectionController`
- Added support for cells created from storyboard. [Bofei Zhu](https://github.com/zhubofei) [(#92)](https://github.com/Instagram/IGListKit/pull/92)

1.0.0
-----

Initial release. :tada:
