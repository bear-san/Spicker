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

class LastDateInfo: Object{
    @objc dynamic var lastDate = 0 //最終読み書き日付（UNIX時間で管理）
}
class AppMetaData: Object{ //メタデータ・権限
    @objc dynamic var ID = 0 //書き換えの際のデータ番号
    @objc dynamic var isSendDataPermission = true //利用状況の送信を許可するか
    @objc dynamic var isFirstLaunch = true //初回起動か
    @objc dynamic var CloseTask = 0 //タスクの締め時間
    @objc dynamic var isToday = true //データの登録を当日に行うか
}
class Task: Object { //Realmで使うオブジェクト定義
    @objc dynamic var ID = 0 //ID：データ管理に利用、連番を付け、基本的に一定の数値になるまで使い回しはしない
    @objc dynamic var priority = 0 //優先度
    @objc dynamic var TaskName = "" //タスク名
    @objc dynamic var NotificationTime = 0 //通知時間 UNIX時間で管理
    @objc dynamic var hasFinished = false //タスクが完了しているか（追加時点で既に終わっているわけないので基本はfalse）
}

class CreateViewController : UIViewController {
    
    
    @IBOutlet weak var Priority_box: UITextField!
    @IBOutlet weak var TaskName_box: UITextField!
    @IBOutlet weak var NotificationTime: UIDatePicker!
    @IBOutlet weak var dontnotification: UISwitch!
    
    
    @IBOutlet weak var Number: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
        //let database = try! Realm()
        
        //let PermitDataLocal = AppMetaData()
        permitCreate()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func permitCreate() {
        let data = try! Realm()
        let PermitData = data.objects(AppMetaData.self).sorted(byKeyPath: "isFirstLaunch", ascending: true)
        
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
                AddData.CloseTask = 0
                
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
                AddData.CloseTask = 0
                
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
    @IBAction func Register(_ sender: Any) { //データ登録
        Priority_box.endEditing(true)
        TaskName_box.endEditing(true)
        
        let notificationTimeInUNIX = NotificationTime.date.timeIntervalSince1970 + 32400
        
        var isNotification_Local = false
        if dontnotification.isOn == true{
            isNotification_Local = true
        }else{
            isNotification_Local = false
        }
        
        DataAdd(Name: TaskName_box.text!, Priority: Priority_box.text!, isNotification: isNotification_Local, notificationTime: notificationTimeInUNIX)
        
        Priority_box.text = ""
        TaskName_box.text = ""
    }
    func DataAdd(Name:String,Priority:String,isNotification:Bool,notificationTime:Double){
        
        var isCanRegister = false
        
        print("処理に入りました")
        NotificationTime.locale = Locale(identifier: "ja-JP")
        let notificationTimeInJSTfrom1970 = NotificationTime.date.timeIntervalSince1970 + 32400
        let NowTimeInUNIX = Int(Date().timeIntervalSince1970)
        let WantFireNotificationTime = Double(Int(notificationTimeInJSTfrom1970) - NowTimeInUNIX - 32400)
        print("通知時間：\(WantFireNotificationTime)秒後")
        
        if isNotification == true{
            isCanRegister = true
        }else{
            if notificationTime <= 0 {
                let alert = UIAlertController(title: "エラー",message: "時間は未来の時間を選択してください", preferredStyle: .alert)
                let OKbutton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    isCanRegister = false
                })
                alert.addAction(OKbutton)
                
                self.present(alert, animated: true, completion:nil)
            }else{
                isCanRegister = true
            }
        }
        
        if isCanRegister == true{
            let database = try! Realm()
            let regiTask = Task()
            var CurrentPriority = database.objects(Task.self).sorted(byKeyPath: "priority", ascending: true) //優先度でソート（昇順）
            var CurrentID = database.objects(Task.self).sorted(byProperty: "ID", ascending: false) //IDでソート（降順）
            let newestID = CurrentID.first?.ID //IDを降順でソートした時、現在登録されているIDの最大値
            let maxiumPriority = CurrentPriority.last?.priority //優先度を昇順でソートしたとき、現在登録されている優先度で最も低いもの（＝数字が大きいもの）
            if Priority != ""{
                regiTask.priority = Int(Priority)!
            }else{
                if maxiumPriority != nil{
                    regiTask.priority = maxiumPriority! + 1 //優先度が入力されていない場合は優先度を最も低い値にする
                }else{
                    regiTask.priority = 1 //そもそもデータが登録されていない場合は優先度を１とする
                }
            }
            if newestID != nil{ //既にデータが存在する場合の処理
                regiTask.ID = newestID! + 1
            }else{ //データが存在しない場合の処理
                regiTask.ID = 1 //初回データのIDは１
            }
            if CurrentPriority.count >= 1{
                if regiTask.priority > (CurrentPriority.last?.priority)! + 1{ //優先度に連続性を持たせるため、既存のもので最大の優先度＋２以上であれば最大優先度＋１に整形
                    regiTask.priority = (CurrentPriority.last?.priority)! + 1
                }
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
            
            
            
            regiTask.TaskName = Name
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
            
            if isNotification == false{
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
                
            }
            
            let AfterData = try! Realm()
            CurrentPriority = AfterData.objects(Task.self).sorted(byProperty: "priority", ascending: false)
            self.tabBarController?.selectedIndex = 0;
            TimeControl()
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
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["Spicker_\(deleteData.TaskName)"])
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
        let Today = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        
        let StrDate = dateFormat.string(from: Today)
        print("今日は\(StrDate)です")
        
        let MetaDateDB = try! Realm()
        let DataFormat = LastDateInfo()
        let MetaDateData = MetaDateDB.objects(LastDateInfo.self)
        print(MetaDateData)
        let dateInDate = dateFormat.date(from: StrDate)
        let dateInterval = dateInDate?.timeIntervalSince1970
        let dateUnix = Date(timeIntervalSince1970: dateInterval!)
        print(dateInterval)
        print(Int(dateInterval!))
        DataFormat.lastDate = Int(dateInterval!)
        if MetaDateData.count <= 0{
            print("最後のデータ書き込みが行われた日はありません！")
            try! MetaDateDB.write() {
                MetaDateDB.add(DataFormat)
            }
        }else{
            print("最後のデータ書き込みが行われた日は\((MetaDateData.first?.lastDate)!)です")
            try! MetaDateDB.write() {
                MetaDateData.first?.lastDate = Int(dateInterval!)
            }
        }
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        print("通知を受信しました")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
