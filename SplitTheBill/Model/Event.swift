//
//  Event.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import Foundation
import RealmSwift

class Event:Object{
    @objc dynamic var eventName = ""
    var contributors = List<Contributor>()
    @objc dynamic var total = 0.0
    
}
