//
//  Category.swift
//  taskapp
//
//  Created by 小嶋暸太 on 2018/08/03.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import Foundation
import RealmSwift

class Category:Object {
    
    @objc dynamic var name=""
    
    @objc dynamic var id=0
    
    override static func primaryKey()->String?{
        return "id"
    }
}
