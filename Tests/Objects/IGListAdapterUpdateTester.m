/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdateTester.h"

@implementation IGListAdapterUpdateTester

- (void)listAdapter:(IGListAdapter *)listAdapter didFinishUpdate:(IGListAdapterUpdateType)update animated:(BOOL)animated {
    self.hits++;
    self.type = update;
    self.animated = animated;
}

@end
