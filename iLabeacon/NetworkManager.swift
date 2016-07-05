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

class NetworkManager {

	
	func getUserStatusWithName(name: String) -> Bool {
		
		Alamofire.request(.GET, "http://99.153.167.172:25566/list.php").responseJSON { response in
			print(response.description)
		}
		
		return false
	}
	
}