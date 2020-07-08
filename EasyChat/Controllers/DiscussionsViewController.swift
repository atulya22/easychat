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
    
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func startListeningforConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
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
            self?.createNewDiscussion(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewDiscussion(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id:nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
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

        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
