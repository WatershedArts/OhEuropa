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
	let centerBox = GMSMutablePath()
	var mapView: GMSMapView!
	var beacons = [OEMapBeacon]()
	
//	@IBOutlet weak var backButton: UIButton!
	
//	override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//
//    }
	
	///------------------------------------------------------------------------------------------
	/// Load The View
	///------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 51.4545404, longitude: -2.6081, zoom: 14)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
		
        self.view = mapView
	
        for beacon in beacons {
            
            print(beacon.name)
            
            // This is for Debug purposes only
            let outerCircle = GMSCircle(position: beacon.centerCoordinate, radius: CLLocationDistance(beacon.radius*3))
            outerCircle.title = beacon.name
            outerCircle.strokeColor = UIColor.red
            outerCircle.fillColor = UIColor.red
            outerCircle.isTappable = true
            outerCircle.map = mapView
            
            let midCircle = GMSCircle(position: beacon.centerCoordinate, radius: CLLocationDistance(beacon.radius*2))
            midCircle.title = beacon.name
            midCircle.strokeColor = UIColor.orange
            midCircle.fillColor = UIColor.orange
            midCircle.isTappable = true
            midCircle.map = mapView
            
            let innerCirle = GMSCircle(position: beacon.centerCoordinate, radius: CLLocationDistance(beacon.radius))
            innerCirle.title = beacon.name
            innerCirle.strokeColor = UIColor.green
            innerCirle.fillColor = UIColor.green
            innerCirle.isTappable = true
            innerCirle.map = mapView
        }
		
		determineMyCurrentLocation()
	
    }

	override func viewDidLayoutSubviews() {
		print(self.view.bounds)
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
