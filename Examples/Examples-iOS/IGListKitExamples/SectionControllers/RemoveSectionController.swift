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

protocol RemoveSectionControllerDelegate: class {
    func removeSectionControllerWantsRemoved(_ sectionController: RemoveSectionController)
}

final class RemoveSectionController: IGListSectionController, IGListSectionType, RemoveCellDelegate {

    weak var delegate: RemoveSectionControllerDelegate?
    var number: Int?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }

    func numberOfItems() -> Int {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: RemoveCell.self, forSectionController: self, at: index) as! RemoveCell
        cell.label.text = "Cell: \((number ?? 0) + 1)"
        cell.delegate = self
        return cell
    }

    func didUpdate(to object: Any) {
        number = object as? Int
    }

    func didSelectItem(at index: Int) {}

    //MARK: RemoveCellDelegate

    func removeCellDidTapButton(_ cell: RemoveCell) {
        delegate?.removeSectionControllerWantsRemoved(self)
    }

}
