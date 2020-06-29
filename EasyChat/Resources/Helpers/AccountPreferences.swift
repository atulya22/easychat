//
//  AccountPreferences.swift
//  EasyChat
//
//  Created by Atulya Shetty on 6/26/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import Foundation


class AccountPreferences {
    
    static let shared = AccountPreferences()
    
    private let isLoggedInKey = "isLoggedIn"
   
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: isLoggedInKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey:isLoggedInKey)
        }
    }
}
