//
//  TawkUserManagerTests.swift
//  TawkUserManagerTests
//
//  Created by tungphan on 14/05/2022.
//

import XCTest
@testable import TawkUserManager

class TawkUserManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let coreDataService = CoreDataService.shared
        coreDataService.setup(managedContext: (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext)
        coreDataService.deleteAll(entityName: "User")
        
        //test create logic
        var mockUser = UserModel(_id: 001, avatarUrl: "", login: "abc", htmlUrl: "")
        let userManager = UserManager(coreDataService: coreDataService, entityName: "User")
        
        userManager.saveUser(mockUser)
        
        let savedUser = userManager.getUser(userId: mockUser._id)
        XCTAssertEqual(savedUser?._id, mockUser._id)
        XCTAssertEqual(savedUser?.login, mockUser.login)
        
        //test update logic
        mockUser.login = "abcdddd"
        userManager.saveUser(mockUser)
        
        let newSavedUser = userManager.getUser(userId: mockUser._id)
        XCTAssertEqual(newSavedUser?.login, "abcdddd")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
