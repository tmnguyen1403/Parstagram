//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Tom Riddle on 10/20/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  @IBAction func onSignIn(_ sender: Any) {
    if let username = usernameField.text, let password = passwordField.text {
      PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
        if let error = error {
          print("Log in ERROR \(error.localizedDescription)")
        }
        else if let user = user {
          print("Log in successfully")
          self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        else {
          print("Log in ERROR UNKNOWN")
        }
      }
    }
    else {
      print("Log in ERROR username and password cannot be empty")
    }
  }
  
  @IBAction func onSignUp(_ sender: Any) {
    let user = PFUser()
    
  
    user.username = usernameField.text
    user.password = passwordField.text
    print(user.username!)
    user.signUpInBackground { (success, error) in
      if let error = error{
        print("Sign up Error: \(error.localizedDescription)")
      } else {
        print("Sign up successfully")
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
      }
    }
  }
}
