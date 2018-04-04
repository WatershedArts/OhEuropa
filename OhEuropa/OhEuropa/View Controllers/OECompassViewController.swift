//
//  OECompassViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import CoreLocation
import FontAwesome_swift
import ProcessingKit
import TweenKit
import Reachability
import MediaPlayer

class OECompassViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var compassView: OECompass!
	@IBOutlet weak var nearestMarkerDistanceLabel: UILabel!

	@IBOutlet weak var TitleOfSong: UILabel!
	@IBOutlet weak var PerformersNames: UILabel!
	
	var locationManager = CLLocationManager()
	var beacons = [OEMapBeacon]()
	let audioManager = OEAudioController()
	var trackTimer: Timer!
	let scheduler = ActionScheduler()
	var showVolumeAlert = true
	let reachability = Reachability()!

	var getBeaconsTimer = Timer()
	
	var labelColorChanges = [(UIColor.black,UIColor.black,UIColor.clear),(UIColor.clear,UIColor.clear,UIColor.black)]
	
	///-----------------------------------------------------------------------------
	/// Setup View Controller
	///-----------------------------------------------------------------------------
	func setup() {
		
		// Get the Beacons from the Server / Local Hosts
		
		let dev = [String]()
		
		OEGetBeacons(dev,completion:parseBeacons)
		
//		// Check if we have New Beacons
//		getBeaconsTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getNewBeacons), userInfo: nil, repeats: true)
		
		// As it sounds
		enableLocationServices()
		
		// Setup the Timer for getting the track name
		trackTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(getTrackName), userInfo: nil, repeats: true)
		
		// Setup Notifications
		// Center of the Beacon
		NotificationCenter.default.addObserver(self, selector: #selector(beaconEntered(_:)), name: NSNotification.Name.EnteredBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(beaconExited(_:)), name: NSNotification.Name.ExitedBeacon, object: nil)
		
		// Inner Area of the Beacon
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconInnerPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconInnerPerimeter, object: nil)
		
		// Outer Area of the Beacon
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconOuterPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconOuterPerimeter, object: nil)
	}
	
	///-----------------------------------------------------------------------------
	/// Get New Beacons that might exist on the Server
	///-----------------------------------------------------------------------------
	@objc func getNewBeacons() {
		print("Checking if New Beacons Available")
		
		var listOfBeaconIds = [String]()
		
		for beacon in self.beacons {
			listOfBeaconIds.append(beacon.beaconData.placeid)
		}
		
		OEGetBeacons(listOfBeaconIds, completion: parseBeacons)
	}
	
	///-----------------------------------------------------------------------------
	/// Parse the Beacons
	///
	/// - Parameter com: the returning value from the async call
	///-----------------------------------------------------------------------------
	func parseBeacons(com:[OEMapBeacon]!) {
		beacons = com
		
		// When we launch the application we want to send the beacons in to the second view
		// This is a dirty way of doing that
		let dvc = tabBarController?.viewControllers![1] as! OEMapViewController
		dvc.beacons = beacons
	}
	
	///-----------------------------------------------------------------------------
	/// Enable the Location Services
	///-----------------------------------------------------------------------------
	func enableLocationServices() {
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
			locationManager.headingFilter = 1
		}
		else {
			// If we dont have permissions display this error
			let alert = UIAlertController(title: "Warning!", message: "Location Services are Currently Inactive. Please go to Settings and Enable." , preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Should we show the compass calibration message
	///
	/// - Parameter manager: Location Manager Delegate
	/// - Returns: boolean
	///-----------------------------------------------------------------------------
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
	///-----------------------------------------------------------------------------
	/// Update the Current Location
	///
	/// - Parameters:
	///   - manager: Location Manager Delegate
	///   - locations: Current Location
	///-----------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		// Get the users location
		let userLocation:CLLocation = locations[0] as CLLocation
		
		// Check the Distance from the Beacon
		for beacon in beacons {
			beacon.checkBeaconDistance(userlocation: userLocation.coordinate)
		}
		
		// Sort the Beacons in Ascending Order
		self.beacons.sort { return $0.distanceFromUser < $1.distanceFromUser }
		
		// Show us the Nearest Marker in terms of distance
		if beacons.count > 0 {
			self.nearestMarkerDistanceLabel.text = String(format: "%.0f metres",((beacons.first?.distanceFromUser)! * 1000))
		}
		
		// Update the Compass View
		for (index, beacon) in beacons.enumerated() {
			let newHeading = calculateRelativeHeading(userLocation: userLocation, beacons: beacon.beaconData.centercoordinate)
			// Only send the nearest beacon
			if index == 0 {
				if compassView != nil {
					compassView.setBeaconRotation(beaconAngle: newHeading)
				}
			}
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Update the Heading
	///
	/// - Parameters:
	///   - manager: Location Manager Delegate
	///   - newHeading: Updated heading
	///-----------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		if compassView != nil {
			compassView.setCompassHeading(heading: newHeading.magneticHeading)
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Location Manager Error Delegate
	///
	/// - Parameters:
	///   - manager: Location Manager
	///   - error: Error
	///-----------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error \(error)")
	}
	
	///-----------------------------------------------------------------------------
	/// Calculate Relative Heading for beacon
	///
	/// - Parameters:
	///   - userLocation: Current User Location
	///   - beacons: Beacon Structure
	/// - Returns: Heading relative to north
	///-----------------------------------------------------------------------------
	func calculateRelativeHeading(userLocation: CLLocation!,beacons:CLLocationCoordinate2D!) -> Double {
		
		// Convert Degrees
		let userLocationLat = userLocation.coordinate.latitude.toRadians()
		let userLocationLng = userLocation.coordinate.longitude.toRadians()
		let targetPointLat = beacons.latitude.toRadians()
		let targetPointLng = beacons.longitude.toRadians()
		
		// Difference the Degrees
		let longitudeDiff = targetPointLng - userLocationLng
		
		// Calculate the angle
		let y = sin(longitudeDiff) * cos(targetPointLat)
		let x = cos(userLocationLat) * sin(targetPointLat) - sin(userLocationLat) * cos(targetPointLat) * cos(longitudeDiff)
		var radiansValue = atan2(y, x)
		
		if radiansValue < 0.0 {
			radiansValue += 2 * .pi
		}
		
		return radiansValue
	}
	
	// MARK: Beacon Events.
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func beaconEntered(_ n:Notification) {
	
		let set1 = InterpolationAction(from: labelColorChanges[1].0,
									   to: labelColorChanges[1].2,
									   duration: 1.5,
									   easing: .exponentialInOut) { [unowned self] in self.PerformersNames.textColor = $0 }
		
		let set2 = InterpolationAction(from: labelColorChanges[1].0,
									   to: labelColorChanges[1].2,
									   duration: 1.5,
									   easing: .exponentialInOut) { [unowned self] in self.TitleOfSong.textColor = $0 }
		
		let set3 = InterpolationAction(from: labelColorChanges[0].0,
									   to: labelColorChanges[0].2,
									   duration: 1.5,
									   easing: .exponentialInOut) { [unowned self] in self.nearestMarkerDistanceLabel.textColor = $0 }
		
		let actions = ActionGroup(actions: set1,set2,set3)
		scheduler.run(action: actions)
		
		if compassView != nil {
			compassView.enteredBeaconZone(zonetype: "C")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Beacon: \(placeId) Entered")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "C", action: "Entered")
			}
		}
	
		audioManager.fadeOutStaticAndFadeUpRadio()
	}
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func beaconExited(_ n:Notification) {
		
		let set1 = InterpolationAction(from: labelColorChanges[1].2,
									   to: labelColorChanges[1].0,
									   duration: 1.5,
									   easing: .exponentialIn) { [unowned self] in self.PerformersNames.textColor = $0 }

		let set2 = InterpolationAction(from: labelColorChanges[1].2,
									   to: labelColorChanges[1].0,
									   duration: 1.5,
									   easing: .exponentialIn) { [unowned self] in self.TitleOfSong.textColor = $0 }

		let set3 = InterpolationAction(from: labelColorChanges[0].2,
									   to: labelColorChanges[0].0,
									   duration: 1.5,
									   easing: .exponentialIn) { [unowned self] in self.nearestMarkerDistanceLabel.textColor = $0 }
		
		let actions = ActionGroup(actions: set1,set2,set3)
		scheduler.run(action: actions)
		
		if compassView != nil {
			compassView.exittedBeaconZone(zonetype: "C")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Beacon: \(placeId) Exited")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "C", action: "Exited")
			}
		}
		
		audioManager.fadeOutRadioAndFadeUpStatic()
	}
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func outerBeaconPerimeterEntered(_ n:Notification) {

		if compassView != nil {
			compassView.enteredBeaconZone(zonetype: "O")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Outer Beacon: \(placeId) Perimeter Entered")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "O", action: "Entered")
			}
		}
		audioManager.startPlayingStatic()
	}
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func outerBeaconPerimeterExited(_ n:Notification) {
		
		if compassView != nil {
			compassView.exittedBeaconZone(zonetype: "O")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Outer Beacon: \(placeId) Perimeter Exited")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "O", action: "Exited")
			}
		}
		
		audioManager.stopPlayingStatic()
	}
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func innerBeaconPerimeterEntered(_ n:Notification) {
		
		if compassView != nil {
			compassView.enteredBeaconZone(zonetype: "I")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Inner Beacon: \(placeId) Perimeter Entered")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "I", action: "Entered")
			}
		}
		
		audioManager.crossFadeStaticAndRadio()
	}
	
	///-----------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///-----------------------------------------------------------------------------
	@objc func innerBeaconPerimeterExited(_ n:Notification) {
		
		if compassView != nil {
			compassView.exittedBeaconZone(zonetype: "I")
		}
		
		// Check if we have user info
		if let userInfo = n.userInfo {
			// Safely Unwrap the Value
			if let placeId = userInfo["placeid"] as? String {
				print("Inner Beacon: \(placeId) Perimeter Exited")
				httpController.uploadUserInteraction(userid: USER_ID, placeid: placeId, zoneid: "I", action: "Exited")
			}
		}
		
		audioManager.stopPlayingRadio()
		audioManager.startPlayingStatic()
	}
	
	// MARK: View Events.
	
	///-----------------------------------------------------------------------------
    /// View Did Load
	///-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		
		PerformersNames.textColor = labelColorChanges[1].1
		TitleOfSong.textColor = labelColorChanges[1].1
		nearestMarkerDistanceLabel.textColor = labelColorChanges[0].1
		
		var center = CGPoint(x: (self.view.frame.size.width / 2.0),y: (self.view.frame.size.height / 2.0))
		
		self.view.createCircle(center: CGPoint(x:16,y:150), radius: 10, color: INACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:self.view.frame.size.width-16,y:50), radius: 10, color: INACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:50,y:35), radius: 10, color: INACTIVE_COMPASS_COLOR)
	
		getTrackName()
		
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
			let avsession = AVAudioSession.sharedInstance()
			try? avsession.setActive(true)
			
			let vol = avsession.outputVolume
			print(vol)
			if vol < 0.2 {
				if showVolumeAlert {
					// If we dont have permissions display this error
					let alert = UIAlertController(title: "WARNING!", message: "Your volume is low, for the best experience turn your volume up!" , preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
					present(alert, animated: true, completion: nil)
					showVolumeAlert = false
				}
			}
	}

	///-----------------------------------------------------------------------------
	/// Waited for the Views to properly scale before creating the compass elements
	///-----------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {
		self.view.createGradientBackground()
	}
	
	///-----------------------------------------------------------------------------
	/// Get the track name for the scroll bar
	///-----------------------------------------------------------------------------
	@objc func getTrackName() {
		httpController.getCurrentRadioTrack(self.setScrollBarText)
	}
	
	///-----------------------------------------------------------------------------
	/// Get the track name for the scroll bar
	///-----------------------------------------------------------------------------
	func setScrollBarText(name: String) {
		
		print(name)
		let strippedname = name.replacingOccurrences(of: "\"", with: "");
		let trackInfo = strippedname.components(separatedBy: " - ")
		
		if trackInfo.count >= 1 {
			self.TitleOfSong.text = trackInfo[1] // TODO fix this crash 
			self.PerformersNames.text = trackInfo[0]
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Memory
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
