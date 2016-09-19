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

	@IBAction func shareUserBarButtonSelected(sender: AnyObject) {
		
		// Parameters to share
		let name        = "Their Name"
		let isIn        = "Is In"
		let dateLastIn  = "Date Last In"
		let dateLastOut	= "Date Oast Out"
		let itemsToShare: [AnyObject] = [name]
		
		// Ask user to select some parameters
		let selectShareItemsAlertController = UIAlertController(title: "Share",
		                                                        message: "Select what you want to share:",
		                                                        preferredStyle: .ActionSheet)
		
		let userNameAction    = UIAlertAction(title: name, style: .Default, handler: nil)
		let isInAction        = UIAlertAction(title: isIn, style: .Default, handler: nil)
		let dateLastInAction  = UIAlertAction(title: dateLastIn, style: .Default, handler: nil)
		let dateLastOutAction = UIAlertAction(title: dateLastOut, style: .Default, handler: nil)
		
		let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel) { cancelAction in
			return
		}

		let actions = [userNameAction, isInAction, dateLastInAction, dateLastOutAction, cancelAction]
		selectShareItemsAlertController.addActions(actions)
		

		// Configure the share sheet
		let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//		self.presentViewController(activityController, animated: true, completion: nil)
		
		
		// Show the user a list of parameters to share
		// Then, present the share controller.
		
		self.presentViewController(selectShareItemsAlertController, animated: true) {
			
		}

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

	

}
