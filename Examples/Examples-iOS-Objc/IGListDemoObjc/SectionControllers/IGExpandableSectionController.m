//
//  IGExpandableSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGExpandableSectionController.h"
#import "IGLabelCell.h"

@interface IGExpandableSectionController ()
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, copy) NSString *object;
@end

@implementation IGExpandableSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width;
    
    IGLabelCell *labelCell = [[IGLabelCell alloc] init];
    CGFloat height = self.expanded ? [labelCell textHeightWithText:self.object ?: @"" width:width] : labelCell.singleLineHeight;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGLabelCell class] forSectionController:self atIndex:index];
    cell.label.numberOfLines = self.expanded ? 0 : 1;
    cell.label.text = self.object;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.object = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    self.expanded = !self.expanded;
    [self.collectionContext reloadSectionController:self];
}

@end
