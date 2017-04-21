/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestStackedDataSource.h"

#import <IGListKit/IGListStackedSectionController.h>

#import "IGTestCell.h"
#import "IGListTestSection.h"
#import "IGListTestContainerSizeSection.h"

@implementation IGTestStackedDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (id value in [(IGTestObject *)object value]) {
        id controller;
        // use a standard IGListTestSection
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([(NSNumber*)value isEqual: @42]) {
                IGListTestContainerSizeSection *section = [[IGListTestContainerSizeSection alloc] init];
                section.items = [value integerValue];
                controller = section;
            } else {
                IGListTestSection *section = [[IGListTestSection alloc] init];
                section.items = [value integerValue];
                controller = section;
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            void (^configureBlock)(id, __kindof UICollectionViewCell *) = ^(id obj, IGTestCell *cell) {
                // capturing the value in block scope so we use the CHILD OBJECT of the stack
                // otherwise the block uses the IGTestObject in the block param
                cell.label.text = value;
            };
            CGSize (^sizeBlock)(id, id<IGListCollectionContext>) = ^CGSize(IGTestObject *item, id<IGListCollectionContext> collectionContext) {
                return CGSizeMake([collectionContext containerSize].width, 44);
            };

            // use either nibs or storyboards with NSString depending on the string value
            if ([value isEqualToString:@"nib"]) {
                controller = [[IGListSingleSectionController alloc] initWithNibName:@"IGTestNibCell"
                                                                       bundle:[NSBundle bundleForClass:self.class]
                                                               configureBlock:configureBlock
                                                                    sizeBlock:sizeBlock];
            } else {
                controller = [[IGListSingleSectionController alloc] initWithStoryboardCellIdentifier:@"IGTestStoryboardCell"
                                                                                configureBlock:configureBlock
                                                                                     sizeBlock:sizeBlock];
            }
        }
        [controllers addObject:controller];
    }
    return [[IGListStackedSectionController alloc] initWithSectionControllers:controllers];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
