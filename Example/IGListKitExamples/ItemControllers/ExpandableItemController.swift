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
import IGListKit

class ExpandableItemController: IGListItemController, IGListItemType {

    var expanded = false
    var item: String?

    func numberOfItems() -> UInt {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        let height = expanded ? LabelCell.textHeight(item ?? "", width: width) : LabelCell.singleLineHeight
        return CGSize(width: width, height: height)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        cell.label.numberOfLines = expanded ? 0 : 1
        cell.label.text = item
        return cell
    }

    func didUpdate(toItem item: Any) {
        self.item = item as? String
    }

    func didSelect(at index: Int) {
        expanded = !expanded
        collectionContext?.reload(self)
    }

}
