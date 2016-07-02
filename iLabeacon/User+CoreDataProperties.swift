//
//  User+CoreDataProperties.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var name: String?
    @NSManaged var dateLastIn: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var isIn: NSNumber?
    @NSManaged var dateLastOut: NSDate?
    @NSManaged var beacon: Beacon?

}
