//
//  OEMapViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import GoogleMaps
import FontAwesome_swift

class OEMapViewController: UIViewController, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()
	var currentLocation = CLLocationCoordinate2D()
	let centerBox = GMSMutablePath()
	var mapView: GMSMapView!
	var beacons = [OEMapBeacon]()
	var camera = GMSCameraPosition.camera(withLatitude: 51.45105, longitude: -2.30456, zoom: 3.5)

	///-----------------------------------------------------------------------------
	/// Load The View
	///-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		
		determineMyCurrentLocation()
		
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
		
		do {
			if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
				mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
			} else {
				print("Whoa There! There is no Style.json")
			}
			
		} catch {
			print("Style Failed")
		}
		
		// Set the main view to be the map view
        self.view = mapView
		
        for beacon in self.beacons {
			let innerCirle = GMSMarker(position: beacon.beaconData.centercoordinate)
			innerCirle.isFlat = true
			innerCirle.icon = UIImage(named: "MarkerIcon")
            innerCirle.map = mapView
        }
    }
	
	///-----------------------------------------------------------------------------
	/// Memory
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	///-----------------------------------------------------------------------------
	/// Request Permission
	///-----------------------------------------------------------------------------
	func determineMyCurrentLocation() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.startUpdatingLocation()
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Have we got an update from the location manager
	///
	/// - Parameters:
	///   - manager: locations manager
	///   - locations: return locations
	///-----------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let userLocation:CLLocation = locations[0] as CLLocation
		currentLocation = userLocation.coordinate
		
		// This will probably go but every time we make a significant
		// move the map view will update with the user
		// more likely to add button to allow users the choice
//		mapView.animate(toLocation: userLocation.coordinate);
	}

	///-----------------------------------------------------------------------------
	/// Have we had an issue with the location manager
	///
	/// - Parameters:
	///   - manager: location manager
	///   - error: whats the error mr wolf
	///-----------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error \(error)")
	}
}
