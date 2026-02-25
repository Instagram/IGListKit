/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <TargetConditionals.h>

#if TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR || TARGET_OS_MACCATALYST
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <METAUIKitBridge/METAUIKitBridge.h>
#else
#import <Cocoa/Cocoa.h>
#endif
