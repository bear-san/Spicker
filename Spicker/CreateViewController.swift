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

class CreateViewController : UIViewController {
    let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    @IBOutlet weak var Priority_box: UITextField!
    @IBOutlet weak var TaskName_box: UITextField!
    @IBOutlet weak var NotificationTime_box: UITextField!
    
    @IBOutlet weak var Number: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
        let fileName = "Test"
        let path = Document_path + "/" + fileName + ".json"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Register(_ sender: Any) { //データ登録
        var JsonNum = JsonGet(fileName: "schedule_test1") //JSONを参照してデータの個数を特定
        if JsonNum == nil{ //何らかの理由でJSONファイルが読み込めなかった場合は、アプリ内に保持しているサンプルのJSONファイルをDocumentにコピーして再試行
            let path = Bundle.main.path(forResource: "example", ofType: "json")
            let ToPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let second_filename = "schedule_test1.json"
            print("\(ToPath)/\(second_filename)")
            try! FileManager.default.copyItem(atPath: path!, toPath: "\(ToPath)/\(second_filename)");
            JsonNum = JsonGet(fileName: "schedule_test1")
        }
        print(JsonNum)
        let DataNum = String(describing:JsonNum["DataNum"]) //データの個数を代入
        var DataNumber = Int(DataNum)!
        print(DataNumber)
        let TaskName = self.TaskName_box.text!
        var Priority = self.Priority_box.text!
        if Priority == ""{
            print("優先度が入力されていないため、最下位にデータを作成します")
            Priority = String(describing:DataNumber+1) //優先度が入力されていない場合は、最下位にデータ差し込み
        }
        let NotificationTime = self.NotificationTime_box.text!
        
        let RegisterData = ["Priority":Priority,"TaskName":TaskName,"notificationTime":NotificationTime] //登録用データの作成（Dictionry型）
        
        print(RegisterData)
        var dic:Dictionary<String,Any> = [:]
        for i in 1...DataNumber { //既存のJSONのデータの個数（先頭に表示するルール）分繰り返す
            print(i) //iは現在の繰り返しの回数
            
            var StrI = String(describing:i)
            dic[String(describing:i)] = ["Priority":JsonNum["Description"][StrI]["Priority"],"TaskName":JsonNum["Description"][StrI]["TaskName"],"notificationTime":JsonNum["Description"][StrI]["notificationTime"]] //優先度がiのデータをDictionary型変数に代入
            //print(dic[String(describing:i)])
        }
        for i in 1...DataNumber { //既存のJSONのデータの個数（先頭に表示するルール）分繰り返す
           print(dic[String(describing:i)])
        }
        var newData:Dictionary<String,Any> = [:]
        for j in 1...Int(Priority)!-1 { //新規追加データの影響を受けないデータの作成（新規データの優先度−１の優先度を登録する）
            print(j)
            var StrJ = String(describing:j)
            newData[String(describing:j)] = ["Priority":StrJ,"TaskName":JsonNum["Description"][StrJ]["TaskName"],"notificationTime":JsonNum["Description"][StrJ]["notificationTime"]]
        }
        DataNumber += 1
        newData[Priority] = ["Priority":Priority,"TaskName":TaskName,"notificationTime":NotificationTime] //新規追加データの差し込み
        for k in Int(Priority)!+1...DataNumber+1{ //新規追加データの影響を受けるデータの作成（新規データの優先度＋１の優先度を登録する）
            print(k)
            var StrK = String(describing:k-1) //優先度をString型に変換（kは新規データを追加した新しい優先度として使う）
            var StrK_Newal = String(describing:k)
            newData[String(describing:k)] = ["Priority":StrK_Newal,"TaskName":JsonNum["Description"][StrK]["TaskName"],"notificationTime":JsonNum["Description"][StrK]["notificationTime"]]
        }
        print("新規データ追加後のデータ数は" + String(describing:DataNumber) + "個です")
        print(newData)
        
        let newData_NS = NSDictionary(dictionary: newData)
        print(newData_NS)
        
        var toJsonData:Dictionary<String, AnyObject> = [:]
        toJsonData["DataNum"] = NSString(string: String(describing:DataNumber))
        toJsonData["Description"] = NSDictionary(dictionary: newData_NS)
        print("Dictionaryデータの作成が完了しました")
        
        print(toJsonData)
        var json: String = ""
        /*do {
            // Dict -> JSON
            let jsonData = try JSONSerialization.data(withJSONObject: toJsonData, options: []) //(*)options??
            
            json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            print("jsonデータ")
        } catch {
            print("Error!: \(error)")
        }
        
        let strData = json.data(using: String.Encoding.utf8)
        print(strData)
 */
        let jsonData = try? JSONSerialization.data(withJSONObject: toJsonData, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)
        print(jsonString)
        
        
        //Dictionary型への変換プログラム作成済み
        //Dictionary -> jsonのプログラム作成中（エラーあり）
        //現在データの追加は１つのみ可（jsonを書き換えていないため）
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
