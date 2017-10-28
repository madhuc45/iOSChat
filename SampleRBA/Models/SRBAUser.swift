//
//  SRBAUser.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


struct SRBAUser {
  
  let uid: String
  let email: String
  let displayName: String
  
  init(authData: User) {
    uid = authData.uid
    email = authData.email!
    displayName = authData.displayName!
  }
  
  init(uid: String, email: String, displayName: String) {
    self.uid = uid
    self.email = email
    self.displayName = displayName
  }
}
