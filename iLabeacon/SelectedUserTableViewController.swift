//
//  SelectedUserTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/2/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit


// Adds ability to add multiple actions to a UIAlertController at once
extension UIAlertController {
	func addActions(actions: [UIAlertAction]) {
		for action in actions {
			self.addAction(action)
		}
	}
}


class SelectedUserTableViewController: UITableViewController {

	// User
	@IBOutlet weak var userNameCell: UITableViewCell!
	@IBOutlet weak var userIsInCell: UITableViewCell!
	@IBOutlet weak var userDateLastInCell: UITableViewCell!
	@IBOutlet weak var userDateLastOutCell: UITableViewCell!
	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var shareButtonAfterSelection: UIBarButtonItem!
	@IBOutlet var shareButton: UIBarButtonItem!
	
	@IBAction func shareUserIconSelected(sender: AnyObject) {
		
		// Enable multiple selection, show cancel button
		self.tableView.setEditing(true, animated: true)
		updateButtons()
	}
	
	@IBAction func shareUserInformation(sender: AnyObject) {
		
		// Parameters to share
		let name        = "Name"
		let isIn        = "In iLab"
		let dateLastIn  = "Last In"
		let dateLastOut	= "Last Out"
		var itemsToShare = [AnyObject]()
		
		// TODO: Parameterize this into UIAlertController extension?
		let userNameAction    = UIAlertAction(title: name, style: .Default)        { action in itemsToShare.append(action) }
		let isInAction        = UIAlertAction(title: isIn, style: .Default)        { action in itemsToShare.append(action) }
		let dateLastInAction  = UIAlertAction(title: dateLastIn, style: .Default)  { action in itemsToShare.append(action) }
		let dateLastOutAction = UIAlertAction(title: dateLastOut, style: .Default) { action in itemsToShare.append(action) }
		
		
		// Configures the list of actions that were selected.
		let selectedRowPaths = self.tableView.indexPathsForSelectedRows
		var actions = [UIAlertAction]()
		
		// If nothing was selected, close the view.
		guard selectedRowPaths != nil else {
			cancelEditing(sender)
			return
		}
		
		// Loop through each selection and determine what kind it was.
		for row in selectedRowPaths! {
			
			let cell = self.tableView.cellForRowAtIndexPath(row)
			
			// Then, add it to the array of actions.
			switch cell!.textLabel!.text! {
				case name:        actions.append(userNameAction)
				case isIn:        actions.append(isInAction)
				case dateLastIn:  actions.append(dateLastInAction)
				case dateLastOut: actions.append(dateLastOutAction)
				default:          break
			}
		}
		
		// TODO: Parse actions into a coherent, descriptive string to share.
		let nameString: [AnyObject] = [parseFields(actions)]
		
		// Configure the share sheet
		let shareController = UIActivityViewController(activityItems: nameString, applicationActivities: nil)
		
		// Show the user a list of parameters to share
		// Then, present the share controller and hide the editing view.
		self.presentViewController(shareController, animated: true, completion: nil)
		self.tableView.setEditing(false, animated: true)
		updateButtons()
		
	}
	
	
	var user: User? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Date formatter
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .LongStyle
		dateFormatter.timeStyle = .ShortStyle
		
		
		// User
		userNameCell.detailTextLabel!.text = user?.name
		userIsInCell.detailTextLabel!.text = isInToEnglish()
		userDateLastInCell.detailTextLabel!.text = dateFormatter.stringFromDate(user!.dateLastIn)
		userDateLastOutCell.detailTextLabel!.text = dateFormatter.stringFromDate(user!.dateLastOut)
		
		// Sets nav bar title to usernmae
		self.title = user?.name
		
    }

	func isInToEnglish() -> String {
		if (user!.isIn) {
			return "Is In"
		} else {
			return "Is Not In"
		}
	}

	// MARK: - Action Methods for Editing

	@IBAction func cancelEditing(sender: AnyObject) {
		self.tableView.setEditing(false, animated: true)
		updateButtons()
	}
	
	func updateButtons() {
		if self.tableView.editing {
			self.navigationItem.setHidesBackButton(true, animated: true)
			cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelEditing(_:)))
			shareButtonAfterSelection = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(shareUserInformation(_:)))
			self.navigationItem.leftBarButtonItem = self.cancelButton
			self.navigationItem.rightBarButtonItem = self.shareButtonAfterSelection
		} else {
			self.tableView.setEditing(false, animated: true)
			self.navigationItem.setHidesBackButton(false, animated: true)
			self.navigationItem.leftBarButtonItem = nil
			
			shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(shareUserIconSelected(_:)))
			self.navigationItem.rightBarButtonItem = self.shareButton
		}
	}
	
	// MARK: Parsing for sharing selected actions
	func parseFields(actions: [UIAlertAction]) -> String {
		return "This is cool!"
	}
	
	

}
