/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListUpdateCoalescer.h"

@implementation IGListUpdateCoalescer {
    BOOL _hasQueuedUpdate;
}

- (void)queueUpdate {
    if (_hasQueuedUpdate) {
        return;
    }
    
    // dispatch_async to give the main queue time to collect more batch updates so that a minimum amount of work
    // (diffing, etc) is done on main. dispatch_async does not garauntee a full runloop turn will pass though.
    // see -performUpdateWithCollectionViewBlock:animated:sectionDataBlock:applySectionDataBlock:completion: for more
    // details on how coalescence is done.
    _hasQueuedUpdate = YES;
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf _performUpdate];
    });
}

- (void)_performUpdate {
    _hasQueuedUpdate = NO;
    [self.delegate performUpdateWithCoalescer:self];
}

@end
