/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit

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
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = feedItem.comments[index]
        return cell
    }

    override func didUpdate(to object: Any) {
        feedItem = object as? FeedItem
    }

    // MARK: ListSupplementaryViewSource

    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return userHeaderView(atIndex: index)
        case UICollectionView.elementKindSectionFooter:
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
        let view: UserHeaderView = collectionContext.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            forSectionController: self,
            nibName: "UserHeaderView",
            bundle: nil,
            atIndex: index)
        view.handle = "@" + feedItem.user.handle
        view.name = feedItem.user.name
        return view
    }

    private func userFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: UserFooterView = collectionContext.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            forSectionController: self,
            nibName: "UserFooterView",
            bundle: nil,
            atIndex: index)
        view.commentsCount = "\(feedItem.comments.count)"
        return view
    }
}
