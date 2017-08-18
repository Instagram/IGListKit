//
//  Post.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import IGListKit

final class Post: ListDiffable {
    
    let username: String
    let timestamp: String
    let imageURL: URL
    let likes: Int
    let comments: [Comment]

    init(username: String, timestamp: String, imageURL: URL, likes: Int, comments: [Comment]) {
        self.username = username
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.likes = likes
        self.comments = comments
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return (username + timestamp) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
