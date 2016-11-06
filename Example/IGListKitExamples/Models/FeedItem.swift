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

class FeedItem: IGListDiffable {

    let pk: Int
    let user: User
    let comments: [String]

    init(pk: Int, user: User, comments: [String]) {
        self.pk = pk
        self.user = user
        self.comments = comments
    }

    //MARK: IGListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(_ object: IGListDiffable?) -> Bool {
        if self === object {
            return true
        }
        guard let object = object as? FeedItem else { return false }
        return user.isEqual(object.user) && comments == object.comments
    }

}
