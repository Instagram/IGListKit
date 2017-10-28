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

final class PrefixedLabelSectionController: ListSectionController, ListSupplementaryViewSource {

    private var object: LabelsItem?

    private let prefix: String
    private let group: Int

    required init(prefix: String, group: Int) {
        self.prefix = prefix
        self.group = group
        super.init()
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.supplementaryViewSource = self
    }

    override func numberOfItems() -> Int {
        guard let object = object else { return 0 }
        return group == 1 ? object.labels1.count : object.labels2.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell else {
            fatalError()
        }
        if let object = object {
            if group == 1 {
                cell.text = "\(prefix) \(object.labels1[index])"
            } else {
                cell.text = "\(prefix) \(object.labels2[index])"
            }
        } else {
            cell.text = "\(prefix) [X]"
        }
        cell.backgroundColor = object?.color
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? LabelsItem
    }

    override func canMoveItem(at index: Int) -> Bool {
        return true
    }

    override func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
        guard let object = object else { return }
        if group == 1 {
            let item = object.labels1.remove(at: sourceIndex)
            object.labels1.insert(item, at: destinationIndex)
        } else {
            let item = object.labels2.remove(at: sourceIndex)
            object.labels2.insert(item, at: destinationIndex)
        }
    }

    // MARK: ListSupplementaryViewSource

    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                             for: self,
                                                                             nibName: "UserHeaderView",
                                                                             bundle: nil,
                                                                             at: index) as? UserHeaderView else {
                                                                                fatalError()
        }
        view.name = "Sections of Letters & Numbers"
        view.handle = ""
        return view
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 40)
    }
}
