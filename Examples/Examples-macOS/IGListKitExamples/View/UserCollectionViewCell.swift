/**
 Copyright (c) Facebook, Inc. and its affiliates.

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

protocol UserCollectionViewCellDelegate: class {

    func itemDeleted(_ user: User)
}

final class UserCollectionViewCell: NSCollectionViewItem {

    weak var delegate: UserCollectionViewCellDelegate?

    @IBAction func deleteButtonClicked(_ sender: AnyObject) {
        guard let user = representedObject as? User else { return }
        delegate?.itemDeleted(user)
    }

    func bindViewModel(_ user: User) {
        representedObject = user
        textField?.stringValue = user.name
    }
}
