//
//  UserRequest.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

class UserRequest: RequestType {
    var headerParams: [String : Any]?
    var method: HTTPMethod = .get
    var path: String = "users"
    var bodyParams: [String : Any]?
    
    init(since userId: Int) {
        self.bodyParams = ["since": userId]
    }
}
