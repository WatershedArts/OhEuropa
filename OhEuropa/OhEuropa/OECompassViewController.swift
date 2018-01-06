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

class OECompassViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var compassView: OECompass!
	@IBOutlet weak var nearestMarkerNameLabel: UILabel!
	@IBOutlet weak var nearestMarkerDistanceLabel: UILabel!

	var locationManager = CLLocationManager()
	var beacons = [OEMapBeacon]()
	let audioManager = OEAudioController()
	
	///------------------------------------------------------------------------------------------
	/// Setup View Controller
	///------------------------------------------------------------------------------------------
	func setup() {
		
		
		OEGetBeacons(parseBeacons)
		
		NotificationCenter.default.addObserver(self, selector: #selector(zoneEntered(_:)), name: NSNotification.Name.EnteredBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(zoneExited(_:)), name: NSNotification.Name.ExitedBeacon, object: nil)
		
		enableLocationServices()
		
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter com: <#com description#>
	///------------------------------------------------------------------------------------------
	func parseBeacons(com:[OEMapBeacon]!) {
		print("Got Beacons")
		beacons = com
	}
	
	///------------------------------------------------------------------------------------------
	/// Enable the Location Services
	///------------------------------------------------------------------------------------------
	func enableLocationServices() {
		print("Enabling Location Services")
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			print("Location Services Enabled")
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
		}
		else {
			print("Location Services Disabled")
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter manager: <#manager description#>
	/// - Returns: <#return value description#>
	///------------------------------------------------------------------------------------------
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
	///------------------------------------------------------------------------------------------
	/// Update the Current Location
	///
	/// - Parameters:
	///   - manager: Location Manager Delegate
	///   - locations: Current Location
	///------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let compassView = self.compassView as OECompass
		let userLocation:CLLocation = locations[0] as CLLocation
		
		for beacon in beacons {
			beacon.checkBeaconDistance(userlocation: userLocation.coordinate)
		}
		
		self.beacons.sort { return $0.distanceFromUser < $1.distanceFromUser }
		
		if beacons.count > 0 {
			self.nearestMarkerNameLabel.text = beacons.first?.name
			self.nearestMarkerDistanceLabel.text = String(format: "%.3f km",(beacons.first?.distanceFromUser)!)
			
		}
		
		for (index, beacon) in beacons.enumerated() {
			let newHeading = calculateRelativeHeading(userLocation: userLocation, beacons: beacon.centerCoordinate)
			compassView.setBeaconRotation(index: index, angle: newHeading)
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// Update the Heading
	///
	/// - Parameters:
	///   - manager: Location Manager Delegate
	///   - newHeading: Updated heading
	///------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//		headingindicator.text = "\(newHeading.magneticHeading)"
		let compassView = self.compassView as OECompass
		compassView.setCompassHeading(heading: newHeading.magneticHeading)
	}
	
	///------------------------------------------------------------------------------------------
	/// Location Manager Error Delegate
	///
	/// - Parameters:
	///   - manager: Location Manager
	///   - error: Error
	///------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error \(error)")
	}
	
	///------------------------------------------------------------------------------------------
	/// Calculate Relative Heading for beacon
	///
	/// - Parameters:
	///   - userLocation: Current User Location
	///   - beacons: Beacon Structure
	/// - Returns: Heading relative to north
	///------------------------------------------------------------------------------------------
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
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func zoneEntered(_ n:Notification) {
		//		let t = CompassView as! Compass
		print("Zone Entered")
		print(n.userInfo!)
		audioManager.startPlayingRadio()
		//		t.insideBeaconZone(zonetype: "O")
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func zoneExited(_ n:Notification) {
		print("Zone Exited")
		print(n.userInfo!)
		audioManager.stopPlayingRadio()
	}
	
	///------------------------------------------------------------------------------------------
    /// View Did Load
	///------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		
    }

	///------------------------------------------------------------------------------------------
	/// View Did Load
	///------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
