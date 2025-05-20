/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class FeedViewController: UIViewController, ListAdapterDataSource {
    
    // MARK: - Properties
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var posts: [Post] = []
    private var isLoading = false
    private var shouldShowLoadingCell = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAdapter()
        loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Feed View"
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshFeed)
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAdapter() {
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
        adapter.dataSource = self
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        isLoading = true
        APIService.shared.resetPagination()
        posts = []
        shouldShowLoadingCell = true
        adapter.performUpdates(animated: true)
        
        APIService.shared.fetchPosts { [weak self] newPosts in
            guard let self = self else { return }
            self.posts = newPosts
            self.isLoading = false
            self.adapter.performUpdates(animated: true)
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        
        isLoading = true
        shouldShowLoadingCell = true
        adapter.performUpdates(animated: true)
        
        APIService.shared.fetchPosts { [weak self] newPosts in
            guard let self = self else { return }
            
            // Append new posts to existing posts
            self.posts.append(contentsOf: newPosts)
            self.isLoading = false
            
            // If no new posts were fetched, hide the loading cell
            if newPosts.isEmpty {
                self.shouldShowLoadingCell = false
            }
            
            self.adapter.performUpdates(animated: true)
        }
    }
    
    @objc private func refreshFeed() {
        loadInitialData()
    }
    
    // MARK: - ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects: [ListDiffable] = posts
        
        if shouldShowLoadingCell {
            objects.append(LoadingCellModel())
        }
        
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is Post {
            let sectionController = PostSectionController()
            sectionController.delegate = self
            return sectionController
        } else {
            return LoadingSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyView = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No posts available"
        label.textAlignment = .center
        label.textColor = .gray
        
        emptyView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
        
        return emptyView
    }
}

// MARK: - UIScrollViewDelegate

extension FeedViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, 
                                  withVelocity velocity: CGPoint, 
                                  targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        
        if !isLoading && distance < 200 && !posts.isEmpty {
            loadMoreData()
        }
    }
}

// MARK: - PostSectionControllerDelegate

extension FeedViewController: PostSectionControllerDelegate {
    func postSectionController(_ sectionController: PostSectionController, didSelectOptionsFor post: Post, from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePost(post)
        }
        
        let reportAction = UIAlertAction(title: "Report", style: .default) { _ in
            print("Reported post: \(post.id)")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        // Configure for iPad
        if let popoverController = alertController.popoverPresentationController {
            // If we have a specific source view (like a button), use it
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func postSectionController(_ sectionController: PostSectionController, didRequestDeleteFor post: Post) {
        deletePost(post)
    }
    
    private func deletePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts.remove(at: index)
            adapter.performUpdates(animated: true)
        }
    }
}
