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

final class ListeningSectionController: IGListSectionController<IGListDiffable>, IGListSectionType, IncrementListener {

    var value: Int = 0

    init(announcer: IncrementAnnouncer) {
        super.init()
        announcer.addListener(listener: self)
    }

    func configureCell(cell: LabelCell) {
        let section = collectionContext!.section(for: self)
        cell.label.text = "Section: \(section), value: \(value)"
    }

    // MARK: IGListSectionType

    func numberOfItems() -> Int {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        configureCell(cell: cell)
        return cell
    }

    func didUpdate(to object: Any) {}
    func didSelectItem(at index: Int) {}

    // MARK: IncrementListener

    func didIncrement(announcer: IncrementAnnouncer, value: Int) {
        self.value = value
        guard let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? LabelCell else { return }
        configureCell(cell: cell)
    }

}
