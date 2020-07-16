//
//  ProfileViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 6/25/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

enum ProfileModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileModelType
    let title: String
    let handler: (() -> Void)?
}


class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        let name = UserDefaults.standard.value(forKey: "name") as? String ?? "No Name"
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(name)",
                                     handler:nil))
        
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? "No Email"
        print(email)
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(email)",
                                     handler:nil))
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Logout", handler:{ [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Log out",
                                                style: .destructive,
                                                handler: { _ in
                                                    
                                                    UserDefaults.standard.set(nil, forKey: "email")
                                                        UserDefaults.standard.set(nil, forKey: "name")
                                                    

                                                    GIDSignIn.sharedInstance()?.signOut()
                                                    FBSDKLoginKit.LoginManager().logOut()
                                                    
                                                    do {
                                                        try
                                                            FirebaseAuth.Auth.auth().signOut()
                                                        let vc = LoginViewController()
                                                        let nav = UINavigationController(rootViewController: vc)
                                                        nav.modalPresentationStyle = .fullScreen
                                                        strongSelf.present(nav, animated: true)
                                                    }
                                                    catch {
                                                        print("Failed to logut")
                                                    }
                                                    
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            self?.present(actionSheet, animated: true)
            
            
        }))
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()

    }
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let cleanEmail = DatabaseManager.cleanEmail(emailAddress: email)
        let fileName = cleanEmail + "_profile_picture.png"
        
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url:\(error)")
            }
        })
        return headerView
        
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        
        cell.setup(with: viewModel)
        
//        cell.textLabel?.text = data[indexPath.row].title
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.textColor = .purple
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    
}


class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    func setup(with viewModel:ProfileViewModel) {
        textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
            
        }
    }
}
