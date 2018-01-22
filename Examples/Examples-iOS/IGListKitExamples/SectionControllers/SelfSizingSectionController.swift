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

final class SelfSizingSectionController: ListSectionController {

    private var model: SelectionModel!

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }

    override func numberOfItems() -> Int {
        return model.options.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model.options[index]
        let cell: UICollectionViewCell
        switch model.type {
        case .none:
            guard let manualCell = collectionContext?.dequeueReusableCell(of: ManuallySelfSizingCell.self,
                                                                          for: self,
                                                                          at: index) as? ManuallySelfSizingCell else {
                                                                            fatalError()
            }
            manualCell.text = text
            cell = manualCell
        case .fullWidth:
            guard let manualCell = collectionContext?.dequeueReusableCell(of: FullWidthSelfSizingCell.self,
                                                                          for: self,
                                                                          at: index) as? FullWidthSelfSizingCell else {
                                                                            fatalError()
            }
            manualCell.text = text
            cell = manualCell
        case .nib:
            guard let nibCell = collectionContext?.dequeueReusableCell(withNibName: "NibSelfSizingCell",
                                                                       bundle: nil,
                                                                       for: self,
                                                                       at: index) as? NibSelfSizingCell else {
                                                                        fatalError()
            }
            nibCell.contentLabel.text = text
            cell = nibCell
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        self.model = object as? SelectionModel
    }

}
