//
//  Contributor.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import Foundation
import RealmSwift
class Contributor:Object {
    @objc dynamic var name = ""
    var bill = List<Bill>()
    var parentEvent = LinkingObjects(fromType: Event.self, property: "contributors")

}
