# Best Practices and FAQs

This guide provides notes and details on best practices in using `IGListKit`, general tips, and answers to FAQs.

## Best Practices

- We recommend adding an assert to check [`-isKindOfClass:`](https://developer.apple.com/reference/objectivec/1418956-nsobject/1418511-iskindofclass) on the object you receive in [`-didUpdateToObject:`](https://instagram.github.io/IGListKit/Protocols/IGListSectionType.html#/c:objc(pl)IGListSectionType(im)didUpdateToObject:) in your section controllers. 
This makes it easy to track down easily-overlooked mistakes in your [`IGListAdapaterDataSource`](https://instagram.github.io/IGListKit/Protocols/IGListAdapterDataSource.html#/c:objc(pl)IGListAdapterDataSource(im)listAdapter:sectionControllerForObject:) implementation. 
If this assert is ever hit, that means `IGListKit` has sent your section controller the incorrect type of object. 
This would only happen if your objects provide *non-unique* diff identifiers. 

```objective-c
- (void)didUpdateToObject:(id)object {
    NSParameterAssert([object isKindOfClass:[MyModelClass class]]);
    _myModel = object;
}
```

- Make sure your [`-diffIdentifier`](https://instagram.github.io/IGListKit/Protocols/IGListDiffable.html#/c:objc(pl)IGListDiffable(im)diffIdentifier) implementation returns a **unique identifier** for each object.

- We highly recommend using single-item sections when possible. That is, each section controller manages a single model (which may have one or multiple cells). This gives you the greatest amount of flexibility, modularity, and re-use for your components.

## Frequently asked questions

**How do you implement separators between cells?**

See discussion in [#329](https://github.com/Instagram/IGListKit/issues/329)

**How do I fix the error `Could not build Objective-C module 'IGListKit'`?**

See discussion in [#316](https://github.com/Instagram/IGListKit/issues/316)

**The documentation and examples have `<X>` feature or changes, but I don't have it in my version. Why?**

This feature is on the `master` branch only and hasn't been officially tagged and [released](https://github.com/Instagram/IGListKit/releases). If you need to, you can [install from the `master` branch](https://instagram.github.io/IGListKit/installation.html).

**Does `IGListKit` work with...?**

- Core Data ([#460](https://github.com/Instagram/IGListKit/issues/460), [#461](https://github.com/Instagram/IGListKit/issues/461))
- AsyncDisplayKit ([AsyncDisplayKit/#2942](https://github.com/facebook/AsyncDisplayKit/pull/2942))
- ComponentKit ([ocrickard/IGListKit-ComponentKit](https://github.com/ocrickard/IGListKit-ComponentKit))
- React Native
- Reactive Cocoa
- RxSwift

Yes.

**Does `IGListKit` work with `UITableView`?**

No, but you can install the [diffing subspec via CocoaPods](https://instagram.github.io/IGListKit/installation.html).

**What's the purpose of `IGListCollectionView`?**

We use this subclass to gain compile-time safety to prevent disallowed methods from being called on `UICollectionView`, because `IGListKit` handles model and view updates. See discussion at [#409](https://github.com/Instagram/IGListKit/issues/409).

**How can I manage cell selection and deselection?**

See discussion at [#184](https://github.com/Instagram/IGListKit/issues/184).
