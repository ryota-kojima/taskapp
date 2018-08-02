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

class inputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task:Task!
    let realm=try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text=task.title
        contentsTextView.text=task.contens
        datePicker.date=task.date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title=self.titleTextField.text!
            self.task.contens=self.contentsTextView.text!
            self.task.date=datePicker.date
            self.realm.add(self.task,update:true)
        }
        super.viewWillDisappear(animated)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
