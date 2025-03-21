<p align="center">
  <img src="https://raw.githubusercontent.com/Instagram/IGListKit/main/Resources/logo.png" width=450 />
</p>

<p align="center">
  <a href="https://github.com/Instagram/IGListKit/actions/workflows/CI.yml"><img src="https://img.shields.io/github/actions/workflow/status/Instagram/IGListKit/CI.yml" alt="Build Status"></a>
  <a href="https://coveralls.io/github/Instagram/IGListKit?branch=main"><img src="https://coveralls.io/repos/github/Instagram/IGListKit/badge.svg?branch=main" alt="Coverage Status" /></a>
  <a href="https://cocoapods.org/pods/IGListKit"><img src="https://img.shields.io/cocoapods/v/IGListKit.svg?style=flat" alt="Pods Version"></a>
  <a href="https://instagram.github.io/IGListKit/"><img src="https://img.shields.io/cocoapods/p/IGListKit.svg?style=flat" alt="Platforms"></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat" alt="Carthage Compatible"></a>
</p>

----------------

A data-driven `UICollectionView` framework for building fast and flexible lists.

|         | Main Features  |
----------|-----------------
&#128581; | Never call `performBatchUpdates(_:, completion:)` or `reloadData()` again
&#127968; | Better architecture with reusable cells and components
&#128288; | Create collections with multiple data types
&#128273; | Decoupled diffing algorithm
&#9989;   | Fully unit tested
&#128269; | Customize your diffing behavior for your models
&#128241; | Simply `UICollectionView` at its core
&#128640; | Extendable API
&#128038; | Written in Objective-C with full Swift interop support

`IGListKit` is built and maintained with &#10084;&#65039; by [Instagram engineering](https://engineering.instagram.com/).
We use the open source version `main` branch in the Instagram app.

## Multilingual translation

[Chinese README](README.zh.md)

## Requirements

- Swift 5.1+
- iOS 11.0+
- tvOS 11.0+
- macOS 10.13+ *(diffing algorithm components only)*
- Interoperability with Swift 3.0+

## Installation

### CocoaPods

The preferred installation method is with [CocoaPods](https://cocoapods.org). Add the following to your `Podfile`:

```ruby
pod 'IGListKit', '~> 5.0.0'
```

### Carthage

For [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "Instagram/IGListKit" ~> 5.0.0
```

### Swift Package Manager

For [Swift Package Manager](https://swift.org/package-manager/):

```
To integrate using Xcode:

File -> Swift Packages -> Add Package Dependency

Enter package URL: https://github.com/Instagram/IGListKit, and select the latest release.
```

> For advanced usage, see our [Installation Guide](https://instagram.github.io/IGListKit/installation.html).

## Getting Started

Try out IGListKit by opening any of the sample apps available in the `Examples ` directory.

- Our [Getting Started guide](https://instagram.github.io/IGListKit/getting-started.html)
- Ray Wenderlich's [IGListKit Tutorial: Better UICollectionViews](https://www.raywenderlich.com/147162/iglistkit-tutorial-better-uicollectionviews)
- Our [example projects](https://github.com/Instagram/IGListKit/tree/main/Examples)
- Ryan Nystrom's [talk at try! Swift NYC](https://academy.realm.io/posts/tryswift-ryan-nystrom-refactoring-at-scale-lessons-learned-rewriting-instagram-feed/)(Note: this talk was for an earlier version. Some APIs have changed.)
- [Migrating an UITableView to IGListCollectionView](https://medium.com/cocoaacademymag/iglistkit-migrating-an-uitableview-to-iglistkitcollectionview-65a30cf9bac9), by Rodrigo Cavalcante
- [Keeping data fresh in Buffer for iOS with AsyncDisplayKit, IGListKit & Pusher](https://overflow.buffer.com/2017/04/10/keeping-data-fresh-buffer-ios-asyncdisplaykit-iglistkit-pusher/), Andy Yates, Buffer

## Documentation

You can find [the docs here](https://instagram.github.io/IGListKit). Documentation is generated with [jazzy](https://github.com/realm/jazzy) and hosted on [GitHub-Pages](https://pages.github.com).

To regenerate docs, run `./scripts/build_docs.sh` from the root directory in the repo.

## Vision

For the long-term goals and "vision" of `IGListKit`, please read our [Vision](https://github.com/Instagram/IGListKit/blob/main/Guides/VISION.md) doc.

## Contributing

Please see the [CONTRIBUTING](https://github.com/Instagram/IGListKit/blob/main/.github/CONTRIBUTING.md) file for how to help. At Instagram, we sync the open source version of `IGListKit` daily, so we're always testing the latest changes. But that requires all changes be thoroughly tested and follow our style guide.

We have a set of [starter tasks](https://github.com/Instagram/IGListKit/issues?q=is%3Aissue+is%3Aopen+label%3Astarter-task) that are great for beginners to jump in on and start contributing.

## License

`IGListKit` is [MIT-licensed](./LICENSE.md).

The files in the `/Examples/` directory are licensed under a separate license as specified in each file. Documentation is licensed [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).

## Legal

Copyright © Meta Platforms, Inc &#x2022; <a href="https://opensource.fb.com/legal/terms">Terms of Use</a> &#x2022; <a href="https://opensource.fb.com/legal/privacy">Privacy Policy</a>
