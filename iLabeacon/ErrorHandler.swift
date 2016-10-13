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
		SVProgressHUD.showError(withStatus: "Could not create local user.")
		SVProgressHUD.dismiss(withDelay: 2)
	}
	
	func showError(_ error: Error) {
		OperationQueue.main.addOperation {
			SVProgressHUD.showError(withStatus: error.localizedDescription)
			SVProgressHUD.dismiss(withDelay: 2)
		}
	}
	
}
