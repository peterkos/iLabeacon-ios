//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class MainUsersTableViewController: UITableViewController {

	let networkManager = NetworkManager()
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Networking!
		networkManager.updateListOfUsersFromNetwork()

		// Register for new user notification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveUser(_:)), name: "NewUser", object: nil)
		
		// Firebase	code goes here
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Segues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// Loading selected user info in table view
		if let selectedUserVC = segue.destinationViewController as? SelectedUserTableViewController {
			// Access selectedUserVC and add it to Firebase
		}
	}
	
	// MARK: - Add new user from SignupViewController
	func saveUser(notification: NSNotification) {

		// Save to users list!
//		(notification.userInfo! as! [String: String])["name"]
	}
	
	// MARK: - Firebase and Data
	let users: [User] = []
	
	// Insert Firebase managment here
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return users.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// TODO: Subclass UITableViewCell, implement image
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
		let user = users[indexPath.row]
		
		cell?.textLabel!.text = user.name
		if (user.isIn == 0) {
			cell?.detailTextLabel!.text = "Is Not In"
		} else {
			cell?.detailTextLabel!.text = "Is In"
		}
		
		// TODO: Assign local user a special color
		if (user.isLocalUser == 1) {
			NSOperationQueue.mainQueue().addOperationWithBlock({
				let view = UIView(frame: CGRectMake(0, 0, 10, (cell?.frame.size.height)!))
				view.backgroundColor = ThemeColors.tintColor
				cell?.addSubview(view)
			})
		}
		
		cell?.textLabel?.textColor = UIColor.blackColor()
		
		return cell!
	}


}
