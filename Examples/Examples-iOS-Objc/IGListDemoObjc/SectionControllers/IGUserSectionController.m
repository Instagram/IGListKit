//
//  IGUserSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGUserSectionController.h"
#import "IGDetailLabelCell.h"
#import "IGUser.h"

@interface IGUserSectionController ()
@property (nonatomic, strong) IGUser *user;
@end

@implementation IGUserSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 55);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGDetailLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGDetailLabelCell class] forSectionController:self atIndex:index];
    cell.titleLabel.text = self.user.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@%@", @"@", self.user.handle ?: @""];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.user = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

@end
