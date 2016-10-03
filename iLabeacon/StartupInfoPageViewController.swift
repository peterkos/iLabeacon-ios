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
			pages.append((self.storyboard?.instantiateViewController(withIdentifier: "tutorialView\(i)"))!)
		}
		
		setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
		
		// Fixes page view glitch
		self.automaticallyAdjustsScrollViewInsets = false
		
		
	}
	
	// MARK: - UIPageViewControllerDataSource
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		let previousIndex = pages.index(of: viewController)! - 1
		return pageViewControllerIsInRange(viewController, atIndex: previousIndex)
		
	}
 
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		let nextIndex = pages.index(of: viewController)! + 1
		return pageViewControllerIsInRange(viewController, atIndex: nextIndex)

	}
 
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages.count
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}

	// MARK: - Helper Functions
	func pageViewControllerIsInRange(_ viewController: UIViewController, atIndex index: Int) -> UIViewController? {
		
		if (index >= 0 && index < pages.count) {
			return pages[abs(index)]
		} else {
			return nil
		}
		
	}
}
