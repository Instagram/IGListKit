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

class StoryboardLabelSectionController: IGListSectionController, IGListSectionType {
    
    var object: String?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: (self.object?.characters.count)! * 10, height: (self.object?.characters.count)! * 10)
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "cell", for: self, at: index) as! StoryboardCell
        cell.textLabel.text = object
        cell.textLabel.textColor = .white
        cell.backgroundColor = UIColor.magenta
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.object = object as? String
    }
    
    func didSelectItem(at index: Int) {}
    
}
