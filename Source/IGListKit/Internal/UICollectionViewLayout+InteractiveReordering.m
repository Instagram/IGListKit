/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UICollectionViewLayout+InteractiveReordering.h"

#import <objc/runtime.h>

#import "IGListAdapterInternal.h"
#import "IGListSectionController.h"

@implementation UICollectionViewLayout (InteractiveReordering)

static void * kIGListAdapterKey = &kIGListAdapterKey;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class layoutClass = [self class];

        // override implementation for targetIndexPathForInteractivelyMovingItem:withPosition:
        SEL userMoveSelector = @selector(targetIndexPathForInteractivelyMovingItem:withPosition:);
        SEL overrideMoveSelector = @selector(ig_targetIndexPathForInteractivelyMovingItem:withPosition:);
        Method userMoveMethod = class_getInstanceMethod(layoutClass, userMoveSelector);
        Method overrideMoveMethod = class_getInstanceMethod(layoutClass, overrideMoveSelector);
        IMP userMoveIMP = method_getImplementation(userMoveMethod);
        IMP overrideMoveIMP = method_getImplementation(overrideMoveMethod);
        class_replaceMethod(layoutClass, overrideMoveSelector, userMoveIMP, method_getTypeEncoding(userMoveMethod));
        class_replaceMethod(layoutClass, userMoveSelector, overrideMoveIMP, method_getTypeEncoding(overrideMoveMethod));

        // override implementation for
        // invalidationContextForInteractivelyMovingItems:withTargetPosition:previousIndexPaths:previousPosition:
        SEL userInvalidationSelector =
        @selector(invalidationContextForInteractivelyMovingItems:withTargetPosition:previousIndexPaths:previousPosition:);
        SEL overrideInvalidationSelector =
        @selector(ig_invalidationContextForInteractivelyMovingItems:withTargetPosition:previousIndexPaths:previousPosition:);
        Method userInvalidationMethod = class_getInstanceMethod(layoutClass, userInvalidationSelector);
        Method overrideInvalidationMethod = class_getInstanceMethod(layoutClass, overrideInvalidationSelector);
        IMP userInvalidationIMP = method_getImplementation(userInvalidationMethod);
        IMP overrideInvalidationIMP = method_getImplementation(overrideInvalidationMethod);
        class_replaceMethod(layoutClass, overrideInvalidationSelector, userInvalidationIMP, method_getTypeEncoding(userInvalidationMethod));
        class_replaceMethod(layoutClass, userInvalidationSelector, overrideInvalidationIMP, method_getTypeEncoding(overrideInvalidationMethod));

        // override implementation for
        // invalidationContextForInteractivelyMovingItems:withTargetPosition:previousIndexPaths:previousPosition:
        SEL userEndInvalidationSelector =
        @selector(invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:previousIndexPaths:movementCancelled:);
        SEL overrideEndInvalidationSelector =
        @selector(ig_invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:previousIndexPaths:movementCancelled:);
        Method userEndInvalidationMethod = class_getInstanceMethod(layoutClass, userEndInvalidationSelector);
        Method overrideEndInvalidationMethod = class_getInstanceMethod(layoutClass, overrideEndInvalidationSelector);
        IMP userEndInvalidationIMP = method_getImplementation(userEndInvalidationMethod);
        IMP overrideEndInvalidationIMP = method_getImplementation(overrideEndInvalidationMethod);
        class_replaceMethod(layoutClass, overrideEndInvalidationSelector, userEndInvalidationIMP, method_getTypeEncoding(userEndInvalidationMethod));
        class_replaceMethod(layoutClass, userEndInvalidationSelector, overrideEndInvalidationIMP, method_getTypeEncoding(overrideEndInvalidationMethod));
    });
}

- (void)ig_hijackLayoutInteractiveReorderingMethodForAdapter:(IGListAdapter *)adapter {
    objc_setAssociatedObject(self, kIGListAdapterKey, adapter, OBJC_ASSOCIATION_ASSIGN);
}

- (NSIndexPath *)ig_targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath
                                                 withPosition:(CGPoint)position NS_AVAILABLE_IOS(9_0) {
    // call looks recursive, but through swizzling is calling the original implementation for
    // targetIndexPathForInteractivelyMovingItem:withPosition:
    NSIndexPath *originalTarget = [self ig_targetIndexPathForInteractivelyMovingItem:previousIndexPath
                                                                        withPosition:position];

    IGListAdapter *adapter = (IGListAdapter *)objc_getAssociatedObject(self, kIGListAdapterKey);
    if (adapter == nil) {
        return originalTarget;
    }

    NSIndexPath *updatedTarget = [self updatedTargetForInteractivelyMovingItem:previousIndexPath
                                                                   toIndexPath:originalTarget
                                                                       adapter:adapter];

    return updatedTarget ?: originalTarget;
}

