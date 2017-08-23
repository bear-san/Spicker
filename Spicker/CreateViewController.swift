//
//  CreateViewController.swift
//  Spicker
//
//  Created by KentaroAbe on 2017/08/04.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
import NCMB
import UserNotifications
import NotificationCenter

class AppMetaData: Object{ //メタデータ・権限
    @objc dynamic var ID = 0 //書き換えの際のデータ番号
    @objc dynamic var isSendDataPermission = true //利用状況の送信を許可するか
    @objc dynamic var isFirstLaunch = true //初回起動か
}
class Task: Object { //Realmで使うオブジェクト定義
    @objc dynamic var ID = 0 //ID：データ管理に利用、連番を付け、基本的に一定の数値になるまで使い回しはしない
    @objc dynamic var priority = 0 //優先度
    @objc dynamic var TaskName = "" //タスク名
    @objc dynamic var NotificationTime = 0 //通知時間 UNIX時間で管理
    @objc dynamic var hasFinished = false //タスクが完了しているか（追加直後に既に終わっているわけないので基本はfalse）
}

class CreateViewController : UIViewController {
    
    
    @IBOutlet weak var Priority_box: UITextField!
    @IBOutlet weak var TaskName_box: UITextField!
    @IBOutlet weak var NotificationTime: UIDatePicker!
    
    
    @IBOutlet weak var Number: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
        let database = try! Realm()
        let data = try! Realm()
        let PermitDataLocal = AppMetaData()
        
        let PermitData = data.objects(AppMetaData.self).sorted(byProperty: "isFirstLaunch", ascending: true)
        
        if PermitData.first?.isFirstLaunch == true{
            let alert = UIAlertController(title: "利用状況の送信",message: "アプリの品質向上のため、\n利用状況の送信に同意しますか？\n \n***送信されるデータ***\n・タスクを追加した日\n・タスクの名前\n・タスクの優先度\n・タスクの通知時間\n　\n送信されたデータはユーザーの特定が出来ない形で保存され、ユーザーの許可なしに第三者へ提供することは一切ありません \nなおこの設定は後から「Settings」で変更できます", preferredStyle: .alert)
            let OKbutton = UIAlertAction(title: "同意する", style: UIAlertActionStyle.default, handler: { action in
                print("許可されました")
                let data = try! Realm()
                let AddData = AppMetaData()
                
                let ID = PermitData.count + 1
                AddData.ID = ID
                AddData.isFirstLaunch = false
                AddData.isSendDataPermission = true
                
                try! data.write() {
                    data.add(AddData)
                }
            })
            let NGbutton = UIAlertAction(title: "同意しない", style: UIAlertActionStyle.destructive, handler: { action in
                print("許可されませんでした")
                let data = try! Realm()
                let AddData = AppMetaData()
                
                let ID = PermitData.count + 1
                AddData.ID = ID
                AddData.isFirstLaunch = false
                AddData.isSendDataPermission = false
                
                try! data.write() {
                    data.add(AddData)
                }
            })
            alert.addAction(OKbutton)
            alert.addAction(NGbutton)
            
            self.present(alert, animated: true, completion:nil)
        }else{
            print("初回起動ではありません")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func Register(_ sender: Any) { //データ登録
        
        var isCanRegister = false
        
        Priority_box.endEditing(true)
        TaskName_box.endEditing(true)
        print("処理に入りました")
        NotificationTime.locale = Locale(identifier: "ja-JP")
        let notificationTimeInJSTfrom1970 =
            NotificationTime.date.timeIntervalSince1970 + 32400
        let NowTimeInUNIX = Int(Date().timeIntervalSince1970)
        let WantFireNotificationTime = Double(Int(notificationTimeInJSTfrom1970) - NowTimeInUNIX - 32400)
        print("通知時間：\(WantFireNotificationTime)秒後")
        
        
        if WantFireNotificationTime <= 0 {
            let alert = UIAlertController(title: "エラー",message: "時間は未来の時間を選択してください", preferredStyle: .alert)
            let OKbutton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                isCanRegister = false
            })
            alert.addAction(OKbutton)
            
            self.present(alert, animated: true, completion:nil)
        }else{
            isCanRegister = true
        }
        
