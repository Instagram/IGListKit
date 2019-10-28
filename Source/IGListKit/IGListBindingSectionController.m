/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListBindingSectionController.h"

#import <IGListDiffKit/IGListAssert.h>
#import <IGListKit/IGListBindable.h>

#import "IGListArrayUtilsInternal.h"

typedef NS_ENUM(NSInteger, IGListDiffingSectionState) {
    IGListDiffingSectionStateIdle = 0,
    IGListDiffingSectionStateUpdateQueued,
    IGListDiffingSectionStateUpdateApplied
};

@interface IGListBindingSectionController()

@property (nonatomic, strong, readwrite) NSArray<id<IGListDiffable>> *viewModels;

@property (nonatomic, strong) id object;
@property (nonatomic, assign) IGListDiffingSectionState state;

@end

@implementation IGListBindingSectionController

#pragma mark - Public API

- (void)updateAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    IGAssertMainThread();

    if (self.state != IGListDiffingSectionStateIdle) {
        if (completion != nil) {
            completion(NO);
        }
        return;
    }
    self.state = IGListDiffingSectionStateUpdateQueued;

    __block IGListIndexSetResult *result = nil;
    __block NSArray<id<IGListDiffable>> *oldViewModels = nil;

    id<IGListCollectionContext> collectionContext = self.collectionContext;
    [self.collectionContext performBatchAnimated:animated updates:^(id<IGListBatchContext> batchContext) {
        if (self.state != IGListDiffingSectionStateUpdateQueued) {
            return;
        }
        
        oldViewModels = self.viewModels;

        id<IGListDiffable> object = self.object;
        IGAssert(object != nil, @"Expected IGListBindingSectionController object to be non-nil before updating.");
        
        NSArray *newViewModels = [self.dataSource sectionController:self viewModelsForObject:object];
        self.viewModels = objectsWithDuplicateIdentifiersRemoved(newViewModels);
        result = IGListDiff(oldViewModels, self.viewModels, IGListDiffEquality);
        
        [result.updates enumerateIndexesUsingBlock:^(NSUInteger oldUpdatedIndex, BOOL *stop) {
            id identifier = [oldViewModels[oldUpdatedIndex] diffIdentifier];
            const NSInteger indexAfterUpdate = [result newIndexForIdentifier:identifier];
            if (indexAfterUpdate != NSNotFound) {
                UICollectionViewCell<IGListBindable> *cell = [collectionContext cellForItemAtIndex:oldUpdatedIndex
                                                                                 sectionController:self];
                [cell bindViewModel:self.viewModels[indexAfterUpdate]];
            }
        }];
        
        if (IGListExperimentEnabled(self.collectionContext.experiments, IGListExperimentInvalidateLayoutForUpdates)) {
            [batchContext invalidateLayoutInSectionController:self atIndexes:result.updates];
        }
        [batchContext deleteInSectionController:self atIndexes:result.deletes];
        [batchContext insertInSectionController:self atIndexes:result.inserts];
        
        for (IGListMoveIndex *move in result.moves) {
            [batchContext moveInSectionController:self fromIndex:move.from toIndex:move.to];
        }
        
        self.state = IGListDiffingSectionStateUpdateApplied;
    } completion:^(BOOL finished) {
        self.state = IGListDiffingSectionStateIdle;
        if (completion != nil) {
            completion(YES);
        }
    }];
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return self.viewModels.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return [self.dataSource sectionController:self sizeForViewModel:self.viewModels[index] atIndex:index];
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
        NSArray *viewModels = [self.dataSource sectionController:self viewModelsForObject:object];
        self.viewModels = objectsWithDuplicateIdentifiersRemoved(viewModels);
    } else {
#if IGLK_LOGGING_ENABLED
        if (![oldObject isEqualToDiffableObject:object]) {
            IGLKLog(@"Warning: Unequal objects %@ and %@ will cause IGListBindingSectionController to reload the entire section",
                    oldObject, object);
        }
#endif
        [self updateAnimated:YES completion:nil];
    }
}

- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSMutableArray *viewModels = [self.viewModels mutableCopy];
    
    id modelAtSource = [viewModels objectAtIndex:sourceIndex];
    [viewModels removeObjectAtIndex:sourceIndex];
    [viewModels insertObject:modelAtSource atIndex:destinationIndex];
    
    self.viewModels = viewModels;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didSelectItemAtIndex:index viewModel:self.viewModels[index]];
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didDeselectItemAtIndex:index viewModel:self.viewModels[index]];
}

- (void)didHighlightItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didHighlightItemAtIndex:index viewModel:self.viewModels[index]];
}

- (void)didUnhighlightItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didUnhighlightItemAtIndex:index viewModel:self.viewModels[index]];
}

@end
