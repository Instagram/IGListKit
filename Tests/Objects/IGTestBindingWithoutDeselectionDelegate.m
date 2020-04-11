/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestBindingWithoutDeselectionDelegate.h"

@implementation IGTestBindingWithoutDeselectionDelegate

- (void)sectionController:(IGListBindingSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel {
    self.selected = YES;
}

- (void)sectionController:(IGListBindingSectionController *)sectionController
   didDeselectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel; {
}

- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController
  didHighlightItemAtIndex:(NSInteger)index
                viewModel:(nonnull id)viewModel {
}


- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController
didUnhighlightItemAtIndex:(NSInteger)index
                viewModel:(nonnull id)viewModel {
}


- (UIContextMenuConfiguration * _Nullable)sectionController:(nonnull IGListBindingSectionController *)sectionController
                    contextMenuConfigurationForItemAtIndex:(NSInteger)index
                                                     point:(CGPoint)point
                                                 viewModel:(nonnull id)viewModel API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos) {
  return nil;
}

@end
