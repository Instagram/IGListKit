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

final class CalendarViewController: UIViewController, IGListAdapterDataSource {
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    let collectionView = IGListCollectionView(
        frame: .zero,
        collectionViewLayout: IGListCollectionViewLayout(stickyHeaders: false, topContentInset: 0)
    )
    
    var months = [Month]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let currentMonth = Calendar.current.component(.month, from: date)
        
        let month = Month(
            name: DateFormatter().monthSymbols[currentMonth - 1],
            days: 30,
            appointments: [
                2: ["Hair"],
                4: ["Nails"],
                7: ["Doctor appt", "Pick up groceries"],
                12: ["Call back the cable company", "Find a babysitter"],
                13: ["Dinner at The Smith"],
                17: ["Buy running shoes", "Buy a fitbit", "Start running"],
                20: ["Call mom"],
                21: ["Contribute to IGListKit"],
                25: ["Interview"],
                26: ["Quit running", "Buy ice cream"]
            ]
        )
        months.append(month)
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return months
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return MonthSectionController()
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }

}
