/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
