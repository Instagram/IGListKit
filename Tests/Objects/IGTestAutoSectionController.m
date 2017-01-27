/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestAutoSectionController.h"

#import "IGTestAutoObject.h"
#import "IGTestStringBindableCell.h"
#import "IGTestNumberBindableCell.h"

@implementation IGTestAutoSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

#pragma mark - IGListAutoSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)viewModelsForObject:(id)object {
    return [(IGTestAutoObject *)object objects];
}

- (UICollectionViewCell<IGListBindable> *)cellForViewModel:(id)viewModel atIndex:(NSInteger)index {
    const BOOL isString = [viewModel isKindOfClass:[NSString class]];
    Class cellClass = isString ? [IGTestStringBindableCell class] : [IGTestNumberBindableCell class];
    id cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    return cell;
}

- (CGSize)sizeForViewModel:(id)viewModel {
    const BOOL isString = [viewModel isKindOfClass:[NSString class]];
    return CGSizeMake([self.collectionContext containerSize].width, isString ? 55 : 30);
}

@end
