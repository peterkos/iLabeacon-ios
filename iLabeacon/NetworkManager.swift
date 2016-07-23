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
		
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		
		let body: [String: AnyObject]? = [
			"name": user.name!,
			"isIn": (user.isIn?.description)!,
		]

		
		Alamofire.request(.POST, postURLString, parameters: body, encoding: .URL, headers: headers) .validate().responseJSON { response in
			guard response.result.error == nil else {
				debugPrint(response.result.error)
				return
			}
			
			debugPrint("Response: \(response.data)")
			
		}
	}
	
}