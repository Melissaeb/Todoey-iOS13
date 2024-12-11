//
//  Category.swift
//  Todoey
//
//  Created by Melissa Elliston-Boyes on 11/12/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import Chameleon

class Category: Object {
    @Persisted var name: String = ""
//    @Persisted var categoryID = UUID().uuidString
    @Persisted var color: String = UIColor.randomFlat().hexValue()
    @Persisted var items = List<Item>()
}
