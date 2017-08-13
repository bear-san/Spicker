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

class CreateViewController : UIViewController {
    let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    @IBOutlet weak var Priority_box: UITextField!
    @IBOutlet weak var TaskName_box: UITextField!
    @IBOutlet weak var NotificationTime_box: UITextField!
    
    class Task: Object { //Realmで使うオブジェクト定義
        @objc dynamic var ID = Int() //ID：データ管理に利用、基本的に一定の数値になるまで使い回しはしない
        @objc dynamic var priority = Int() //優先度
        @objc dynamic var TaskName = String() //タスク名
        @objc dynamic var NotificationTime = Int() //通知時間、Int型なのはTimeInterval用
    }

     let database = try! Realm()
    
    @IBOutlet weak var Number: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Register(_ sender: Any) { //データ登録
        let task:Task = Task()
        if Priority_box.text != nil{
            print("優先度は入力されています")
        }else{
            print("優先度が入力されていないため、優先度は１とします")
            Priority_box.text = "1"
        }
        task.priority = Int(Priority_box.text!)!
        task.TaskName = TaskName_box.text!
        //task.NotificationTime -> UNIX時間と指定時刻の変換を出来るようになったら作成
        try! database.write { //realmに保存
            database.add(task)
        }

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
