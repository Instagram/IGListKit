/*
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListTransitionData.h"

@implementation IGListTransitionData

- (instancetype)initFromObjects:(NSArray *)fromObjects
                      toObjects:(NSArray *)toObjects
           toSectionControllers:(NSArray<IGListSectionController *> *)toSectionControllers {
    if (self = [super init]) {
        _fromObjects = [fromObjects copy];
        _toObjects = [toObjects copy];
        _toSectionControllers = [toSectionControllers copy];
    }
    return self;
}

@end
