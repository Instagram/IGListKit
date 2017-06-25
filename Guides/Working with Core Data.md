# Working with Core Data

This guide provides details on how to work with [Core Data](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html) and `IGListKit`.

## Background

The main difference in the setup and architecture of a Core Data and `IGListKit` application is the configuration of the model layer. Core Data operates with a mutable model layer, where objects are always passed by reference and the same instance is modified when an object is edited.

`IGListKit` requires an immutable model in order to correctly calculate the diffing between model snapshots and to correctly animate the `UICollectionView`.

In order to satisfy these prerequisites, Core Data `NSManagedObject`s should not be used directly as `ListDiffable` objects. Instead, a view model (or some sort of token object) should be used to mimic (or act as a placeholder for) the data that will be displayed in the collection view.

## Further discussion

There are further discussions on this topic at [#460](https://github.com/Instagram/IGListKit/issues/460), [#461](https://github.com/Instagram/IGListKit/issues/461), [#407](https://github.com/Instagram/IGListKit/issues/407).

## Basic Setup

The basic setup for Core Data and `IGListKit` is the same as the normal setup that is found in the [Getting Started Guide](https://instagram.github.io/IGListKit/getting-started.html). The main difference will be in the setup of the model used in the `IGListAdapterDataSource`.

## Working with view model

### Creating a view model

Suppose the Core Data model consist of:

```swift
extension User {
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var address: String
    @NSManaged var someVariableNotNeededInUI: String
}
```

A `ViewModel` object will contain only the necessary information needed to build UI. The properties of the `ViewModel` will be immutable:

```swift
class UserViewModel: NSObject {
    let firstName: String
    let lastName: String
    let address: String
}
```

We recommend writing a helper method to translate Core Data objects into `ViewModel` objects:

```swift
extension UserViewModel {
    static func fromCoreData(user: User) -> UserViewModel {
        // - Note: For avoiding Core Data threading violation, the following code should be wrapped in a
        // user.managedObjectContext?.performAndWait {}
        return UserViewModel(firstName: user.firstName, lastName: user.lastName, address: user.lastName)
    }
}
```

The `IGListDiffable` protocol is implemented on the `ViewModel` layer:

```swift
extension UserViewModel: ListDiffable {

    public func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: firstName + lastName)
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let toObject = object as? UserViewModel else { return false }

        return self.firstName == toObject.firstName
            && self.lastName == toObject.lastName
            && self.address == toObject.address
    }
}
```

## Setting up the view model in the adapter data source

Steps to configure the `UICollectionView` with the `ViewModel`:

- Retrieve Core Data objects
- Transform Core Data objects into ViewModel objects and return them
- Track changes to Core Data objects and update the datasource with them

### Retrieve Core Data objects

The way objects are retrieved from Core Data is depends on the project. 

Example: Suppose there is a delegate `Provider` class with the role of fetching Core Data objects and checking for updates. It can use an `NSFetchedResultsController` to leverage on the Core Data framework and rely on automatic notifications for updates.

```swift
final class UserProvider: NSObject {

    private lazy var userFetchResultController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = NSFetchRequest(entityName: "User")

        // sort descriptors and predicates 
        // ...
    
        let fetchResultController = NSFetchedResultsController(
           fetchRequest: tripsFetchRequest,
           managedObjectContext: self.coreDataStack.mainQueueManagedObjectContext,
           sectionNameKeyPath: nil,
           cacheName: nil)

        // Set delegate to track CoreData changes
        fetchResultController.delegate = self

        return fetchResultController
    }()

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init()
        do {
            try userFetchResultController.performFetch()
        }
        catch {
            fatalError("Cannot Fetch! \(error)")
        }
    }
}
```

### Transform Core Data objects into view models

```swift
func getUsers() -> [UserViewModel]? {
    guard let users = self.userFetchResultController.fetchedObjects else { return nil }
    // Here we transform and return ViewModel objects!
    return users.flatMap { UserViewModel.fromCoreData(user: $0) }
}
```

### Track changes to Core Data

The `Provider` will track changes to the Core Data model by listening to the `NSFetchedResultsController` methods and inform the application about this changes via KVO, notifications, delegation, etc.

```swift
extension UserProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.performUpdatesForCoreDataChange(animated: true)
    }
}
```

### Configure the datasource

The data source retrieves ViewModels and configures the `IGListSectionController` with them:

```swift
func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return self.userProvider.getUsers()
}
```

### Reacting to Core Data changes in UI

The `UIViewController` containing the `UICollectionView`, will react to the `NSFetchedResultController` messages by updating the UI:

```swift
func performUpdatesForCoreDataChange(animated: Bool) {
    // Updating contents of collection view
    self.adapter.performUpdates(animated: animated)
}
```
