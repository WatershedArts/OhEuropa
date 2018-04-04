//
//  OEHTTPController.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class OEHTTPController: NSObject {
	
	///-----------------------------------------------------------------------------
	/// Post the User Id to the Server
	///
	/// - Parameter userid: the users randomely generated id string
	///-----------------------------------------------------------------------------
	public func uploadNewUserId(userid:String) {
		let parameters = [
			"userid": userid,
			"newuser":"1"]
		
		Alamofire.request("http://oheuropa.com/api/userinteraction.php", method: .post, parameters: parameters)
			.responseString { response in
				switch response.result {
				case .failure(let error):
					print("Failed to Upload User ID \(error)")
					break;
				case .success(let data):
					print("Uploaded User ID \(data)")
					break;
				default:
					break;
				}
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Post the User Id to the Server
	///
	/// - Parameter userid: the users randomely generated id string
	///-----------------------------------------------------------------------------
	public func uploadUserInteraction(userid:String,placeid:String,zoneid:String,action:String) {
		let parameters = [
			"newevent":"1",
			"userid":userid,
			"placeid":placeid,
			"zoneid":zoneid,
			"action":action]
		
		Alamofire.request("http://oheuropa.com/api/userinteraction.php", method: .post, parameters: parameters)
			.responseString { response in
				switch response.result {
				case .failure(let error):
					print("Failed to Upload User Interaction \(error)")
					break;
				case .success(let data):
					print("Uploaded User Interaction \(data)")
					break;
				default:
					break;
				}
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Get Radio Track
	///
	/// - Returns: returns the current radio track
	///-----------------------------------------------------------------------------
	public func getCurrentRadioTrack(_ completion: @escaping (String) -> Void) {
		var returnValue = "No Track Found - Error"
		Alamofire.request("https://public.radio.co/stations/s02776f249/status", method: .get)
			.responseJSON { response in
				switch response.result {
					case .failure(let error):
						print("Failed to Get Radio Song \(error)")
						completion(returnValue)
						break;
					case .success(let data):
						if let data = response.result.value {
							let json = JSON(data)
							returnValue = json["current_track"]["title"].string!
							completion(returnValue)
						}
						
						break;
					default:
						break;
				}
		}
	}
}
