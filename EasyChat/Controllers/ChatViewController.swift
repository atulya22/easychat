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
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation


struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
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


struct Media: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    
}

class ChatViewController: MessagesViewController {
    
    
    private var senderPhotoURL: URL?
    private var otherPhotoURL: URL?
    
    internal static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    public var isNewConversation = false
    public let otherUserEmail: String
    private var conversationId: String?

    
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
            
        }
        
        let safeEmail = DatabaseManager.cleanEmail(emailAddress: email)
        return Sender(senderId: safeEmail,
        displayName: "Me",
        photoURL: "")
         
    }
    


    init(with email:String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInputButton()
        
    }
    
    func setupInputButton() {
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: true)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside({ [weak self] _ in
            self?.presentInputActionSheet()
            
        })
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([button], forStack: .left, animated:false)
    }
    
    private func presentInputActionSheet() {
        let actionsheet = UIAlertController(title: "Attact Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoActionSheet()
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoActionSheet()
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
            
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionsheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil, isPickable: true)
        vc.title = "Select Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                   let name = strongSelf.title,
                let selfSender = strongSelf.selfSender else {
                       return
               }
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            print("Longitude: \(longitude)")
            print("Latitude: \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude,
                                                      longitude: longitude),
                                                      size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                
                if success {
                    print("Location message sent successfully")
                }
                else {
                    print("Failed to send Location message")
                    
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoActionSheet() {
        
        let actionsheet = UIAlertController(title: "Attact Photo",
                                            message: "Where would you like to attach a photo from?",
                                            preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self?.present(imagePicker, animated: true)
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self?.present(imagePicker, animated: true)
            
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true)

        
    }
    
    private func presentVideoActionSheet() {
        
        let actionsheet = UIAlertController(title: "Attact Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
            imagePicker.allowsEditing = true
            self?.present(imagePicker, animated: true)
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
            imagePicker.allowsEditing = true
            self?.present(imagePicker, animated: true)
            
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversations(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()

                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }

                }
                
            case .failure(let error):
                print("Failed to list for messages:\(error)")
            }
                
        })
    }
}

extension ChatViewController:MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, np cached email")

    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard  let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .link
        }
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            if let currentUserImage = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImage, completed: nil)
            } else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let cleanEmail = DatabaseManager.cleanEmail(emailAddress: email)
                
                let path = "images/\(cleanEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Failed to download profile image: \(error)")
                        
                    }
                })
            }

        } else {
            if let otherUserImage = otherPhotoURL {
                avatarView.sd_setImage(with: otherUserImage, completed: nil)
            } else {
                
                let email = self.otherUserEmail
            
                let cleanEmail = DatabaseManager.cleanEmail(emailAddress: email)
                
                let path = "images/\(cleanEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    
                    switch result {
                    case .success(let url):
                        self?.otherPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Failed to download profile image: \(error)")
                        
                    }
                })

            }
        }
    }
}


extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = ImageViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
         
        default:
            break
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
         
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates, isPickable: false)
            vc.title = "Location"
            self.navigationController?.pushViewController(vc, animated: true)
         
        default:
            break
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
            return
        }
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        print("Sending message: \(text)")
        if isNewConversation {
            //Create Conversation in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("Message sent successfully")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId,
                                            shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Failed to send message")
                }
            })
        } else {
            guard let conversationId = conversationId, let name = self.title  else {
                return
            }
            // Append to existing conversatiseon
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("Message sent to existing conversation")
                } else {
                    print("Failed to send message")
                }
            })
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


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let name = self.title,
            let selfSender = self.selfSender else {
                return
        }
        // Send message containing image

        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            
            let fileName = "photo_message_\(messageId)".replacingOccurrences(of: " ", with: "-") + ".png"
            print(fileName)
            
            // Logic to upload image
            StorageManager.shared.uploadPhotoMessage(with: imageData, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    print("Uploaded photo message to url: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeHolder = UIImage(systemName: "plus") else {
                            return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("Photo message sent successfully")
                        }
                        else {
                            print("Failed to send photo message")
                            
                        }
                    })
                case .failure(let error):
                    print("Message photo upload failed with error: \(error)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "photo_message_\(messageId)".replacingOccurrences(of: " ", with: "-") + ".mov"
            // Upload video
            
            // Logic to upload image
            StorageManager.shared.uploadVideoMessage(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    print("Uploaded video message to url: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeHolder = UIImage(systemName: "plus") else {
                            return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("Video message sent successfully")
                        }
                        else {
                            print("Failed to send Video message")
                            
                        }
                    })
                case .failure(let error):
                    print("Message Video upload failed with error: \(error)")
                }
            })
        }
        
    }
}

