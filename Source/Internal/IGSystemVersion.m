/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGSystemVersion.h"

bool IGSystemVersionIsIOS9OrNewer(void) {
  if (@available(iOS 9.0, *)) {
    return true;
  } else {
    return false;
  }
}
