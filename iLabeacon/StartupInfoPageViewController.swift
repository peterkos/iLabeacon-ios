//
//  StartupInfoPageViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/4/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class StartupInfoPageViewController: UIPageViewController, UIPageViewControllerDelegate {

	let pages = [UIViewController]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.delegate = self
		
		
	}
	
}
