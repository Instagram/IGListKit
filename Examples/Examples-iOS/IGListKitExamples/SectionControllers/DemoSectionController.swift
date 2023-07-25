/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class DemoItem: NSObject {

    let name: String
    let imageName: String
    let controllerClass: UIViewController.Type
    let controllerIdentifier: String?

    init(
        name: String,
        imageName: String,
        controllerClass: UIViewController.Type,
        controllerIdentifier: String? = nil
        ) {
        self.name = name
        self.imageName = imageName
        self.controllerClass = controllerClass
        self.controllerIdentifier = controllerIdentifier
    }

}

extension DemoItem: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? DemoItem else { return false }
        return controllerClass == object.controllerClass && controllerIdentifier == object.controllerIdentifier
    }

}

final class DemoSectionController: ListSectionController {
    private var object: DemoItem?

    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else {
            return .zero
        }
        let inset = context.containerInset
        let safeArea = viewController?.view.safeAreaInsets ?? .zero
        let width = context.containerSize.width - (inset.left + inset.right + safeArea.left + safeArea.right)
        return CGSize(width: width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object?.name
        cell.imageName = object?.imageName
        cell.style = .grouped
        cell.isTopCell = isFirstSection
        cell.isBottomCell = isLastSection
        if let splitViewController = viewController?.splitViewController {
            cell.disclosureImageView.isHidden = splitViewController.viewControllers.count > 1
        }
        cell.separator.isHidden = cell.isSelected
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? DemoItem
    }

    override func didSelectItem(at index: Int) {
        setSeparatorsHidden(true)

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        if let identifier = object?.controllerIdentifier {
            let storyboard = UIStoryboard(name: "Demo", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: identifier)
            controller.title = object?.name
            navigationController.viewControllers = [controller]
            viewController?.showDetailViewController(navigationController, sender: self)
        } else if let controller = object?.controllerClass.init() {
            controller.title = object?.name
            navigationController.viewControllers = [controller]
            viewController?.showDetailViewController(navigationController, sender: self)
        }
    }

    override func didDeselectItem(at index: Int) {
        setSeparatorsHidden(false)
    }

    private func setSeparatorsHidden(_ hidden: Bool) {
        if let cell = collectionContext.cellForItem(at: 0, sectionController: self) as? LabelCell {
            cell.separator.isHidden = hidden
        }

        if section > 0,
           let listAdapter = collectionContext as? ListAdapter,
           let previousSectionController = listAdapter.sectionController(forSection: section - 1),
           let previousCell = collectionContext.cellForItem(at: 0, sectionController: previousSectionController) as? LabelCell {
            previousCell.separator.isHidden = hidden
        }
    }
}
