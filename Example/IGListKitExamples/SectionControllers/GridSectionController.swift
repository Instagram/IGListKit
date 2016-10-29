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

class GridItem: NSObject {

    let color: UIColor
    let itemCount: Int

    init(color: UIColor, itemCount: Int) {
        self.color = color
        self.itemCount = itemCount
    }
    
    // MARK: Create from JSON
    
    class func from(json: [String: Any]) -> GridItem? {
        guard let colorDictionary = json["color"] as? [String: CGFloat],
                          let red = colorDictionary["red"],
                        let green = colorDictionary["green"],
                         let blue = colorDictionary["blue"],
                        let alpha = colorDictionary["alpha"],
                    let itemCount = json["count"] as? Int else {
                return nil
        }
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return GridItem(color: color, itemCount: itemCount)
    }

}

class GridSectionController: IGListSectionController, IGListSectionType {

    var object: GridItem?

    override init() {
        super.init()
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }

    func numberOfItems() -> Int {
        return object?.itemCount ?? 0
    }

    func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 4)
        return CGSize(width: itemSize, height: itemSize)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: CenterLabelCell.self, for: self, at: index) as! CenterLabelCell
        cell.label.text = "\(index + 1)"
        cell.backgroundColor = object?.color
        return cell
    }

    func didUpdate(to object: Any) {
        self.object = object as? GridItem
    }

    func didSelectItem(at index: Int) {}

}
