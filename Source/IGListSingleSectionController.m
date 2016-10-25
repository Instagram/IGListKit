/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListSingleSectionController.h"

#import <IGListKit/IGListAssert.h>

@interface IGListSingleSectionController ()

@property (nonatomic, strong, readonly) NSString *nibName;
@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) Class cellClass;
@property (nonatomic, strong, readonly) IGListSingleSectionCellConfigureBlock configureBlock;
@property (nonatomic, strong, readonly) IGListSingleSectionCellSizeBlock sizeBlock;

@property (nonatomic, strong) id item;

@end

@implementation IGListSingleSectionController

- (instancetype)initWithCellClass:(Class)cellClass
                   configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                        sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock {
    IGParameterAssert(cellClass != nil);
    IGParameterAssert(configureBlock != nil);
    IGParameterAssert(sizeBlock != nil);
    if (self = [super init]) {
        _cellClass = cellClass;
        _configureBlock = [configureBlock copy];
        _sizeBlock = [sizeBlock copy];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)bundle
                 configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                      sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock {
    IGParameterAssert(nibName != nil);
    IGParameterAssert(configureBlock != nil);
    IGParameterAssert(sizeBlock != nil);
    if (self = [super init]) {
        _nibName = nibName;
        _bundle = bundle;
        _configureBlock = [configureBlock copy];
        _sizeBlock = [sizeBlock copy];
    }
    return self;
}

- (instancetype)initWithStoryboardCellIdentifier:(NSString *)identifier
                                  configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                                       sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock {
    IGParameterAssert(identifier.length > 0);
    IGParameterAssert(configureBlock != nil);
    IGParameterAssert(sizeBlock != nil);
    if (self = [super init]) {
        _identifier = [identifier copy];
        _configureBlock = [configureBlock copy];
        _sizeBlock = [sizeBlock copy];
    }
    return self;

}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return self.sizeBlock(self.collectionContext);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    id cell;
    id<IGListCollectionContext> collectionContext = self.collectionContext;
    if ([self.nibName length] > 0) {
        cell = [collectionContext dequeueReusableCellWithNibName:self.nibName
                                                          bundle:self.bundle
                                            forSectionController:self
                                                         atIndex:index];
    } else if ([self.identifier length] > 0) {
        cell = [collectionContext dequeueReusableCellFromStoryboardWithIdentifier:self.identifier
                                                             forSectionController:self
                                                                          atIndex:index];
    } else {
        cell = [collectionContext dequeueReusableCellOfClass:self.cellClass forSectionController:self atIndex:index];
    }
    self.configureBlock(self.item, cell);
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.item = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate didSelectSingleSectionController:self];
}

@end
