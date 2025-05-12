//
//  AppDelegate.swift
//
//  Created by Evan Booth and Justin Andre
//


import UIKit

@UIApplicationMain //main entry
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? //allows main storyboard file to be used

    //called immediately when app launches
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    } //checks storyboard to load and show initial view controller


}
//first goes to Info and displays LaunchScreen briefly, and then once the real viewController's ready it goes to Main screen
  
