//
//  User.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/3/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class User: NSObject {
	
	// Required properties
	var dateLastIn: NSDate
	var dateLastOut: NSDate
	var isIn: Bool
	var name: String
	var email: String?
	var uid: String?
	
	override var description: String {
		return "Name: \(name), isIn: \(isIn), dateLastIn: \(dateLastIn), dateLastOut: \(dateLastOut)"
	}
	
	// Init from FIRDataSnapshots
	init(snapshot: FIRDataSnapshot) {
		self.name = snapshot.value!["name"] as! String
		self.isIn = snapshot.value!["isIn"] as! Bool
		self.dateLastIn  = NSDate.init(timeIntervalSince1970: (snapshot.value!["dateLastIn"] as! NSTimeInterval))
		self.dateLastOut = NSDate.init(timeIntervalSince1970: (snapshot.value!["dateLastOut"] as! NSTimeInterval))
		
		self.email = nil
		self.uid = nil
	}
	
	init(firebaseUser: FIRUser) {
		self.name = firebaseUser.displayName!
		self.email = firebaseUser.email!
		self.uid = firebaseUser.uid
		self.dateLastIn = NSDate.init(timeIntervalSince1970: 0)
		self.dateLastOut = NSDate.init(timeIntervalSince1970: 0)
		self.isIn = false
	}
	
	func toFirebase() -> AnyObject {
		let data: [String: AnyObject] = ["name": name,
		                                 "isIn": isIn,
		                                 "dateLastIn" : NSNumber(double: dateLastIn.timeIntervalSince1970),
		                                 "dateLastOut": NSNumber(double: dateLastOut.timeIntervalSince1970)]
		return data
	}
	
}