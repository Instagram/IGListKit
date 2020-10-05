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
    <a href="https://instagram.github.io/IGListKit/">
        <img src="https://img.shields.io/cocoapods/p/IGListKit.svg?style=flat"
             alt="Platforms">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat"
             alt="Carthage Compatible">
    </a>
</p>

----------------

一个数据驱动的“UICollectionView”框架，用于构建快速灵活的列表。

|         | 主要特性  |
----------|-----------------
&#128581; | 不要直接调用 `performBatchUpdates(_:, completion:)` 或 `reloadData()`
&#127968; | 更好的可复用cell和组件体系结构
&#128288; | 创建具有多个数据类型的集合
&#128273; | 解耦扩散算法
&#9989;   | 全单元测试
&#128269; | 自定义差异行为模型的
&#128241; | 简化 `UICollectionView`核心
&#128640; | 可扩展API
&#128038; | Objective-C编写,同时完全支持Swift

`IGListKit`由[Instagram 工程师](https://engineering.instagram.com/) 创建 并且&#10084;&#65039; 维护.
我们在Instagram中使用开源的`master`主版本.
## 多语言翻译

[英文README](README.md)

## 要求

- Xcode 9.0+
- iOS 8.0+
- tvOS 9.0+
- macOS 10.11+ *(diffing algorithm components only)*
- Interoperability with Swift 3.0+

## 安装

### CocoaPods

[CocoaPods](https://cocoapods.org)优选安装方法. 添加如下到 `Podfile`文件中:

```ruby
pod 'IGListKit', '~> 3.0'
```

### Carthage

针对[Carthage](https://github.com/Carthage/Carthage), 添加如下到 `Cartfile`文件中:

```ogdl
github "Instagram/IGListKit" ~> 3.0
```

> 对于高级用法, 查阅 [安装指南](https://instagram.github.io/IGListKit/installation.html).

## 入门指南

```bash
$ git clone https://github.com/Instagram/IGListKit.git
$ cd IGListKit/
$ ./scripts/setup.sh
```

- [入门指南](https://instagram.github.io/IGListKit/getting-started.html)
- Ray Wenderlich's [IGListKit Tutorial: Better UICollectionViews](https://www.raywenderlich.com/147162/iglistkit-tutorial-better-uicollectionviews)
- [样例项目](https://github.com/Instagram/IGListKit/tree/master/Examples)
- Ryan Nystrom's [talk at try! Swift NYC](https://realm.io/news/tryswift-ryan-nystrom-refactoring-at-scale-lessons-learned-rewriting-instagram-feed/) (Note: this talk was for an earlier version. Some APIs have changed.)
- [Migrating an UITableView to IGListCollectionView](https://medium.com/cocoaacademymag/iglistkit-migrating-an-uitableview-to-iglistkitcollectionview-65a30cf9bac9), by Rodrigo Cavalcante
- [Keeping data fresh in Buffer for iOS with AsyncDisplayKit, IGListKit & Pusher](https://overflow.buffer.com/2017/04/10/keeping-data-fresh-buffer-ios-asyncdisplaykit-iglistkit-pusher/), Andy Yates, Buffer

## 文档

[这里可以查阅文档](https://instagram.github.io/IGListKit). 文档由[jazzy](https://github.com/realm/jazzy)生成, 托管在 [GitHub-Pages](https://pages.github.com).

运行位于数据仓root目录 `./scripts/build_docs.sh`生成文档.

## 远景

For the long-term goals and "vision" of `IGListKit`, please read our [Vision](https://github.com/Instagram/IGListKit/blob/master/Guides/VISION.md) doc.

## 贡献

Please see the [CONTRIBUTING](https://github.com/Instagram/IGListKit/blob/master/.github/CONTRIBUTING.md) file for how to help. At Instagram, we sync the open source version of `IGListKit` daily, so we're always testing the latest changes. But that requires all changes be thoroughly tested and follow our style guide.

We have a set of [starter tasks](https://github.com/Instagram/IGListKit/issues?q=is%3Aissue+is%3Aopen+label%3Astarter-task) that are great for beginners to jump in on and start contributing.

## License

`IGListKit` is [MIT-licensed](./LICENSE).

The files in the `/Examples/` directory are licensed under a separate license as specified in each file. Documentation is licensed [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
