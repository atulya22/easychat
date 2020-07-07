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
    
    static func cleanEmail(emailAddress: String) -> String {
        let email = emailAddress.replacingOccurrences(of: ".", with: ",")
        return email
    }
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
    public func insertUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.cleanEmail).setValue([
            "first_name": user.firstName,
            "last_name" : user.lastName
        ], withCompletionBlock: {error, _ in
            guard error == nil else {
                print("Database write failed")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append to user diction
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.cleanEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                        
                    })
                    
                } else {
                    let newCollection:  [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.cleanEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
            })
            completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
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
    
    var profilePictureFileName: String {
        return "\(cleanEmail)_profile_picture.png"
    }
}

// MARK: - Message Sending

extension DatabaseManager {
    
    /// Start new conversation with target user email and the initial message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentEmail)
        let ref = database.child("\(cleanEmail)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "otherUserEmail": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                ]
                
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversations for current user
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
                
            } else {
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId,
                        firstMessage: firstMessage,
                        completion: completion)
                 })
            }
        })
    }
    
    /// Returns all conversations for a users email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
    }
    
    // Fetches all conversation for a given conversation
    public func getAllMessagsForConversations(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
    
    }
    
    /// Sends a message to an existing conversation
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentEmail)

        
        var textMessage = ""

        switch firstMessage.kind {
        case .text(let messageText):
            textMessage = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": textMessage,
            "date": dateString,
            "sender_email": cleanEmail,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messages": [
               message
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
            
        })
        
    }
}
