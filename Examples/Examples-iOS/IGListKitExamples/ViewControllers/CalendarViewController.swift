/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class CalendarViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
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

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return months
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return MonthSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}
