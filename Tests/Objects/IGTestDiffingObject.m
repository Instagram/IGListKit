/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestDiffingObject.h"

@implementation IGTestDiffingObject

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects {
    if (self = [super init]) {
        _key = key;
        _objects = objects;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; key: %@; objects: %@>",
            NSStringFromClass(self.class), self, self.key, self.objects];
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return self.key;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return YES;
}

@end
