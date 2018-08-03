//
//  inputViewController.swift
//  taskapp
//
//  Created by 小嶋暸太 on 2018/08/02.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class inputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categorypicker: UIPickerView!
    
    var task:Task!
    let realm=try! Realm()
    var category=try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    var categ:String!=""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        categorypicker.delegate=self
        categorypicker.dataSource=self
        titleTextField.text=task.title
        contentsTextView.text=task.contens
        datePicker.date=task.date
        
        let category=Category()
        
        try! realm.write {
            category.name="未指定"
            category.id=1
            realm.add(category, update: true)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count-1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let alcategory=category[row+1]
        return alcategory.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categ=category[row+1].name
    }

    override func viewWillAppear(_ animated: Bool) {
        self.categorypicker.reloadAllComponents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func setNotification(task:Task){
        
        let content=UNMutableNotificationContent()
        
        if task.title==""{
            content.title="（タイトルなし）"
        }else{
            content.title=task.title
        }
        if task.contens==""{
            content.body="（内容なし）"
        }else{
            content.body=task.contens
        }
        content.sound=UNNotificationSound.default()
        
        //ローカル通知が発動するトリガーを設定する
        let calender=Calendar.current
        let dateComponents=calender.dateComponents([.year,.month,.day,.hour,.minute],from : task.date)
        let trigger=UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        //identifer,conten,trigeerから通知を作成(identifierが同じだと通知をうわがき)
        let request=UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        let center=UNUserNotificationCenter.current()
        
        center.add(request){(error)in
            print(error ?? "ローカル通知登録　OK") //errorがnilならローカル通知の設定完了のメッセージ,そうじゃないならerror
        }
        
        //見通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{(requests : [UNNotificationRequest])in
            for request in requests{
                print("/---------------")
                print(request)
                print("/---------------")
            }
        }
        

    }
    
    @IBAction func unwind(_ segue:UIStoryboardSegue){
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="categorysegue"{
            let categoryviewcontroller:categoryViewController=segue.destination as! categoryViewController
            let allcategory=realm.objects(Category.self)
            
            let category = Category()
            try! realm.write {
                if allcategory.count != 0{
            category.id=allcategory.max(ofProperty: "id")! + 1
                }
            }
            
            categoryviewcontroller.newcategory=category
            
        }else if segue.identifier=="save"{
            try! realm.write {
                self.task.title=self.titleTextField.text!
                self.task.contens=self.contentsTextView.text!
                self.task.date=datePicker.date
                self.task.categorys=categ
                self.realm.add(self.task,update:true)
            }
        }else{
            realm.delete(task)
        }
    }
    
    @IBAction func savebutton(_ sender: Any) {
        performSegue(withIdentifier: "save", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
