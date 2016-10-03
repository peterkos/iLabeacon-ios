//
//  SelectedUserTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/2/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

// TODO: Move into error class
enum ShareStringParseError: Error {
	case nameNotSelected
}

extension ShareStringParseError: CustomStringConvertible {
	var description: String {
		switch self {
		case .nameNotSelected: return "Need to select name!"
		}
	}
}

class SelectedUserTableViewController: UITableViewController {
	
	// Defined parameters
	var user: User? = nil
	enum shareType {
		case name
		case isIn
		case dateLastIn
		case dateLastOut
	}
	
	
	// IB Properties & Functions
	@IBOutlet weak var userNameCell: UITableViewCell!
	@IBOutlet weak var userIsInCell: UITableViewCell!
	@IBOutlet weak var userDateLastInCell: UITableViewCell!
	@IBOutlet weak var userDateLastOutCell: UITableViewCell!
	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var shareButtonAfterSelection: UIBarButtonItem!
	@IBOutlet var shareButton: UIBarButtonItem!
	
	@IBAction func shareUserIconSelected(_ sender: AnyObject) {
		
		// Change title to ask user to select properties.
		
		// Move in animation
		let newTitleMoveInAnimation = CATransition()
		newTitleMoveInAnimation.duration = 0.3
		newTitleMoveInAnimation.type = kCATransitionPush
		newTitleMoveInAnimation.startProgress = 0
		newTitleMoveInAnimation.subtype = kCATransitionFromTop
		newTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		
		// Fade in animation
		let newTitleFadeInAnimation = CABasicAnimation(keyPath: "opacity")
		newTitleFadeInAnimation.fromValue = 0.0
		newTitleFadeInAnimation.toValue = 1
		newTitleFadeInAnimation.duration = 0.5
		newTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		// Applying the animations
		self.navigationItem.titleView!.layer.add(newTitleFadeInAnimation, forKey: "changeTitleOpacity")
		self.navigationItem.titleView!.layer.add(newTitleMoveInAnimation, forKey: "changeTitle")
		
		// New title to animate in
		(navigationItem.titleView as! UILabel).text = "Select Properties to Share"
		
		// Set editing and update butons
		// TODO: Fade in "Cancel" button so it doens't clip over nav back button?
		self.tableView.setEditing(true, animated: true)
		updateButtons()
	}
	
	@IBAction func shareUserInformation(_ sender: AnyObject) {
		
		// Parameters to check against UI
		// TODO: Add tags
		let nameParameter        = "Name"
		let isInParameter        = "In iLab"
		let dateLastInParameter  = "Last In"
		let dateLastOutParameter = "Last Out"
		var valuesToShare = [shareType: String]()
		
		// Actual values for the aforememtioned parameters
		// FIXME: user might be nil
		let nameValue        = user!.name
		let isInValue        = isInToEnglish()
		let dateLastInValue  = dateToString(user!.dateLastOut as Date)
		let dateLastOutValue = dateToString(user!.dateLastIn as Date)
		
		// Configures the list of actions that were selected.
		let selectedRowPaths = self.tableView.indexPathsForSelectedRows
		
		// If nothing was selected, close the view.
		guard selectedRowPaths != nil else {
			cancelEditing(sender)
			return
		}
		
		// Loop through each selection and determine what kind it was.
		for row in selectedRowPaths! {
			
			let cell = self.tableView.cellForRow(at: row)
			
			// Then, add it to the dictionary of shareType actions.
			switch cell!.textLabel!.text! {
				case nameParameter:		   valuesToShare[.name] = nameValue
				case isInParameter:		   valuesToShare[.isIn] = isInValue
				case dateLastInParameter:  valuesToShare[.dateLastIn] = dateLastInValue
				case dateLastOutParameter: valuesToShare[.dateLastOut] = dateLastOutValue
				default: break
			}
		}
		
		// Parses actions into a coherent, descriptive string for social media
		
		let parsedValues: String
		
		do {
			parsedValues = try parseFields(valuesToShare)
			print("Parsed ShareType successfully!")
		} catch let error as ShareStringParseError {
			print("ERROR: \(error.description)")
			return
		} catch {
			print("ERROR: Unknown ShareType error!")
			return
		}
		
		let nameString: AnyObject = parsedValues as AnyObject
		
		// Configure the share sheet
		let shareController = UIActivityViewController(activityItems: [nameString], applicationActivities: nil)
		
		// Show the user a list of parameters to share
		// Then, present the share controller and hide the editing view.
		self.present(shareController, animated: true, completion: nil)
		self.tableView.setEditing(false, animated: true)
		updateButtons()
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// User
		userNameCell.detailTextLabel!.text = user?.name
		userIsInCell.detailTextLabel!.text = isInToEnglish()
		userDateLastInCell.detailTextLabel!.text = dateToString(user!.dateLastIn as Date)
		userDateLastOutCell.detailTextLabel!.text = dateToString(user!.dateLastOut as Date)
		
		// Sets nav bar title to usernmae
		// Separate property so it can be animated
		let newTitleLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
		newTitleLabelView.textColor = self.navigationController?.navigationBar.tintColor
		newTitleLabelView.font = UIFont.boldSystemFont(ofSize: 16.0)
		newTitleLabelView.textAlignment = .center
		newTitleLabelView.text = user?.name
		self.navigationItem.titleView = newTitleLabelView
		
	}
	
