//
//  OEGetBeacons.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import Sync

class OEGetBeacons  {

	var json: JSON = JSON.null
	
	lazy var dataStack: DataStack = DataStack(modelName: "Beacons")
	var items = [NSManagedObject]()

	///------------------------------------------------------------------------------------------
	/// Get Data From The Server
	///
	///------------------------------------------------------------------------------------------
	func getDataFromRemoteServer() -> [OEMapBeacon] {
		// Empty Container
		var beacons = [OEMapBeacon]()
		
		// Get Request
		Alamofire.request("https://www.davidhaylock.co.uk/oheuropa/getdata.php?getplaces")
			.responseJSON { response in
				
				if response.error != nil || response.response?.statusCode != 200 {
					print("GETLOCATIONS Bad Request")
					if response.error != nil {
						print("GETLOCATIONS: Failed to Get a Response")
						print(response.error?.localizedDescription)
						print(response.error!)
					}
				}
				
				if let data = response.result.value {
					print("GETLOCATIONS: Got Return Data")
					self.json = JSON(data)

					print(self.json)
					// If we get data from the server update the core data for backup incase of connection issues.
					if let newdata = self.json["data"].arrayObject as? [[String:Any]] {
						self.dataStack.sync(newdata, inEntityNamed: "Beacons") { error in
							print("Updating the Core Data Storage")
						}
					}
					
					// Loop throught the return and parse the beacons
					if let locationArray = self.json["data"].array {
						for location in locationArray {
							let loc = OEMapBeacon(
								centercoordinate: CLLocationCoordinate2D(
									latitude: Double(location["lat"].string!)!,
									longitude: Double(location["lng"].string!)!),
								centerradius: Double(location["centerradius"].string!)!,
								innerradius: Double(location["innerradius"].string!)!,
								outerradius: Double(location["outerradius"].string!)!,
								datecreated: location["datecreated"].string!,
								name: location["name"].string!,
								nearbys: Int(location["nearbys"].string!)!,
								placeid: location["placeid"].string!,
								radioplays: Int(location["radioplays"].string!)!)
							beacons.append(loc)
						}
					}
				}
		}
		return beacons
	}
	
	///------------------------------------------------------------------------------------------
	/// Get data from the Core Data Solutions
	///
	///------------------------------------------------------------------------------------------
	private func getBeaconsFromLocalServer() -> [OEMapBeacon] {
		
		// Empty Container
		var beacons = [OEMapBeacon]()
	
		// Request to local
		let request: NSFetchRequest<Beacons> = Beacons.fetchRequest()
		let beaconData = try! self.dataStack.viewContext.fetch(request)

		if beaconData != nil {
			for beacon in beaconData {
				let loc = OEMapBeacon(
							centercoordinate: CLLocationCoordinate2D(
								latitude: beacon.lat,
								longitude: beacon.lng),
							centerradius: beacon.centerradius,
							innerradius: beacon.innerradius,
							outerradius: beacon.outerradius,
							datecreated: beacon.datecreated!,
							name: beacon.name!,
							nearbys: 0,
							placeid: beacon.placeid!,
							radioplays: 1)
						beacons.append(loc)
			}
		}
		return beacons
	}
	

	///------------------------------------------------------------------------------------------
	/// Initializer
	///
	/// - Parameter completion: return values
	///------------------------------------------------------------------------------------------
	init(_ completion: @escaping ([OEMapBeacon]) -> Void) {
		
		// Prioritize data from the Remote Server
		var beacons: [OEMapBeacon] = getDataFromRemoteServer()
		
		if beacons.count > 0 {
			completion(beacons)
		}
		else {
			beacons = getBeaconsFromLocalServer()
		}
		
		completion(beacons)
	}
};
