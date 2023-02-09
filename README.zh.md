<p align="center">
  <img src="https://raw.githubusercontent.com/Instagram/IGListKit/main/Resources/logo-animation.gif" width=400 />
</p>

<p align="center">
    <a href="https://github.com/Instagram/IGListKit/actions/workflows/CI.yml">
        <img src="https://img.shields.io/github/actions/workflow/status/Instagram/IGListKit/CI.yml"
             alt="Build Status">
    </a>
    <a href="https://coveralls.io/github/Instagram/IGListKit?branch=main">
      <img src="https://coveralls.io/repos/github/Instagram/IGListKit/badge.svg?branch=main"
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

一个数据驱动的`UICollectionView`框架，用于构建快速灵活的列表。

|         | 主要特性  |
----------|-----------------
&#128581; | 无须直接调用 `performBatchUpdates(_:, completion:)` 或 `reloadData()`
&#127968; | 更好的可复用 cell 和组件体系结构
&#128288; | 创建具有多个数据类型的列表
&#128273; | 解耦的 Diff 算法
&#9989;   | 完全的单元测试
&#128269; | 可自定义数据模型的 Diff 行为
&#128241; | 简化并维持`UICollectionView`的核心特性
&#128640; | 可扩展的 API 设计
&#128038; | Objective-C 编写,同时完全支持 Swift

`IGListKit`由 [Instagram 工程师](https://engineering.instagram.com/) 创建 并且&#10084;&#65039; 维护。
我们在 Instagram 中使用开源的`main`主版本。
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

推荐使用[CocoaPods](https://cocoapods.org)来进行安装，只需添加如下语句到你的`Podfile`文件中:

```ruby
pod 'IGListKit', '~> 4.0.0'
```

### Carthage

对于[Carthage](https://github.com/Carthage/Carthage), 添加如下到`Cartfile`文件中:

```ogdl
github "Instagram/IGListKit" ~> 3.0
```

> 对于高级用法, 查阅 [安装指南](https://instagram.github.io/IGListKit/installation.html)。

## 入门指南

```bash
$ git clone https://github.com/Instagram/IGListKit.git
$ cd IGListKit/
$ ./scripts/setup.sh
```

- [入门指南](https://instagram.github.io/IGListKit/getting-started.html)
- Ray Wenderlich's [IGListKit Tutorial: Better UICollectionViews](https://www.raywenderlich.com/147162/iglistkit-tutorial-better-uicollectionviews)
- [样例项目](https://github.com/Instagram/IGListKit/tree/main/Examples)
- Ryan Nystrom's [talk at try! Swift NYC](https://realm.io/news/tryswift-ryan-nystrom-refactoring-at-scale-lessons-learned-rewriting-instagram-feed/) (Note: this talk was for an earlier version. Some APIs have changed.)
- [Migrating an UITableView to IGListCollectionView](https://medium.com/cocoaacademymag/iglistkit-migrating-an-uitableview-to-iglistkitcollectionview-65a30cf9bac9), by Rodrigo Cavalcante
- [Keeping data fresh in Buffer for iOS with AsyncDisplayKit, IGListKit & Pusher](https://overflow.buffer.com/2017/04/10/keeping-data-fresh-buffer-ios-asyncdisplaykit-iglistkit-pusher/), Andy Yates, Buffer

## 文档

[这里可以查阅文档](https://instagram.github.io/IGListKit)。文档由[jazzy](https://github.com/realm/jazzy)生成，托管在 [GitHub-Pages](https://pages.github.com)。

运行位于仓库根目录下的`./scripts/build_docs.sh`脚本来生成文档。

## 远景

想要了解`IGListKit`的长期目标和愿景，请阅读[Vision](https://github.com/Instagram/IGListKit/blob/main/Guides/VISION.md)。

## 贡献

请查看[CONTRIBUTING](https://github.com/Instagram/IGListKit/blob/main/.github/CONTRIBUTING.md)来了解如何参与贡献。在 Instagram，我们每日都会同步开源版本的`IGListKit`，因此我们总是在测试最新的改动。但是这也需要所有的改动都需要经历完全的测试，并且遵守我们的开发风格。

我们有一系列[新人任务](https://github.com/Instagram/IGListKit/issues?q=is%3Aissue+is%3Aopen+label%3Astarter-task)，来帮助新人学习如何参入其中。

## License

`IGListKit` 遵循[MIT-licensed](./LICENSE)。

`/Examples/`目录下的文件，在文档里指明了它们各自所遵循的协议。文档遵循[CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/)。