- (nullable NSIndexPath *)updatedTargetForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath
                                                      toIndexPath:(NSIndexPath *)originalTarget
                                                          adapter:(IGListAdapter *)adapter {
    const NSInteger sourceSectionIndex = previousIndexPath.section;
    NSInteger destinationSectionIndex = originalTarget.section;
    NSInteger destinationItemIndex = originalTarget.item;

    IGListSectionController *sourceSectionController = [adapter sectionControllerForSection:sourceSectionIndex];
    IGListSectionController *destinationSectionController = [adapter sectionControllerForSection:destinationSectionIndex];

    adapter.isLastInteractiveMoveToLastSectionIndex = NO;

    // this is a reordering of sections themselves
    if ([sourceSectionController numberOfItems] == 1
        && [destinationSectionController numberOfItems] == 1) {

        if (destinationItemIndex == 1) {
            // the "item" representing our section was dropped
            // into the end of a destination section rather than the beginning
            // so it really belongs one section after the section where it landed
            if (destinationSectionIndex < [[adapter objects] count] - 1) {
                destinationSectionIndex += 1;
                destinationItemIndex = 0;
            }
            else {
                // if we're moving an item to the last spot, our index would exceed the number of sections available
                // so we have to special case this scenario. iOS doesnt allow an item move to "create" a new section
                adapter.isLastInteractiveMoveToLastSectionIndex = YES;
            }
            NSIndexPath *updatedTarget = [NSIndexPath indexPathForItem:destinationItemIndex
                                                             inSection:destinationSectionIndex];
            return updatedTarget;
        }
    }

    return nil;
}

- (UICollectionViewLayoutInvalidationContext *)ig_invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition {

    // call looks recursive, but through swizzling is calling the original implementation for
    // invalidationContextForInteractivelyMovingItems:withTargetPosition:previousIndexPaths:previousPosition:
    UICollectionViewLayoutInvalidationContext *originalContext =
    [self ig_invalidationContextForInteractivelyMovingItems:targetIndexPaths withTargetPosition:targetPosition previousIndexPaths:previousIndexPaths previousPosition:previousPosition];

    return [self ig_cleanupInvalidationContext:originalContext];
}

- (UICollectionViewLayoutInvalidationContext *)ig_invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled {

    // call looks recursive, but through swizzling is calling the original implementation for
    // invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:previousIndexPaths:movementCancelled:
    UICollectionViewLayoutInvalidationContext *originalContext =
    [self ig_invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:indexPaths previousIndexPaths:previousIndexPaths movementCancelled:movementCancelled];

    return [self ig_cleanupInvalidationContext:originalContext];
}

- (UICollectionViewLayoutInvalidationContext *)ig_cleanupInvalidationContext:(UICollectionViewLayoutInvalidationContext *)originalContext {
    IGListAdapter *adapter = (IGListAdapter *)objc_getAssociatedObject(self, kIGListAdapterKey);
    if (adapter == nil || !self.collectionView) {
        return originalContext;
    }

    const NSInteger numSections = [adapter numberOfSectionsInCollectionView:(UICollectionView * _Nonnull)self.collectionView];

    // protect against invalidating an index path that no longer exists
    // (like item 1 in the last section after interactively reordering an item to the end of a list of 1 item sections)
    if ([originalContext.invalidatedItemIndexPaths count] > 0) {
        NSUInteger indexToRemove = NSNotFound;

        indexToRemove = [originalContext.invalidatedItemIndexPaths indexOfObjectPassingTest:
                         ^BOOL(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                             if (obj.section == numSections-1) {
                                 IGListSectionController *section = [adapter sectionControllerForSection:obj.section];
                                 return obj.item > [section numberOfItems] - 1;
                             }
                             return NO;
                         }];

        if (indexToRemove != NSNotFound) {
            NSMutableArray<NSIndexPath *> *invalidatedItemIndexPaths = [originalContext.invalidatedItemIndexPaths mutableCopy];
            [invalidatedItemIndexPaths removeObjectAtIndex:indexToRemove];

            UICollectionViewLayoutInvalidationContext *modifiedContext;
            if ([originalContext isKindOfClass:[UICollectionViewFlowLayoutInvalidationContext class]]) {
                // UICollectionViewFlowLayout has a special invalidation context subclass
                UICollectionViewFlowLayoutInvalidationContext *flowModifiedContext =
                [[self.class invalidationContextClass] new];

                flowModifiedContext.invalidateFlowLayoutDelegateMetrics =
                [(UICollectionViewFlowLayoutInvalidationContext *)originalContext invalidateFlowLayoutDelegateMetrics];
                flowModifiedContext.invalidateFlowLayoutAttributes =
                [(UICollectionViewFlowLayoutInvalidationContext *)originalContext invalidateFlowLayoutAttributes];
                modifiedContext = flowModifiedContext;
            }
            else {
                modifiedContext = [[self.class invalidationContextClass] new];
            }

            [modifiedContext invalidateItemsAtIndexPaths:invalidatedItemIndexPaths];
            [self ig_invalidateAccessoryElementsWithSupplementaryIndexPaths:originalContext.invalidatedSupplementaryIndexPaths
                                                       decorationIndexPaths:originalContext.invalidatedDecorationIndexPaths
                                                                  inContext:modifiedContext];
            modifiedContext.contentOffsetAdjustment = originalContext.contentOffsetAdjustment;
            modifiedContext.contentSizeAdjustment = originalContext.contentSizeAdjustment;

            return modifiedContext;
        }
    }
    return originalContext;
}

- (void)ig_invalidateAccessoryElementsWithSupplementaryIndexPaths:(NSDictionary<NSString *, NSArray<NSIndexPath *> *> *)supplementaryIndexPaths
                                             decorationIndexPaths:(NSDictionary<NSString *, NSArray<NSIndexPath *> *> *)decorationIndexPaths
                                                        inContext:(UICollectionViewLayoutInvalidationContext *)context {
    [supplementaryIndexPaths enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<NSIndexPath *> *obj, BOOL *stop) {
        [context invalidateSupplementaryElementsOfKind:key atIndexPaths:obj];
    }];
    [decorationIndexPaths enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<NSIndexPath *> *obj, BOOL *stop) {
        [context invalidateDecorationElementsOfKind:key atIndexPaths:obj];
    }];
}

@end
