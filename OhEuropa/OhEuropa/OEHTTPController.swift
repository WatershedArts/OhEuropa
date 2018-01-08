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
	
	///------------------------------------------------------------------------------------------
	/// Post the User Id to the Server
	///
	/// - Parameter userid: the users randomely generated id string
	///------------------------------------------------------------------------------------------
	public func uploadNewUserId(userid:String) {
		let parameters = [
			"userid": userid,
			"newuser":"1"]
		
		Alamofire.request("https://www.davidhaylock.co.uk/oheuropa/userinteraction.php", method: .post, parameters: parameters)
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
	
	///------------------------------------------------------------------------------------------
	/// Post the User Id to the Server
	///
	/// - Parameter userid: the users randomely generated id string
	///------------------------------------------------------------------------------------------
	public func uploadUserInteraction(userid:String,placeid:String,zoneid:String,action:String) {
		let parameters = [
			"newevent":"1",
			"userid":userid,
			"placeid":placeid,
			"zoneid":zoneid,
			"action":action]
		
		Alamofire.request("https://www.davidhaylock.co.uk/oheuropa/userinteraction.php", method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
	
	///------------------------------------------------------------------------------------------
	/// Get Radio Track
	///
	/// - Returns: returns the current radio track
	///------------------------------------------------------------------------------------------
	public func getCurrentRadioTrack() -> String {
		var returnValue = ""
		Alamofire.request("https://public.radio.co/stations/s02776f249/status", method: .get)
			.responseJSON { response in
				switch response.result {
					case .failure(let error):
						print("Failed to Get Radio Song \(error)")
						break;
					case .success(let data):
						print("Got Radio Track \(data)")
						
						if let data = response.result.value {
							var json = JSON(data)
							print(json)
						}
						returnValue = "Hey"
						break;
					default:
						break;
				}
		}
		return returnValue
	}
	
}
