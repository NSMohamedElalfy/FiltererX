//
//  Palette+CoreDataProperties.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/6/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Palette {

    @NSManaged var date: NSDate?
    @NSManaged var background: String?
    @NSManaged var primary: String?
    @NSManaged var secondary: String?
    @NSManaged var detail: String?

}
