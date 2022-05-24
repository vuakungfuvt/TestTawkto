//
//  String+Extensions.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

extension String {
    func trim() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
}
