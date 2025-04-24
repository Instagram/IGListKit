/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "IGListAdapterDelegateAnnouncerInternal.h"

@implementation IGListAdapterDelegateAnnouncer {
    NSHashTable<id<IGListAdapterDelegate>> *_delegates;
}

+ (instancetype)sharedInstance {
    static IGListAdapterDelegateAnnouncer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

- (void)addListener:(id<IGListAdapterDelegate>)listener {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }

    [_delegates addObject:listener];
}

- (void)removeListener:(id<IGListAdapterDelegate>)listener {
    [_delegates removeObject:listener];
}

- (void)announceObjectDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object index:(NSInteger)index {
    for (id<IGListAdapterDelegate> delegate in [_delegates allObjects]) {
        [delegate listAdapter:listAdapter willDisplayObject:object atIndex:index];
    }
}

- (void)announceObjectEndDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object index:(NSInteger)index {
    for (id<IGListAdapterDelegate> delegate in [_delegates allObjects]) {
        [delegate listAdapter:listAdapter didEndDisplayingObject:object atIndex:index];
    }
}

- (void)announceCellDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object cell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    for (id<IGListAdapterDelegate> delegate in [_delegates allObjects]) {
        [delegate listAdapter:listAdapter willDisplayObject:object cell:cell atIndexPath:indexPath];
    }
}

- (void)announceCellEndDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object cell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    for (id<IGListAdapterDelegate> delegate in [_delegates allObjects]) {
        [delegate listAdapter:listAdapter didEndDisplayingObject:object cell:cell atIndexPath:indexPath];
    }
}

@end
