# Best Practices and FAQs

This guide provides notes and details on best practices in using `IGListKit`, general tips, and answers to FAQs.

## Best Practices

- We recommend adding an assert to check [`-isKindOfClass:`](https://developer.apple.com/reference/objectivec/1418956-nsobject/1418511-iskindofclass) on the object you receive in [`-didUpdateToObject:`](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L63-L72) in your section controllers. 
This makes it easy to track down easily-overlooked mistakes in your [`IGListAdapaterDataSource`](https://instagram.github.io/IGListKit/Protocols/IGListAdapterDataSource.html#/c:objc(pl)IGListAdapterDataSource(im)listAdapter:sectionControllerForObject:) implementation. 
If this assert is ever hit, that means `IGListKit` has sent your section controller the incorrect type of object. 
This would only happen if your objects provide *non-unique* diff identifiers. 

```objective-c
// Objective-C
- (void)didUpdateToObject:(id)object {
    NSParameterAssert([object isKindOfClass:[MyModelClass class]]);
    _myModel = object;
}
```

```swift
// Swift
func didUpdate(to object: Any) {
    precondition(object is MyModelClass)
    myModel = object as! MyModelClass
}
```

- Make sure your [`-diffIdentifier`](https://instagram.github.io/IGListKit/Protocols/IGListDiffable.html#/c:objc(pl)IGListDiffable(im)diffIdentifier) implementation returns a **unique identifier** for each object.

- We highly recommend using single-item sections when possible. That is, each section controller manages a single model (which may have one or multiple cells). This gives you the greatest amount of flexibility, modularity, and re-use for your components.

## Frequently asked questions

#### I upgraded IGListKit and now everything is broken!

Check out our [migration guide](https://github.com/Instagram/IGListKit/blob/master/Guides/Migration.md) to make upgrading easier.

#### How do you implement separators between cells?

See discussion in [#329](https://github.com/Instagram/IGListKit/issues/329)

#### How do I fix the error `Could not build Objective-C module 'IGListKit'`?

See discussion in [#316](https://github.com/Instagram/IGListKit/issues/316)

#### The documentation and examples have `<X>` feature or changes, but I don't have it in my version. Why?

This feature is on the `master` branch only and hasn't been officially tagged and [released](https://github.com/Instagram/IGListKit/releases). If you need to, you can [install from the `master` branch](https://instagram.github.io/IGListKit/installation.html).

#### Does `IGListKit` work with...?

- Core Data ([Working with Core Data](https://instagram.github.io/IGListKit/working-with-core-data.html) Guide)
- AsyncDisplayKit ([AsyncDisplayKit/#2942](https://github.com/facebook/AsyncDisplayKit/pull/2942))
- ComponentKit ([ocrickard/IGListKit-ComponentKit](https://github.com/ocrickard/IGListKit-ComponentKit))
- RxSwift ([yuzushioh/RxIGListKit](https://github.com/yuzushioh/RxIGListKit))
- React Native
- Reactive Cocoa

Yes.

#### Does `IGListKit` work with `UITableView`?

No, but you can install the [diffing subspec via CocoaPods](https://instagram.github.io/IGListKit/installation.html).

#### What's the purpose of `IGListCollectionView`?

Historically, we used this subclass to gain compile-time safety to prevent disallowed methods from being called on `UICollectionView`, because `IGListKit` handles model and view updates. However, it has since been removed. See discussion at [#409](https://github.com/Instagram/IGListKit/issues/409).

#### How can I manage cell selection and deselection?

See discussion at [#184](https://github.com/Instagram/IGListKit/issues/184).

#### I have a *huge* data set and [`-performUpdatesAnimated: completion:`](https://instagram.github.io/IGListKit/Classes/IGListAdapter.html#/c:objc(cs)IGListAdapter(im)performUpdatesAnimated:completion:) is *super* slow. What do I do?

If you have multiple thousands of items and you cannot batch them in, you'll see performance issues with `-performUpdatesAnimated: completion:`. The real bottle neck behind the scenes here is `UICollectionView` attempting to insert so many cells at once. Instead, call [`-reloadDataWithCompletion:`](https://instagram.github.io/IGListKit/Classes/IGListAdapter.html#/c:objc(cs)IGListAdapter(im)reloadDataWithCompletion:) when you first load data. Behind the scenes, this method *does not* do any diffing and simply calls `-reloadData` on `UICollectionView`. For subsequent updates, you can then use `-performUpdatesAnimated: completion:`.

#### How do I use IGListKit and estimated cell sizes with Auto Layout?

This should work in theory, and we have an [example section controller](https://github.com/Instagram/IGListKit/blob/master/Examples/Examples-iOS/IGListKitExamples/SectionControllers/SelfSizingSectionController.swift), but the estimated-size API in `UICollectionViewFlowLayout` has changed dramatically over different iOS versions, making first-class support in IGListKit difficult. We don't use estimated cell sizes or Auto Layout in Instagram and cannot commit to fully supporting it.

See [#516](https://github.com/Instagram/IGListKit/issues/516) for a master list of all known issues. We very much welcome contribution to fixing this!

#### Is creating a "wrapper" model just for IGListKit ok?

Yes! We create models that act as a grab-bag for other models, specifically for use in section controllers. Things like:

```swift
class WeatherSectionModel {
  let location: Location
  let forecast: Forecast
  let conditions: Conditions
}
```

Just don't forget to make your models diffable using the data in the contained models:

```swift
extension WeatherSectionModel: ListDiffable {
  func diffIdentifier() -> NSObjectProtocol {
    return location.identifier
  }

  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? WeatherSectionModel else { return false }
    return location == object.location && forecast == object.forecast && conditions == object.conditions
  }
}
```

#### What if I want to make my Swift structs diffable?

Give [this box](https://github.com/Instagram/IGListKit/issues/35#issuecomment-277503724) a try.

#### I want to deliver messages to certain section controllers, how do I do that?

We recommend using dependency injection and announcing changes, demonstrated in [our example](https://github.com/Instagram/IGListKit/blob/master/Examples/Examples-iOS/IGListKitExamples/ViewControllers/AnnouncingDepsViewController.swift).

#### Should I reuse my section controllers between models?

No! `IGListKit` is designed to have a 1:1 instance mapping between objects and section controllers. `IGListKit` does not reuse section controllers, and if you do unintended behaviors will occur.

`IGListKit` _does_ still use `UICollectionView`'s cell reuse, so you shouldn't be concerned about performance.

#### Why does `UICollectionViewFlowLayout` put everything in a new row?

`UICollectionViewFlowLayout` has its limitations, and it's not well designed to support sections on the same "line". Instead you should use [`IGListCollectionViewLayout`](https://github.com/Instagram/IGListKit/blob/master/Source/IGListCollectionViewLayout.h).

#### What if I just want a section controller and don't need the object?

Feel free to use a static string or number as your model. You can use this object as a "key" to find your section controller. Take a look at our [example](https://github.com/Instagram/IGListKit/blob/master/Examples/Examples-iOS/IGListKitExamples/ViewControllers/SearchViewController.swift#L34) of this.

#### How do I make my cells diff and animate?

Use [`IGListBindingSectionController`](https://github.com/Instagram/IGListKit/blob/master/Source/IGListBindingSectionController.h) to automatically diff and animate your cells.

#### How can I power and update the number of items in a section controller with a dynamic array?

We recommend creating a model that owns an array to the items that power `numberOfItems`. Checkout our [Post example](https://github.com/Instagram/IGListKit/blob/master/Examples/Examples-iOS/IGListKitExamples/SectionControllers/PostSectionController.m#L32) that has dynamic comment cells. Just be sure to check when your array changes:

```swift
class Forecast: ListDiffable {
  let day: Date
  let hourly: [HourlyForecast]

  func diffIdentifier() -> NSObjectProtocol {
    return day
  }

  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? Forecast else { return false }
    return hourly == object.hourly // compare elements in the arrays
  }
}
```
