//
//  IGEmbeddedSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGEmbeddedSectionController.h"
#import <IGListKit.h>
#import "IGCenterLabelCell.h"

@interface IGEmbeddedSectionController ()
@property (nonatomic, strong) NSNumber *number;
@end

@implementation IGEmbeddedSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    return self;
}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat height = self.collectionContext.containerSize.height;
    return CGSizeMake(height, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGCenterLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGCenterLabelCell class] forSectionController:self atIndex:index];
    NSNumber *value = self.number ?: @(0);
    cell.label.text = [@(value.integerValue + 1) stringValue];
    cell.backgroundColor = [UIColor colorWithRed:237/255.0 green:73/255.0 blue:86/255.0 alpha:1];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.number = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

@end
