# Working with Core Data

This guide provides details on what additional setup is required to work with Core Data and `IGListKit`.

## Background

The main difference in the setup and architecture of a Core Data + `IGListKit` application, is the configuration of the model layer.
Core Data is a mutable model layer, where your objects are always passed by reference and the same instance is modified when you edit your object.

`IGListKit` needs a immutable model in order to correctly calculate the diffing between models snapshots and to correctly animate the `UICollectionView`

In order to satisfy this prerequisites, Core Data `NSManagedObject`s should not be used directly as `IGListDiffable` objects. Instead a ViewModel should be used to mimic the data that will be displayed in UI.

## Basic Setup

The basic setup for Core Data and `IGListKit` is the same as the normal setup that is found in the [Getting Started Guide][https://instagram.github.io/IGListKit/getting-started.html].

The main difference will be in the setup of the model in the datasource.

## Working with the ViewModel

### Creating a ViewModel

Let's suppose the Core Data model consist of:

```swift
extension User {
  \@NSManaged var firstName: String
  \@NSManaged var lastName: String
  \@NSManaged var address: String
  \@NSManaged var someVariableNotNeededInUI: String
}
```

ViewModel objects will mimic the necessary information needed in UI. The variables of the ViewModel will be constants (immutable) 

```swift
class UserViewModel: NSObject {
  let firstName: String
  let lastName: String
  let address: String
}
```

a helper method can be used to translate Core Data objects into ViewModel objects.

```swift
extension UserViewModel {
  static func fromCoreData(user: User) -> UserViewModel {
    // - Note: For avoiding Core Data threading violation, the following code should be wrapped in a
    // user.managedObjectContext?.performAndWait {}
    return UserViewModel(firstName: user.firstName, lastName: user.lastName, address: user.lastName)
  }
}
```

the `IGListDiffable` protocol is implemented on the ViewModel

```swift
extension UserViewModel: IGListDiffable {

  public func diffIdentifier() -> NSObjectProtocol {
    return NSString(string: firstName + lastName)
  }

  public func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
    guard let toObject = object as? UserViewModel else { return false }

    return self.firstName == toObject.firstName &&
    self.lastName == toObject.lastName &&
    self.address == toObject.address
  }

}
```

## Setting up the ViewModel in the Adapter DataSource

Steps to configure the UICollectionView with the ViewModel:

- retrieve Core Data objects
- transform and return Core Data objects into ViewModel objects
- track changes to Core Data objects and update the datasource with them

### Retrieve Core Data objects

The way objects are retrieved from Core Data is project dependent. 

Example: a delegate `Provider` class with the role of fetching Core Data objects and checking for updates. It can use a `NSFetchedResultsController` to leverage on the Core Data framework and rely on automatic notifications for updates.

```swift
class UserProvider: NSObject {

  private lazy var userFetchResultController: NSFetchedResultsController<User> = {
    let fetchRequest: NSFetchRequest<User> = NSFetchRequest(entityName: "User")

    // sort descriptors and predicates 
    // ...
    
    let fetchResultController = NSFetchedResultsController(
      fetchRequest: tripsFetchRequest,
      managedObjectContext: self.coreDataStack.mainQueueManagedObjectContext,
      sectionNameKeyPath: nil,
      cacheName: nil)

    // Set delegation to track CoreData changes
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

```

### Transform Core Data objects into ViewModel objects

```swift
func getUsers() -> [UserViewModel]? {
    guard let users = self.userFetchResultController.fetchedObjects else { return nil }
    // Here we transform and return ViewModel objects!
    return users.flatMap { UserViewModel.fromCoreData(user: $0) }
  }
```

### Track changes to Core Data

the Provider will track changes to the CoreData model by listening to the `NSFetchedResultsController` methods and inform the application about this changes (with KVO, Notifications, Delegation..)

```swift
extension UserProvider: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.delegate?.performUpdatesForCoreDataChange(animated: true)
  }
}
```

### Configure the datasource

The data source retrieves ViewModel objects and setups `IGListSectionController`s with them.

```swift
func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
    return self.tripProvider.getUsers()
}
```

### React to CoreData changes in UI

The `UIViewController` containing the `UICollectionView`, will react to the `NSFetchedResultController` messages by updating the UI

```swift
func performUpdatesForCoreDataChange(animated: Bool) {
      // Updating contents of collection view
      self.adapter.performUpdates(animated: animated)
}
```
