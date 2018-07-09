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

import IGListKit
import UIKit

final class Person: ListDiffable {

    let pk: Int
    let name: String

    init(pk: Int, name: String) {
        self.pk = pk
        self.name = name
    }

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSNumber
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Person else { return false }
        return self.name == object.name
    }

}

final class DiffTableViewController: UITableViewController {

    let oldPeople = [
        Person(pk: 1, name: "Kevin"),
        Person(pk: 2, name: "Mike"),
        Person(pk: 3, name: "Ann"),
        Person(pk: 4, name: "Jane"),
        Person(pk: 5, name: "Philip"),
        Person(pk: 6, name: "Mona"),
        Person(pk: 7, name: "Tami"),
        Person(pk: 8, name: "Jesse"),
        Person(pk: 9, name: "Jaed")
    ]
    let newPeople = [
        Person(pk: 2, name: "Mike"),
        Person(pk: 10, name: "Marne"),
        Person(pk: 5, name: "Philip"),
        Person(pk: 1, name: "Kevin"),
        Person(pk: 3, name: "Ryan"),
        Person(pk: 8, name: "Jesse"),
        Person(pk: 7, name: "Tami"),
        Person(pk: 4, name: "Jane"),
        Person(pk: 9, name: "Chen")
    ]
    lazy var people: [Person] = {
        return self.oldPeople
    }()
    var usingOldPeople = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play,
                                                            target: self,
                                                            action: #selector(DiffTableViewController.onDiff))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc func onDiff() {
        let from = people
        let to = usingOldPeople ? newPeople : oldPeople
        usingOldPeople = !usingOldPeople
        people = to

        let result = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: from, newArray: to, option: .equality).forBatchUpdates()

        tableView.beginUpdates()
        tableView.deleteRows(at: result.deletes, with: .fade)
        tableView.insertRows(at: result.inserts, with: .fade)
        result.moves.forEach { tableView.moveRow(at: $0.from, to: $0.to) }
        tableView.endUpdates()
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }

}
