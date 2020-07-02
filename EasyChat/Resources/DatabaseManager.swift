//
//  DatabaseManager.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/1/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

// MARK: Account Management
extension DatabaseManager {
        
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        let email = email.replacingOccurrences(of: ".", with: ",")
        
        database.child(email).observeSingleEvent(of: .value, with:{snapshot in
            completion(snapshot.exists())
        })
    }
    /// Insert user to database
    public func insertUser(with user: AppUser) {
        database.child(user.cleanEmail).setValue([
            "first_name": user.firstName,
            "last_name" : user.lastName
        ])
    }
}

struct AppUser {
    let firstName : String
    let lastName : String
    let emailAddress: String
    
    var cleanEmail : String {
        let email = emailAddress.replacingOccurrences(of: ".", with: ",")
        return email
    }
}
