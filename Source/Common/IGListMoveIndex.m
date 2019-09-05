/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListMoveIndex.h"

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
    return [NSString stringWithFormat:@"<%@ %p; from: %li; to: %li;>", NSStringFromClass(self.class), self, (long)self.from, (long)self.to];
}

@end
