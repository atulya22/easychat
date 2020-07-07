//
//  ChatViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/5/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}

extension MessageKind {
    var messageKindString: String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attribited_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
    
}

struct Sender: SenderType {
    public var senderId: String
    public var displayName: String
    public var photoURL: String
}


class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    public var isNewConversation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
            
        }
        return Sender(senderId: email,
        displayName: "Jum",
        photoURL: "")
         
    }

    init(with email:String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue


        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController:MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, np cached email")
        return Sender(senderId: "",
                      displayName: "12",
                      photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
            return
        }
        
        print("Sending message: \(text)")
        if isNewConversation {
            //Create Conversation in database
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: {[weak self] success in
                if success {
                    print("Message sent successfully")
                } else {
                    print("Failed to send message")
                }
            })
        } else {
            // Append to existing conversation
        }
    }
    
    func createMessageId() -> String? {
        // date, otherUserEmail, SenderEmail
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentEmail)

        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(cleanEmail)_\(dateString)"
        print("Unique message indentifier:\(newIdentifier)")
        
        return newIdentifier
    }
}
