/**
 Copyright (c) Facebook, Inc. and its affiliates.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

extension MutableCollection {

    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        guard count > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: count, to: 1, by: -1)) {
            let distance: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard distance != 0 else { continue }

            let shuffleIndex = index(firstUnshuffled, offsetBy: distance)

            self.swapAt(firstUnshuffled, shuffleIndex)
        }
    }

}

extension Sequence {

    /// Returns an array with the contents of this sequence, shuffled.
    var shuffled: [Iterator.Element] {
        var result = Array(self)
        result.shuffle()

        return result
    }

}
