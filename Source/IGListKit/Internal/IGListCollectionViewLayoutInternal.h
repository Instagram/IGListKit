/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIScreen.h>

static inline CGRect IGListRectIntegralScaled(CGRect rect) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return CGRectMake(floor(rect.origin.x * scale) / scale,
                      floor(rect.origin.y * scale) / scale,
                      ceil(rect.size.width * scale) / scale,
                      ceil(rect.size.height * scale) / scale);
}
