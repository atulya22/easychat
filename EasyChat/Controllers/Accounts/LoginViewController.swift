//
//  LoginViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 03/22/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn


class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let FBLoginBTN : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private let googleLoginButton : GIDSignInButton = {
        let button = GIDSignInButton()
        return button
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
    
    private var loginObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Called viewdidLoad")
        
        loginObserver = NotificationCenter.default.addObserver(forName:.didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
                                                
            guard let strongSelf = self else {
                return
            }
                                                
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                                
        })
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self

        title = "Log in"
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        addNavButton()
        loginButton.addTarget(self, action: #selector(didTapLoginButton),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        FBLoginBTN.delegate = self
        addSubviews()

    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FBLoginBTN)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        setupLogoViewConstraints()
        setupEmailFieldConstraints()
        setupPasswordFieldConstraints()
        setupLoginButtonConstraints()
        setupFacebookLoginButtonConstraints()
        setupGoogleLoginButtonConstraints()
    }
    
    func setupLogoViewConstraints() {
        
        let size = scrollView.width/3

        let margins = scrollView.layoutMarginsGuide

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: (scrollView.width-size)/2).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    func setupEmailFieldConstraints() {
        
        let logoViewMargins = logoImageView.layoutMarginsGuide
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        emailField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true

        emailField.topAnchor.constraint(equalTo: logoViewMargins.bottomAnchor, constant: 10).isActive = true
    }
    
    func setupPasswordFieldConstraints() {
        let emailFieldMargins = emailField.layoutMarginsGuide

        passwordField.translatesAutoresizingMaskIntoConstraints = false

        passwordField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailFieldMargins.bottomAnchor, constant: 25).isActive = true
    }
    
    func setupLoginButtonConstraints() {
        let passwordFieldMargins = passwordField.layoutMarginsGuide

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginButton.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordFieldMargins.bottomAnchor, constant: 25).isActive = true
        
    }
    
    func setupFacebookLoginButtonConstraints() {
        
        FBLoginBTN.translatesAutoresizingMaskIntoConstraints = false
        FBLoginBTN.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        
        FBLoginBTN.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        
        FBLoginBTN.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
    }

    func setupGoogleLoginButtonConstraints() {
        
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        googleLoginButton.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        
        googleLoginButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        
        googleLoginButton.topAnchor.constraint(equalTo: FBLoginBTN.bottomAnchor, constant: 20).isActive = true
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
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email,
                                        password: password,
                                        completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
                                            
            guard let result = authResult, error == nil else {
                print("Login Error")
                return
            }
            print(result)
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
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
    deinit {
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
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

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("Failed to login with facebook ")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any],
                error == nil else {
                print("Facebook graph request failed")
                return
            }
            
            guard let fullName = result["name"] as? String,
                let email = result["email"] as? String else {
                return
            }
            
            let nameComponent = fullName.components(separatedBy: " ")
            let firstName = nameComponent[0]
            let lastName = nameComponent[1]
            
            print(firstName)
            print(lastName)
            
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                
                if !exists {
                    let user = AppUser(firstName: firstName,
                                       lastName: lastName,
                                       emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: user)
                }
            })
            
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authresult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authresult != nil , error == nil else {
                    if let error = error {
                        print(error)
                    }
                    return
                }
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
        

        
    }
    
    
}

