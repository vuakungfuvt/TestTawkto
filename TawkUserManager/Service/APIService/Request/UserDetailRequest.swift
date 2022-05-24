//
//  UserDetail.swift
//  TawkUserManager
//
//  Created by tungphan on 15/05/2022.
//

import Foundation

class UserDetailRequest: RequestType {
    var headerParams: [String : Any]?
    var method: HTTPMethod = .get
    var path: String
    var bodyParams: [String : Any]?
    
    init(userName: String) {
        self.path = "users/\(userName)"
    }
}
