//
//  LoginViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 03/22/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight:.bold)
        return button
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Called viewdidLoad")

        title = "Log in"
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        addNavButton()
        loginButton.addTarget(self, action: #selector(didTapLoginButton),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        let margins = scrollView.layoutMarginsGuide
        let logoViewMargins = logoImageView.layoutMarginsGuide
        let emailFieldMargins = emailField.layoutMarginsGuide
        let passwordFieldMargins = passwordField.layoutMarginsGuide

        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: (scrollView.width-size)/2).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        

        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        emailField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true

        emailField.topAnchor.constraint(equalTo: logoViewMargins.bottomAnchor, constant: 10).isActive = true
        
        
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        passwordField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailFieldMargins.bottomAnchor, constant: 25).isActive = true
        
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        loginButton.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordFieldMargins.bottomAnchor, constant: 25).isActive = true
//        logoImageView.frame = CGRect(x: (scrollView.width-size)/2,
//                                     y: 20,
//                                     width: size,
//                                     height: size)
//
//        emailField.frame = CGRect(x: 30,
//                                  y: logoImageView.bottom+10,
//                                  width: (scrollView.width-size)/2,
//                                  height: 52)
//
//        passwordField.frame = CGRect(x: 30,
//                                     y: emailField.bottom+10,
//                                     width: scrollView.width-60,
//                                     height: 52)
//
//        loginButton.frame = CGRect(x: 30,
//                                   y: passwordField.bottom + 10,
//                                   width: scrollView.width-60,
//                                   height: 52)
    }
    
    func addNavButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
    }
    
    @objc private func didTapLoginButton() {
        
        guard let email = emailField.text, let password = passwordField.text,
            !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Error",
                                      message: "Please enter all information to continue",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        print("Register button tapped")
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapLoginButton()
        }
        
        return true
    }
}
