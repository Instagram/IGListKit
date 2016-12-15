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

    @IBOutlet weak var tableView: NSTableView!
    
    var users = [User]() {
        didSet {
            let diff = IGListDiff(oldValue, users, .equality)
            
            tableView.beginUpdates()
            tableView.insertRows(at: diff.inserts, withAnimation: .slideDown)
            tableView.removeRows(at: diff.deletes, withAnimation: .slideUp)
            tableView.reloadData(forRowIndexes: diff.updates, columnIndexes: .zero)
            diff.moves.forEach { move in
                self.tableView.moveRow(at: move.from, to: move.to)
            }
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleUsers()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.titleVisibility = .hidden
    }
    
    private func loadSampleUsers() {
        guard let file = Bundle.main.url(forResource: "users", withExtension: "json") else { return }
        
        do {
            self.users = try UsersProvider(with: file).users
        } catch {
            NSAlert(error: error).runModal()
        }
    }
    
    @IBAction func shuffle(_ sender: Any?) {
        
    }
    
}

extension UsersViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return users.count
    }
    
}

extension UsersViewController: NSTableViewDelegate {
    
    private struct Storyboard {
        static let cellIdentifier = "cell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.make(withIdentifier: Storyboard.cellIdentifier, owner: tableView) as? NSTableCellView else {
            return nil
        }
        
        cell.textField?.stringValue = users[row].name
        
        return cell
    }
    
}
