//
//  SelectedUserTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/2/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

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
		
		// Change title to ask user to select properties.
		
		// Move in animation
		let newTitleMoveInAnimation = CATransition()
		newTitleMoveInAnimation.duration = 0.3
		newTitleMoveInAnimation.type = kCATransitionPush
		newTitleMoveInAnimation.startProgress = 0
		newTitleMoveInAnimation.subtype = kCATransitionFromTop
		newTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

		// Fade in animation
		let newTitleFadeInAnimation = CABasicAnimation(keyPath: "opacity")
		newTitleFadeInAnimation.fromValue = 0.0
		newTitleFadeInAnimation.toValue = 1
		newTitleFadeInAnimation.duration = 0.5
		newTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

		// Applying the animations
		self.navigationItem.titleView!.layer.addAnimation(newTitleFadeInAnimation, forKey: "changeTitleOpacity")
		self.navigationItem.titleView!.layer.addAnimation(newTitleMoveInAnimation, forKey: "changeTitle")
		
		// New title to animate in
		(navigationItem.titleView as! UILabel).text = "Select Properties to Share"
		
		// Set editing and update butons
		// TODO: Fade in "Cancel" button so it doens't clip over nav back button?
		self.tableView.setEditing(true, animated: true)
		updateButtons()
	}
	
	@IBAction func shareUserInformation(sender: AnyObject) {
		
		// Parameters to check against UI
		let nameParameter        = "Name"
		let isInParameter        = "In iLab"
		let dateLastInParameter  = "Last In"
		let dateLastOutParameter = "Last Out"
		var valuesToShare = [String]()
		
		// Actual values for the aforemnetioned parameters
		// FIXME: user might be nil
		let nameValue        = user!.name
		let isInValue        = isInToEnglish()
		let dateLastInValue  = dateToString(user!.dateLastOut)
		let dateLastOutValue = dateToString(user!.dateLastIn)
		
		// Configures the list of actions that were selected.
		let selectedRowPaths = self.tableView.indexPathsForSelectedRows
		
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
				case nameParameter:		   valuesToShare.append(nameValue)
				case isInParameter:		   valuesToShare.append(isInValue)
				case dateLastInParameter:  valuesToShare.append(dateLastInValue)
				case dateLastOutParameter: valuesToShare.append(dateLastOutValue)
				default: break
			}
		}
		
		// Parses actions into a coherent, descriptive string for social media
		let nameString: AnyObject = parseFields(valuesToShare)
		
		// Configure the share sheet
		let shareController = UIActivityViewController(activityItems: [nameString], applicationActivities: nil)
		
		// Show the user a list of parameters to share
		// Then, present the share controller and hide the editing view.
		self.presentViewController(shareController, animated: true, completion: nil)
		self.tableView.setEditing(false, animated: true)
		updateButtons()
	}
	
	
	var user: User? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		// User
		userNameCell.detailTextLabel!.text = user?.name
		userIsInCell.detailTextLabel!.text = isInToEnglish()
		userDateLastInCell.detailTextLabel!.text = dateToString(user!.dateLastIn)
		userDateLastOutCell.detailTextLabel!.text = dateToString(user!.dateLastOut)
		
		// Sets nav bar title to usernmae
		// Separate property so it can be animated
		let newTitleLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
		newTitleLabelView.textColor = self.navigationController?.navigationBar.tintColor
		newTitleLabelView.font = UIFont.boldSystemFontOfSize(16.0)
		newTitleLabelView.text = user?.name
		self.navigationItem.titleView = newTitleLabelView
		
    }

	// MARK: Conversion methods!
	
	func isInToEnglish() -> String {
		if (user!.isIn) {
			return "Is In"
		} else {
			return "Is Not In"
		}
	}

	func dateToString(date: NSDate) -> String {
		// Date formatter
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .LongStyle
		dateFormatter.timeStyle = .ShortStyle
		
		return dateFormatter.stringFromDate(date)
	}
	
	
	// MARK: - Action Methods for Editing

	@IBAction func cancelEditing(sender: AnyObject) {
		self.tableView.setEditing(false, animated: true)
		
		// TODO: Implement with animation!
		self.title = user?.name
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
	// TODO: Parse!
	func parseFields(fields: [AnyObject]) -> String {
		
		var message = ""
		
		for field in fields as! [String] {
			message.appendContentsOf(field + " ")
		}
		
		return message
	}
	
	

}
