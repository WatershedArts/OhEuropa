//
//  OEMapBeacon.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import CoreLocation

let EarthRadius = 6371.0 // Km

struct OEMapBeaconModel {
	var centercoordinate = CLLocationCoordinate2D()
	var centerradius:Double = 0
	var innerradius:Double = 0
	var outerradius:Double = 0
	var datecreated: String!
	var name: String!
	var nearbys:Int!
	var placeid:String!
	var radioplays:Int!
	var zonenumber:Int!
}

class OEMapBeacon {
	var userInsideBeacon: Bool = false
	var userInsideInnerBeaconPerimeter: Bool = false
	var userInsideOuterBeaconPerimeter: Bool = false
	var heading:Double = 0.0
	var distanceFromUser: Double = 1000.0
	
	var beaconData = OEMapBeaconModel()
	
	///-----------------------------------------------------------------------------
	/// Create New Beacon
	///
	/// - Parameters:
	///   - centercoordinate: the central point of the beacon
	///   - centerradius: how big the central ring is
	///   - innerradius: how big the inner ring is
	///   - outerradius: how big the outer ring is
	///   - datecreated: when the beacon was made
	///   - name: the beacons name
	///   - nearbys: how many times someone has been near the beacon
	///   - placeid: the place id
	///   - radioplays: how many times the radio has been played in this particular zone
	///-----------------------------------------------------------------------------
	init(centercoordinate: CLLocationCoordinate2D, centerradius: Double, innerradius: Double, outerradius: Double, datecreated: String, name: String, nearbys: Int, placeid: String, radioplays: Int) {
		
		beaconData.centercoordinate = centercoordinate
		beaconData.centerradius = Double(centerradius)
		beaconData.innerradius = Double(innerradius)
		beaconData.outerradius = Double(outerradius)
		beaconData.datecreated = datecreated
		beaconData.name = name
		beaconData.nearbys = Int(nearbys)
		beaconData.placeid = placeid
		beaconData.radioplays = Int(radioplays)
	}
	
	///-----------------------------------------------------------------------------
	/// Check the Distance from the Beacon to the Users Location
	/// This will be as the crow flies distance
	///
	/// - Parameter coord: Users Location
	/// - Returns: Distance in Meters
	///-----------------------------------------------------------------------------
	private func computeDistance(coord: CLLocationCoordinate2D) -> Double {
		let userLat: Double = coord.latitude
		let userLng: Double = coord.longitude
		let thisLat: Double = beaconData.centercoordinate.latitude
		let thisLng: Double = beaconData.centercoordinate.longitude
		
		let deltaP = (thisLat.toRadians() - userLat.toRadians())
		let deltaL = (thisLng.toRadians() - userLng.toRadians())
		
		let a = sin(deltaP/2) * sin(deltaP/2) + cos(userLat.toRadians()) * cos(thisLat.toRadians()) * sin(deltaL/2) * sin(deltaL/2)
		let c = 2 * atan2(sqrt(a), sqrt(1-a))
		let d = EarthRadius * c
		
		return d
	}
	
	///-----------------------------------------------------------------------------
	/// Check to see if the User has entered any of the Zones
	///
	/// - Parameter userlocation: users location
	///-----------------------------------------------------------------------------
	func checkBeaconDistance(userlocation: CLLocationCoordinate2D!) {
		distanceFromUser = computeDistance(coord: userlocation)
		
		let info = [
			"placeid": self.beaconData.placeid,
			"name": self.beaconData.name
		]
		
		// Beacon
		if !userInsideBeacon && distanceFromUser < (beaconData.centerradius / 1000)  {
			NotificationCenter.default.post(name: Notification.Name.EnteredBeacon, object: nil, userInfo: info)
			userInsideBeacon = true
		}
		else if userInsideBeacon && distanceFromUser > (beaconData.centerradius / 1000) {
			NotificationCenter.default.post(name: Notification.Name.ExitedBeacon, object: nil, userInfo: info)
			userInsideBeacon = false
		}
		
		///-----------------------------------------------
		// Inner Perimeter
		///-----------------------------------------------
		if !userInsideInnerBeaconPerimeter && distanceFromUser < ((beaconData.innerradius) / 1000)  {
			NotificationCenter.default.post(name: Notification.Name.EnteredBeaconInnerPerimeter, object: nil, userInfo: info)
			userInsideInnerBeaconPerimeter = true
		}
		else if userInsideInnerBeaconPerimeter && distanceFromUser > ((beaconData.innerradius) / 1000) {
			NotificationCenter.default.post(name: Notification.Name.ExitedBeaconInnerPerimeter, object: nil, userInfo: info)
			userInsideInnerBeaconPerimeter = false
		}
		
		///-----------------------------------------------
		// Outer Perimeter
		///-----------------------------------------------
		if !userInsideOuterBeaconPerimeter && distanceFromUser < ((beaconData.outerradius) / 1000)  {
			NotificationCenter.default.post(name: Notification.Name.EnteredBeaconOuterPerimeter, object: nil, userInfo: info)
			userInsideOuterBeaconPerimeter = true
		}
		else if userInsideOuterBeaconPerimeter && distanceFromUser > ((beaconData.outerradius) / 1000) {
			NotificationCenter.default.post(name: Notification.Name.ExitedBeaconOuterPerimeter, object: nil, userInfo: info)
			userInsideOuterBeaconPerimeter = false
		}
	}
	
	///-----------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter angle: <#angle description#>
	///-----------------------------------------------------------------------------
	func setHeading(angle:Double) {
		heading = angle
	}
	
	///-----------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Returns: <#return value description#>
	///-----------------------------------------------------------------------------
	func getHeading() -> Double {
		return heading
	}
	
}
