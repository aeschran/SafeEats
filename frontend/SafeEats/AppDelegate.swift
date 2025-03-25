//
//  AppDelegate.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/27/25.
//


import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        print("App is terminating...")
        //
        //        // Perform any cleanup or data saving here
        //        UserDefaults.standard.set(false, forKey: "createdProfile")  // Example: Log the user out
        //
        //        print(UserDefaults.standard.bool(forKey: "createdProfile"))
        
        UserDefaults.standard.set(UserDefaults.standard.bool(forKey: "staySignedIn"), forKey: "loggedIn")
    }
}
