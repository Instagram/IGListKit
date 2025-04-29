/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

/// To allow communication between PostSectionController and ListoGramViewController
protocol PostSectionControllerDelegate: AnyObject {
    func postSectionController(_ sectionController: PostSectionController, didSelectOptionsFor post: Post, from sourceView: UIView)
}
