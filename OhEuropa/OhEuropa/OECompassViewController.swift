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


class OECompassViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var compassView: OECompass!
	@IBOutlet weak var nearestMarkerNameLabel: UILabel!
	@IBOutlet weak var nearestMarkerDistanceLabel: UILabel!

	
	
	var locationManager = CLLocationManager()
	var beacons = [OEMapBeacon]()
	let audioManager = OEAudioController()
	
//	let httpManager = OEHTTPController()
	
	
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
		
		
		
		OEGetBeacons(parseBeacons)
		
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(beaconEntered(_:)), name: NSNotification.Name.EnteredBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(beaconExited(_:)), name: NSNotification.Name.ExitedBeacon, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconInnerPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(innerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconInnerPerimeter, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterEntered(_:)), name: NSNotification.Name.EnteredBeaconOuterPerimeter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(outerBeaconPerimeterExited(_:)), name: NSNotification.Name.ExitedBeaconOuterPerimeter, object: nil)
		
		enableLocationServices()
        
        
        let floaty = Floaty()
        
        floaty.size = 40
        floaty.itemSize = 40
        floaty.plusColor = DEFAULT_COLOR_OPPOSED
        floaty.buttonColor = DEFAULT_COLOR

        let info  = FloatyItem()
        info.buttonColor = DEFAULT_COLOR
        info.icon = UIImage.fontAwesomeIcon(name: .infoCircle, textColor: DEFAULT_COLOR_OPPOSED, size: CGSize(width: 60, height: 60), backgroundColor: UIColor.clear)
        info.handler = { item in
            self.performSegue(withIdentifier: "showInfomation", sender: self)
        }
        floaty.addItem(item: info)
        
        let map  = FloatyItem()
        map.buttonColor = DEFAULT_COLOR
        map.icon = UIImage.fontAwesomeIcon(name: .globe, textColor: DEFAULT_COLOR_OPPOSED, size: CGSize(width: 60, height: 60), backgroundColor: UIColor.clear)
        map.handler = { item in
            self.performSegue(withIdentifier: "showMap", sender: self)
        }
        floaty.addItem(item: map)

        floaty.openAnimationType = .pop
        self.view.addSubview(floaty)
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
		
		let compassView = self.compassView as OECompass
		compassView.insideBeaconZone(zonetype: "O")
		
		
//		httpManager.uploadUserInteraction(userid: USER_ID, placeid: , zoneid: <#T##String#>, action: <#T##String#>)
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
