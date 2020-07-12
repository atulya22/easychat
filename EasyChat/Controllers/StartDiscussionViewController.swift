//
//  StartDiscussionViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 6/25/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import JGProgressHUD

class StartDiscussionViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private var results = [SearchResult]()
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var hasFetched = false
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2, height: 200)
        
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }


}

extension StartDiscussionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension StartDiscussionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(by: query)
        } else {
            DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(by: query)
                case .failure(let error):
                    self?.spinner.dismiss()
                    print("Failed to fetch users:\(error)")
                }
            })
        }
    }
    
    func filterUsers(by term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss()

        
        let results : [SearchResult] = users.filter({
            guard let email = $0["email"],
                email != cleanEmail else {
                    return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"],
                let name = $0["name"] else {
                    return nil
            }
            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        print("\(results)")
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name: String
    let email: String
}
