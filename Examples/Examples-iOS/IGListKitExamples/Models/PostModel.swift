/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class Post {
    let id: String
    let username: String
    let userAvatarURL: URL?
    let imageURL: URL?
    let title: String
    let description: String
    let likes: Int
    let timeStamp: Date
    
    init(id: String, username: String, userAvatarURL: URL?, imageURL: URL?, title: String, description: String, likes: Int, timeStamp: Date) {
        self.id = id
        self.username = username
        self.userAvatarURL = userAvatarURL
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.likes = likes
        self.timeStamp = timeStamp
    }
}

// MARK: - ListDiffable Implementation

// ListDiffable is the core protocol in IGListKit for data diffing
// It's similar to Equatable but with more specific requirements for efficient diffing
extension Post: ListDiffable {
    
    // This method returns a unique identifier for the object
    // IGListKit uses this to track objects across updates
    // It should be unique and stable across updates (like a database ID)
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }
    
    // This method compares all properties that might cause visual changes
    // If this returns false for objects with the same diffIdentifier,
    // IGListKit will reload that section instead of leaving it alone
    func isEqual(toDiffableObject object: (any ListDiffable)?) -> Bool {
        guard let object = object as? Post else { return false }
        
        return self.id == object.id &&
               self.username == object.username &&
               self.userAvatarURL == object.userAvatarURL &&
               self.imageURL == object.imageURL &&
               self.title == object.title &&
               self.description == object.description &&
               self.likes == object.likes
    }
}
