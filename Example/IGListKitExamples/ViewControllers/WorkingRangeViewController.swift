//
//  WorkingRangeViewController.swift
//  IGListKitExamples
//
//  Created by Ryan Nystrom on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

import UIKit
import IGListKit

class WorkingRangeViewController: UIViewController, IGListAdapterDataSource {

    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()

    let collectionView = IGListCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    let data: [Int] = {
        var arr = [Int]()
        while arr.count < 20 {
            let int = Int(arc4random_uniform(200)) + 200
            guard !arr.contains(int) else { continue }
            // only use unique values
            arr.append(int)
        }
        return arr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    //MARK: IGListAdapterDataSource

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return data as [NSNumber]
    }

    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return WorkingRangeSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }

}
