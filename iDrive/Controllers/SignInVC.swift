//
//  ViewController.swift
//  iDrive
//
//  Created by Nishant Hooda on 2018-01-13.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import UIKit

class signInVC: UIViewController {
    
    private let DRIVER_SEGUE = "DriverVC"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        if (emailTextField.text?.isValidEmail())! && passwordTextField.text != ""{
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler:{(message) in
                if message != nil {
                    self.alertUser(title: "Problem with Authentication", message: message!)
                }else {
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                    print("LOGIN COMPLETE")
                }
            })
        }else if !(emailTextField.text?.isValidEmail())!{
            alertUser(title: "Invalid email", message: "Please enter a valid email in textfield")
        }else {
            alertUser(title: "Password is required", message: "Please enter password in textfield")
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        if (emailTextField.text?.isValidEmail())! && passwordTextField.text != ""{
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                if message != nil{
                    self.alertUser(title: "Cannot create new user", message: message!)
                }else{
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                    print("USER CREATED")
                }
            })
        }else if !(emailTextField.text?.isValidEmail())!{
            alertUser(title: "Invalid email", message: "Please enter a valid email in textfield")
        }else {
            alertUser(title: "Password is required", message: "Please enter password in textfield")
        }
    }
    
    private func alertUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