	// MARK: Conversion methods!
	
	func isInToEnglish() -> String {
		if (user!.isIn) {
			return "Is In"
		} else {
			return "Is Not In"
		}
	}
	
	func dateToString(_ date: Date) -> String {
		// Date formatter
		let dateFormatter = DateFormatter()
		
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		
		return dateFormatter.string(from: date)
	}
	
	
	// MARK: - Action Methods for Editing
	
	@IBAction func cancelEditing(_ sender: AnyObject) {
		// Change title to ask user to select properties.
		
		// Move in animation
		let oldTitleMoveInAnimation = CATransition()
		oldTitleMoveInAnimation.duration = 0.3
		oldTitleMoveInAnimation.type = kCATransitionPush
		oldTitleMoveInAnimation.startProgress = 0
		oldTitleMoveInAnimation.subtype = kCATransitionFromTop
		oldTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		
		// Fade in animation
		let oldTitleFadeInAnimation = CABasicAnimation(keyPath: "opacity")
		oldTitleFadeInAnimation.fromValue = 0.0
		oldTitleFadeInAnimation.toValue = 1
		oldTitleFadeInAnimation.duration = 0.5
		oldTitleMoveInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		// Applying the animations
		self.navigationItem.titleView!.layer.add(oldTitleFadeInAnimation, forKey: "changeTitleOpacity")
		self.navigationItem.titleView!.layer.add(oldTitleMoveInAnimation, forKey: "changeTitle")
		
		// Restore old title
		(navigationItem.titleView as! UILabel).text = user!.name
		
		self.tableView.setEditing(false, animated: true)
		updateButtons()
	}
	
