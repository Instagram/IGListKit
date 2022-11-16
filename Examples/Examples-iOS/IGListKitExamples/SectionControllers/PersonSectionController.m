/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "PersonSectionController.h"

#import "PersonCell.h"
#import "PersonModel.h"

@implementation PersonSectionController {
    PersonModel *_person;
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    const CGFloat height = 74.0;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    const Class cellClass = [PersonCell class];
    PersonCell *cell = (PersonCell *)[self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    cell.person = _person;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _person = (PersonModel *)object;
}

@end
