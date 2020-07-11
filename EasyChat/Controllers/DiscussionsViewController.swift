//
//  DiscussionsViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 6/25/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class DiscussionsViewController: UIViewController {
    override func didReceiveMemoryWarning() {
        
    }
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    private var loginObserver : NSObjectProtocol?
    
    private let tableView : UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(DiscussionTableViewCell.self,
                       forCellReuseIdentifier: DiscussionTableViewCell.identifier)
        return table
        
    }()
    
    private let noConversationsLabel : UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningforConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName:.didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
                                                     
                 guard let strongSelf = self else {
                     return
                 }
                                                     
                 strongSelf.startListeningforConversations()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func startListeningforConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("Start Listening for Conversations")
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: cleanEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print(conversations)
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                print("Success Fetching Conversations")

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case.failure(let error):
                print("Failed fetch to messages:\(error)")
            }
        })
    }
    
    @objc func didTapComposeButton() {
        let vc = StartDiscussionViewController()
        vc.completion = { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            let conversations = strongSelf.conversations
            
            if let targetConversation = conversations.first(where: {
                $0.otherUserEmail == DatabaseManager.cleanEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id:targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            } else {
                strongSelf.createNewDiscussion(result: result)
            }
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewDiscussion(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.cleanEmail(emailAddress: result.email)
        // Check database to see if conversation exists
        
        
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id:conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id:nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
        

    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func fetchConversations() {
        tableView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    func isLoggedIn() -> Bool {
        return AccountPreferences.shared.isLoggedIn
    }
    
    
    private func validateAuth() {
        
        if (FirebaseAuth.Auth.auth().currentUser == nil) {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}


extension DiscussionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Table View Cell")
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscussionTableViewCell.identifier, for: indexPath) as! DiscussionTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)

    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            print("Begin Table View Updates")
            let conversationId = conversations[indexPath.row].id
            DatabaseManager.shared.deleteConversation(for: conversationId) { [weak self] (success) in
                if success {
                    print("Delete conversation in Discussion View")
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            print("End Table View Updates")

            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}


