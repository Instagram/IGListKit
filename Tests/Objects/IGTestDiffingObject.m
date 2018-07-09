/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
