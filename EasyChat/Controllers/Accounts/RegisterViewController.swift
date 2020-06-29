//
//  RegisterViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 03/22/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        return imageView
    }()
    
    
    
    private let firstName: UITextField = {
       let field = UITextField()
       field.autocapitalizationType = .none
       field.autocorrectionType = .no
       field.returnKeyType = .continue
       field.layer.cornerRadius = 12
       field.layer.borderWidth = 1
       field.layer.borderColor = UIColor.lightGray.cgColor
       field.placeholder = "First Name..."
       field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
       field.leftViewMode = .always
       field.backgroundColor = .white
       return field
        
    }()
    
    private let lastName: UITextField = {
       let field = UITextField()
       field.autocapitalizationType = .none
       field.autocorrectionType = .no
       field.returnKeyType = .continue
       field.layer.cornerRadius = 12
       field.layer.borderWidth = 1
       field.layer.borderColor = UIColor.lightGray.cgColor
       field.placeholder = "Last Name..."
       field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
       field.leftViewMode = .always
       field.backgroundColor = .white
       return field
        
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight:.bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .white
        
        
        emailField.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        passwordField.delegate = self
        

        view.addSubview(scrollView)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        profileImageView.addGestureRecognizer(gesture)
        



        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        let margins = scrollView.layoutMarginsGuide
        let profileViewMargins = profileImageView.layoutMarginsGuide
        let firstNameMargins = firstName.layoutMarginsGuide
        let lastNameMargins = lastName.layoutMarginsGuide

        let emailFieldMargins = emailField.layoutMarginsGuide
        let passwordFieldMargins = passwordField.layoutMarginsGuide

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: (scrollView.width-size)/2).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        firstName.translatesAutoresizingMaskIntoConstraints = false
        firstName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                           constant: 30).isActive = true
        firstName.topAnchor.constraint(equalTo: profileViewMargins.bottomAnchor,
                                       constant: 20).isActive = true
        firstName.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        firstName.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        lastName.translatesAutoresizingMaskIntoConstraints = false
        lastName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                                  constant: 30).isActive = true
        lastName.topAnchor.constraint(equalTo: firstNameMargins.bottomAnchor,
                                              constant: 20).isActive = true
        lastName.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        lastName.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                            constant: 30).isActive = true
        emailField.topAnchor.constraint(equalTo: lastNameMargins.bottomAnchor,
                                        constant: 20).isActive = true
                 
        emailField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 52).isActive = true
  
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordField.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                            constant: 30).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailFieldMargins.bottomAnchor,
                                        constant: 20).isActive = true
        
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        registerButton.widthAnchor.constraint(equalToConstant: scrollView.width-60).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                            constant: 30).isActive = true
        registerButton.topAnchor.constraint(equalTo: passwordFieldMargins.bottomAnchor,
                                        constant: 20).isActive = true
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func didTapProfilePicture() {
        print("Did Tap Register")
    }
    func didTapRegisterButton() {
        print("Did Tap Register")
    }

}
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName {
            lastName.becomeFirstResponder()
        }
        else if textField == lastName {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapRegisterButton()
        }
        
        return true
    }
}
