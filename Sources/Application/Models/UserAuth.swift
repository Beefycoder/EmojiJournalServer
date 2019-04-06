//
//  UserAuth.swift
//  Application
//
//  Created by Pat Butler on 2019-03-25.
//

import Foundation
import CredentialsHTTP
import SwiftKueryORM

public struct UserAuth: Model {
    public var id: String
    private let password: String
}

extension UserAuth: TypeSafeHTTPBasic {
    public static let authenticate = ["John": "12345", "Mary": "ABCDE"]
    
    public static func verifyPassword(username: String, password: String, callback: @escaping (UserAuth?) -> Void) {
        // 1
        UserAuth.find(id: username) { (userAuth, error ) in
            // 2
            if let userAuth = userAuth {
                // 3
                if password == userAuth.password {
                    // 4
                    callback(userAuth)
                    return
                }
            }
            // 5
            callback(nil)
        }
    }
}
