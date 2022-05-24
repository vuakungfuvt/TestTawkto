//
//  UserManager.swift
//  TawkUserManager
//
//  Created by tungphan on 15/05/2022.
//

import Foundation

class UserManager {
    private let coreDataService: CoreDataService
    private let entityName: String
    
    static let shared: UserManager = {
        return UserManager(coreDataService: CoreDataService.shared, entityName: "User")
    }()
    
    private init(coreDataService: CoreDataService, entityName: String) {
        self.coreDataService = coreDataService
        self.entityName = entityName
    }
    
    @discardableResult
    func saveUser(_ user: UserModel) -> Bool {
        let predicate = NSPredicate(format: "id = %d", user._id)
        if let saveUser = coreDataService.fetch(entityName: entityName, predicate: predicate, fetchLimit: 1)?.first {
            return coreDataService.update(model: saveUser, dataDict: user.dictionary ?? [:])
        } else {
            return coreDataService.save(entityName: "User", dataDict: user.dictionary ?? [:])
        }
    }
    
    func getUser(userId: Int) -> UserModel? {
        let predicate = NSPredicate(format: "id = %d", userId)
        if let user: User = coreDataService.fetch(entityName: entityName, predicate: predicate, fetchLimit: 1)?.first {
            return UserModel(user: user)
        }
        return nil
    }
    
    func getAllUser() -> [UserModel] {
        let users: [User] = coreDataService.fetch(entityName: entityName) ?? []
        return users.map({ UserModel(user: $0) })
    }
}
