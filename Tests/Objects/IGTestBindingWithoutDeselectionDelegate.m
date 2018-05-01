/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestBindingWithoutDeselectionDelegate.h"

@implementation IGTestBindingWithoutDeselectionDelegate

- (void)sectionController:(IGListBindingSectionController *)sectionController didSelectItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.selected = YES;
}

@end
