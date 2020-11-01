//
//  Bill.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import Foundation
import RealmSwift
class Bill : Object{
    @objc dynamic var title = ""
    @objc dynamic var amount = 0.0
    var parentContributor = LinkingObjects(fromType: Contributor.self, property: "bill")
}
