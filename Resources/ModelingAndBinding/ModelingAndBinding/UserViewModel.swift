//
//  UserViewModel.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import IGListKit

final class UserViewModel: ListDiffable {

    let username: String
    let timestamp: String

    init(username: String, timestamp: String) {
        self.username = username
        self.timestamp = timestamp
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return "user" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? UserViewModel else  { return false }
        return username == object.username
        && timestamp == object.timestamp
    }

}
