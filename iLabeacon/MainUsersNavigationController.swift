//
//  MainUsersNavigationController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/13/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class MainUsersNavigationController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationBar.barTintColor = ThemeColors.secondaryBackgroundColor
		self.navigationBar.tintColor = UIColor.whiteColor()
	}
	
}
