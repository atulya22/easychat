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
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let fullName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentEmail)
        let ref = database.child("\(cleanEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
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
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                ]
                
            ]
            
            let recipientNewconversation: [String: Any] = [
                "id": conversationId,
                "other_user_email": cleanEmail,
                "name": fullName,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                ]
                
            ]
            
            //Update recepient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                
                if var conversations = snapshot.value as? [[String: Any]] {
                    // Append
                    conversations.append(recipientNewconversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)

                } else {
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipientNewconversation])
                }
            })

            
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversations for current user
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
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
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                 })
            }
        })
    }
    
    /// Returns all conversations for a users email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        print(email)
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("Getting All Conversations")

            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                let name = dictionary["name"] as? String,
                let otherUserEmail = dictionary["other_user_email"] as? String,
                let latestMessage = dictionary["latest_message"] as? [String: Any],
                let date = latestMessage["date"] as? String,
                let message = latestMessage["message"] as? String,
                let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                    
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            print("Success Getting All Conversations")

            completion(.success(conversations))
        })
    }
    
    // Fetches all chat messages for a given conversation
    public func getAllMessagesForConversations(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("Getting All Conversations")

            let conversations: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageId = dictionary["id"] as? String,
                    let type = dictionary["type"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                let senderObject = Sender(senderId: senderEmail,
                                          displayName: name,
                                          photoURL: "")
                return Message(sender: senderObject, messageId: messageId, sentDate: date, kind: .text(content))


            })
            print("Success gettiing all chat messages")

            completion(.success(conversations))
        })
    
    }
    
    /// Sends a message to an existing conversation
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        
        //Add new messages
        
        //Update latest message from sender
        
        //Update latest message to recipient
        

        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
                    
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentEmail)
            
            var textMessage = ""

            switch newMessage.kind {
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
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            let messageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": textMessage,
                "date": dateString,
                "sender_email": cleanEmail,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(messageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Unable to set conversations messages:\(error)")

                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(cleanEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        print("Unable to fetch conversations list")
                        completion(false)
                        return
                    }
                    
                    
                    for i in currentUserConversations.indices {
                        
                        if let currentid = currentUserConversations[i]["id"] as? String,
                            currentid == conversation {
                            
                            print("Inside for loop")
                            print(textMessage)
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "message": textMessage,
                                "is_read": false
                            ]
                            
                            currentUserConversations[i]["latest_message"] = updateValue
                            
                        }
                    }

                    
                    strongSelf.database.child("\(cleanEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Error Sending Conversation")
                            completion(false)
                            return
                        }
                        
                        
                        /// Update latest message for recipient
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                print("Unable to fetch conversations list")
                                completion(false)
                                return
                            }
                            
                            
                            for i in otherUserConversations.indices {
                                
                                if let currentid = otherUserConversations[i]["id"] as? String,
                                    currentid == conversation {
                                    
                                    print("Inside for loop")
                                    print(textMessage)
                                    let updateValue: [String: Any] = [
                                        "date": dateString,
                                        "message": textMessage,
                                        "is_read": false
                                    ]
                                    
                                    otherUserConversations[i]["latest_message"] = updateValue
                                    
                                }
                            }

                            
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    print("Error Sending Conversation")
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message,  completion: @escaping (Bool) -> Void) {
        
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
            "is_read": false,
            "name": name,
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

extension DatabaseManager {
    public func getData(for path: String, completion:@escaping (Result <Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                print("getData failed to fetch")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
}
