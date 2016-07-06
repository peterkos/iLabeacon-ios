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
	
	func getJSON(name: String, completionHandler: (result: AnyObject?, error: NSError?) -> ()) {
		
		Alamofire.request(.GET, "http://99.153.167.172:25566/list.php").validate().responseJSON { response in
			switch response.result {
				case .Success(let value):
					completionHandler(result: value, error: nil)
				case .Failure(let error):
					completionHandler(result: nil, error: error)
			}
		}
	
	}
	
}