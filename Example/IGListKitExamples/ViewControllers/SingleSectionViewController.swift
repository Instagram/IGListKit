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

final class SingleSectionViewController: UIViewController, IGListAdapterDataSource, IGListSingleSectionControllerDelegate {
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    let collectionView = IGListCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var data = [Int]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0..<20 {
            data.append(index)
        }
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    //MARK: - IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return data as [IGListDiffable]
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        let configureBlock = { (data: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? NibCell, let number = data as? Int else { return }
            cell.textLabel.text = "Cell: \(number + 1)"
        }
        
        let sizeBlock = { (context: IGListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: 44)
        }
        let sectionController = IGListSingleSectionController(nibName: NibCell.nibName,
                                                              bundle: nil,
                                                              configureBlock: configureBlock,
                                                              sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        
        return sectionController
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - IGListSingleSectionControllerDelegate
    
    func didSelect(_ sectionController: IGListSingleSectionController) {
        let section = adapter.section(for: sectionController) + UInt(1)
        let alert = UIAlertController(title: "Section \(section) was selected 🎉", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
