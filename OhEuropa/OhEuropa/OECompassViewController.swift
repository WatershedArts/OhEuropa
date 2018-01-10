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
	
	var timer:Timer?
	var change:CGFloat = 0.01
	
	var wave:SwiftSiriWaveformView!

	@objc func refreshAudioView() {
		if self.wave.amplitude <= self.wave.idleAmplitude || self.wave.amplitude > 1.0 {
			self.change *= -1.0
		}
		
		// Simply set the amplitude to whatever you need and the view will update itself.
		self.wave.amplitude += self.change
	}
	
	///------------------------------------------------------------------------------------------
	/// Setup View Controller
	///------------------------------------------------------------------------------------------
	func setup() {
		
//		wave = SwiftSiriWaveformView(frame: CGRect(x: 0, y: 0, width: compassView.frame.width, height: compassView.frame.height))
//		wave.backgroundColor = UIColor.clear
//		wave.waveColor = UIColor.black
//		wave.primaryLineWidth = 2
//		wave.numberOfWaves = 1
//		wave.amplitude = 0.25
//		wave.frequency = 10
//
//
//
//
//		self.view.addSubview(wave)
//
//		self.wave.density = 1.0
//
//		timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(refreshAudioView), userInfo: nil, repeats: true)
		
		OEGetBeacons(parseBeacons)
		
		NotificationCenter.default.addObserver(self, selector: #selector(beaconEntered(_:)), name: NSNotification.Name.EnteredBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(beaconExited(_:)), name: NSNotification.Name.ExitedBeacon, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconInnerPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconInnerPerimeter, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconOuterPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconOuterPerimeter, object: nil)
		
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
			self.nearestMarkerDistanceLabel.text = String(format: "%.3f meters",((beacons.first?.distanceFromUser)! * 1000))
			
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
	@objc func beaconEntered(_ n:Notification) {
		print("Beacon Entered")
		print(n.userInfo!)
		audioManager.startPlayingRadio()
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func beaconExited(_ n:Notification) {
		print("Beacon Exited")
		print(n.userInfo!)
		audioManager.stopPlayingRadio()
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func outerBeaconPerimeterEntered(_ n:Notification) {
		print("Outer Beacon Perimeter Entered")
		print(n.userInfo!)
		audioManager.startPlayingStatic()
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func outerBeaconPerimeterExited(_ n:Notification) {
		print("Outer Beacon Perimeter Exited")
		print(n.userInfo!)
		audioManager.stopPlayingStatic()
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func innerBeaconPerimeterEntered(_ n:Notification) {
		print("Inner Beacon Perimeter Entered")
		print(n.userInfo!)
		audioManager.crossFadeStaticAndRadio()
	}
	
	///------------------------------------------------------------------------------------------
	/// Event Observer from the Beacons
	///
	/// - Parameter n: <#n description#>
	///------------------------------------------------------------------------------------------
	@objc func innerBeaconPerimeterExited(_ n:Notification) {
		print("Inner Beacon Perimeter Exited")
		print(n.userInfo!)
		audioManager.stopPlayingRadio()
		audioManager.startPlayingStatic()
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMap" {
			let destinationVC = segue.destination as! OEMapViewController
			destinationVC.beacons = self.beacons
			print("Sending You Some Data")
		}
        else if segue.identifier == "showInformation" {
            let destinationVC = segue.destination as! OEInformationViewController
        }
	}
}
