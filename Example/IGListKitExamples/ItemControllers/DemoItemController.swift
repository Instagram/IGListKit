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

import UIKit
import IGListKit

class DemoItem: NSObject {

    let name: String
    let controllerClass: UIViewController.Type

    init(
        name: String,
        controllerClass: UIViewController.Type
        ) {
        self.name = name
        self.controllerClass = controllerClass
    }

}

class DemoItemController: IGListItemController, IGListItemType {

    var item: DemoItem?

    func numberOfItems() -> UInt {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        cell.label.text = item?.name
        return cell
    }

    func didUpdate(toItem item: Any) {
        self.item = item as? DemoItem
    }

    func didSelect(at index: Int) {
        if let controller = item?.controllerClass.init() {
            controller.title = item?.name
            viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }

}
