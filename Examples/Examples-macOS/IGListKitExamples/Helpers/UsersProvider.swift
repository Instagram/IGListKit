/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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

        self.users = dicts.enumerated().compactMap { index, dict in
            guard let name = dict["name"] else { return nil }

            return User(pk: index, name: name.capitalized)
        }.sorted(by: { $0.name < $1.name })
    }

}
