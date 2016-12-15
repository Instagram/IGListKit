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

    var users = [User]() {
        didSet {
            users.forEach({ print($0.name) })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleUsers()
    }
    
    private func loadSampleUsers() {
        guard let file = Bundle.main.url(forResource: "users", withExtension: "json") else { return }
        
        do {
            self.users = try UsersProvider(with: file).users
        } catch {
            NSAlert(error: error).runModal()
        }
    }
    
}

