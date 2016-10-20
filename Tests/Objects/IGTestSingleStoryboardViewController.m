//
//  IGTestSingleStoryboardViewController.m
//  IGListKit
//
//  Created by Bofei Zhu on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

#import "IGTestSingleStoryboardViewController.h"

#import <IGListKit/IGListSingleSectionController.h>

#import "IGTestStoryboardCell.h"

@interface IGTestSingleStoryboardViewController ()

@end

@implementation IGTestSingleStoryboardViewController


- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object
{
    void (^configureBlock)(id, __kindof UICollectionViewCell *) = ^(IGTestObject *item, IGTestStoryboardCell *cell) {
        cell.label.text = [item.value description];
    };
    CGSize (^sizeBlock)(id<IGListCollectionContext>) = ^CGSize(id<IGListCollectionContext> collectionContext) {
        return CGSizeMake([collectionContext containerSize].width, 44);
    };
    return [[IGListSingleSectionController alloc] initWithStoryboardCellIdentifier:@"IGTestStoryboardCell"
                                                                    configureBlock:configureBlock
                                                                         sizeBlock:sizeBlock];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
