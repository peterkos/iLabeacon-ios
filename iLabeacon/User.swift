//
//  User.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/3/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation

class User {
	
	var dateLastIn: NSDate?
	var dateLastOut: NSDate?
	var image: NSData?
	var isIn: NSNumber
	var isLocalUser: NSNumber?
	var name: String
	var beacon: Beacon?
	
	init(name: String) {
		self.name = name
		self.isIn = false
		dateLastIn = NSDate.init(timeIntervalSince1970: 0)
		dateLastOut = NSDate.init(timeIntervalSince1970: 0)
	}
	
	func toFirebase() -> AnyObject {
		let data: [String: AnyObject] = ["name": name,
		                                 "isIn": isIn,
		                                 "dateLastIn" : NSNumber(double: (dateLastIn?.timeIntervalSince1970)!),
		                                 "dateLastOut": NSNumber(double: (dateLastOut?.timeIntervalSince1970)!)]
		return data
	}

}