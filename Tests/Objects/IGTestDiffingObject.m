/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
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

- (BOOL)isEqualToDiffableObject:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[IGTestDiffingObject class]]) {
        /* A simple equality test that only looks at the number of objects for the key.
           It does not currently test the equality of each of the objects. */
        IGTestDiffingObject *testDiffingObject = (IGTestDiffingObject *)object;
        return self.objects.count == testDiffingObject.objects.count;
    }

    return NO;
}

@end
