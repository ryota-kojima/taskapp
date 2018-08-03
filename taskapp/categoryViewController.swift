//
//  categoryViewController.swift
//  taskapp
//
//  Created by 小嶋暸太 on 2018/08/03.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import RealmSwift

class categoryViewController: UIViewController {
    @IBOutlet weak var categoryname: UITextField!
    let realm=try! Realm()
    var newcategory:Category!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(_ animated: Bool){
        if categoryname.text != ""{
            
            try! realm.write {
                newcategory.name=categoryname.text!
                
                self.realm.add(self.newcategory,update:true)
            
            }
          super.viewWillDisappear(animated)
            
        }
    }
    
}
