//
//  IGDemoSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGDemoSectionController.h"
#import "IGDemoItem.h"
#import "IGLabelCell.h"

@interface IGDemoSectionController ()

@end

@implementation IGDemoSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 55);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGLabelCell class] forSectionController:self atIndex:index];
    cell.label.text = self.object.name;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.object = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    if (self.object && self.object.controller) {
        self.object.controller.title = self.object.name ?: @"";
        [self.viewController.navigationController pushViewController:self.object.controller animated:YES];
    }
}

@end
