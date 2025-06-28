/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

// MARK: - UICollectionViewCell

// In IGListKit, cells are regular UICollectionViewCells
// There's no special base class - IGListKit works with standard UIKit components
final class PostCell: UICollectionViewCell {

    // MARK: - UI Components

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()

    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()

    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private let captionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    private let captionUsernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        return label
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()

    // MARK: - Properties

    // Closure for handling the options button tap
    // This allows the section controller to respond to UI events in the cell
    var optionsButtonTapped: ((UIButton) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Clean up cell for reuse - important for efficient cell recycling
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        postImageView.image = nil
        usernameLabel.text = nil
        captionUsernameLabel.text = nil
        captionLabel.text = nil
        likesLabel.text = nil
        timestampLabel.text = nil
    }

    // MARK: - Setup

    private func setupViews() {

        optionsButton.accessibilityIdentifier = "optionsButton"

        contentView.backgroundColor = .systemBackground

        // Add subviews
        contentView.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(optionsButton)

        contentView.addSubview(postImageView)

        contentView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(likeButton)
        actionStackView.addArrangedSubview(commentButton)
        actionStackView.addArrangedSubview(shareButton)

        contentView.addSubview(likesLabel)

        contentView.addSubview(captionStackView)
        captionStackView.addArrangedSubview(captionUsernameLabel)
        captionStackView.addArrangedSubview(captionLabel)

        contentView.addSubview(timestampLabel)

        // Layout constraints
        NSLayoutConstraint.activate([

            // Header view
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            avatarImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            optionsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            optionsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            optionsButton.widthAnchor.constraint(equalToConstant: 30),
            optionsButton.heightAnchor.constraint(equalToConstant: 30),

            // Post image
            postImageView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor), // Square aspect ratio

            // Action buttons
            actionStackView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),

            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),

            commentButton.widthAnchor.constraint(equalToConstant: 30),
            commentButton.heightAnchor.constraint(equalToConstant: 30),

            shareButton.widthAnchor.constraint(equalToConstant: 30),
            shareButton.heightAnchor.constraint(equalToConstant: 30),

            // Likes
            likesLabel.topAnchor.constraint(equalTo: actionStackView.bottomAnchor, constant: 5),
            likesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),

            // Caption
            captionStackView.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 5),
            captionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            captionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            // Timestamp
            timestampLabel.topAnchor.constraint(equalTo: captionStackView.bottomAnchor, constant: 5),
            timestampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    private func setupActions() {
        optionsButton.addTarget(self, action: #selector(handleOptionsButtonTap), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func handleOptionsButtonTap() {
        optionsButtonTapped?(optionsButton)
    }

    // MARK: - Configuration

    // Configure the cell with data from a Post model
    // In IGListKit, cells are configured by their section controllers
    func configure(with post: Post) {
        usernameLabel.text = post.username
        captionUsernameLabel.text = post.username
        captionLabel.text = post.description
        likesLabel.text = "\(post.likes) likes"

        // Format timestamp
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        timestampLabel.text = formatter.localizedString(for: post.timeStamp, relativeTo: Date())

        if let avatarURL = post.userAvatarURL {
            URLSession.shared.dataTask(with: avatarURL) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.avatarImageView.image = image
                    }
                }
            }.resume()
        }

        if let imageURL = post.imageURL {
            URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.postImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
