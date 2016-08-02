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

class MainUsersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var dataStack: DATAStack? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	let networkManager = NetworkManager()
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		
		// Checks for first launch, shows tutorial if true
		if userDefaults.boolForKey("hasLaunchedBefore") == false {
			if let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("StartupTutorial") as? StartupInfoPageViewController {
				self.navigationController!.presentViewController(tutorialVC, animated: true, completion: nil)
				print("showing")
				
				// Passes managedObjectContext to SingupVC
				if let signupVC = tutorialVC.pages.last as? SignupViewController {
					signupVC.managedObjectContext = self.managedObjectContext!
				}
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Core Data initialization
		dataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStack
		managedObjectContext = dataStack?.mainContext
		fetchedResultsController.delegate = self
		
		// Networking!
		updateListOfUsersFromNetwork()

		// Refresh control
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(updateListOfUsersFromNetwork), forControlEvents: .ValueChanged)

		// Register for new user notification
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(saveUser(_:)),
		                                                 name: "NewUser",
		                                                 object: nil)
		
		// Register for incoming data notification (isIn from AppDelegate)
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(refreshIsIn(_:)),
		                                                 name: "refreshIsIn",
		                                                 object: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Segues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// Loading selected user info in table view
		if let selectedUserVC = segue.destinationViewController as? SelectedUserTableViewController {
			
			let selectedUser = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! User
			selectedUserVC.user = selectedUser

		}
	}
	
	// MARK: - Add new user from SignupViewController
	func saveUser(notification: NSNotification) {
		
		let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.managedObjectContext!) as! User
		
		newUser.name = (notification.userInfo! as! [String: String])["name"]
		newUser.isLocalUser = 1
		newUser.isIn = false
		
		do {
			// Save user to CoreData
			try self.managedObjectContext?.save()
			
			// Save user to network
			networkManager.postNewUserToServer(newUser, completionHandler: { (error) in
				print("NETWORK ERROR \(error!.description)")
			})
			
			
		} catch {
			print(error)
			abort()
		}
	}
	
	// MARK: - Update isIn data from AppDelegate
	func refreshIsIn(notification: NSNotification) {
		print("RELOADING from AppDelelgate refreshIsIn NSNotification post")
//		self.tableView.reloadData()
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
					print("MOC Saved")
				} catch {
					print(error)
					return
				}
				
				if self.refreshControl!.refreshing {
					self.refreshControl!.endRefreshing()
				}
			})
			
		}
		
		networkManager.getJSON() { (result, error) in
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
	
	// MARK: - Core Data
	
	var fetchedResultsController: NSFetchedResultsController {
		
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: (self.managedObjectContext!))
		
		// Sorts by local user, then by isIn, then by dateLastIn
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isLocalUser", ascending: false),
		                                NSSortDescriptor(key: "isIn",        ascending: false),
		                                NSSortDescriptor(key: "dateLastIn",  ascending: false)]
		
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
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
		self.tableView.reloadData()
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
			case .Delete: self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
			case .Insert: self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
			default: return
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		
		func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
			
			let user = self.fetchedResultsController.objectAtIndexPath(indexPath) as! User
			cell.textLabel!.text = user.name!
			if (user.isIn == 0) {
				cell.detailTextLabel!.text = "Is Not In"
			} else {
				cell.detailTextLabel!.text = "Is In"
			}
			
			print("configureCell in MainUsersTableViewController from .Update")
			
		}
		
		switch type {
			case .Delete: self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
			case .Insert: self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Top)
			case .Update: configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
			case .Move:   self.tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
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
			print("====\(user.name!) is not in")
			cell?.detailTextLabel!.text = "Is Not In"
		} else {
			print("====\(user.name!) is in")
			cell?.detailTextLabel!.text = "Is In"
		}
		
		// TODO: Assign local user a special color
		if (user.isLocalUser == 1) {
			
			NSOperationQueue.mainQueue().addOperationWithBlock({
				print("\(user.name!) is the local user")
				let view = UIView(frame: CGRectMake(0, 0, 10, (cell?.frame.size.height)!))
				view.backgroundColor = ThemeColors.tintColor
				cell?.addSubview(view)
			})
			
			
		}
		
		cell?.textLabel?.textColor = UIColor.blackColor()
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return fetchedResultsController.sections![section].name
	}


}
