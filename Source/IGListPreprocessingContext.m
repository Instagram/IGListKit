/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListPreprocessingContext.h"
#import "IGListAssert.h"
#import <stdatomic.h>

@implementation IGListPreprocessingContext {
    dispatch_group_t _group;
    atomic_flag _completed;
}

- (instancetype)initWithObject:(id)object containerSize:(CGSize)containerSize sectionIndex:(NSInteger)sectionIndex dispatchGroup:(nonnull dispatch_group_t)group {
    if (self = [super init]) {
        _objectOfSectionController = object;
        _containerSize = containerSize;
        _sectionIndex = sectionIndex;
        _group = group;
        _completed = (atomic_flag)ATOMIC_FLAG_INIT;
    }
    return self;
}

- (void)completePreprocessing {
    if (atomic_flag_test_and_set(&_completed)) {
        IGAssert(NO, @"Attempt to complete preprocessing more than once in the same context: %@", self);
        return;
    }
    dispatch_group_leave(_group);
}

@end
