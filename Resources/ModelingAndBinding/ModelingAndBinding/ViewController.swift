//
//  ViewController.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit

class ViewController: UIViewController, ListAdapterDataSource {

    var data = [ListDiffable]()
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()

    override func viewDidLoad() {
        super.viewDidLoad()

        data.append(Post(
            username: "@janedoe",
            timestamp: "15min",
            imageURL: URL(string: "https://placekitten.com/g/375/250")!,
            likes: 384,
            comments: [
                Comment(username: "@ryan", text: "this is beautiful!"),
                Comment(username: "@jsq", text: "😱"),
                Comment(username: "@caitlin", text: "#blessed"),
            ]
        ))

        adapter.dataSource = self
        adapter.collectionView = self.collectionView
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }

    func listAdapter(
        _ listAdapter: ListAdapter,
        sectionControllerFor object: Any
        ) -> ListSectionController {
        return PostSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}
