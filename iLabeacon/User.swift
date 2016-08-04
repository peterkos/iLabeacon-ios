//
//  User.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/3/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
	
	init(snapshot: FIRDataSnapshot) {
		self.name = snapshot.value!["name"] as! String
		self.isIn = snapshot.value!["isIn"] as! NSNumber
		self.dateLastIn  = snapshot.value!["dateLastIn"] as? NSDate
		self.dateLastOut = snapshot.value!["dateLastOut"] as? NSDate
	}
	
	func toFirebase() -> AnyObject {
		let data: [String: AnyObject] = ["name": name,
		                                 "isIn": isIn,
		                                 "dateLastIn" : NSNumber(double: (dateLastIn?.timeIntervalSince1970)!),
		                                 "dateLastOut": NSNumber(double: (dateLastOut?.timeIntervalSince1970)!)]
		return data
	}

}