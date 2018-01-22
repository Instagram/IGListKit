/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
