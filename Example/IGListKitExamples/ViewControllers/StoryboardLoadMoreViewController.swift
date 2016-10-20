//
//  StoryboardLoadMoreViewController.swift
//  IGListKitExamples
//
//  Created by Bofei Zhu on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

import UIKit
import IGListKit

class StoryboardLoadMoreViewController: UIViewController, IGListAdapterDataSource, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: IGListCollectionView!
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    lazy var words = "Maecenas faucibus mollis interdum Praesent commodo cursus magna, vel scelerisque nisl consectetur et".components(separatedBy: " ")
    var loading = false
    let spinToken = NSObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    //MARK: IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        var items: [IGListDiffable] = words as [IGListDiffable]
        if loading {
            items.append(spinToken)
        }
        return items
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if let obj = object as? NSObject, obj === spinToken {
            return spinnerSectionController()
        } else {
            return StoryboardLabelSectionController()
        }
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !loading && distance < 200 {
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async(execute: {
                // fake background loading task
                sleep(2)
                DispatchQueue.main.async {
                    self.loading = false
                    self.words.append(contentsOf: "Etiam porta sem malesuada magna mollis euismod".components(separatedBy: " "))
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            })
        }
    }

}
