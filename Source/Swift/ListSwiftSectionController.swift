/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit

public enum ListCellType<T: UICollectionViewCell> {
    case `class`(T.Type)
    case storyboard(T.Type, String)
    case nib(T.Type, String, Bundle?)
}

public struct ListBinder {

    enum CellType {
        case cellClass(UICollectionViewCell.Type)
        case storyboard(String)
        case nib(String, Bundle?)
    }

    let value: ListSwiftDiffable
    let cellType: CellType
    let size: (ListSectionController, ListCollectionContext, Int) -> CGSize
    let configure: (UICollectionViewCell, ListSectionController, ListCollectionContext, Int) -> Void
    let didSelect: (ListSectionController, ListCollectionContext, Int) -> Void
    let didDeselect: (ListSectionController, ListCollectionContext, Int) -> Void
    let didHighlight: (ListSectionController, ListCollectionContext, Int) -> Void
    let didUnhighlight: (ListSectionController, ListCollectionContext, Int) -> Void
}

open class ListSwiftSectionController<T: ListSwiftDiffable>: ListSectionController {

    public struct Context<ValueType, CellType> {

        public let value: ValueType
        public let collection: ListCollectionContext
        public let index: Int

        fileprivate let sectionController: ListSectionController

        public var cell: CellType? {
            return collection.cellForItem(at: index, sectionController: sectionController) as? CellType
        }

        public func deselect(animated: Bool = true) {
            collection.deselectItem(
                at: index,
                sectionController: sectionController,
                animated: animated
            )
        }

        public func select(
            animated: Bool = true,
            scrollPosition: UICollectionViewScrollPosition = .centeredVertically
            ) {
            collection.selectItem(
                at: index,
                sectionController: sectionController,
                animated: animated,
                scrollPosition: scrollPosition
            )
        }
        
    }

    public func binder<ValueType: ListSwiftDiffable, CellType: UICollectionViewCell>(
        _ value: ValueType,
        cellType: ListCellType<CellType>,
        size: @escaping (Context<ValueType, CellType>) -> CGSize,
        configure: ((CellType, Context<ValueType, CellType>) -> Void)? = nil,
        didSelect: ((Context<ValueType, CellType>) -> Void)? = nil,
        didDeselect: ((Context<ValueType, CellType>) -> Void)? = nil,
        didHighlight: ((Context<ValueType, CellType>) -> Void)? = nil,
        didUnhighlight: ((Context<ValueType, CellType>) -> Void)? = nil
        ) -> ListBinder {
        let nestedCellType: ListBinder.CellType
        switch cellType {
        case let .class(type): nestedCellType = .cellClass(type)
        case let .storyboard(_, type): nestedCellType = .storyboard(type)
        case let .nib(_, type, bundle): nestedCellType = .nib(type, bundle)
        }

        return ListBinder(
            value: value,
            cellType: nestedCellType,
            size: { (sc, context, index) -> CGSize in
                return size(Context(value: value, collection: context, index: index, sectionController: sc))
        },
            configure: { (cell, sc, context, index) -> Void in
                guard let typedCell = cell as? CellType else {
                    fatalError("Critical cell mapping failure. Expected \(CellType.self) but received \(cell).")
                }
                configure?(typedCell, Context(value: value, collection: context, index: index, sectionController: sc))
        },
            didSelect: { (sc, context, index) -> Void in
                didSelect?(Context(value: value, collection: context, index: index, sectionController: sc))
        },
            didDeselect: { (sc, context, index) -> Void in
                didDeselect?(Context(value: value, collection: context, index: index, sectionController: sc))
        },
            didHighlight: { (sc, context, index) -> Void in
                didHighlight?(Context(value: value, collection: context, index: index, sectionController: sc))
        },
            didUnhighlight: { (sc, context, index) -> Void in
                didUnhighlight?(Context(value: value, collection: context, index: index, sectionController: sc))
        })
    }

    internal enum State: Int {
        case idle
        case queued
        case applied
    }
    internal var state: State = .idle

    public internal(set) var binders = [ListBinder]()
    public internal(set) var value: T?

    open func createBinders(from value: T) -> [ListBinder] {
        return []
    }

    /**
     Perform an asyncronous update on the section controller. This method will regenerate view models through
     `createBinders(from value:)`, diff the models, and apply the results of the diff to the backing `UICollectionView`.

     @param animated A flag indicating if the update is animated. Default is `true`.
     @param completion An optional closure executed once the update is applied. Default is `nil`.
     */
    public final func update(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let collectionContext = self.collectionContext else { return }
        guard state == .idle else {
            completion?()
            return
        }
        state = .queued

        collectionContext.performBatch(animated: animated, updates: { [weak self] (batchContext) in
            guard let strongSelf = self,
                let value = strongSelf.value
                else { return }

            let fromBoxed = strongSelf.binders.map { $0.value.boxed }
            let to = strongSelf.createBinders(from: value)
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
                    let cell = strongSelf.collectionContext?.cellForItem(at: i, sectionController: strongSelf) {
                    to[toIndex].configure(cell, strongSelf, collectionContext, toIndex)
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

    /**
     :nodoc:
     */
    public final override func numberOfItems() -> Int {
        return binders.count
    }

    /**
     :nodoc:
     */
    public final override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = self.collectionContext else { return .zero }
        return binders[index].size(self, collectionContext, index)
    }

    /**
     :nodoc:
     */
    public final override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let collectionContext = self.collectionContext else {
            fatalError("Must have a collectionContext when dequeuing cells")
        }

        let binder = binders[index]
        let rawCell: UICollectionViewCell?
        switch binder.cellType {
        case let .cellClass(type):
            rawCell = collectionContext.dequeueReusableCell(of: type, for: self, at: index)
        case let .nib(type, bundle):
            rawCell = collectionContext.dequeueReusableCell(withNibName: type, bundle: bundle, for: self, at: index)
        case let .storyboard(type):
            rawCell = collectionContext.dequeueReusableCellFromStoryboard(withIdentifier: type, for: self, at: index)
        }

        guard let cell = rawCell else {
            fatalError("Cell is nil for type \(binder.cellType)")
        }

        binder.configure(cell, self, collectionContext, index)
        return cell
    }

    /**
     :nodoc:
     */
    public final override func didUpdate(to object: Any) {
        guard let box = object as? ListDiffableBox,
            let value = box.value as? T
            else { return }

        let hadNoValue = self.value == nil
        self.value = value

        if hadNoValue {
            binders = createBinders(from: value)
        } else {
            update()
        }
    }

    /**
     :nodoc:
     */
    public final override func didSelectItem(at index: Int) {
        guard let collectionContext = self.collectionContext else {
            fatalError("Must have a collectionContext when selection occurs.")
        }
        binders[index].didSelect(self, collectionContext, index)
    }

    /**
     :nodoc:
     */
    public final override func didDeselectItem(at index: Int) {
        guard let collectionContext = self.collectionContext else {
            fatalError("Must have a collectionContext when deselection occurs.")
        }
        binders[index].didDeselect(self, collectionContext, index)
    }

    /**
     :nodoc:
     */
    public final override func didHighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext else {
            fatalError("Must have a collectionContext when highlighting occurs.")
        }
        binders[index].didHighlight(self, collectionContext, index)
    }

    /**
     :nodoc:
     */
    public final override func didUnhighlightItem(at index: Int) {
        guard let collectionContext = self.collectionContext else {
            fatalError("Must have a collectionContext when unhighlighting occurs.")
        }
        binders[index].didUnhighlight(self, collectionContext, index)
    }

}

