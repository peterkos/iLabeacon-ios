//
//  NewUserTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData

protocol NewUserTableViewControllerDelegate {
	func saveUser(user: User)
}

class NewUserTableViewController: UITableViewController {

	
	@IBOutlet weak var usernameField: UITextField!
	
	@IBAction func doneButton(sender: AnyObject) {
		user?.name = usernameField.text
		delegate?.saveUser(user!)
		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	var delegate: NewUserTableViewControllerDelegate? = nil
	var user: User? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	

}
