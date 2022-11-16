/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

final class HorizontalSectionController: ListSectionController, ListAdapterDataSource {

    var number: Int?

    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 340)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell: EmbeddedCollectionViewCell = collectionContext?.dequeueReusableCell(
            for: self,
            at: index
        ) else {
            fatalError()
        }
        adapter.collectionView = cell.collectionView
        return cell
    }

    override func didUpdate(to object: Any) {
        number = object as? Int
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let number = number else { return [] }
        return (0..<number).map { $0 as ListDiffable }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CarouselSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}
