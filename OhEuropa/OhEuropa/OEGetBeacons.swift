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

class OEGetBeacons  {
	var beacons = [OEMapBeacon]()
	var json: JSON = JSON.null
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter completion: <#completion description#>
	///------------------------------------------------------------------------------------------
	init(_ completion: @escaping ([OEMapBeacon]) -> Void) {
		Alamofire.request("https://www.davidhaylock.co.uk/oheuropa/getdata.php?getplaces")
			.responseJSON { response in
				
				if response.error != nil || response.response?.statusCode != 200 {
					print("GETLOCATIONS Bad Request Line 62")
					if response.error != nil {
						print("GETLOCATIONS: Failed to Get a Response")
						print(response.error?.localizedDescription)
						print(response.error!)
					}
					completion(self.beacons);
				}
				
				if let data = response.result.value {
					print("GETLOCATIONS: Got Return Data")
					self.json = JSON(data)
					print(self.json)
					if let locationArray = self.json["data"].array {
						for location in locationArray {
							let loc = OEMapBeacon(
								centerCoordinate: CLLocationCoordinate2D(
									latitude: Double(location["lat"].string!)!,
									longitude: Double(location["lng"].string!)!),
								radius: Double(location["areasize"].string!)!,
								datecreated: location["datecreated"].string!,
								name: location["name"].string!,
								nearbys: Int(location["nearbys"].string!)!,
								placeid: location["placeid"].string!,
								radioplays: Int(location["radioplays"].string!)!,
								zonenumber: Int(location["zonenumber"].string!)!)
							self.beacons.append(loc)
						}
					}
					completion(self.beacons);
					return
				}
		}
	}
};
