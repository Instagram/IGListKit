/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

// MARK: - Data Provider

// In IGListKit architecture, the data provider is separated from the UI components
// This enables clean separation of concerns and makes testing easier
class APIService {
    static let shared = APIService()

    // Pagination state
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true

    // Fetch posts with pagination support
    // This is called by the view controller to load data
    // IGListKit will handle the diffing and UI updates based on the results
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        guard !isLoading, hasMoreData else { return }

        self.isLoading = true

        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let posts = self.generateMockPosts(page: self.currentPage)

            if self.currentPage >= 5 {
                self.hasMoreData = false
            }

            self.currentPage += 1
            self.isLoading = false

            DispatchQueue.main.async {
                completion(posts)
            }
        }
    }

    // Reset pagination state for refreshing
    func resetPagination() {
        self.currentPage = 1
        self.hasMoreData = true
    }

    // Generate mock data for the demo app
    // In a real app, this would be replaced with API calls
    func generateMockPosts(page: Int) -> [Post] {
        let baseCount = (page - 1) * 5

        return (1...5).map { index in
            let id = "\(baseCount + index)"
            return Post(
                id: id,
                username: "user\(Int.random(in: 100...999))",
                userAvatarURL: URL(string: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"),
                imageURL: URL(string: "https://picsum.photos/id/\(baseCount + index + 10)/500/500"),
                title: "Post #\(id)",
                description: "This is a beautiful photo I took while traveling. What do you think? #travel #photography #nature",
                likes: Int.random(in: 10...1000),
                timeStamp: Date().addingTimeInterval(-Double(Int.random(in: 1...86400) * (baseCount + index)))
            )
        }
    }
}