	func updateButtons() {
		if self.tableView.isEditing {
			self.navigationItem.setHidesBackButton(true, animated: true)
			cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditing(_:)))
			shareButtonAfterSelection = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(shareUserInformation(_:)))
			self.navigationItem.leftBarButtonItem = self.cancelButton
			self.navigationItem.rightBarButtonItem = self.shareButtonAfterSelection
		} else {
			self.tableView.setEditing(false, animated: true)
			self.navigationItem.setHidesBackButton(false, animated: true)
			self.navigationItem.leftBarButtonItem = nil
			
			shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareUserIconSelected(_:)))
			self.navigationItem.rightBarButtonItem = self.shareButton
		}
	}
	
	/*
	* MARK: Parsing for sharing selected actions
	*
	* This function turns the series of selected parameters into a human-readble string.
	* For instance, if two parameters were defined as follows,
	*     name = "Peter"
	*     dateLastIn = "December 12th, 2016 at 3:09PM"
	* and a user shared those two parameters on December 12th, it would return the following:
	*	  "Peter was last in the iLab at 3:09PM today"
	* Conversely, if they were to view this the next day, it would return:
	*     "Peter was last in the iLab yesterday at 3:09PM".
	*
	* For convinence, shareType cases are defined as follows.
	* 	name        = n
	* 	isIn        = i
	* 	dateLastIn  = dI
	* 	dateLastOut = dO
	*
	*
	* Let G = {P, T, S, V} be a context-sensitive phrase structure grammar, where
	*
	* 	P = {n, i, dI, dO}
	* 	T = {dI, dO, i}
	* 	S = {n}
	* 	V = {n·i}, {n·dI}, {n·dO}, {n·dI·dO}
	*
	* // lw(1)r -> lw(2)r [Type 1 psg]
	*
	*
	* PRECONDITION: Parameter list is in the defined order of
	* [name, isIn, dateLastIn, dateLastOut]
	*
	*/
	
	
	func parseFields(_ fields: [shareType: String]) throws -> String {
		
		
		// MARK: Helper functions
		
		// Converts isIn to bool for easy comparison
		func isInToBool(_ isIn: String) -> Bool {
			if isIn == "Is In" {
				return true
			} else {
				return false
			}
		}
		
		
		var message = ""
		
		let name = fields[shareType.name] 
		let isIn = fields[shareType.isIn] 
		let dateLastIn = fields[shareType.dateLastIn] as! Date?
		let dateLastOut = fields[shareType.dateLastOut] as! Date?
		
		enum dateType {
			case lastIn
			case lastOut
		}
		
		
		// MARK: Error checking
		// If no name is selected, throw error
		guard name != nil else {
			throw ShareStringParseError.nameNotSelected
		}
		
		// If only one element was selected, return just that element.
		guard fields.count != 1 else {
			message = (fields.first!).1 
			return message
		}
		
		
		// MARK: Date Calculations
		
		/*
		*
		* Date calculations follow the patterns below.
		* As the time range increases, the details are less specific.
		* Conversely, the sooner the user was in/out, the more specific
		* the time will be.
		*
		* SINGLE DATES
		* For instance, let today be 8/25 at 1:15 PM.
		*    If the user was in at 9:00 AM, the message would read:
		*    "Peter was in the iLab this morning."
		*
		*    If the user left the previous Tuesday at 10:45AM, the message would read:
		*    "Peter left the iLab last Tuesday at 10:45AM."
		*
		*    If the user was in the iLab two weeks prior on a Friday at 11:00PM, the message would read:
		*    "Peter was in the iLab 2 weeks ago on Friday."
		*
		*
		* DOUBLE DATES
		* When given two dates, the result is simply the concatenation of the two single values.
		*
		* Here the formal definitions, divided into sections:
		*
		* // 1.
		* dateLastIn: "was in"
		* dateLastOut: "left"
		*
		* // 2.
		* Today at [time.1]       (2.1
		* Yesterday at [time.1]   (2.2
		* [DOW] [time.2]          (2.3
		* last [DOW] at [time.1]  (2.4
		* [n] weeks ago           (2.5
		*
		* // 0.5.
		* [time.1] ~= "4:45 P.M."
		* [time.2] ~= "morning" | "afternoon" | "evening"
		*/
		func parseDate(_ date: Date, ofType dateType: dateType) -> String {
			
			var dateMessage = ""
			let today = Date.init(timeIntervalSinceNow: 0)
			let calendar = Calendar.current
			
			// 0.5
			// Helper function to calcualte specific time
			func specificTime() -> String {
				let timeFormatter = DateFormatter()
				timeFormatter.dateStyle = .none
				timeFormatter.timeStyle = .short
				return timeFormatter.string(from: date)
				
			}
			
			// 1.
			switch dateType {
			case .lastIn: dateMessage.append("was in ")
			case .lastOut: dateMessage.append("left ")
			}
			
			dateMessage.append("the iLab ")
			
			// 2.1
			let todayComparison = (calendar as NSCalendar).compare(date, to: today, toUnitGranularity: .day)
			
			if (todayComparison == .orderedSame) {
				dateMessage.append("today \(specificTime())")
				return dateMessage
			}
			
			// 2.2
			if ((calendar as NSCalendar).component(.day, from: date) == (calendar as NSCalendar).component(.day, from: today) - 1) {
				dateMessage.append("yesterday \(specificTime())")
				return dateMessage
			}
			
			// 2.3 & 2.4
			let weekComparison = (calendar as NSCalendar).compare(date, to: today, toUnitGranularity: .weekOfYear)
			let weekDifference = (calendar as NSCalendar).component(.weekOfYear, from: today) -
				(calendar as NSCalendar).component(.weekOfYear, from: date)
			
			if (weekComparison == .orderedAscending && weekDifference <= 1) {
				dateMessage.append("last ")
			}
			
			if ((weekComparison == .orderedSame || weekComparison == .orderedAscending) && weekDifference <= 1) {
				let weekdayFormatter = DateFormatter()
				weekdayFormatter.setLocalizedDateFormatFromTemplate("EEEE")
				dateMessage.append("\(weekdayFormatter.string(from: date)) at \(specificTime())")
				
				return dateMessage
			}
			
			// 2.5
			if (weekDifference >= 2) {
				dateMessage.append("\(weekDifference) weeks ago")
			}
			
			// Finally,
			return dateMessage
		}
		
		
		//MARK: Calculations
		// {n·i}, {n·dI}, {n·dO}, {n·dI·dO}
		
		// 1) Case {n·i}
		if (isIn != nil && fields.count == 2) {
			message = isInToBool(isIn!) ? name! + " is in the iLab!" : name! + "is not in the iLab."
			return message
		}
		
		// 4) Case {n·dI·dO}
		if let dateLastIn = dateLastIn, let dateLastOut = dateLastOut {
			print("Case 2")
			message = name! + " " + parseDate(dateLastIn, ofType: dateType.lastIn) + " and " +
				parseDate(dateLastOut, ofType: dateType.lastOut)
			return message
		}
		
		// 2, 3) Case {n·dI} & {n·dO}
		// FIXME: Parse both
		if let dateLastIn = dateLastIn {
			message = name! + " " + parseDate(dateLastIn, ofType: dateType.lastIn)
			return message
		} else if let dateLastOut = dateLastOut {
			message = name! + " " + parseDate(dateLastOut, ofType: dateType.lastOut)
			return message
		}
		
		
		// TODO: Handle if all cases (somehow) fail.
		return message
	}


}

