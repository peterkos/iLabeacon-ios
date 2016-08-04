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
	
	// Location (Beacon)
	@IBOutlet weak var beaconUUIDCell: UITableViewCell!
	@IBOutlet weak var beaconRSSICell: UITableViewCell!
	@IBOutlet weak var beaconMajorCell: UITableViewCell!
	@IBOutlet weak var beaconMinorCell: UITableViewCell!
	@IBOutlet weak var beaconProximityCell: UITableViewCell!
	@IBOutlet weak var beaconAccuracyCell: UITableViewCell!
	
	
	var user: User? = nil
	var beacon: Beacon? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// User
		userNameCell.detailTextLabel!.text = user?.name
		userIsInCell.detailTextLabel!.text = user?.isIn.description
		userDateLastInCell.detailTextLabel!.text = user?.dateLastIn?.description ?? "Unknown"
		userDateLastOutCell.detailTextLabel!.text = user?.dateLastOut?.description ?? "Unknown"
		
		// Beacon
		beaconUUIDCell.detailTextLabel!.text = beacon?.uuid?.description
		beaconRSSICell.detailTextLabel!.text = beacon?.rssi?.description
		beaconMajorCell.detailTextLabel!.text = beacon?.major?.description
		beaconMinorCell.detailTextLabel!.text = beacon?.minor?.description
		beaconProximityCell.detailTextLabel!.text = beacon?.proximity?.description
		beaconAccuracyCell.detailTextLabel!.text = beacon?.accuracy?.description
		
		// Sets nav bar title to usernmae
		self.title = user?.name
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	

}
