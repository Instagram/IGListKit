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

import IGListKit
import UIKit

final class UserSectionController: ListSectionController {

    private var user: User?
    private let isReorderable: Bool

    required init(isReorderable: Bool = false) {
        self.isReorderable = isReorderable
        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DetailLabelCell.self, for: self, at: index) as? DetailLabelCell else {
            fatalError()
        }
        cell.title = user?.name
        cell.detail = "@" + (user?.handle ?? "")
        return cell
    }

    override func didUpdate(to object: Any) {
        self.user = object as? User
    }

    override func canMoveItem(at index: Int) -> Bool {
        return isReorderable
    }
}
