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

import Foundation

final class UsersProvider {

    enum UsersError: Error {
        case invalidData
    }

    let users: [User]

    init(with file: URL) throws {
        let data = try Data(contentsOf: file)
        let json = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dicts = json as? [[String: String]] else {
            throw UsersError.invalidData
        }

        self.users = dicts.enumerated().flatMap { index, dict in
            guard let name = dict["name"] else { return nil }

            return User(pk: index, name: name.capitalized)
        }.sorted(by: { $0.name < $1.name })
    }

}
