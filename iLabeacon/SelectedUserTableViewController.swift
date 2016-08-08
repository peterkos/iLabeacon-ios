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
	
	var user: User? = nil
	var beacon: Beacon? = nil
	
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
		if (user!.isIn == 0) {
			return "Is Not In"
		} else {
			return "Is In"
		}
	}

	

}
