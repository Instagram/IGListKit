# Best Practices and FAQs

This guide provides notes and details on best practices in using `IGListKit`, general tips, and answers to FAQs.

## Best Practices

- We recommend adding an assert to check [`-isKindOfClass:`](https://developer.apple.com/reference/objectivec/1418956-nsobject/1418511-iskindofclass) on the object you receive in [`-didUpdateToObject:`](https://instagram.github.io/IGListKit/Protocols/IGListSectionType.html#/c:objc(pl)IGListSectionType(im)didUpdateToObject:) in your section controllers. 
This makes it easy to track down easily-overlooked mistakes in your [`IGListAdapaterDataSource`](https://instagram.github.io/IGListKit/Protocols/IGListAdapterDataSource.html#/c:objc(pl)IGListAdapterDataSource(im)listAdapter:sectionControllerForObject:) implementation. 
If this assert is ever hit, that means `IGListKit` has sent your section controller the incorrect type of object. 
This would only happen if your objects provide *non-unique* diff identifiers. 

- Make sure your [`-diffIdentifier`](https://instagram.github.io/IGListKit/Protocols/IGListDiffable.html#/c:objc(pl)IGListDiffable(im)diffIdentifier) implementation returns a **unique identifier** for each object.
