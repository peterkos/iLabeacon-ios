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
	
	func postToServer(user: User, completionHandler: (error: NSError?) -> ()) {
		
		// Add Headers
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
		]
		
		// JSON Body
		let body = [
			"name": user.name!,
		]
		
		print("body: \(body.description)")
		// Fetch Request
		Alamofire.request(.POST, postURLString, headers: headers, parameters: body, encoding: .JSON)
			.validate(statusCode: 200 ..< 300)
			.responseJSON { response in
				if (response.result.error == nil) {
					debugPrint("HTTP Response Body: \(response.data!)")
				}
				else {
					debugPrint("HTTP Request failed: \(response.result.error!)")
					debugPrint("CODE: \(response.result.error!.code)")
				}
		}
	}

}
