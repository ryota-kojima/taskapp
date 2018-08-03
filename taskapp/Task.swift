//
//  Task.swift
//  taskapp
//
//  Created by 小嶋暸太 on 2018/08/02.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import RealmSwift

class Task: Object{
    @objc dynamic var  id=0
    
    @objc dynamic var title=""
    
    @objc dynamic var contens=""
    
    @objc dynamic var categorys=""
    
    @objc dynamic var date=Date()
    
    //Idをプライマリーキーに設定
    override static func primaryKey()->String?{
        return "id"
    }
}


