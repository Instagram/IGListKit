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

final class FeedItemSectionController: IGListSectionController, IGListSectionType, IGListSupplementaryViewSource {

    var feedItem: FeedItem!

    override init() {
        super.init()
        supplementaryViewSource = self
    }

    // MARK: IGlistSectionType

    func numberOfItems() -> Int {
        return feedItem.comments.count
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        cell.label.text = feedItem.comments[index]
        return cell
    }

    func didUpdate(to object: Any) {
        feedItem = object as? FeedItem
    }

    func didSelectItem(at index: Int) {}
  
    func didDeselectItem(at index: Int) {}

    // MARK: IGListSupplementaryViewSource

    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                       for: self,
                                                                       nibName: "UserHeaderView",
                                                                       bundle: nil,
                                                                       at: index) as! UserHeaderView
        view.handleLabel.text = "@" + feedItem.user.handle
        view.nameLabel.text = feedItem.user.name
        return view
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 40)
    }

}
