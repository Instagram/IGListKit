/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit
import SwiftUI

final class TextViewModel: ObservableObject {
    @Published var text: String
    @Published var extraPadding: Bool = false

    init(text: String) {
        self.text = text
    }
}

struct ExpandTextView: View {
    @ObservedObject var viewModel: TextViewModel

    var body: some View {
        Text(viewModel.text)
            .padding(viewModel.extraPadding ? 20 : 10)
            .border(.gray.opacity(0.2), width: 1)
    }
}

final class SelectionComposableSectionController: ListSectionController, CompositionLayoutCapable {

    private var viewModels: [TextViewModel] = []

    override func numberOfItems() -> Int {
        return viewModels.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 100, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionContext.dequeueReusableCell(
            for: self,
            at: index
        )
        let viewModel = viewModels[index]
        cell.contentConfiguration = UIHostingConfiguration(content: {
            ExpandTextView(viewModel: viewModel)
        })
        .margins(.all, 0)
        return cell
    }

    override func didSelectItem(at index: Int) {
        withAnimation {
            viewModels[index].extraPadding.toggle()
        }

    }

    override func didUpdate(to object: Any) {
        guard let selection = object as? SelectionModel else {
            return
        }
        viewModels = selection.options.map { TextViewModel(text: $0) }
    }

    // MARK: CompositionLayoutCapable

    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        var maxItemHeight: CGFloat = 0.0
        let itemCount: Int = numberOfItems()
        let items = (0..<itemCount).map { itemIndex in
            let itemSize = sizeForItem(at: itemIndex)
            let layoutSize = NSCollectionLayoutSize(widthDimension: .estimated(itemSize.width),
                                                    heightDimension: .estimated(itemSize.height))
            maxItemHeight = max(maxItemHeight, itemSize.height)
            return NSCollectionLayoutItem(layoutSize: layoutSize)
        }

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(maxItemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        if minimumInteritemSpacing > 0.0 {
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(minimumInteritemSpacing)
        }
        let layoutSection = NSCollectionLayoutSection(group: group)

        if let suplementaryViewProvider = supplementaryViewSource {
            layoutSection.boundarySupplementaryItems = suplementaryViewProvider.supportedElementKinds().map { kind in
                let size = suplementaryViewProvider.sizeForSupplementaryView(ofKind: kind, at: 0)
                let layoutSize = NSCollectionLayoutSize(widthDimension: .absolute(size.width), heightDimension: .absolute(size.height))
                let alignment: NSRectAlignment
                switch kind {
                case UICollectionView.elementKindSectionHeader: alignment = .top
                case UICollectionView.elementKindSectionFooter: alignment = .bottom
                default: alignment = .none
                }
                return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize, elementKind: kind, alignment: alignment)
            }
        }

        if inset != .zero {
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: inset.top,
                                                                  leading: inset.left,
                                                                  bottom: inset.bottom,
                                                                  trailing: inset.right)
        }
        if minimumLineSpacing > 0.0 {
            layoutSection.interGroupSpacing = minimumLineSpacing
        }
        return layoutSection
    }

}
