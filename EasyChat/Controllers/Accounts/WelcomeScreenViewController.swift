//
//  SignInViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/12/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
      
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
