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
	var dateLastIn: Date
	var dateLastOut: Date
	var isIn: Bool
	var name: String
	var email: String?
	var uid: String?
	
	override var description: String {
		return "Name: \(name), isIn: \(isIn), dateLastIn: \(dateLastIn), dateLastOut: \(dateLastOut)"
	}
	
	// Init from FIRDataSnapshots
	init(snapshot: FIRDataSnapshot) {
		let snapshotValue = snapshot.value as! Dictionary<String, AnyObject>
		self.name = snapshotValue["name"] as! String
		self.isIn = snapshotValue["isIn"] as! Bool
		self.dateLastIn  = Date.init(timeIntervalSince1970: (snapshotValue["dateLastIn"] as! TimeInterval))
		self.dateLastOut = Date.init(timeIntervalSince1970: (snapshotValue["dateLastOut"] as! TimeInterval))
		
		self.email = nil
		self.uid = nil
	}
	
	init(firebaseUser: FIRUser) {
		self.name = firebaseUser.displayName!
		self.email = firebaseUser.email!
		self.uid = firebaseUser.uid
		self.dateLastIn = Date.init(timeIntervalSince1970: 0)
		self.dateLastOut = Date.init(timeIntervalSince1970: 0)
		self.isIn = false
	}
	
	func toFirebase() -> AnyObject {
		let data: [String: AnyObject] = ["name": name as AnyObject,
		                                 "isIn": isIn as AnyObject,
		                                 "dateLastIn" : NSNumber(value: dateLastIn.timeIntervalSince1970 as Double),
		                                 "dateLastOut": NSNumber(value: dateLastOut.timeIntervalSince1970 as Double)]
		return data as AnyObject
	}
	
}
