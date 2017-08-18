//
//  Comment.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import IGListKit

final class Comment: ListDiffable {

    let username: String
    let text: String

    init(username: String, text: String) {
        self.username = username
        self.text = text
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return (username + text) as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }

}
