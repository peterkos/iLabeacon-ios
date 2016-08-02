//
//  NetworkManager.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/4/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation
import Alamofire
import Sync
import SwiftyJSON


class NetworkManager {
	
	let requestURLString = "http://jacobzipper.com/ilabeacon/list.php"
	let postURLString = "http://jacobzipper.com/ilabeacon/index.php"
	var manager: Manager?
	
	init() {
		
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		manager = Alamofire.Manager(configuration: configuration)
		
	}
	
	func getJSON(completionHandler: (result: AnyObject?, error: NSError?) -> ()) {
		
		Alamofire.request(.GET, requestURLString).validate().responseJSON { response in
			switch response.result {
				case .Success(let value):
					completionHandler(result: value, error: nil)
				case .Failure(let error):
					completionHandler(result: nil, error: error)
			}
		}
	
	}
	
	// TODO: Error handling and fix server response!
	func postNewUserToServer(user: User, completionHandler: (error: NSError?) -> ()) {
		
		// Add Headers
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
		]
		
		// JSON Body
		let body: [String: AnyObject] = [
			"name": user.name!
		]
		
		// Fetch Request
		manager!.request(.POST, postURLString, parameters: body, headers: headers, encoding: .URL)
			.validate(statusCode: 200 ..< 300)
			.responseJSON { response in
				if (response.result.error == nil) {
					debugPrint("HTTP Response Body: \(response.data!)")
				} else {
					debugPrint("HTTP Request failed: \(response.result.error!)")
					debugPrint("CODE: \(response.result.error!.code)")
					print(response.result.description)
				}
		}
	}
	
	// TODO: Error handling and fix server response!
	func postUpdateToUserInfoToServer(user: User, completionHandler: (error: NSError?) -> ()) {
		
		// Add Headers
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
		]
		
		// JSON Body
		let body: [String: AnyObject] = [
			"name": user.name!,
			"isIn": user.isIn!
		]
		
		// Fetch Request
		manager!.request(.POST, postURLString, parameters: body, headers: headers, encoding: .URL)
			.validate(statusCode: 200 ..< 300)
			.responseJSON { response in
				if (response.result.error == nil) {
					debugPrint("HTTP Response Body: \(response.data!)")
				} else {
					debugPrint("HTTP Request failed on postUpdateToUserInfoToServer: \(response.result.error!)")
					debugPrint("CODE: \(response.result.error!.code)")
					print(response.result.description)
				}
		}
	}

}
