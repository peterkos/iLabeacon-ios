//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MainUsersTableViewController: UITableViewController, CLLocationManagerDelegate {

	// General properties
	let networkManager = NetworkManager()
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	// Firebase properties
	let usersReference = FIRDatabase.database().reference().child("users")
	var localUser: User? {
		get {
			if let firUser = FIRAuth.auth()?.currentUser {
				return User(firebaseUser: firUser)
			} else {
				return nil
			}
		}
		
		set(newLocalUser) {
			self.localUser = newLocalUser
		}
	}
	
	// Data
	var users = [User]()
	
	// Location!
	let locationManager = CLLocationManager()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Networking!
		networkManager.updateListOfUsersFromNetwork()

		// Register for new user notification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveLocalUser(_:)), name: "UserDidSignupNotification", object: nil)
		
		// Location
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		
		// Regions
		let mainiLabRegion = CLBeaconRegion(proximityUUID: pcUUID, major: iLabMajorMain, identifier: "iLab General Beacons")
		
		locationManager.startMonitoringForRegion(mainiLabRegion)
		locationManager.startRangingBeaconsInRegion(mainiLabRegion)
		locationManager.requestStateForRegion(mainiLabRegion)
		mainiLabRegion.notifyEntryStateOnDisplay = true
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		usersReference.observeEventType(.Value, withBlock: { snapshot in
			
			var newListOfUsers = [User]()
			
			for user in snapshot.children.allObjects as! [FIRDataSnapshot] {
				newListOfUsers.append(User(snapshot: user))
			}
			
			// Sort by isIn, then dateLastIn
			let isInSortDescriptor = NSSortDescriptor(key: "isIn", ascending: false)
			let dateLastInSortDescriptor = NSSortDescriptor(key: "dateLastIn", ascending: false)
			newListOfUsers = (newListOfUsers as NSArray).sortedArrayUsingDescriptors([isInSortDescriptor, dateLastInSortDescriptor]) as! [User]
			
			// Puts localUser at top
			print(self.localUser?.name)
			let localUserIndex = newListOfUsers.indexOf( { $0.name == self.localUser!.name } )
			newListOfUsers.insert(newListOfUsers.removeAtIndex(localUserIndex!), atIndex: 0)
			
			
			self.users = newListOfUsers
			self.tableView.reloadData()
			
		})
		
	}
	
	deinit {
		// Remove observers
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// Loading selected user info in table view
		if let selectedUserVC = segue.destinationViewController as? SelectedUserTableViewController {
			selectedUserVC.user = users[tableView.indexPathForSelectedRow!.row]
		}
	}
	
	
	// MARK: - Add new user from SignupViewController
	
	func saveLocalUser(notification: NSNotification) {
		localUser = User(firebaseUser: (notification.object as! FIRUser))
	}
	
	
	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// TODO: Subclass UITableViewCell, implement image
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		let user = users[indexPath.row]
		print("CellForRowAtIndexPath: \(user)")
		
		cell.textLabel!.text = user.name
		if (user.isIn) {
			cell.detailTextLabel!.text = "Is In"
		} else {
			cell.detailTextLabel!.text = "Is Not In"
		}
		
		if (user.name == localUser?.name) {
			NSOperationQueue.mainQueue().addOperationWithBlock({
				let view = UIView(frame: CGRectMake(0, 0, 10, (cell.frame.size.height)))
				view.backgroundColor = ThemeColors.tintColor
				cell.addSubview(view)
			})
		}
		
		cell.textLabel?.textColor = UIColor.blackColor()
		
		return cell
	}

	
	// MARK: - Location
	
	// Location Properties
	let pcUUID = NSUUID(UUIDString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!
	
	let iLabMajorMain: CLBeaconMajorValue = 0x17AB
	let iLabMinor1: CLBeaconMinorValue = 0x1024
	let iLabMinor2: CLBeaconMinorValue = 0x1025
	let iLabMinor3: CLBeaconMinorValue = 0x1026
	let iLabMinor4: CLBeaconMinorValue = 0x1027
	
	
	// MARK: Location Management
	
	// Determines isIn status
	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
		
		func isInState() {
			localUser!.dateLastIn = NSDate.init(timeIntervalSinceNow: 0)
			localUser!.isIn = true
		}
		
		func isNotInState() {
			localUser!.dateLastOut = NSDate.init(timeIntervalSinceNow: 0)
			localUser!.isIn = false
		}
		
		if (region.identifier == "iLab General Beacons") {
			switch state {
			case .Inside: isInState()
			case .Outside: isNotInState()
			case .Unknown: print("UNKNOWN ENTRANCE STATE")
			}
			
			print("Local user \(localUser!.name) isIn: \(localUser!.isIn)")
		}
		
		usersReference.child(localUser!.uid!).setValue(localUser!.toFirebase())
	}
	
	func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
		
		guard beacons.count > 0 else {
			return
		}
		
		var closestBeacon = beacons.first!

		for beacon in beacons {
			if (beacon.rssi < closestBeacon.rssi) {
				closestBeacon = beacon
			}
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("BeaconDidUpdateNotification",
		                                                          object: closestBeacon, userInfo: ["isIn": localUser!.isIn.description])
	}
	
	/*
	* BEACON MANAGMENT
	*
	* When the local user connnects to a becaon, they will be added to the list of connected users for that beacon
	* in the database.
	*
	* There are two types of beacons: Entrance and General. Entrance beacons are meant to be triggered only two
	* times, while General beacons can be triggered an unlimited amount of times. These two will be used in
	* conjunction to determine when a user is "in".
	*
	*/
	

}
