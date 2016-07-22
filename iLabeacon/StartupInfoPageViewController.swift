//
//  StartupInfoPageViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/4/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class StartupInfoPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

	var pages = [UIViewController]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.delegate = self
		self.dataSource = self
		
		// Instantiates all view controllers
		for i in 1...5 {
			pages.append((self.storyboard?.instantiateViewControllerWithIdentifier("tutorialView\(i)"))!)
		}
		
		setViewControllers([pages.first!], direction: .Forward, animated: true, completion: nil)
		
		// Sets background color
		self.view.backgroundColor = UIColor.whiteColor()
		
	}
	
	// MARK: - UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		
		let previousIndex = pages.indexOf(viewController)! - 1
		return pageViewControllerIsInRange(viewController, atIndex: previousIndex)
		
	}
 
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		
		let nextIndex = pages.indexOf(viewController)! + 1
		return pageViewControllerIsInRange(viewController, atIndex: nextIndex)

	}
 
	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
		return pages.count
	}
 
	func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
		return 0
	}
	
	// MARK: - Helper Functions
	func pageViewControllerIsInRange(viewController: UIViewController, atIndex index: Int) -> UIViewController? {
		
		if (index >= 0 && index < pages.count) {
			return pages[abs(index)]
		} else {
			return nil
		}
		
	}
}
