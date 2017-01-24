<p align="center">
  <img src="https://raw.githubusercontent.com/Instagram/IGListKit/master/Resources/logo-animation.gif" width=400 />
</p>

<p align="center">
    <a href="https://travis-ci.org/Instagram/IGListKit">
        <img src="https://travis-ci.org/Instagram/IGListKit.svg?branch=master&style=flat"
             alt="Build Status">
    </a>
    <a href="https://coveralls.io/github/Instagram/IGListKit?branch=master">
      <img src="https://coveralls.io/repos/github/Instagram/IGListKit/badge.svg?branch=master"
           alt="Coverage Status" />
    </a>
    <a href="https://cocoapods.org/pods/IGListKit">
        <img src="https://img.shields.io/cocoapods/v/IGListKit.svg?style=flat"
             alt="Pods Version">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat"
             alt="Carthage Compatible">
    </a>
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

`IGListKit` is built and maintained with &#10084;&#65039; by [Instagram engineering](https://engineering.instagram.com/), using the open source version for the Instagram app.

## Requirements

- Xcode 8.0+
- iOS 8.0+
- tvOS 9.0+
- Interoperability with Swift 3.0+

## Installation

### CocoaPods

The preferred installation method for `IGListKit` is with [CocoaPods](https://cocoapods.org). Simply add the following to your `Podfile`:

```ruby
# Latest release of IGListKit
pod 'IGListKit'

# Use the master branch (we use this at Instagram)
pod 'IGListKit', :git => 'https://github.com/Instagram/IGListKit.git', :branch => 'master'
```

### Carthage

To integrate `IGListKit` into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "Instagram/IGListKit" ~> 2.0.0
```

### Manually

You can also manually install the framework by dragging and dropping the `IGListKit.xcodeproj` into your project or workspace.

## Getting Started

See the [Getting Started guide here](https://instagram.github.io/IGListKit/getting-started.html).

## Documentation

You can find [the docs here](https://instagram.github.io/IGListKit). Documentation is generated with [jazzy](https://github.com/realm/jazzy) and hosted on [GitHub-Pages](https://pages.github.com).

## Contributing

Please see the [CONTRIBUTING](https://github.com/Instagram/IGListKit/blob/master/.github/CONTRIBUTING.md) file for how to help out. At Instagram we sync the open source version of `IGListKit` almost daily, so we're always testing the latest changes. But that requires all changes be thoroughly tested follow our style guide.

## License

`IGListKit` is BSD-licensed. We also provide an additional patent grant.

The files in the /Example directory are licensed under a separate license as specified in each file; documentation is licensed [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
