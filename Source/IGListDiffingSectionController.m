/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListDiffingSectionController.h"

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListBindable.h>

typedef NS_ENUM(NSInteger, IGListDiffingSectionState) {
    IGListDiffingSectionStateIdle = 0,
    IGListDiffingSectionStateUpdateQueued,
    IGListDiffingSectionStateUpdateApplied
};

@interface IGListDiffingSectionController()

@property (nonatomic, strong, readwrite) NSArray<id<IGListDiffable>> *viewModels;

@property (nonatomic, strong) id object;
@property (nonatomic, assign) IGListDiffingSectionState state;

@end

@implementation IGListDiffingSectionController

#pragma mark - Public API

- (void)updateAnimated:(BOOL)animated completion:(void (^)())completion {
    IGAssertMainThread();

    if (self.state != IGListDiffingSectionStateIdle) {
        return;
    }
    self.state = IGListDiffingSectionStateUpdateQueued;

    __block IGListIndexSetResult *result = nil;
    __block NSArray<id<IGListDiffable>> *oldViewModels = nil;

    id<IGListCollectionContext> collectionContext = self.collectionContext;

    [collectionContext performBatchAnimated:YES updates:^{
        if (self.state != IGListDiffingSectionStateUpdateQueued) {
            return;
        }

        oldViewModels = self.viewModels;
        self.viewModels = [self.dataSource sectionController:self viewModelsForObject:self.object];
        result = IGListDiff(oldViewModels, self.viewModels, IGListDiffEquality);

        [collectionContext deleteInSectionController:self atIndexes:result.deletes];
        [collectionContext insertInSectionController:self atIndexes:result.inserts];

        for (IGListMoveIndex *move in result.moves) {
            [collectionContext moveInSectionController:self fromIndex:move.from toIndex:move.to];
        }

        self.state = IGListDiffingSectionStateUpdateApplied;
    } completion:^(BOOL finished) {
        self.state = IGListDiffingSectionStateIdle;

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
    return [self.dataSource sectionController:self sizeForViewModel:self.viewModels[index]];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    id<IGListDiffable> viewModel = self.viewModels[index];
    UICollectionViewCell<IGListBindable> *cell = [self.dataSource sectionController:self cellForViewModel:viewModel atIndex:index];
    [cell bindViewModel:viewModel];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    id oldObject = self.object;
    self.object = object;

    if (oldObject == nil) {
        self.viewModels = [self.dataSource sectionController:self viewModelsForObject:object];
    } else {
        [self updateAnimated:YES completion:nil];
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didSelectItemAtIndex:index viewModel:self.viewModels[index]];
}

@end
