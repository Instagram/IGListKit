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

class JSONMixedDataViewController: MixedDataViewController {

    let spinToken = NSObject()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        data.removeAll()
        data.append(spinToken)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let mixedDataJSON = try? loadJSON(withFileName: "MixedData")
        guard let mixedData = mixedDataJSON ?? nil else { return }
        guard let sections = mixedData["sections"] as? [[String: Any]] else { return }
        
        data.removeAll()
        
        for section in sections {
            guard let sectionType = section["type"] as? String else { continue }
            
            switch sectionType {
            case "ExpandableLabel":
                guard let labelText = section["text"] as? String else { continue }
                data.append(labelText)
                continue
            case "GridItem":
                guard let gridItem = GridItem.from(json: section) else { continue }
                data.append(gridItem)
                continue
            case "User":
                guard let user = User.from(json: section) else { continue }
                data.append(user)
                continue
            default: continue
            }
        }
        
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    func loadJSON(withFileName fileName: String) throws -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else { return nil }
        
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
}
