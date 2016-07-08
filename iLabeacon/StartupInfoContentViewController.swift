//
//  StartupInfoContentViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/8/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class StartupInfoContentViewController: UIViewController {
	
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var headerLabel: UITextView!
	@IBOutlet weak var contentLabel: UITextView!

	
	var index = 0
	var headerText = ""
	var imageTitle = ""
	var contentText = ""
	
	
	override func viewDidLoad() {
		imageView.image = UIImage(named: imageTitle)
		headerLabel.text = headerText
		contentLabel.text = contentText
	}
	
}