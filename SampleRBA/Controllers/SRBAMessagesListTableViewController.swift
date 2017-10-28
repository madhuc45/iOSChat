//
//  SRBAMessagesListTableViewController.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseDatabaseUI
class SRBAMessagesListTableViewController: UITableViewController {

  // MARK: Constants
  let userListIdentifier = "UsersListIdentifier"
  
  // MARK: Properties 
  var items: [SRBAMessage] = []
   var ref: DatabaseReference!
  var dataSource: FUITableViewDataSource?

//  let ref = Database.database().reference(withPath: "RBAMessages1")
  let usersRef = Database.database().reference(withPath: "RBAOnlineUsers1")

  var user: SRBAUser!
  var onlineUsersBarButton: UIBarButtonItem!
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = Database.database().reference()

    tableView.allowsMultipleSelectionDuringEditing = false
    
    onlineUsersBarButton = UIBarButtonItem(title: "1",
                                             style: .plain,
                                             target: self,
                                             action: #selector(onlineUsers))
    onlineUsersBarButton.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = onlineUsersBarButton
    
    usersRef.observe(.value, with: { snapshot in
      if snapshot.exists() {
        self.onlineUsersBarButton?.title = snapshot.childrenCount.description
      } else {
        self.onlineUsersBarButton?.title = "0"
      }
    })
    
    let identifier = "SRBAMessageTableViewCell"
    let nib = UINib.init(nibName: "SRBAMessageTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: identifier)
    
  
    dataSource = FUITableViewDataSource.init(query: getQuery()) { (tableView, indexPath, snap) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SRBAMessageTableViewCell

      guard let post = SRBAMessage(snapshot: snap) else { return cell }
      cell.nameLabel.text = post.author
      cell.messageLabel.text = post.body
      return cell
    }

    dataSource?.bind(to: tableView)
    tableView.delegate = self
    
    
//    ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
//      var newItems: [SRBAMessage] = []
//
//      for item in snapshot.children {
//        let listItem = SRBAMessage(snapshot: item as! DataSnapshot)
//        newItems.append(listItem!)
//      }
//
//      self.items = newItems
//      self.tableView.reloadData()
//    })
    
    
    Auth.auth().addStateDidChangeListener { (auth, user) in
      guard let user = user else { return }
      self.user = SRBAUser(authData: user)
      let currentUserRef = self.usersRef.child(self.user.uid)
      currentUserRef.setValue(self.user.email)
      currentUserRef.onDisconnectRemoveValue()
    }
  }
  
  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    tableView.register(UINib(nibName: "SRBAMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SRBAMessageTableViewCell")
//
//    let messageCell = tableView.dequeueReusableCell(withIdentifier: "SRBAMessageTableViewCell") as! SRBAMessageTableViewCell
//    let listItem = items[indexPath.row]
//    messageCell.nameLabel.text = listItem.author
//    messageCell.messageLabel.text = listItem.body
//
//   // toggleCellCheckbox(messageCell, isCompleted: listItem.completed)
//
//    return messageCell
//  }
  
  // MARK: Actions
  @IBAction func addMessage(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Message",
                                  message: "Send your Message",
                                  preferredStyle: .alert)
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { _ in
                                    // 1
                                    
                                    let messageField = alert.textFields![0]
                                    guard let messageText = messageField.text else {
                                      self.showAlert(title: "Message", message: "message can't be empty")
                                      return
                                    }
                                    if messageText.characters.count == 0 {
                                      self.showAlert(title: "Message", message: "message can't be empty")
                                      return
                                    }
                                    messageField.resignFirstResponder()
                                    
                                    let userID = Auth.auth().currentUser?.uid
                                    self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                      
                                      // Write new post
                                      self.writeNewPost(withUserID: userID!, username: self.user.displayName, title: "", body: messageText)
                                    }) { (error) in
                                      print(error.localizedDescription)
                                    }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: Custom Methods
  func writeNewPost(withUserID userID: String, username: String, title: String, body: String) {
    // Create new post at /user-posts/$userid/$postid and at
    let key = ref.child("posts").childByAutoId().key
    let post = ["uid": userID,
                "author": username,
                "title": title,
                "body": body]
    let childUpdates = ["/posts/\(key)": post,
                        "/user-posts/\(userID)/\(key)/": post]
    ref.updateChildValues(childUpdates)
  }
  
  func onlineUsers() {
    performSegue(withIdentifier: userListIdentifier, sender: nil)
  }
  
  func getUid() -> String {
    return (Auth.auth().currentUser?.uid)!
  }
  
  func getQuery() -> DatabaseQuery {
    let recentPostsQuery = (ref?.child("posts").queryLimited(toFirst: 100))!
    return recentPostsQuery
   // return self.ref
  }

}
