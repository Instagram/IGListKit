/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

final class DemoItem: NSObject {

    let name: String
    let controllerClass: UIViewController.Type
    let controllerIdentifier: String?

    init(name: String,
         controllerClass: UIViewController.Type,
         controllerIdentifier: String? = nil) {

        self.name = name
        self.controllerClass = controllerClass
        self.controllerIdentifier = controllerIdentifier
    }

}

final class DemoSectionController: ListSectionController {

    var object: DemoItem?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 50, bottom: 10, right: 0)
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let itemWidth = (collectionContext!.containerSize.width / 2) - inset.left
        return CGSize(width: itemWidth, height: 100)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell: DemoCell = collectionContext?.dequeueReusableCell(for: self, at: index) else {
            fatalError()
        }
        cell.label.text = object?.name
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? DemoItem
    }

    override func didSelectItem(at index: Int) {
        if let identifier = object?.controllerIdentifier {
            let storyboard = UIStoryboard(name: "Demo", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: identifier)
            controller.title = object?.name
            viewController?.navigationController?.pushViewController(controller, animated: true)
        } else if let controller = object?.controllerClass.init() {
            controller.title = object?.name
            viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }

}
