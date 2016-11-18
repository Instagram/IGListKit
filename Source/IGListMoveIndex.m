/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListMoveIndex.h"
#import "IGListMoveIndexInternal.h"

@implementation IGListMoveIndex

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to {
    if (self = [super init]) {
        _from = from;
        _to = to;
    }
    return self;
}

- (NSUInteger)hash {
    return _from ^ _to;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[IGListMoveIndex class]]) {
        const NSInteger f1 = self.from, f2 = [object from];
        const NSInteger t1 = self.to, t2 = [object to];
        return f1 == f2 && t1 == t2;
    }
    return NO;
}

- (NSComparisonResult)compare:(id)object {
    const NSInteger right = [object from];
    const NSInteger left = [self from];
    if (left == right) {
        return NSOrderedSame;
    } else if (left < right) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; from: %zi; to: %zi;>", NSStringFromClass(self.class), self, self.from, self.to];
}

@end
