//
//  NumberString.swift
//  ICE
//
//  Created by Felix Gruber on 01.06.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import Foundation
import CoreData

@objc(NumberString)
class NumberString: NSManagedObject {
    @NSManaged var number: String
}