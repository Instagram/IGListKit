/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

@objc protocol IncrementListener: class {
    func didIncrement(announcer: IncrementAnnouncer, value: Int)
}

final class IncrementAnnouncer: NSObject {

    private var value: Int = 0
    private let map: NSHashTable<IncrementListener> = NSHashTable<IncrementListener>.weakObjects()

    func addListener(listener: IncrementListener) {
        map.add(listener)
    }

    func increment() {
        value += 1
        for listener in map.allObjects {
            listener.didIncrement(announcer: self, value: value)
        }
    }

}
