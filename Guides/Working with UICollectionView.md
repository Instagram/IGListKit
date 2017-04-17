# Working with `UICollectionView`

This guide provides details on how to work with [`UICollectionView`](https://developer.apple.com/reference/uikit/uicollectionview) and `IGListKit`.

## Background

Early versions of `IGListKit` (v2.x and prior) shipped with a subclass of `UICollectionView` called [`IGListCollectionView`](https://github.com/Instagram/IGListKit/blob/2.1.0/Source/IGListCollectionView.h). 
The class contained *no* special functionality and was merely used to enforce compile-time restrictions to prevent users from calling certain methods directly on `UICollectionView`. 
Beginning with v3.0, `IGListCollectionView` [was removed](https://github.com/Instagram/IGListKit/commit/2284ce389708f62d99f48ff2ec15644f1ec59537) for a number of reasons. 
For further discussion, see [#240](https://github.com/Instagram/IGListKit/issues/240) and [#409](https://github.com/Instagram/IGListKit/issues/409).

## Methods to avoid

