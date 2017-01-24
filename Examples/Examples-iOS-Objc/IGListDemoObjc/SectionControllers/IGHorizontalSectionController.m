//
//  IGHorizontalSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGHorizontalSectionController.h"
#import <IGListKit.h>
#import "IGEmbeddedCollectionViewCell.h"
#import "IGEmbeddedSectionController.h"

@interface IGHorizontalSectionController () <IGListAdapterDataSource>
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) IGListAdapter *adapter;
@end

@implementation IGHorizontalSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 100);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGEmbeddedCollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGEmbeddedCollectionViewCell class] forSectionController:self atIndex:index];
    self.adapter.collectionView = cell.collectionView;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.number = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray *numbers = [@[] mutableCopy];
    for (NSInteger index = 0; index < self.number.integerValue; index++) {
        [numbers addObject:@(index)];
    }
    return numbers;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [[IGEmbeddedSectionController alloc] init];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - Custom Accessors 

- (IGListAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self.viewController workingRangeSize:0];
        _adapter.dataSource = self;
    }
    return _adapter;
}

@end
