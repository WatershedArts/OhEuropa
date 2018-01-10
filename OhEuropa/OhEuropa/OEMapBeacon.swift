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

class OEMapBeacon {
	var userInsideBeacon: Bool = false
	var userInsideInnerBeaconPerimeter: Bool = false
	var userInsideOuterBeaconPerimeter: Bool = false
	
	var centerCoordinate = CLLocationCoordinate2D()
	var radius:Double = 0
	var datecreated: String!
	var name: String!
	var nearbys:Int!
	var placeid:String!
	var radioplays:Int!
	var zonenumber:Int!
	var heading:Double = 0.0
	var distanceFromUser: Double = 1000.0
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - centerCoordinate: <#centerCoordinate description#>
	///   - radius: <#radius description#>
	///   - datecreated: <#datecreated description#>
	///   - name: <#name description#>
	///   - nearbys: <#nearbys description#>
	///   - placeid: <#placeid description#>
	///   - radioplays: <#radioplays description#>
	///   - zonenumber: <#zonenumber description#>
	///------------------------------------------------------------------------------------------
	init(centerCoordinate: CLLocationCoordinate2D, radius: Double, datecreated: String, name: String, nearbys: Int, placeid: String, radioplays: Int, zonenumber: Int) {
		
		self.centerCoordinate = centerCoordinate
		self.radius = Double(radius)
		self.datecreated = datecreated
		self.name = name
		self.nearbys = Int(nearbys)
		self.placeid = placeid
		self.radioplays = Int(radioplays)
		self.zonenumber = Int(zonenumber)
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter coord: <#coord description#>
	/// - Returns: <#return value description#>
	///------------------------------------------------------------------------------------------
	private func computeDistance(coord: CLLocationCoordinate2D) -> Double {
		let userLat: Double = coord.latitude
		let userLng: Double = coord.longitude
		let thisLat: Double = centerCoordinate.latitude
		let thisLng: Double = centerCoordinate.longitude
		
		let deltaP = (thisLat.toRadians() - userLat.toRadians())
		let deltaL = (thisLng.toRadians() - userLng.toRadians())
		
		let a = sin(deltaP/2) * sin(deltaP/2) + cos(userLat.toRadians()) * cos(thisLat.toRadians()) * sin(deltaL/2) * sin(deltaL/2)
		let c = 2 * atan2(sqrt(a), sqrt(1-a))
		let d = EarthRadius * c
		
		return d
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter userlocation: <#userlocation description#>
	///------------------------------------------------------------------------------------------
	func checkBeaconDistance(userlocation: CLLocationCoordinate2D!) {
		distanceFromUser = computeDistance(coord: userlocation)
		
		// Beacon
		if !userInsideBeacon && distanceFromUser < (radius / 1000)  {
			let info = [
				"placeid": self.placeid,
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.EnteredBeacon, object: nil, userInfo: info)
			userInsideBeacon = true
		}
		else if userInsideBeacon && distanceFromUser > (radius / 1000) {
			
			let info = [
				"placeid": self.placeid,
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.ExitedBeacon, object: nil, userInfo: info)
			userInsideBeacon = false
		}
		
		///-----------------------------------------------
		// Inner Perimeter
		///-----------------------------------------------
		if !userInsideInnerBeaconPerimeter && distanceFromUser < ((radius*2) / 1000)  {
			let info = [
				"placeid": self.placeid + "P",
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.EnteredBeaconInnerPerimeter, object: nil, userInfo: info)
			userInsideInnerBeaconPerimeter = true
		}
		else if userInsideInnerBeaconPerimeter && distanceFromUser > ((radius*2) / 1000) {
			
			let info = [
				"placeid": self.placeid + "P",
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.ExitedBeaconInnerPerimeter, object: nil, userInfo: info)
			userInsideInnerBeaconPerimeter = false
		}
		
		///-----------------------------------------------
		// Outer Perimeter
		///-----------------------------------------------
		if !userInsideOuterBeaconPerimeter && distanceFromUser < ((radius*3) / 1000)  {
			let info = [
				"placeid": self.placeid + "P",
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.EnteredBeaconOuterPerimeter, object: nil, userInfo: info)
			userInsideOuterBeaconPerimeter = true
		}
		else if userInsideOuterBeaconPerimeter && distanceFromUser > ((radius*3) / 1000) {
			
			let info = [
				"placeid": self.placeid + "P",
				"name": self.name
			]
			NotificationCenter.default.post(name: Notification.Name.ExitedBeaconOuterPerimeter, object: nil, userInfo: info)
			userInsideOuterBeaconPerimeter = false
		}
		
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter angle: <#angle description#>
	///------------------------------------------------------------------------------------------
	func setHeading(angle:Double) {
		heading = angle
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Returns: <#return value description#>
	///------------------------------------------------------------------------------------------
	func getHeading() -> Double {
		return heading
	}
	
}