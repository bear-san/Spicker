//
//  FirstSettings.swift
//  Spicker
//
//  Created by KentaroAbe on 2017/09/04.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class FirstSettingsController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    var yesOrTod = ["前日","当日"]
    var desc = 0
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yesOrTod.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        self.desc = row
        return yesOrTod[row]
    }
    
    
    @IBOutlet weak var todayOrTom: UIPickerView!
    @IBOutlet weak var Time: UIDatePicker!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if self.restorationIdentifier == "TimeSettings"{
            self.todayOrTom.dataSource = self
            self.todayOrTom.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func GetSendPrem(_ sender: Any) {
        GetUserPermission()
    }
    
    @IBAction func NextToOther(_ sender: Any) {
        print(self.desc)
        let rawTime = Time.date
        var nextTime = Int(rawTime.timeIntervalSince1970)
        print(nextTime)
        if self.desc == 1{ //当日指定の場合はNextTimeに１日プラス（今日は実行しない）
            nextTime += 3600*24
        }
        var TimeIn = Date(timeIntervalSince1970: TimeInterval(nextTime))
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        let TimeInFormatted = format.string(from: TimeIn)
        let newFormat = "\(TimeInFormatted):00"
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newDate = format.date(from: newFormat)
        
        var newDateUNIX = Int((newDate?.timeIntervalSince1970)!)
        
        let today = Date()
        if Int(today.timeIntervalSince1970) >= newDateUNIX{ //指定時間を既に過ぎている場合はNextTimeに１日プラス（今日は実行しない）
            newDateUNIX += 3600*24
        }
        print(newDateUNIX)
        let data = try! Realm()
        let PermitData = data.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
        try! data.write() {
            PermitData[0].CloseTask = newDateUNIX
        }
        print(PermitData)
        
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "OtherSettings") as! FirstSettingsController
        self.present(nextView, animated: true, completion: nil)

        
    }
    
    
    func GetUserPermission() {
        let data = try! Realm()
        let PermitData = data.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
        let alert = UIAlertController(title: "利用状況の送信",message: "アプリの品質向上のため、\n利用状況の送信に同意しますか？\n \n***送信されるデータ***\n・タスクを追加した日\n・タスクの名前\n・タスクの優先度\n・タスクの通知時間\n　\n送信されたデータはユーザーの特定が出来ない形で保存され、ユーザーの許可なしに第三者へ提供することは一切ありません \nなおこの設定は後から「Settings」で変更できます", preferredStyle: .alert)
        let OKbutton = UIAlertAction(title: "同意する", style: UIAlertActionStyle.default, handler: { action in
            print("許可されました")
            let data = try! Realm()
            let AddData = AppMetaData()
            let PermitData = data.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
            try! data.write() {
                PermitData[0].isSendDataPermission = true
            }
        })
        let NGbutton = UIAlertAction(title: "同意しない", style: UIAlertActionStyle.destructive, handler: { action in
            print("許可されませんでした")
            let data = try! Realm()
            let AddData = AppMetaData()
            
            try! data.write() {
                PermitData[0].isSendDataPermission = false
            }
        })
        alert.addAction(OKbutton)
        alert.addAction(NGbutton)
        
        self.present(alert, animated: true, completion:nil)
    }
}
