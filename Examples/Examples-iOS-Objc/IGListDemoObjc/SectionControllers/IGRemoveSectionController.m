//
//  IGRemoveSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGRemoveSectionController.h"
#import <IGListKit.h>
#import "IGRemoveCell.h"

@interface IGRemoveSectionController () <IGRemoveCellDelegate>
@property (nonatomic, strong) NSNumber *number;
@end

@implementation IGRemoveSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    return self;
}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 55);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGRemoveCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGRemoveCell class] forSectionController:self atIndex:index];
    cell.label.text = [NSString stringWithFormat:@"Cell : %@", @(self.number.integerValue + 1)];
    cell.delegate = self;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.number = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {

}

#pragma mark - IGRemoveCellDelegate

- (void)removeCellDidTapButton:(IGRemoveCell *)removeCell {
    if ([self.delegate respondsToSelector:@selector(removeSectionControllerwantsRemove:)]) {
        [self.delegate removeSectionControllerwantsRemove:self];
    }
}

@end