        if isCanRegister == true{
            let database = try! Realm()
            let regiTask = Task()
            if Priority_box.text != nil{
                print("優先度は入力されています")
            }else{
                print("優先度が入力されていないため、優先度は１とします")
                Priority_box.text = "1"
            }
            print("regiTaskの定義")
            var CurrentPriority = database.objects(Task.self).sorted(byProperty: "priority", ascending: true) //優先度でソート（昇順）
            var CurrentID = database.objects(Task.self).sorted(byProperty: "ID", ascending: false) //IDでソート（降順）
            //print(CurrentPriority)
            let newestID = CurrentID.first?.ID //IDを降順でソートした時、現在登録されているIDの最大値
            if Priority_box.text != ""{
                regiTask.priority = Int(Priority_box.text!)!
            }else{
                regiTask.priority = 1 //優先度が入力されていない場合は優先度を1とする
            }
            if newestID != nil{ //既にデータが存在する場合の処理
                regiTask.ID = newestID! + 1
            }else{ //データが存在しない場合の処理
                regiTask.ID = 1 //初回データのIDは１
            }
            let HowManyData = CurrentPriority.count
            if HowManyData >= 1{
                if HowManyData == 1{
                    try! database.write(){
                        CurrentPriority[0].priority += 1
                    }
                }else{
                    print("データの登録が既にあります")
                    if regiTask.priority != 1{
                        rewriteengine:for i in 1...HowManyData{
                            
                            print("現在\(i)回目のデータ書き換え")
                            var LeftI = HowManyData - i //書き換えようとしているデータ番地（最大データ数からカウントダウン）
                            if LeftI < regiTask.priority-1 { //書き換えようとしているデータ番地が
                                print("ここで処理を中断します")
                                break rewriteengine
                            }
                            print("書き換えるデータ番地：\(LeftI)")
                            try! database.write() {
                                CurrentPriority[LeftI].priority += 1
                            }
                            print("\(i)回目のデータ書き換え完了")
                        }
                    }else{
                        for i in regiTask.priority...HowManyData{
                            print("現在\(i)回目のデータ書き換え")
                            var LeftI = HowManyData - i
                            
                            print("書き換えるデータ番地：\(LeftI)")
                            try! database.write() {
                                CurrentPriority[LeftI].priority += 1
                            }
                            print("\(i)回目のデータ書き換え完了")
                        }
                    }
                }
            }else{ //優先度の登録されたデータが存在しない場合
                regiTask.priority = 1 //優先度は自動で1とする
            }
            
            
            
            regiTask.TaskName = TaskName_box.text!
            regiTask.NotificationTime = Int(notificationTimeInJSTfrom1970)
            
            //task.NotificationTime -> UNIX時間と指定時刻の変換を出来るようになったら作成
            try! database.write { //realmに保存
                database.add(regiTask)
            }
            print(CurrentPriority)
            
            var MetaData = database.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
            if MetaData.first?.isSendDataPermission == true && MetaData.first?.isFirstLaunch == false{
                print("データの送信が許可されています")
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "YYYY-MM-dd"
                let strDate = format.string(from: date)
                
                let obj = NCMBObject(className: "Spicker_Data")
                // オブジェクトに値を設定
                obj?.setObject(strDate, forKey: "Date")
                obj?.setObject(regiTask.TaskName, forKey: "taskName")
                obj?.setObject(regiTask.priority, forKey: "taskPriority")
                obj?.setObject(regiTask.NotificationTime, forKey: "notificationTime")
                // データストアへの保存を実施
                obj?.saveInBackground({ (error) in
                    if error != nil {
                        // 保存に失敗した場合の処理
                        print("保存に失敗しました")
                    }else{
                        // 保存に成功した場合の処理
                        print("送信しました")
                        print(error)
                    }
                })
            }else{
                print("データの送信は許可されていません")
                print(MetaData)
            }
            let nowDate = Data()
            
            //Int型で現在時刻を取得
            
            
            let notification_left_time = Date.init(timeIntervalSinceNow: notificationTimeInJSTfrom1970)
            let notification = UNMutableNotificationContent()
            notification.title = "TodayHaveToDo"
            notification.body = "\(regiTask.TaskName)は終わった？？"
            notification.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: WantFireNotificationTime, repeats: false)
            let request = UNNotificationRequest.init(identifier: "Spicker_\(regiTask.TaskName)", content: notification, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            print("全ての登録処理が完了しました")
            Priority_box.text = ""
            TaskName_box.text = ""
            let AfterData = try! Realm()
            CurrentPriority = AfterData.objects(Task.self).sorted(byProperty: "priority", ascending: false)
            self.tabBarController?.selectedIndex = 0;
        }else{
            print("エラー")
        }
        
    }
    
    func DataDeletePerDay(dataKeyPriority :Int) -> String{
        var Result = ""
        let OldDataBase = try! Realm()
        let OldData = OldDataBase.objects(Task.self).sorted(byKeyPath: "priority", ascending: true)
        print(OldData)
    
        let deleteData = OldData[dataKeyPriority]
        for i in 0...OldData.count-1{
            if OldData[i].priority >= deleteData.priority{
                try! OldDataBase.write() {
                    OldData[i].priority -= 1
                }
            }
        }
        try! OldDataBase.write() {
            OldDataBase.delete(deleteData)
        }
        
        Result = "Complete_Delete"
        
        return Result
    }
    
    func TimeControl() {
        
    }
    
    func JsonGet(fileName :String) -> JSON {
        let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = Document_path + "/" + fileName + ".json"
        print(path)
        
        do{
            let jsonStr = try String(contentsOfFile: path)
            print(jsonStr)
            
            let json = JSON.parse(jsonStr)
            
            return json
        } catch {
            return nil
        }
        
    }
}
