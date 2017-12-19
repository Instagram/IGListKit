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

final class FeedItemSectionController: ListSectionController, ListSupplementaryViewSource {

    private var feedItem: FeedItem!

    override init() {
        super.init()
        supplementaryViewSource = self
    }

    // MARK: IGListSectionController Overrides

    override func numberOfItems() -> Int {
        return feedItem.comments.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell else {
            fatalError()
        }
        cell.text = feedItem.comments[index]
        return cell
    }

    override func didUpdate(to object: Any) {
        feedItem = object as? FeedItem
    }

    // MARK: ListSupplementaryViewSource

    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            return userHeaderView(atIndex: index)
        case UICollectionElementKindSectionFooter:
            return userFooterView(atIndex: index)
        default:
            fatalError()
        }
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 40)
    }

    // MARK: Private
    private func userHeaderView(atIndex index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                             for: self,
                                                                             nibName: "UserHeaderView",
                                                                             bundle: nil,
                                                                             at: index) as? UserHeaderView else {
                                                                                fatalError()
        }
        view.handle = "@" + feedItem.user.handle
        view.name = feedItem.user.name
        return view
    }

    private func userFooterView(atIndex index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                             for: self,
                                                                             nibName: "UserFooterView",
                                                                             bundle: nil,
                                                                             at: index) as? UserFooterView else {
                                                                                fatalError()
        }

        view.commentsCount = "\(feedItem.comments.count)"
        return view
    }
}
