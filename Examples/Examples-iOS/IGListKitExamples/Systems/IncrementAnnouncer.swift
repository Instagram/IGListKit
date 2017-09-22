/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.

 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
