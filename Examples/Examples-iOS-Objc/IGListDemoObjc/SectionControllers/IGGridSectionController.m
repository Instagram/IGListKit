//
//  IGGridSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGGridSectionController.h"
#import "IGGridItem.h"
#import "IGCenterLabelCell.h"

@interface IGGridSectionController ()
@property (nonatomic, strong) IGGridItem *object;
@end

@implementation IGGridSectionController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 1;
        self.minimumInteritemSpacing = 1;
    }
    return self;
}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return self.object.itemCount;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width ?: 0;
    CGFloat itemSize = floor(width / 4);
    return CGSizeMake(itemSize, itemSize);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGCenterLabelCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGCenterLabelCell class] forSectionController:self atIndex:index];
    cell.label.text = [NSString stringWithFormat:@"%@", @(index + 1)];
    cell.backgroundColor = self.object.color;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.object = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {

}

@end
