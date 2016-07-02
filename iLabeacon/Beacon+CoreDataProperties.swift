//
//  Beacon+CoreDataProperties.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/2/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Beacon {

    @NSManaged var rssi: NSNumber?
    @NSManaged var minor: NSNumber?
    @NSManaged var proximity: NSNumber?
    @NSManaged var uuid: NSObject?
    @NSManaged var major: NSNumber?
    @NSManaged var accuracy: NSNumber?

}
