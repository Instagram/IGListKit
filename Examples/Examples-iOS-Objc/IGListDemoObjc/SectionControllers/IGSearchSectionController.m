//
//  IGSearchSectionController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGSearchSectionController.h"
#import "IGSearchCell.h"

@interface IGSearchSectionController () <UISearchBarDelegate, IGListDisplayDelegate>

@end

@implementation IGSearchSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.displayDelegate = self;
    }
    return self;
}

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 44);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGSearchCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGSearchCell class] forSectionController:self atIndex:index];
    cell.searchBar.delegate = self;
    return cell;
}

- (void)didUpdateToObject:(id)object {

}

- (void)didSelectItemAtIndex:(NSInteger)index {

}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.delegate respondsToSelector:@selector(searchSectionController:didChangeText:)]) {
        [self.delegate searchSectionController:self didChangeText:searchText];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchSectionController:didChangeText:)]) {
        [self.delegate searchSectionController:self didChangeText:@""];
    }
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter didScrollSectionController:(IGListSectionController<IGListSectionType> *)sectionController {
    UISearchBar *searchBar = (UISearchBar *)[self.collectionContext cellForItemAtIndex:0 sectionController:self];
    if (searchBar) {
        searchBar.text = @"";
        [searchBar resignFirstResponder];
    }
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController<IGListSectionType> *)sectionController {

}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController<IGListSectionType> *)sectionController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {

}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController<IGListSectionType> *)sectionController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {

}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController<IGListSectionType> *)sectionController {

}

@end
