//
//  AppDelegate.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import GoogleMaps
import Reachability

var USER_ID: String = ""
let GOOGLE_API_KEY = "AIzaSyB07Q_QcWvaIc9mMm1DN-hPM-_Rl2CpO18"

let reachability = Reachability()!

let DEFAULT_COLOR = UIColor(red:0.129, green:0.490, blue:0.603, alpha:1.0)
let DEFAULT_COLOR_OPPOSED = UIColor(red:0.964, green:0.803, blue:0.592, alpha:1.0)
let httpController = OEHTTPController()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	
	///------------------------------------------------------------------------------------------
	/// Generate a Random String as the Users ID
	///
	/// - Parameter length: how long the string should be
	/// - Returns: id string
	///------------------------------------------------------------------------------------------
	func randomString(length: Int) -> String {
		
		let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let len = UInt32(letters.length)
		
		var randomString = ""
		
		for _ in 0 ..< length {
			let rand = arc4random_uniform(len)
			var nextChar = letters.character(at: Int(rand))
			randomString += NSString(characters: &nextChar, length: 1) as String
		}
		
		return randomString
	}
	
	///------------------------------------------------------------------------------------------
	/// Get the Users ID from the Setting Bundle
	///------------------------------------------------------------------------------------------
	func getUserIdentifier() {
		// Look for the Settings Bundle
		let settingsBundle: NSString = Bundle.main.path(forResource: "UserSettings", ofType: "bundle")! as NSString
		
		// Check if the bundle exists
		if(settingsBundle.contains("")){
			print("Could not find UserSettings.bundle")
			return;
		}

		let userDefaults = UserDefaults.standard
		userDefaults.synchronize()

		// Check if we have the userid key in the bundle
		if userDefaults.object(forKey: "userid") != nil {
			USER_ID = userDefaults.object(forKey: "userid")! as! String
			print("Found User ID: \(USER_ID)")
		}
		else {
			print("Have No User ID: Generating New ID")
			USER_ID = randomString(length: 12)
			userDefaults.set(USER_ID, forKey: "userid")
			userDefaults.synchronize()
			httpController.uploadNewUserId(userid: USER_ID)
		}
		
		// Dev Function
//		userDefaults.removeObject(forKey: "userid")
//		userDefaults.synchronize()
	}
	
	///------------------------------------------------------------------------------------------
	/// Finished Launching With Options
	///
	/// - Parameters:
	///   - application: which application
	///   - launchOptions: launch options
	/// - Returns: boolean
	///------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
//		reachability.whenReachable = { reachability in
//			if reachability.connection == .wifi {
//				print("Reachable via WiFi")
//			} else {
//				print("Reachable via Cellular")
//			}
//		}
//		reachability.whenUnreachable = { _ in
//			print("Not reachable")
//		}
		
		do {
			try reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
		
		GMSServices.provideAPIKey(GOOGLE_API_KEY);
		getUserIdentifier()
		application.isStatusBarHidden = true
		return true
	}

	///------------------------------------------------------------------------------------------
	/// Application Will Resign Active
	///
	/// - Parameter application: which application
	///------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	///------------------------------------------------------------------------------------------
	/// Application Did Enter Background
	///
	/// - Parameter application: which application
	///------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	///------------------------------------------------------------------------------------------
	/// Application Will Enter Foreground
	///
	/// - Parameter application: which application
	///------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	///------------------------------------------------------------------------------------------
	/// Application Did Become Active
	///
	/// - Parameter application: which application
	///------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	///------------------------------------------------------------------------------------------
	/// Application Will Terminate
	///
	/// - Parameter application: which application
	///------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

