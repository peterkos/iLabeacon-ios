//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData
import Sync
import DATAStack
import SwiftyJSON

class MainUsersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, NewUserTableViewControllerDelegate {

	var dataStack: DATAStack? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Core Data initialization
		dataStack = DATAStack(modelName: "iLabeaconModel")
		managedObjectContext = dataStack?.mainContext
		fetchedResultsController.delegate = self
		
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
		updateListOfUsersFromNetwork()
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(newDataChange(_:)),
		                                                 name: NSManagedObjectContextObjectsDidChangeNotification,
		                                                 object: self.dataStack?.mainContext)

		// Refresh control
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(updateListOfUsersFromNetwork), forControlEvents: .ValueChanged)
//		self.tableView.addSubview(refreshControl!)

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
	
	// MARK: - Networking
	func updateListOfUsersFromNetwork() {
		
		// Helper function, converts JSON into Dictionary and syncs it
		func parseJSON(json: JSON) {
			
			var bigDictionary = [[String: AnyObject]]()
			
			for i in 0..<json.count {
				bigDictionary.append(json[i].dictionaryObject!)
			}
			
			Sync.changes(bigDictionary, inEntityNamed: "User", dataStack: self.dataStack!, completion: { (error) in
				guard error == nil else {
					print(error!)
					return
				}
				
				do {
					try self.managedObjectContext?.save()
					print("saved")
				} catch {
					print(error)
					return
				}
				
				print("pulled!")
				if self.refreshControl!.refreshing {
					self.refreshControl!.endRefreshing()
				}
			})
			
		}
		
		let networkManager = NetworkManager()
		let name = "Peter"
		
		networkManager.getJSON(name) { (result, error) in
			guard error == nil else {
				print(error!)
				return
			}
			
			// Parse and sync!
			let json = JSON(result!)
			NSOperationQueue.mainQueue().addOperationWithBlock({ 
				parseJSON(json)
				print("parsing json")
			})
			
		}
		
	}
	
	func newDataChange(notification: NSNotification) {
		if notification.userInfo != nil {
//			let deletedObjects = notification.userInfo![NSInsertedObjectsKey]
			let insertedObjects = notification.userInfo![NSInsertedObjectsKey]
			
//			print("Deleted objects: \(deletedObjects?.description)")
			print("Inserted objects: \(insertedObjects?.description)")
			print("user: \((insertedObjects as? User)!.name)")
		}
		
	}
	
	
	
	// MARK: - Core Data
	
	var fetchedResultsController: NSFetchedResultsController {
		
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: (self.managedObjectContext!))
		
		let sortDescriptor = NSSortDescriptor(key: "isIn", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
		aFetchedResultsController.delegate = self
		
		_fetchedResultsController = aFetchedResultsController
		
		do {
			try _fetchedResultsController?.performFetch()
		} catch {
			print(error)
			abort()
		}
		
		return _fetchedResultsController!
	}
	
	var _fetchedResultsController: NSFetchedResultsController? = nil
	
	// MARK: - NSFetchedResultsController
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("Controller will change")
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("Controller did change")
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
		
		func configureUserCell(withObject user: User, atIndexPath indexPath: NSIndexPath) {
			let cell = self.tableView.cellForRowAtIndexPath(indexPath)
			cell?.textLabel?.text = user.name
			if (user.isIn == 0) {
				cell?.detailTextLabel!.text = "Is Not In"
			} else {
				cell?.detailTextLabel!.text = "Is In"
			}
			
			print("updated user cell wtih user \(user.name)")
		}
		
		switch type {
			case .Delete: self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
			case .Insert: self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Top)
			case .Update: configureUserCell(withObject: anObject as! User, atIndexPath: newIndexPath!)
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
