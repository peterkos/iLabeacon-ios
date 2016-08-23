//
//  ErrorHandler.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/23/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import Foundation
import SVProgressHUD

class ErrorHandler {
	
	func localUserCouldNotBeCreatedException() {
		SVProgressHUD.showErrorWithStatus("Could not create local user.")
		SVProgressHUD.dismissWithDelay(2)
	}
	
	
	
}