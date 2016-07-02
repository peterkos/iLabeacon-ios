//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData

class MainUsersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var dataStack: CoreDataStack? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Core Data initialization
		dataStack = CoreDataStack()
		managedObjectContext = dataStack?.managedObjectContext
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Core Data
	var fetchedResultsController: NSFetchedResultsController {
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedObjectContext!)
		
		let sortDescriptor = NSSortDescriptor(key: "isIn", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "isIn", cacheName: nil)
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

	

}
