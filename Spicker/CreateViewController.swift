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

class Task: Object { //Realmで使うオブジェクト定義
    @objc dynamic var ID = 0 //ID：データ管理に利用、連番を付け、基本的に一定の数値になるまで使い回しはしない
    @objc dynamic var priority = 0 //優先度
    @objc dynamic var TaskName = "" //タスク名
    @objc dynamic var NotificationTime = 0 //通知時間 UNIX時間で管理
}

class CreateViewController : UIViewController {
    @IBOutlet weak var Priority_box: UITextField!
    @IBOutlet weak var TaskName_box: UITextField!
    @IBOutlet weak var NotificationTime_box: UITextField!
    
    @IBOutlet weak var Number: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func Register(_ sender: Any) { //データ登録
        print("処理に入りました")
        let database = try! Realm()
        let regiTask = Task()
        if Priority_box.text != nil{
            print("優先度は入力されています")
        }else{
            print("優先度が入力されていないため、優先度は１とします")
            Priority_box.text = "1"
        }
        print("regiTaskの定義")
        var CurrentPriority = database.objects(Task.self).sorted(byProperty: "priority", ascending: false) //優先度でソート（降順）
        var CurrentID = database.objects(Task.self).sorted(byProperty: "ID", ascending: false) //IDでソート（降順）
        //print(CurrentPriority)
        let newestID = CurrentID.first?.ID //IDを降順でソートした時、現在登録されているIDの最大値
        let maxestPriority = CurrentPriority.first?.priority //優先度を降順でソートした時、現在登録されている優先度の最大値
        regiTask.priority = Int(Priority_box.text!)! //新規で追加しようとしているIDをUITextBoxから持ってくる（String型になっているためInt型に整形）
        if newestID != nil{ //既にデータが存在する場合の処理
            regiTask.ID = newestID! + 1 //最新のデータのIDに+1したものを新しいデータのIDとする
        }else{ //データが存在しない場合の処理
            regiTask.ID = 1 //IDは強制的に1
        }
        if maxestPriority != nil{ //既に優先度の登録されたデータが存在する場合
            if regiTask.priority == maxestPriority{ //優先度が重複する場合
                regiTask.priority = maxestPriority! + 1 //重複回避のため+1
            }else{ //優先度が重複しない場合
                print("優先度の重複はありませんでした")
            }
            
        }else{ //優先度の登録されたデータが存在しない場合
            regiTask.priority = 1 //優先度は自動で1とする
        }
        
        regiTask.TaskName = TaskName_box.text!
        //task.NotificationTime -> UNIX時間と指定時刻の変換を出来るようになったら作成
        try! database.write { //realmに保存
            database.add(regiTask)
        }
        print(CurrentPriority)

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
