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

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンスの取得
    let realm = try! Realm()
    
    //Db内のたすくが収納されるリスト
    //日付で日付近い順（降順でソート）
    let taskArray=try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate=self
        tableView.dataSource=self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputviewcontroller:inputViewController=segue.destination as! inputViewController
        
        if segue.identifier=="cellSegue"{
            let indexPath=self.tableView.indexPathForSelectedRow
            inputviewcontroller.task=taskArray[indexPath!.row]
        }else{
            let task=Task()
            task.date=Date()
            
            let allTaks=realm.objects(Task.self)
            if allTaks.count != 0{
                task.id=allTaks.max(ofProperty: "id")!+1
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

