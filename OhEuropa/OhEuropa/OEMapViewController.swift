//
//  OEMapViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import GoogleMaps

class OEMapViewController: UIViewController, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()
	let centerBox = GMSMutablePath()
	var mapView: GMSMapView!
	var beacons = [OEMapBeacon]()
	
	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
	override func loadView() {
		determineMyCurrentLocation()
		
		let camera = GMSCameraPosition.camera(withLatitude: 51.4545404, longitude: -2.6081, zoom: 14)
		mapView = GMSMapView.map(withFrame: .zero, camera: camera)
		mapView.isMyLocationEnabled = true
		self.view = mapView
		var a = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		a.setTitle("Back", for: UIControlState.normal)
		a.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
		
		self.view.addSubview(a)
	}
	
	@objc func dismissViewController() {
		print("Dismissing Popover")
		self.dismiss(animated: true, completion: nil)
	}

	///------------------------------------------------------------------------------------------
	/// Request Permission
	///------------------------------------------------------------------------------------------
	func determineMyCurrentLocation() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.startUpdatingLocation()
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - manager: <#manager description#>
	///   - locations: <#locations description#>
	///------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let userLocation:CLLocation = locations[0] as CLLocation
		//        for beacon in beacons {
		//            beacon.checkIsUserInBeaconZone(userlocation: userLocation.coordinate)
		//        }
	}

	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - manager: <#manager description#>
	///   - error: <#error description#>
	///------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error \(error)")
	}
	
}
