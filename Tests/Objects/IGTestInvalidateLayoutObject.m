/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestInvalidateLayoutObject.h"

@implementation IGTestInvalidateLayoutObject

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
    if ([object isKindOfClass:[IGTestInvalidateLayoutObject class]]) {
        return YES;
    }

    return NO;
}

@end
