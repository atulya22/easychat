//
//  SignInViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/13/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var circularView: CircularView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)

    
    // MARK: View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        decorateTextFields()
    }
    
    // MARK: General functions
    private func setDelegates() {
        circularView.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // Setup border and placeholder for textfields
    private func decorateTextFields() {
        
        // Add bottom border
        userNameTextField.addBottomBorder()
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        passwordTextField.addBottomBorder()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    private func performAuthentication(email: String, password: String) {
        spinner.show(in: view)

        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
                                            
            guard let _ = authResult, error == nil else {
                print("Login Error")
                return
            }
            let safeEmail = DatabaseManager.cleanEmail(emailAddress: email)
            DatabaseManager.shared.getData(for: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to read error:\(error) ")
                }
            })
            strongSelf.dismiss(animated: true, completion: nil)

            if let presenter = strongSelf.presentingViewController {
                presenter.dismiss(animated: true, completion: nil
                )
            }
        })
    }

}

extension SignInViewController: Altertable {
    @IBAction private func loginButtonTapped() {
        guard let email = userNameTextField.text, let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty else {
                showAlert(title:LoginError.emptyField.errorDescription.title,
                          message: LoginError.emptyField.errorDescription.message)
                return
        }
        
        guard password.count >= 6 else {
            showAlert(title:LoginError.passwordTooShort.errorDescription.title,
                                    message: LoginError.passwordTooShort.errorDescription.message)
            return
        }
        
        performAuthentication(email: email, password: password)
    }
}

extension SignInViewController: CircularButtonDelegate {
    
    func closeButtonClicked() {
      dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            loginButtonTapped()
        }
        
        return true
    }
    
}


enum LoginError: LocalizedError {
    
    case emptyField
    case passwordTooShort
    
    var errorDescription: (title: String, message: String) {
        switch self {
        case .emptyField:
            let title = "Login or Password Emtpy"
            let description = "Please fill out all the fields"
            return (title, description)
        case .passwordTooShort:
            let title = "Password too Short"
            let description = "Password length has to be greater than 6 characters"
            return (title, description)

        }
    }
}


protocol Altertable {}

extension Altertable where Self: UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}
