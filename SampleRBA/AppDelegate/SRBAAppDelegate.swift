//
//  SRBAAppDelegate.swift
//  SampleRBA
//
//  Created by Madhu Chittipolu on 27/10/17.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class SRBAAppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UIApplication.shared.statusBarStyle = .lightContent
    FirebaseApp.configure()
    Database.database().isPersistenceEnabled = true
    return true
  }
}
