# Advanced Installation

This guide provides details on alternative methods of installing `IGListKit`

### CocoaPods

The preferred method of installation for `IGListKit` is using [CocoaPods](https://cocoapods.org/).

In order to use the latest release version of the framework you should add the following to your `Podfile`:

```ruby
pod 'IGListKit', '~> 2.0.0'
```

Alternatively you can use the latest version from the [master branch](https://github.com/Instagram/IGListKit/tree/master). We use this at Instagram, as we are always testing the latest changes!

```ruby
pod 'IGListKit', :git => 'https://github.com/Instagram/IGListKit.git', :branch => 'master'
```

With the exception of macOS (which currently only supports the diffing algorithm components), using `pod 'IGListKit'` will get you the full package including our flexible UICollectionView system. Learn more about how to get started in our [Getting Started guide](https://instagram.github.io/IGListKit/getting-started.html)!

If, however, you only want to use the diffing component of this framework then you're able to use our Subspec. Simply change the pod name from `IGListKit` to `IGListKit/Diffing` as such:

```ruby
pod 'IGListKit/Diffing', '~> 2.0.0'
```

Regardless of whether you only use the diffing components, or the entire package, you will need to import the framework into any source file which uses this framework. An example of this:

```swift
import IGListKit
```

### Carthage

If using [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "Instagram/IGListKit" ~> 2.0.0
```

### Manual Installation

You can also manually install the framework by dragging and dropping the `IGListKit.xcodeproj` into your project or workspace.
