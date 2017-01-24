//
//  IGLabelSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGLabelSectionController.h"
#import "IGLabelCell.h"

@implementation IGLabelSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 55);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGLabelCell class] forSectionController:self atIndex:index];
    cell.label.text = self.object ?: @"";
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.object = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

@end
