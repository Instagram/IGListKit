/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListAutoSectionController.h"

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListBindable.h>

typedef NS_ENUM(NSInteger, IGListAutoSectionState) {
    IGListAutoSectionStateIdle = 0,
    IGListAutoSectionStateUpdateQueued,
    IGListAutoSectionStateUpdateApplied
};

@interface IGListAutoSectionController()

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSArray<id<IGListDiffable>> *viewModels;
@property (nonatomic, assign) IGListAutoSectionState state;

@end

@implementation IGListAutoSectionController

#pragma mark - Public API

- (void)updateAnimated:(BOOL)animated completion:(void (^)())completion {
    IGAssertMainThread();

    if (self.state != IGListAutoSectionStateIdle) {
        return;
    }
    self.state = IGListAutoSectionStateUpdateQueued;

    __block IGListIndexSetResult *result = nil;
    __block NSArray<id<IGListDiffable>> *oldViewModels = nil;

    id<IGListCollectionContext> collectionContext = self.collectionContext;

    [collectionContext performBatchAnimated:YES updates:^{
        if (self.state != IGListAutoSectionStateUpdateQueued) {
            return;
        }

        oldViewModels = self.viewModels;
        self.viewModels = [self.dataSource viewModelsForObject:self.object];
        result = IGListDiff(oldViewModels, self.viewModels, IGListDiffEquality);

        [collectionContext deleteInSectionController:self atIndexes:result.deletes];
        [collectionContext insertInSectionController:self atIndexes:result.inserts];

        for (IGListMoveIndex *move in result.moves) {
            [collectionContext moveInSectionController:self fromIndex:move.from toIndex:move.to];
        }

        self.state = IGListAutoSectionStateUpdateApplied;
    } completion:^(BOOL finished) {
        self.state = IGListAutoSectionStateIdle;

        // "reload" cells after updating since the cells can't be moved and reloaded at the same time.
        // this lets the cell do an animated move and then update its contents
        [result.updates enumerateIndexesUsingBlock:^(NSUInteger oldUpdatedIndex, BOOL *stop) {
            id identifier = [oldViewModels[oldUpdatedIndex] diffIdentifier];
            const NSInteger indexAfterUpdate = [result newIndexForIdentifier:identifier];
            if (indexAfterUpdate != NSNotFound) {
                UICollectionViewCell<IGListBindable> *cell = [collectionContext cellForItemAtIndex:indexAfterUpdate
                                                                                 sectionController:self];
                [cell bindViewModel:self.viewModels[indexAfterUpdate]];
            }
        }];
    }];
}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return self.viewModels.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return [self.dataSource sizeForViewModel:self.viewModels[index]];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    id<IGListDiffable> viewModel = self.viewModels[index];
    UICollectionViewCell<IGListBindable> *cell = [self.dataSource cellForViewModel:viewModel atIndex:index];
    [cell bindViewModel:viewModel];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    id oldObject = self.object;
    self.object = object;

    if (oldObject == nil) {
        self.viewModels = [self.dataSource viewModelsForObject:object];
    } else {
        [self updateAnimated:YES completion:nil];
    }
//    self.viewModels = [self.dataSource viewModelsForObject:object];

    // atm this will queue an update next turn which isn't ideal. really we want to unload this update right here and now
    // maybe we can update performBatchAnimated:completion to fire if we're inside an update block?
//    [self updateAnimated:YES completion:nil];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    // would be nice to have a "selection delegate" here
}

@end
