/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

class ListSwiftSectionController<T: ListSwiftDiffable>: ListSectionController {

    struct Context {
        let collection: ListCollectionContext
        let value: T
    }

    private(set) var value: T?

    final override func didUpdate(to object: Any) {
        guard let object = object as? ListDiffableBox,
            let value = object.value as? T
            else { return }
        self.value = value
    }

    final override func numberOfItems() -> Int {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return numberOfItems(for: Context(collection: collectionContext, value: value))
    }

    final override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return size(at: index, context: Context(collection: collectionContext, value: value))
    }

    final override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return cell(at: index, context: Context(collection: collectionContext, value: value))
    }

    final override func didSelectItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didSelectItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    final override func didDeselectItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didDeselectItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    final override func didHighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didHighlightItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    final override func didUnhighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didUnhighlightItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    // MARK: Overrides

    func numberOfItems(for context: Context) -> Int { return 1 }

    func size(at index: Int, context: Context) -> CGSize { return .zero }

    func cell(at index: Int, context: Context) -> UICollectionViewCell { return UICollectionViewCell() }

    func didSelectItem(at index: Int, context: Context) { }

    func didDeselectItem(at index: Int, context: Context) { }

    func didHighlightItem(at index: Int, context: Context) { }

    func didUnhighlightItem(at index: Int, context: Context) { }

}