/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

extension ListAdapter {

    func value(for sectionController: ListSectionController) -> ListSwiftDiffable? {
        if let box = object(for: sectionController) {
            guard let box = box as? ListDiffableBox else { fatalError() }
            return box.value
        }
        return nil
    }

    func sectionController(for value: ListSwiftDiffable) -> ListSectionController? {
        return sectionController(for: value.boxed)
    }

    func section(for value: ListSwiftDiffable) -> Int {
        return section(for: value.boxed)
    }

    func value(at section: Int) -> ListSwiftDiffable? {
        if let box = object(atSection: section) {
            guard let box = box as? ListDiffableBox else { fatalError() }
            return box.value
        }
        return nil
    }

    func visibleCells(for value: ListSwiftDiffable) -> [UICollectionViewCell] {
        return visibleCells(for: value.boxed)
    }

    func scroll(
        to value: ListSwiftDiffable,
        supplementaryKinds: [String]? = nil,
        scrollDirection: UICollectionViewScrollDirection = .vertical,
        scrollPosition: UICollectionViewScrollPosition = .centeredVertically,
        animated: Bool = true
        ) {
        scroll(
            to: value.boxed,
            supplementaryKinds: supplementaryKinds,
            scrollDirection: scrollDirection,
            scrollPosition: scrollPosition,
            animated: animated
        )
    }

    var values: [ListSwiftDiffable] {
        guard let objects = self.objects() as? [ListDiffableBox] else { fatalError() }
        return objects.map { $0.value }
    }

    var visibleValues: [ListSwiftDiffable] {
        guard let visibleObjects = self.visibleObjects() as? [ListDiffableBox] else { fatalError() }
        return visibleObjects.map { $0.value }
    }

}