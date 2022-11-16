/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "Post.h"

@implementation Post

- (instancetype)initWithUsername:(NSString *)username
                        comments:(NSArray<NSString *> *)comments {
    if (self = [super init]) {
        _username = [username copy];
        _comments = [comments copy];
    }
    return self;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id)object {
    // since the diff identifier returns self, object should only be compared with same instance
    return self == object;
}

@end
