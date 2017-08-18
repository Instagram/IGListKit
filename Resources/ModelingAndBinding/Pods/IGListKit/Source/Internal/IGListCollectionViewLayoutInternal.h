/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

static CGRect IGListRectIntegralScaled(CGRect rect) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return CGRectMake(floorf(rect.origin.x * scale) / scale,
                      floorf(rect.origin.y * scale) / scale,
                      ceilf(rect.size.width * scale) / scale,
                      ceilf(rect.size.height * scale) / scale);
}
