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

	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
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
            innerCirle.title = beacon.beaconData.name
			innerCirle.isFlat = true
			innerCirle.icon = UIImage(named: "OhEuropaMarker.png")
            innerCirle.map = mapView
        }
    }
	
	///------------------------------------------------------------------------------------------
	/// View Did Layout Subviews
	///------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {
		let backButton = UIButton(frame: CGRect(x: self.view.bounds.width-(14+40), y: self.view.bounds.height-(14+40), width: 40, height: 40))
		backButton.setImage(UIImage.fontAwesomeIcon(name: .compass, textColor: DEFAULT_COLOR_OPPOSED, size: CGSize(width: 25, height: 25), backgroundColor: UIColor.clear), for: UIControlState.normal)
		
		backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
		backButton.layer.cornerRadius = 0.5 * backButton.bounds.size.width
		backButton.backgroundColor = DEFAULT_COLOR
		self.view.addSubview(backButton)
	}
	
	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    ///------------------------------------------------------------------------------------------
    /// Dismiss the View Controller
    ///------------------------------------------------------------------------------------------
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
		currentLocation = userLocation.coordinate
		
		mapView.animate(toLocation: userLocation.coordinate);
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
