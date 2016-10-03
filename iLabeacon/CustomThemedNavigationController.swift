//
//  MainUsersNavigationController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/13/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class CustomThemedNavigationController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationBar.barTintColor = ThemeColors.backgroundColor
		self.navigationBar.tintColor = UIColor.white
	}
	
}
