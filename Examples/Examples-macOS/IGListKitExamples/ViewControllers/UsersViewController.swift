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

import Cocoa
import IGListKit

final class UsersViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!

    // MARK: Data

    var users = [User]() {
        didSet {
            computeFilteredUsers()
        }
    }

    var searchTerm = "" {
        didSet {
            computeFilteredUsers()
        }
    }

    private func computeFilteredUsers() {
        guard !searchTerm.isEmpty else {
            filteredUsers = users
            return
        }

        filteredUsers = users.filter({ $0.name.localizedCaseInsensitiveContains(self.searchTerm) })
    }

    fileprivate func delete(user: User) {
        guard let index = self.users.index(where: { $0.pk == user.pk }) else { return }

        self.users.remove(at: index)
    }

    // MARK: -
    // MARK: Diffing 

    var isFirstRun = true
    var filteredUsers = [User]() {
        didSet {
            // A crash occurs when you try to use performBatchUpdates the first time
            guard !isFirstRun else {
                collectionView.reloadData()
                isFirstRun = false
                return
            }

            // get the difference between the old array of Users and the new array of Users
            let diff = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: oldValue, newArray: filteredUsers, option: .equality)
            let batchUpdates = diff.forBatchUpdates()
            let inserts = Set(batchUpdates.inserts)
            let deletes = Set(batchUpdates.deletes)
            let updates = Set(batchUpdates.updates)
            let moves = Set(batchUpdates.moves)

            // this difference is used here to update the collection view, but it can be used
            // to update collection views and other similar interface elements
            // this code can also be added to an extension of NSCollectionView ;)

            // Set the animation duration when updating the collection view
            NSAnimationContext.current.duration = 0.25

            // Perform the updates to the collection view
            collectionView.animator().performBatchUpdates({
                collectionView.deleteItems(at: deletes)
                collectionView.insertItems(at: inserts)
                collectionView.reloadItems(at: updates)
                moves.forEach { move in
                    collectionView.moveItem(at: move.from, to: move.to)
                }
            }, completionHandler: nil)
        }
    }

    // MARK: -

    private func loadSampleUsers() {
        guard let file = Bundle.main.url(forResource: "users", withExtension: "json") else { return }

        do {
            self.users = try UsersProvider(with: file).users
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    // MARK: Interface

    override func viewDidLoad() {
        super.viewDidLoad()

        // The view needs to be backed by a CALayer to be able to enable the collections view animations you can 
        // enable this by selecting the view controller's view in the Interface Builder in the Core Animation section
        // of the View Effects inspector tab, through code you can do by view.wantsLayer = true
        loadSampleUsers()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.titleVisibility = .hidden
    }

    @IBAction func shuffle(_ sender: Any?) {
        users = users.shuffled
    }

    @IBAction func search(_ sender: NSSearchField) {
        searchTerm = sender.stringValue
    }
}

extension UsersViewController: UserCollectionViewCellDelegate {

    func itemDeleted(_ user: User) {
        self.delete(user: user)
    }
}

extension UsersViewController: NSCollectionViewDelegate {
}

extension UsersViewController: NSCollectionViewDataSource {

    private struct Storyboard {
        static let cellIdentifier = "UserCollectionViewCell"
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredUsers.count
    }

    @available(OSX 10.11, *)
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Storyboard.cellIdentifier), for: indexPath)
        guard let cell = item as? UserCollectionViewCell else { return item }

        cell.delegate = self
        cell.bindViewModel(filteredUsers[indexPath.item])
        return cell
    }
}

extension UsersViewController: NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

        let availableWidth = collectionView.bounds.width
        return CGSize(width: availableWidth, height: 44)
    }
}
