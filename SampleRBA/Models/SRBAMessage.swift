//
//  SRBAUser.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import Foundation
import FirebaseDatabase

class SRBAMessage: NSObject {
  var uid: String
  var author: String
  var title: String
  var body: String
  var starCount: AnyObject?
  var stars: Dictionary<String, Bool>?
  
  init(uid: String, author: String, title: String, body: String) {
    self.uid = uid
    self.author = author
    self.title = title
    self.body = body
    self.starCount = 0 as AnyObject?
  }
  
  init?(snapshot: DataSnapshot) {
    guard let dict = snapshot.value as? [String:Any] else { return nil }
//    guard let uid  = dict["uid"] as? String  else { return nil }
//    guard let author = dict["author"]  as? String else { return nil }
//    guard let title = dict["title"]  as? String else { return nil }
//    guard let body = dict["body"]  as? String else { return nil }
//    guard let starCount = dict["starCount"] else { return nil }
    
    self.uid = dict["uid"] as! String
    self.author = dict["author"] as! String
    self.title = dict["title"] as! String
    self.body = dict["body"] as! String
    self.starCount = starCount as AnyObject?
  }
  
  convenience override init() {
    self.init(uid: "", author: "", title: "", body:  "")
  }
}
