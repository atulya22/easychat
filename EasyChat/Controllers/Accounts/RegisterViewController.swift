//
//  RegisterViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 03/22/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
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
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
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
        
        profileImageView.layer.cornerRadius = profileImageView.width/2.0
        
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
        presentPhotoActionSheet()
    }
    @objc func didTapRegisterButton() {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        
        guard let firstName = firstName.text,
            let lastName = lastName.text,
            let email = emailField.text,
            let password = passwordField.text,
            !firstName.isEmpty,
            !lastName.isEmpty,
            !email.isEmpty,
            !password.isEmpty else {
                alertUserLoginError(message: "Please enter all information to continue")
                return
        }
        
        guard password.count >= 6 else {
                alertUserLoginError(message: "Please enter password length greter than 6")
                return
        }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                print("User exists")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                
                guard authResult != nil, error == nil  else {
                    let error_code = AuthErrorCode(rawValue: error!._code)
                    switch error_code {
                    case .emailAlreadyInUse:
                        strongSelf.alertUserLoginError(message: "An Account with that email already exists")
                    default:
                        print("Error")
                        
                    }
                    strongSelf.alertUserLoginError(message: "Error creating account")
                    return
                }
                
                let user = AppUser(firstName: firstName,
                               lastName: lastName,
                               emailAddress: email)
                
                
                UserDefaults.standard.set(email, forKey:"email")

                DatabaseManager.shared.insertUser(with:user, completion: { success in
                    if success {
                        //uplpad image
                        guard let image = strongSelf.profileImageView.image, let data = image.pngData() else {
                            return
                        }
                        
                        let fileName = user.profilePictureFileName
                        
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage Manager Error: \(error)")
                            }
                        })
                    }
                } )
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
            

        
}
    
    
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Error",
                                           message: message,
                                           preferredStyle: .alert)
             
        alert.addAction(UIAlertAction(title: "Dismiss",
                                           style: .cancel,
                                           handler: nil))
        present(alert, animated: true)
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                                 
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                                
        }))
        
        present(actionSheet, animated: true)

    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profileImageView.image = selectedImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
