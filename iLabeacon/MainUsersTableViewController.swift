//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MainUsersTableViewController: UITableViewController {

	// General properties
	let networkManager = NetworkManager()
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	// Firebase properties
	let usersReference = FIRDatabase.database().reference().child("users")
	
	// Data
	var users = [User]()
	var localUserName: String? = NSUserDefaults.standardUserDefaults().objectForKey("localUserName") as! String?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Networking!
		networkManager.updateListOfUsersFromNetwork()

		// Register for new user notification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveLocalUser(_:)), name: "UserDidSignupNotification", object: nil)
		
		// Gets local user name
		localUserName = userDefaults.stringForKey("localUserName")
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		usersReference.observeEventType(.Value, withBlock: { snapshot in
			
			var newListOfUsers = [User]()
			
			for user in snapshot.children.allObjects as! [FIRDataSnapshot] {
				newListOfUsers.append(User(snapshot: user))
			}
			
			self.users = newListOfUsers
			self.tableView.reloadData()
			
		})
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		
		let localUser = notification.object as! User
		
		// Saves local username for UI highlight in cellForRowAtIndexPath
		NSUserDefaults.standardUserDefaults().setObject(localUser.name, forKey: "localUserName")
		localUserName = localUser.name
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
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
		let user = users[indexPath.row]
		print(user)
		
		cell?.textLabel!.text = user.name
		if (user.isIn == 0) {
			cell?.detailTextLabel!.text = "Is Not In"
		} else {
			cell?.detailTextLabel!.text = "Is In"
		}
		
		if (user.name == localUserName) {
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
