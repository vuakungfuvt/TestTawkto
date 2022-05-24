//
//  CoreDataService.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    private init() {}
    
    private var managedContext: NSManagedObjectContext?
    private let lock = NSLock()
    
    func setup(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func fetch<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        fetchLimit: Int? = nil
    ) -> [T]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = predicate
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        return try? managedContext?.fetch(fetchRequest) as? [T]
    }
    
    @discardableResult
    func save(entityName: String, dataDict: [String: Any]) -> Bool {
        guard let managedContext = managedContext,
              let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
                  return false
              }
        let model = NSManagedObject(entity: entity, insertInto: managedContext)
        for data in dataDict {
            model.setValue(data.value, forKey: data.key)
        }
        lock.lock()
        do {
            try managedContext.save()
            lock.unlock()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            lock.unlock()
            return false
        }
    }
    
    @discardableResult
    func update(model: NSManagedObject, dataDict: [String: Any]) -> Bool {
        guard let managedContext = managedContext else {
            return false
        }
        for data in dataDict {
            model.setValue(data.value, forKey: data.key)
        }
        lock.lock()
        do {
            try managedContext.save()
            lock.unlock()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            lock.unlock()
            return false
        }
    }
    
    func deleteAll(entityName: String) {
        guard let managedContext = managedContext else {
            return
        }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        lock.lock()
        do {
            try managedContext.execute(deleteRequest)
            lock.unlock()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            lock.unlock()
        }
    }
}
