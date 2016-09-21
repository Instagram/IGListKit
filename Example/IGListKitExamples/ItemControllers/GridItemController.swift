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

class GridItem: NSObject {

    let color: UIColor
    let itemCount: UInt

    init(color: UIColor, itemCount: UInt) {
        self.color = color
        self.itemCount = itemCount
    }

}

class GridItemController: IGListItemController, IGListItemType {

    var item: GridItem?

    override init() {
        super.init()
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }

    func numberOfItems() -> UInt {
        return item?.itemCount ?? 0
    }

    func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 4)
        return CGSize(width: itemSize, height: itemSize)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeReusableCell(of: CenterLabelCell.self, for: self, at: index) as! CenterLabelCell
        cell.label.text = "\(index + 1)"
        cell.backgroundColor = item?.color
        return cell
    }

    func didUpdate(toItem item: Any) {
        self.item = item as? GridItem
    }

    func didSelect(at index: Int) {}

}
