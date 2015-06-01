//
//  PersonData.swift
//  ICE
//
//  Created by Felix Gruber on 01.06.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import Foundation
import CoreData

@objc(PersonData)
class PersonData: NSManagedObject {
    @NSManaged var allergies: String
    @NSManaged var bloodType: String
    @NSManaged var day: NSNumber
    @NSManaged var firstName: String
    @NSManaged var img: NSData
    @NSManaged var lastName: String
    @NSManaged var medHist: String
    @NSManaged var month: NSNumber
    @NSManaged var year: NSNumber
}