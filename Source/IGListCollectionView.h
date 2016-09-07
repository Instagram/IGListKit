/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>

/**
 This class is never actually used by the IGListKit infrastructure. It exists only to give compiler errors when editing
 methods are called on the collection view returned by -[IGListAdapter collectionView].
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListCollectionView : UICollectionView

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion IGLK_UNAVAILABLE("Call -[IGListAdapter performUpdatesWithCompletion:] instead");

- (void)reloadData IGLK_UNAVAILABLE("Call -[IGListAdapter reloadDataWithCompletion:] instead");
- (void)reloadSections:(NSIndexSet *)sections IGLK_UNAVAILABLE("Call -[IGListAdapter reloadItems:] instead");

- (void)insertSections:(NSIndexSet *)sections IGLK_UNAVAILABLE("Call -[IGListAdapter performUpdatesWithCompletion:] instead");
- (void)deleteSections:(NSIndexSet *)sections IGLK_UNAVAILABLE("Call -[IGListAdapter performUpdatesWithCompletion:] instead");
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection IGLK_UNAVAILABLE("Call -[IGListAdapter performUpdatesWithCompletion:] instead");

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths IGLK_UNAVAILABLE("Call -[<IGListCollectionContext> insertSectionController:forItems:completion:] instead");
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths IGLK_UNAVAILABLE("Call -[<IGListCollectionContext> reloadSectionController:forItems:completion:] instead");
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths IGLK_UNAVAILABLE("Call -[<IGListCollectionContext> deleteSectionController:forItems:completion:] instead");
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath IGLK_UNAVAILABLE("Moving items currently unsupported");

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate IGLK_UNAVAILABLE("IGListAdapter should be the delegate of the collection view");
- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource IGLK_UNAVAILABLE("IGListAdapter should be the data source of the collection view");
- (void)setBackgroundView:(UIView *)backgroundView IGLK_UNAVAILABLE("Return a view in -[IGListAdapterDataSource emptyViewForListAdapter:] instead");

@end
