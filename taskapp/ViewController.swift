//
//  ViewController.swift
//  taskapp
//
//  Created by 小嶋暸太 on 2018/08/02.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var surchCategory: UITextField!
    
    var categorytext=""
    
    //Realmインスタンスの取得
    let realm = try! Realm()
    
    //Db内のたすくが収納されるリスト
    //日付で日付近い順（降順でソート）
    var taskArray=try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    var categoryArray=try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.hidesBackButton=true
        
        let category=Category()
        
        try! realm.write {
            category.name="全てを表示"
            category.id=0
            realm.add(category, update: true)
            
        }
        
        tableView.delegate=self
        tableView.dataSource=self
        
        let pickerview=UIPickerView()
        pickerview.delegate=self
        pickerview.dataSource=self
        
        surchCategory.inputView=pickerview
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        surchCategory.inputAccessoryView = toolbar
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func done() {
        surchCategory.endEditing(true)
        
        if categorytext != ""{
        surchCategory.text = categorytext
        }else{
            surchCategory.text="全てを表示"
        }
        if surchCategory.text=="全てを表示"{
            taskArray=realm.objects(Task.self).sorted(byKeyPath: "id", ascending: true)
        }else if surchCategory.text != "未指定"{
        
        taskArray=realm.objects(Task.self).filter("categorys=%@",categorytext)
        
        }else{
            taskArray=realm.objects(Task.self).filter("categorys=%@","")
        }
        tableView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return categoryArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  categoryArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categorytext=categoryArray[row].name
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputviewcontroller:inputViewController=segue.destination as! inputViewController
        
        
        if segue.identifier=="cellSegue"{
            let indexPath=self.tableView.indexPathForSelectedRow
            inputviewcontroller.task=taskArray[indexPath!.row]
        }else{
             let task=Task()
            task.date=Date()
            
            let allTask=realm.objects(Task.self)
            if allTask.count != 0{
                task.id=allTask.max(ofProperty: "id")!+1
            }
            inputviewcontroller.task=task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task=taskArray[indexPath.row]
        cell.textLabel?.text=task.title
        
        let formatter=DateFormatter()
        formatter.dateFormat="yyyy-mm-dd HH:mm"
        
        let datestring:String=formatter.string(from: task.date)
        cell.detailTextLabel?.text=datestring
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let task=self.taskArray[indexPath.row]
            
            let center=UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
            center.getPendingNotificationRequests { (requests:[UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("/---------------")
                }
            }
        }
    }
}

