/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UIScrollView+IGListKit.h"

@implementation UIScrollView (IGListKit)

- (UIEdgeInsets) ig_contentInset
{
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, tvOS 11.0, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
#else
    return self.contentInset;
#endif
}

@end
