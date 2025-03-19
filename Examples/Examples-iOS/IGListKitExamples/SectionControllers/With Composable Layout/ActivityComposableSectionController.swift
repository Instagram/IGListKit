/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit
import SwiftUI

final class ActivityComposableSectionController: ListSectionController, CompositionLayoutCapable, ListSupplementaryViewSource {

    private var activity: ActivityItem?

    override init() {
        super.init()
        supplementaryViewSource = self
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 60)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionContext.dequeueReusableCell(
            for: self,
            at: index
        )
        cell.contentConfiguration = UIHostingConfiguration(content: {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [ .blue.opacity(0.3), .red.opacity(0.3)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .frame(width: 44)
                    .padding(16)
                Text(activity?.bodyText ?? "No body")
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        RadialGradient(colors: [ .green.opacity(0.3), .yellow.opacity(0.3)],
                                       center: .center,
                                       startRadius: 5,
                                       endRadius: 75)
                    )
                    .frame(width: 44, height: 44)
                    .padding(16)
            }
        })
        .margins(.all, 0)
        return cell
    }

    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let view: UICollectionViewListCell = collectionContext.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            forSectionController: self,
            atIndex: index)
        view.contentConfiguration = UIHostingConfiguration(content: {
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                Text("Activity Start")
            case UICollectionView.elementKindSectionFooter:
                Text("Activity End")
            default: EmptyView()
            }
        })
        return view
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        if activity?.header != nil && elementKind == UICollectionView.elementKindSectionHeader {
            return CGSize(width: collectionContext.containerSize.width, height: 40)
        }
        if activity?.footer != nil && elementKind == UICollectionView.elementKindSectionFooter {
            return CGSize(width: collectionContext.containerSize.width, height: 40)
        }
        return .zero
    }

    override func didUpdate(to object: Any) {
        self.activity = object as? ActivityItem
    }

    // MARK: CompositionLayoutCapable

    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        var maxItemHeight: CGFloat = 0.0
        var anyItemHasEstimatedHeight = false
        let itemCount: Int = numberOfItems()
        let items = (0..<itemCount).map { itemIndex in
            let itemSize = sizeForItem(at: itemIndex)
            let layoutSize = NSCollectionLayoutSize(widthDimension: .absolute(itemSize.width),
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
