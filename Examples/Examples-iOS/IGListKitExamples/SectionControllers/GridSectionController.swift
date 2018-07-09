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

final class GridItem: NSObject {

    let color: UIColor
    let itemCount: Int

    var items: [String] = []

    init(color: UIColor, itemCount: Int) {
        self.color = color
        self.itemCount = itemCount

        super.init()

        self.items = computeItems()
    }

    private func computeItems() -> [String] {
        return [Int](1...itemCount).map {
            String(describing: $0)
        }
    }
}

extension GridItem: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }

}

final class GridSectionController: ListSectionController {

    private var object: GridItem?
    private let isReorderable: Bool

    required init(isReorderable: Bool = false) {
        self.isReorderable = isReorderable
        super.init()
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }

    override func numberOfItems() -> Int {
        return object?.itemCount ?? 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 4)
        return CGSize(width: itemSize, height: itemSize)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CenterLabelCell.self, for: self, at: index) as? CenterLabelCell else {
            fatalError()
        }
        cell.text = object?.items[index] ?? "undefined"
        cell.backgroundColor = object?.color
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? GridItem
    }

    override func canMoveItem(at index: Int) -> Bool {
        return isReorderable
    }

    override func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
        guard let object = object else { return }
        let item = object.items.remove(at: sourceIndex)
        object.items.insert(item, at: destinationIndex)
    }
}
