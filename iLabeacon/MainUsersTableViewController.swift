//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

class MainUsersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, NewUserTableViewControllerDelegate {

	var dataStack: DATAStack? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Core Data initialization
		dataStack = DATAStack(modelName: "iLabeaconModel")
		managedObjectContext = dataStack?.mainContext
		
		// If first launch, ask user for name and add them as a user
		// TODO: Present UIAlertView informing user about username
		let hasLaunchedBefore = userDefaults.boolForKey("hasLaunchedBefore")
		
		if (!hasLaunchedBefore) {
			self.performSegueWithIdentifier("showLoginViewController", sender: self)
			userDefaults.setBool(true, forKey: "hasLaunchedBefore")
		} else {
			print("username: \(userDefaults.boolForKey("hasLaunchedBefore"))")
			// TODO: Fetch actual username
		}
		
		// Networking!
		let networkManager = NetworkManager()
		networkManager.getUserStatusWithName("Peter")
		

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Segues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// Adding new user
		if let newUserVC = segue.destinationViewController.childViewControllers.first as? NewUserTableViewController {
			newUserVC.delegate = self
			
			let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.managedObjectContext!) as! User
			newUser.isLocalUser = 1
			newUser.isIn = false
			newUserVC.user = newUser
		}
		
		// Laoding selected user info in table view
		if let selectedUserVC = segue.destinationViewController as? SelectedUserTableViewController {
			
			let selectedUser = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! User
			selectedUserVC.user = selectedUser

		}
	}
	
	// MARK: - NewUserTableViewControllerDelegate
	func saveUser() {
		do {
			try self.managedObjectContext?.save()
			print("Saved user!")
		} catch {
			print(error)
			abort()
		}
	}
	
	// MARK: - Core Data
	
	var fetchedResultsController: NSFetchedResultsController {
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext!)
		
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
		aFetchedResultsController.delegate = self
		
		//FIXME: Might require usage of _fetchedResultsController & corresponding nil check
		
		do {
			try aFetchedResultsController.performFetch()
		} catch {
			print(error)
			abort()
		}
		
		return aFetchedResultsController
	}
	
	// MARK: - NSFetchedResultsController
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
			case .Delete: self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
			case .Insert: self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
			default: return
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
			case .Delete: self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
			case .Insert: self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Top)
			case .Update: break // TODO
			case .Move: self.tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
		}
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections![section].numberOfObjects
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// TODO: Subclass UITableViewCell, implement image
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
		let user = fetchedResultsController.objectAtIndexPath(indexPath) as! User
		
		cell?.textLabel!.text = user.name
		if (user.isIn == 0) {
			cell?.detailTextLabel!.text = "Is Not In"
		} else {
			cell?.detailTextLabel!.text = "Is In"
		}
		
		// TODO: Assign local user a special color
		cell?.textLabel?.textColor = UIColor.blackColor()
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return fetchedResultsController.sections![section].name
	}


}
