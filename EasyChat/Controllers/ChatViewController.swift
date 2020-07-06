//
//  ChatViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/5/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import MessageKit


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}


class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private var selfSender = Sender(senderId: "James",
                                    displayName: "1",
                                    photoURL: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World Message")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Another World Message")))
        
        view.backgroundColor = .red


        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension ChatViewController:MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
