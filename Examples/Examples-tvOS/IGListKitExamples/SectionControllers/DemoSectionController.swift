/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import IGListKit
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
        guard let cell = collectionContext?.dequeueReusableCell(of: DemoCell.self, for: self, at: index) as? DemoCell else {
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
