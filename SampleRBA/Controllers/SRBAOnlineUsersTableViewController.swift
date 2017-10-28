//
//  SRBAOnlineUsersTableViewController.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SRBAOnlineUsersTableViewController: UITableViewController {

  // MARK: Constants
  let userCell = "UserCell"
  let usersRef = Database.database().reference(withPath: "RBAOnlineUsers1")
  
  // MARK: Properties
  var currentUsers: [String] = []
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    usersRef.observe(.childAdded, with: { snap in
      guard let email = snap.value as? String else { return }
      self.currentUsers.append(email)
      let row = self.currentUsers.count - 1
      let indexPath = IndexPath(row: row, section: 0)
      self.tableView.insertRows(at: [indexPath], with: .top)
    })
    
    usersRef.observe(.childRemoved, with: { snap in
      guard let emailToFind = snap.value as? String else { return }
      for (index, email) in self.currentUsers.enumerated() {
        if email == emailToFind {
          let indexPath = IndexPath(row: index, section: 0)
          self.currentUsers.remove(at: index)
          self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    })
    
  }

  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentUsers.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
    let onlineUserEmail = currentUsers[indexPath.row]
    cell.textLabel?.text = onlineUserEmail
    return cell
  }
  
  // MARK: Actions
  @IBAction func signout(_ sender: AnyObject) {
    do {
      try Auth.auth().signOut()//FIRAuth.auth()!.signOut()
      dismiss(animated: true, completion: nil)
    } catch {
      self.showAlert(title: "Sign Out", message: (error.localizedDescription))
    }
  }
  
}
