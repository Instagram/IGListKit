/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListReloadIndexPath.h"

@implementation IGListReloadIndexPath

- (instancetype)initWithFromIndexPath:(NSIndexPath *)fromIndexPath
                          toIndexPath:(NSIndexPath *)toIndexPath {
    if (self = [super init]) {
        _fromIndexPath = fromIndexPath;
        _toIndexPath = toIndexPath;
    }
    return self;
}

@end
