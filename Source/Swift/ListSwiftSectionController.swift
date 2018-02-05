/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit

/**
 Subclass this class to create section controllers for use with `ListSwiftAdapter`.
 */
open class ListSwiftSectionController<T: ListSwiftDiffable>: ListSectionController {

    /**
     A context object used as a parameter in overridable methods.
     */
    public struct Context {

        /**
         The current collection context, forwarded from `-[IGListAdapter collectionContext]`.
         */
        public let collection: ListCollectionContext

        /**
         The current value powering the section controller.
         */
        public let value: T
    }

    /**
     The current value powering the section controller.
     */
    public private(set) var value: T?

    // MARK: Overridable APIs

    /**
     Return the number of items (cells) to display in the section controller.

     @param context Contextual information about the section controller.

     @return The number of items (cells) to display.
     */
    open func numberOfItems(for context: Context) -> Int { return 1 }

    /**
     Return the size of a given item index.

     @param index The index of the item needing a size.
     @param context Contextual information about the section controller.

     @return A CGSize for the item.
     */
    open func size(at index: Int, context: Context) -> CGSize { return .zero }

    /**
     Dequeue, configure, and return a cell for a given index.

     @param index The index of the item needing a cell.
     @param context Contextual information about the section controller.

     @return A dequeued `UICollectionViewCell`.
     */
    open func cell(at index: Int, context: Context) -> UICollectionViewCell { return UICollectionViewCell() }

    /**
     Handle selection of a cell.

     @param index The index of the selected item.
     @param context Contextual information about the section controller.
     */
    open func didSelectItem(at index: Int, context: Context) { }

    /**
     Handle deselection of a cell.

     @param index The index of the deselected item.
     @param context Contextual information about the section controller.
     */
    open func didDeselectItem(at index: Int, context: Context) { }

    /**
     Handle highlighting of a cell.

     @param index The index of the highlighted item.
     @param context Contextual information about the section controller.
     */
    open func didHighlightItem(at index: Int, context: Context) { }

    /**
     Handle unhighlighting of a cell.

     @param index The index of the unhighlighted item.
     @param context Contextual information about the section controller.
     */
    open func didUnhighlightItem(at index: Int, context: Context) { }

    // MARK: Base implementations

    /**
     :nodoc:
     */
    public final override func didUpdate(to object: Any) {
        guard let object = object as? ListDiffableBox,
            let value = object.value as? T
            else { return }
        self.value = value
    }

    /**
     :nodoc:
     */
    public final override func numberOfItems() -> Int {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return numberOfItems(for: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return size(at: index, context: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        return cell(at: index, context: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func didSelectItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didSelectItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func didDeselectItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didDeselectItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func didHighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didHighlightItem(at: index, context: Context(collection: collectionContext, value: value))
    }

    /**
     :nodoc:
     */
    public final override func didUnhighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext,
            let value = self.value
            else { fatalError("something bad happened") }
        didUnhighlightItem(at: index, context: Context(collection: collectionContext, value: value))
    }

}
