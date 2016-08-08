//
//  LocalUserSettingsTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/8/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class LocalUserSettingsTableViewController: UITableViewController {
	
	
	@IBOutlet weak var uuidCell: UITableViewCell!
	@IBOutlet weak var rssiCell: UITableViewCell!
	@IBOutlet weak var majorCell: UITableViewCell!
	@IBOutlet weak var minorCell: UITableViewCell!
	@IBOutlet weak var proximityCell: UITableViewCell!
	@IBOutlet weak var isInCell: UITableViewCell!
	
	var beacon: Beacon? = nil
	var user: User? = nil
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		uuidCell.detailTextLabel!.text = beacon?.uuid?.description
		rssiCell.detailTextLabel!.text = beacon?.rssi?.description
		majorCell.detailTextLabel!.text = beacon?.major?.description
		proximityCell.detailTextLabel!.text = beacon?.proximity?.description
		isInCell.detailTextLabel!.text = user?.isIn
		
	}
	
	override func viewDidLoad() {
		// Because IB is being stubborn
		self.title = "Local uesr settings"
	}
	
	
	

}
