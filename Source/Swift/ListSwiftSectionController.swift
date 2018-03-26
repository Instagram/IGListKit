/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit

public protocol ListSwiftBindable {
    func bind(value: ListSwiftDiffable)
}

public typealias ListSwiftBindableCell = UICollectionViewCell & ListSwiftBindable

public struct BindingData {
    let value: ListSwiftDiffable
    let cellType: ListSwiftBindableCell.Type
    let size: (ListCollectionContext, Int) -> CGSize
}

open class ListSwiftSectionController<T: ListSwiftIdentifiable>: ListSectionController {

    public struct Context<T> {
        public let value: T
        public let collectionContext: ListCollectionContext
        public let index: Int
    }

    public func bindingData<T: ListSwiftDiffable>(
        _ value: T,
        cellType: ListSwiftBindableCell.Type,
        size: @escaping (Context<T>) -> CGSize
        ) -> BindingData {
        return BindingData(value: value, cellType: cellType, size: { (context, index) -> CGSize in
            return size(Context(value: value, collectionContext: context, index: index))
        })
    }

    private enum State: Int {
        case idle
        case queued
        case applied
    }
    private var state: State = .idle

    public private(set) var data = [BindingData]()
    public private(set) var identifiableValue: T?

    open func createViewModelData(value: T) -> [BindingData] {
        return []
    }

    public final func update(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard state == .idle else {
            completion?()
            return
        }
        state = .queued

        collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
            guard let strongSelf = self,
                let value = strongSelf.identifiableValue
                else { return }

            let fromBoxed = strongSelf.data.map { $0.value.boxed }
            let to = strongSelf.createViewModelData(value: value)
            let toBoxed = to.map { $0.value.boxed }
            let result = ListDiff(
                oldArray: fromBoxed,
                newArray: toBoxed,
                option: .equality
            )

            for (i, _) in result.updates.enumerated() {
                let identifier = fromBoxed[i].diffIdentifier()
                let toIndex = result.newIndex(forIdentifier: identifier)
                if toIndex != NSNotFound,
                    let cell = strongSelf.collectionContext?.cellForItem(at: i, sectionController: strongSelf) as? ListSwiftBindable {
                    cell.bind(value: to[toIndex].value)
                }
            }

            batchContext.delete(in: strongSelf, at: result.deletes)
            batchContext.insert(in: strongSelf, at: result.inserts)

            for move in result.moves {
                batchContext.move(in: strongSelf, from: move.from, to: move.to)
            }

            strongSelf.state = .applied
        }, completion: { [weak self] _ in
            self?.state = .idle
            completion?()
        })
    }

    // MARK: ListSectionController Overrides

    public final override func numberOfItems() -> Int {
        return data.count
    }

    public final override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = self.collectionContext else { return .zero }
        return data[index].size(collectionContext, index)
    }

    public final override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: data[index].cellType, for: self, at: index) as? ListSwiftBindableCell
            else { fatalError() }
        cell.bind(value: data[index].value)
        return cell
    }

    public final override func didUpdate(to object: Any) {
        guard let box = object as? ListIdentifiableBox,
            let value = box.value as? T
            else { return }

        let oldIdentifiableValue = identifiableValue
        identifiableValue = value

        if oldIdentifiableValue == nil {
            data = createViewModelData(value: value)
        } else {
            update()
        }
    }

}

//public class ListSwiftBindingData {
//
////    internal class BindingDataContext {
////        let _value: ListSwiftDiffable
////        init(value: ListSwiftDiffable) {
////            self._value = value
////        }
////    }
//
//    public class Context {
//        let value: ListSwiftDiffable
//        init<T: ListSwiftDiffable>(value: T) {
//            self.value = value
//        }
//    }
//
//    public typealias CellDequeueFunction<T> = (T) -> UICollectionViewCell & ListBindable
//    public typealias SizeFunction<T> = (T) -> CGSize
//
////    public static func pair<T: ListSwiftDiffable>(_ value: T, _ cell: @escaping CellDequeueFunction, _ size: @escaping SizeFunction) -> ListSwiftBindingData {
////        return ListSwiftBindingData(value, cell: cell, size: size)
////    }
//
//    public let value: ListSwiftDiffable
//    public let cell: (ListSwiftDiffable) -> UICollectionViewCell & ListBindable
//    public let size: (ListSwiftDiffable) -> CGSize
//
//    public init<T: ListSwiftDiffable>(
//        _ value: T,
//        cell: @escaping (ListSwiftDiffable) -> UICollectionViewCell & ListBindable,
//        size: @escaping (ListSwiftDiffable) -> CGSize
//        ) {
//        self.value = value
////        self.cell = cell as! (ListSwiftDiffable) -> UICollectionViewCell & ListBindable
////        self.size = size as! (ListSwiftDiffable) -> CGSize
//        self.cell = cell
//        self.size = size
//    }
//
//}
//
//public protocol ListSwiftBindingSectionControllerDataSource: class {
//    func viewModels(sectionController: ListSectionController) -> [ListSwiftBindingData]
//}
//
///**
// - return a single element w/ 3 things:
//   - diffable value
//   - cell gen function
//   - size gen function
// */
//
//open class ListSwiftBindingSectionController<T: ListSwiftIdentifiable>: ListBindingSectionController<ListIdentifiableBox>, ListBindingSectionControllerDataSource {
//
//    public func bindingData<T: ListSwiftDiffable>(
//        _ value: T,
//        cell: @escaping (T, ListCollectionContext) -> UICollectionViewCell & ListBindable,
//        size: @escaping (T, ListCollectionContext) -> CGSize
//        ) -> ListSwiftBindingData {
//        return ListSwiftBindingData(value, cell: { value in
//            guard let collectionContext = self.collectionContext else { fatalError() }
//            return cell(value as! T, collectionContext)
//        }, size: { value in
//            guard let collectionContext = self.collectionContext else { fatalError() }
//            return size(value as! T, collectionContext)
//        })
//    }
//
//    internal var viewModelData = [ListSwiftBindingData]()
//
//    public weak var swiftDataSource: ListSwiftBindingSectionControllerDataSource?
//
//    public override init() {
//        super.init()
//        dataSource = self
//    }
//
//    // MARK: ListBindingSectionControllerDataSource
//
//    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
//        guard let swiftDataSource = self.swiftDataSource else { return [] }
//
//        // only queried when something has changed. rebuild all data.
//        viewModelData = swiftDataSource.viewModels(sectionController: self)
//        return viewModelData.map { $0.value.boxed }
//    }
//
//    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
//        return viewModelData[index].cell(viewModelData[index].value)
//    }
//
//    public func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
//        return viewModelData[index].size(viewModelData[index].value)
//    }
//
//}

/**
 Subclass this class to create section controllers for use with `ListSwiftAdapter`.
 */
open class OLDListSwiftSectionController<T: ListSwiftDiffable>: ListSectionController {

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
