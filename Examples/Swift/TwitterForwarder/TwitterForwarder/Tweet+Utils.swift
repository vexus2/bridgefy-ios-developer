//
//  Tweet+CoreDataProperties.swift
//  TwitterForwarder
//
//  Created by Danno on 7/14/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import Foundation
import CoreData


extension Tweet {

    var status: TweetStatus {
        get {
            return TweetStatus(rawValue: Int(self.rawStatus))!
        }
        set {
            self.rawStatus = Int16(newValue.rawValue)
        }
    }
    
    var date: Date {
        get {
            return Date(timeIntervalSince1970: self.time)
        }
        set {
            self.time = newValue.timeIntervalSince1970
        }
    }
    
    var textDate: String {
        return self.date.timeAgoString(numericDates: true)
    }

}
