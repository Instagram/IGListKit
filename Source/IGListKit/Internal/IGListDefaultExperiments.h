/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#if __has_include(<IGListDiffKit/IGListDiffKit.h>)
#import <IGListDiffKit/IGListExperiments.h>
#else
#import "IGListExperiments.h"
#endif

/// Provides a list of experiments that are enabled by default in IGListKit.
static inline IGListExperiment IGListDefaultExperiments(void) {
    return IGListExperimentThrowOnInconsistencyException;
}
