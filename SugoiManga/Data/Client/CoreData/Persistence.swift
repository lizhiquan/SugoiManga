//
//  Persistence.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext

    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      debugPrint("Unresolved error \(nsError), \(nsError.userInfo)")
    }

    return result
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "CoreData")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        debugPrint("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }

  var context: NSManagedObjectContext {
    return container.viewContext
  }

  func save() {
    let context = container.viewContext

    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nsError = error as NSError
        debugPrint("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

