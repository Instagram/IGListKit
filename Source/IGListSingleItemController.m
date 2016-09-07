/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListSingleItemController.h"

#import <IGListKit/IGListAssert.h>

@interface IGListSingleItemController ()

@property (nonatomic, strong, readonly) Class cellClass;
@property (nonatomic, strong, readonly) void (^configureBlock)(id, __kindof UICollectionViewCell *);
@property (nonatomic, strong, readonly) CGSize (^sizeBlock)(id<IGListCollectionContext>);

@property (nonatomic, strong) id item;

@end

@implementation IGListSingleItemController

- (instancetype)initWithCellClass:(Class)cellClass
                   configureBlock:(void (^)(id, __kindof UICollectionViewCell *))configureBlock
                        sizeBlock:(CGSize (^)(id<IGListCollectionContext>))sizeBlock {
    IGParameterAssert(cellClass != nil);
    IGParameterAssert(configureBlock != nil);
    if (self = [super init]) {
        _cellClass = cellClass;
        _configureBlock = [configureBlock copy];
        _sizeBlock = [sizeBlock copy];
    }
    return self;
}

#pragma mark - IGListItemType

- (NSUInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return self.sizeBlock(self.collectionContext);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    id cell = [self.collectionContext dequeReusableCellOfClass:self.cellClass forItemController:self atIndex:index];
    self.configureBlock(self.item, cell);
    return cell;
}

- (void)didUpdateToItem:(id)item {
    self.item = item;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate didSelectSingleItemController:self];
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate didDeselectSingleItemController:self];
}

@end
