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
import Floaty
import FontAwesome_swift
import ProcessingKit
import MarqueeLabel
import TweenKit

class OECompassViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var compassView: OECompass!
	@IBOutlet weak var nearestMarkerNameLabel: UILabel!
	@IBOutlet weak var nearestMarkerDistanceLabel: UILabel!

	var locationManager = CLLocationManager()
	var beacons = [OEMapBeacon]()
	let audioManager = OEAudioController()
	var trackTimer: Timer!
	var scrollingLabel: MarqueeLabel!
	let scheduler = ActionScheduler()
	
	var gradientLayer: CAGradientLayer!
	

	///-----------------------------------------------------------------------------
	/// Create the Gradient for the Background
	///-----------------------------------------------------------------------------
	func createGradientForBackground() {
		gradientLayer = CAGradientLayer()
		gradientLayer.colors = [GRADIENT_COLOR_TOP.cgColor,GRADIENT_COLOR_BOTTOM.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		gradientLayer.frame = self.view.frame
		self.view.layer.insertSublayer(gradientLayer,at: 0)
	}
	
	///-----------------------------------------------------------------------------
	/// Setup View Controller
	///-----------------------------------------------------------------------------
	func setup() {
		
		OEGetBeacons(parseBeacons)
		
		enableLocationServices()
//		getTrackName()
		
		trackTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getTrackName), userInfo: nil, repeats: true)
		
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
	/// Parse the Beacons
	///
	/// - Parameter com: the returning value from the async call
	///-----------------------------------------------------------------------------
	func parseBeacons(com:[OEMapBeacon]!) {
		print("Got Beacons")
		beacons = com
		let dvc = tabBarController?.viewControllers![1] as! OEMapViewController
		dvc.beacons = beacons
	}
	
	///-----------------------------------------------------------------------------
//	/// Timer Return Function
//	///-----------------------------------------------------------------------------
//	@objc func getTrackName(com:String!) {
//		print("Get Track Name")
//	}
	
	///-----------------------------------------------------------------------------
	/// Enable the Location Services
	///-----------------------------------------------------------------------------
	func enableLocationServices() {
		print("Enabling Location Services")
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			print("Location Services Enabled")
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
			locationManager.headingFilter = 2
		}
		else {
			print("Location Services Disabled")
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
		let userLocation:CLLocation = locations[0] as CLLocation
		
		// Check the Distance from the Beacon
		for beacon in beacons {
			beacon.checkBeaconDistance(userlocation: userLocation.coordinate)
		}
		
		// Sort the Beacons in Ascending Order
		self.beacons.sort { return $0.distanceFromUser < $1.distanceFromUser }
		
		// Show us the Nearest Marker in terms of distance
		if beacons.count > 0 {
			self.nearestMarkerDistanceLabel.text = String(format: "%.0f meters",((beacons.first?.distanceFromUser)! * 1000))
		}
		
		// Update the Compass View
		for (index, beacon) in beacons.enumerated() {
			let newHeading = calculateRelativeHeading(userLocation: userLocation, beacons: beacon.beaconData.centercoordinate)
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
		
		let userLocationLat = userLocation.coordinate.latitude.toRadians()
		let userLocationLng = userLocation.coordinate.longitude.toRadians()
		let targetPointLat = beacons.latitude.toRadians()
		let targetPointLng = beacons.longitude.toRadians()
		
		let longitudeDiff = targetPointLng - userLocationLng
		
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
	
		let move = InterpolationAction(from: UIColor.clear, to: UIColor.black, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.scrollingLabel.textColor = $0 }
		scheduler.run(action: move)
		
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
		
		let move = InterpolationAction(from: UIColor.black, to: UIColor.clear, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.scrollingLabel.textColor = $0 }
		scheduler.run(action: move)
		
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
		
		
    }

	///-----------------------------------------------------------------------------
	/// Waited for the Views to properly scale before creating the compass elements
	///-----------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {
		
		scrollingLabel = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50),duration:8.0,fadeLength:10.0)
		scrollingLabel.backgroundColor = UIColor.clear
		scrollingLabel.textColor = UIColor.clear
		scrollingLabel.font = UIFont.systemFont(ofSize: 20)
		scrollingLabel.animationDelay = 1.0
		scrollingLabel.textAlignment = .left
		scrollingLabel.fadeLength = 15
		scrollingLabel.type = .left
		scrollingLabel.text = ""
		self.view.addSubview(scrollingLabel)
		createGradientForBackground()
		getTrackName()
	}
	
	///-----------------------------------------------------------------------------
	/// Get the track name for the scroll bar
	///-----------------------------------------------------------------------------
	@objc func getTrackName() {
		httpController.getCurrentRadioTrack(setScrollBarText)
	}
	
	///-----------------------------------------------------------------------------
	/// Get the track name for the scroll bar
	///-----------------------------------------------------------------------------
	func setScrollBarText(name: String) {
		print("Setting Scrollbar to \(name)")
		self.scrollingLabel.resetLabel()
		self.scrollingLabel.text = name
	}
	
	///-----------------------------------------------------------------------------
	/// View Did Load
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }	
	
	///-----------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - segue: <#segue description#>
	///   - sender: <#sender description#>
	///-----------------------------------------------------------------------------
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if segue.identifier == "showMap" {
//			let destinationVC = segue.destination as! OEMapViewController
//			destinationVC.beacons = self.beacons
////			print("Sending You Some Data \(self.beacons)")
//		}
//        else if segue.identifier == "showInformation" {
//            let destinationVC = segue.destination as! OEInformationViewController
//        }
	}
}
