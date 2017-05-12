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

final class ListeningSectionController: ListSectionController, IncrementListener {

    private var value: Int = 0

    init(announcer: IncrementAnnouncer) {
        super.init()
        announcer.addListener(listener: self)
    }

    func configureCell(cell: LabelCell) {
        cell.text = "Section: \(self.section), value: \(value)"
    }

    // MARK: ListSectionController Overrides

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell else {
            fatalError()
        }
        configureCell(cell: cell)
        return cell
    }

    // MARK: IncrementListener

    func didIncrement(announcer: IncrementAnnouncer, value: Int) {
        self.value = value
        guard let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? LabelCell else { return }
        configureCell(cell: cell)
    }

}
