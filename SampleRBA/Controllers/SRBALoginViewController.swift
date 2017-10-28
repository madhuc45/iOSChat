//
//  SRBALoginViewController.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import UIKit
import FirebaseAuth
import Firebase


class SRBALoginViewController: UIViewController {

  // MARK: Constants
  let messagesTableViewControllerIdentifier = "MessagesTableViewControllerIdentifier"
  var ref: DatabaseReference!

  // MARK: Outlets
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  // MARK: UIViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = Database.database().reference()
//    Auth.auth().addStateDidChangeListener { (auth, user) in
//      if user != nil {
//        self.performSegue(withIdentifier: self.messagesTableViewControllerIdentifier, sender: nil)
//      }
//    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.hideActivityIndicator()
  }

  // MARK: Actions
  @IBAction func login(_ sender: AnyObject) {
    if emailTextField.text == "" || passwordTextField.text == "" {
      showAlert(title: "Login", message: "Please enter valid email & password!")
      return
    }
      self.showActivityIndicator()
    Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
      if user != nil {
        if user?.displayName != nil {
          self.hideActivityIndicator()
          self.performSegue(withIdentifier: self.messagesTableViewControllerIdentifier, sender: nil)
        } else {
          self.hideActivityIndicator()
          self.updateUsername(user: user!)
        }
      } else {
        self.hideActivityIndicator()
          self.showAlert(title: "Login", message: (error?.localizedDescription)!)
        }
    }
  }

  @IBAction func signup(_ sender: AnyObject) {
    if emailTextField.text == "" || passwordTextField.text == "" {
      showAlert(title: "Signup", message: "Please enter valid email & password!")
      return
    }
    self.showActivityIndicator()
    Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
      if error == nil {
        self.hideActivityIndicator()
        self.updateUsername(user: user!)
      } else {
        self.hideActivityIndicator()
        self.showAlert(title: "Sign up", message: (error?.localizedDescription)!)
      }
    })
  }
  
 // MARK: Custom Methods
  func updateUsername(user: User) {
    let alertController = UIAlertController(title: "Username",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { action in
                                    let usernameField = alertController.textFields![0]
                                    guard let username = usernameField.text else {
                                      self.showAlert(title: "Username", message: "Username can't be empty")
                                      return
                                    }
                                    if username.characters.count == 0 {
                                      self.showAlert(title: "Username", message: "Username can't be empty")
                                      return
                                    }
                                    usernameField.resignFirstResponder()
                                    self.showActivityIndicator()
                                    self.saveUserInfo(user, withUsername: username)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alertController.addTextField { textEmail in
      textEmail.placeholder = "Enter your username"
    }
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  // Saves user profile information to user database
  func saveUserInfo(_ user: Firebase.User, withUsername username: String) {
    
    // Create a change request
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    changeRequest?.displayName = username
    
    // Commit profile changes to server
    changeRequest?.commitChanges() { (error) in
      if let error = error {
        self.hideActivityIndicator()
        self.showAlert(title: "Username", message: (error.localizedDescription))
        return
      }
      self.ref.child("users").child(user.uid).setValue(["username": username])
      
      Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
        if user != nil {
          if user?.displayName != nil {
            self.hideActivityIndicator()
            self.performSegue(withIdentifier: self.messagesTableViewControllerIdentifier, sender: nil)
          } else {
            self.showActivityIndicator()
            self.updateUsername(user: user!)
          }
        }  else {
          self.hideActivityIndicator()
          self.showAlert(title: "Login", message: (error?.localizedDescription)!)
        }
      }
    }
  }
}

// MARK: ViewController Extension
extension UIViewController {
  func showAlert(title: String, message:String)  {
    let alertViewController = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.alert)
    alertViewController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    self.present(alertViewController, animated: true, completion: nil)
  }

  func showActivityIndicator() {
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
    activityIndicator.layer.cornerRadius = 6
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = .whiteLarge
    activityIndicator.startAnimating()
    activityIndicator.tag = 100 // 100 for example
    
    // before adding it, you need to check if it is already has been added:
    for subview in view.subviews {
      if subview.tag == 100 {
        print("already added")
        return
      }
      
      view.addSubview(activityIndicator)
    }
  }
  
  func hideActivityIndicator() {
    let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
    activityIndicator?.stopAnimating()
    activityIndicator?.removeFromSuperview()
  }

}
// MARK: TextField Delegate Extension

extension SRBALoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    if textField == passwordTextField {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
