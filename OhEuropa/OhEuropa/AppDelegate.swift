//
//  AppDelegate.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import GoogleMaps

let GOOGLE_API_KEY = "AIzaSyB07Q_QcWvaIc9mMm1DN-hPM-_Rl2CpO18"
var USER_ID: String = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	let httpController = OEHTTPController()
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter length: <#length description#>
	/// - Returns: <#return value description#>
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
	/// <#Description#>
	///------------------------------------------------------------------------------------------
	func getUserIdentifier() {
		// Look for the Settings Bundle
		let settingsBundle: NSString = Bundle.main.path(forResource: "UserSettings", ofType: "bundle")! as NSString
		if(settingsBundle.contains("")){
			print("Could not find UserSettings.bundle")
			return;
		}
		
		let userDefaults = UserDefaults.standard
		userDefaults.synchronize()
		
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
		
		userDefaults.removeObject(forKey: "userid")
		userDefaults.synchronize()
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - application: <#application description#>
	///   - launchOptions: <#launchOptions description#>
	/// - Returns: <#return value description#>
	///------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter application: <#application description#>
	///------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter application: <#application description#>
	///------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter application: <#application description#>
	///------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter application: <#application description#>
	///------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter application: <#application description#>
	///------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

