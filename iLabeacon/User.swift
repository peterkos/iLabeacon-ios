//
//  User.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/3/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User: NSObject {
	
	var dateLastIn: NSDate
	var dateLastOut: NSDate
	var isIn: NSNumber
	var name: String
	var beacon: Beacon?
	override var description: String {
		return "Name: \(name), isIn: \(isIn), dateLastIn: \(dateLastIn), dateLastOut: \(dateLastOut)"
	}
	
	init(name: String) {
		self.name = name
		self.isIn = false
		dateLastIn = NSDate.init(timeIntervalSince1970: 0)
		dateLastOut = NSDate.init(timeIntervalSince1970: 0)
		
		super.init()
	}
	
	init(snapshot: FIRDataSnapshot) {
		self.name = snapshot.value!["name"] as! String
		self.isIn = snapshot.value!["isIn"] as! NSNumber
		self.dateLastIn  = NSDate.init(timeIntervalSince1970: (snapshot.value!["dateLastIn"] as! NSTimeInterval))
		self.dateLastOut = NSDate.init(timeIntervalSince1970: (snapshot.value!["dateLastOut"] as! NSTimeInterval))
	}
	
	func toFirebase() -> AnyObject {
		let data: [String: AnyObject] = ["name": name,
		                                 "isIn": isIn,
		                                 "dateLastIn" : NSNumber(double: dateLastIn.timeIntervalSince1970),
		                                 "dateLastOut": NSNumber(double: dateLastOut.timeIntervalSince1970)]
		return data
	}

}