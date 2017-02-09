# Best Practices and FAQs

This guide provides notes and details on best practices in using `IGListKit`, general tips, and answers to FAQs.

## Best Practices

- We recommend adding an assert to check [`-isKindOfClass:`](https://developer.apple.com/reference/objectivec/1418956-nsobject/1418511-iskindofclass) on the object you receive in [`-didUpdateToObject:`](https://instagram.github.io/IGListKit/Protocols/IGListSectionType.html#/c:objc(pl)IGListSectionType(im)didUpdateToObject:) in your section controllers. 
This makes it easy to track down easily-overlooked mistakes in your [`IGListAdapaterDataSource`](https://instagram.github.io/IGListKit/Protocols/IGListAdapterDataSource.html#/c:objc(pl)IGListAdapterDataSource(im)listAdapter:sectionControllerForObject:) implementation. 
If this assert is ever hit, that means `IGListKit` has sent your section controller the incorrect type of object. 
This would only happen if your objects provide *non-unique* diff identifiers. 

- Make sure your [`-diffIdentifier`](https://instagram.github.io/IGListKit/Protocols/IGListDiffable.html#/c:objc(pl)IGListDiffable(im)diffIdentifier) implementation returns a **unique identifier** for each object.

## Frequently asked questions

**Q: How do you implement separators between cells?**

**A:** See discussion in [#329](https://github.com/Instagram/IGListKit/issues/329)

**Q: How do I fix the error `Could not build Objective-C module 'IGListKit'`?**

**A:** See discussion in [#316](https://github.com/Instagram/IGListKit/issues/316)

**Q: The documentation and examples have `<X>` feature or changes, but I don't have it in my version. Why?**

**A:** This feature is on the `master` branch only and hasn't been officially tagged and [released](https://github.com/Instagram/IGListKit/releases). If you need to, you can [install from the `master` branch](https://instagram.github.io/IGListKit/installation.html).
