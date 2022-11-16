/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class StoryboardViewController: UIViewController, ListAdapterDataSource, StoryboardLabelSectionControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    lazy var people = [
        Person(pk: 1, name: "Littlefinger"),
        Person(pk: 2, name: "Tommen Baratheon"),
        Person(pk: 3, name: "Roose Bolton"),
        Person(pk: 4, name: "Brienne of Tarth"),
        Person(pk: 5, name: "Bronn"),
        Person(pk: 6, name: "Gilly"),
        Person(pk: 7, name: "Theon Greyjoy"),
        Person(pk: 8, name: "Jaqen H'ghar"),
        Person(pk: 9, name: "Cersei Lannister"),
        Person(pk: 10, name: "Jaime Lannister"),
        Person(pk: 11, name: "Tyrion Lannister"),
        Person(pk: 12, name: "Melisandre"),
        Person(pk: 13, name: "Missandei"),
        Person(pk: 14, name: "Jorah Mormont"),
        Person(pk: 15, name: "Khal Moro"),
        Person(pk: 16, name: "Daario Naharis"),
        Person(pk: 17, name: "Jon Snow"),
        Person(pk: 18, name: "Arya Stark"),
        Person(pk: 19, name: "Bran Stark"),
        Person(pk: 20, name: "Sansa Stark"),
        Person(pk: 21, name: "Daenerys Targaryen"),
        Person(pk: 22, name: "Samwell Tarly"),
        Person(pk: 23, name: "Tormund"),
        Person(pk: 24, name: "Margaery Tyrell"),
        Person(pk: 25, name: "Varys"),
        Person(pk: 26, name: "Renly Baratheon"),
        Person(pk: 27, name: "Joffrey Baratheon"),
        Person(pk: 28, name: "Stannis Baratheon"),
        Person(pk: 29, name: "Hodor"),
        Person(pk: 30, name: "Tywin Lannister"),
        Person(pk: 31, name: "The Hound"),
        Person(pk: 32, name: "Ramsay Bolton")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return people
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = StoryboardLabelSectionController()
        sectionController.delegate = self
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    func removeSectionControllerWantsRemoved(_ sectionController: StoryboardLabelSectionController) {
        let section = adapter.section(for: sectionController)
        people.remove(at: Int(section))
        adapter.performUpdates(animated: true)
    }
}
