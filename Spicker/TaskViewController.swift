//
//  TaskViewController.swift
//  Spicker
//
//  Created by KentaroAbe on 2017/08/04.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

class TaskViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    @IBOutlet weak var Bar: UINavigationBar!
    @IBOutlet weak var cellTableView: UITableView!
    @IBOutlet weak var HowManyTasks: UILabel!
    
    let ap = UIApplication.shared.delegate as! AppDelegate
    var refreshControl:UIRefreshControl!

    override func viewDidLoad(){
        super.viewDidLoad()
        let data = try! Realm()
        let PermitData = data.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        let kurasu = CreateViewController()
        kurasu.permitCreate()
        print(ap.tasks)
        cellTableView.dataSource = self
        cellTableView.delegate = self
        self.cellTableView.reloadData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.cellTableView.addSubview(refreshControl)
        
        
        RenewHowMany()

    }
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        print("テーブルを下に引っ張った時に呼ばれる")
        print("再読込を行います")
        ap.tasks = [String]()
        let data = try! Realm()
        let BaseData = data.objects(Task.self).sorted(byKeyPath: "priority", ascending: true)
        if BaseData.count >= 1{
            for i in 0...BaseData.count-1 {
                ap.tasks.append(BaseData[i].TaskName)
            }
        }
        RenewHowMany()
        
        print(ap.tasks)
        
        self.cellTableView.reloadData()
        
        sender.endRefreshing()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func JsonGet(fileName :String) -> JSON {
        let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = Document_path + fileName + ".json"
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{ //セクションごとの行数を返す
        return ap.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{ //各行に表示するセルを返す
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        // セルに表示する値を設定する
        cell.textLabel!.text = "\(indexPath.row+1)：\(ap.tasks[indexPath.row])"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { //セクション数を返す（初期値は１）
        return 1 //今回は別に何かセクション分けする必要はないので必ず１を返す
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { //セクションタイトルを返す（初期値は空）
        return ""
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セル番号：\(indexPath.row) セルの内容：\(ap.tasks[indexPath.row])")
    }*/
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "完了！") { (action, index) -> Void in
            self.ap.tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let DataMethod = CreateViewController()
            DataMethod.DataDeletePerDay(dataKeyPriority: indexPath.row)
            self.RenewHowMany()
        }
        deleteButton.backgroundColor = UIColor.blue
        
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "削除"
    }


    
    func DataDelete(ByDate :Bool) -> String {
        print("データの削除を行います")
        var message = ""
        if ByDate == true{
            message = "日時削除完了"
        }else{
            message = "削除完了"
        }
        
        return message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let database = try! Realm()
        let PermitData = database.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
        print(PermitData)
        if PermitData.first?.isFirstLaunch == true {
            print("初回起動と判断されます")
            let alert = UIAlertController(title: "Message",message: "初期設定を行ってください", preferredStyle: .alert)
            let OKbutton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                print("OK")
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "TimeSettings") as! FirstSettingsController
                self.present(nextView, animated: true, completion: nil)
            })
            
            alert.addAction(OKbutton)
            
            self.present(alert, animated: true, completion:nil)
        }
    }
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("フォアグラウンド")
            RenewHowMany()
        }
        
    }
    func RenewHowMany() {
        let DataMethod = CreateViewController()
        let DataBase = try! Realm()
        if DataBase.objects(Task.self).count != nil{
            self.HowManyTasks.text = String(describing:DataBase.objects(Task.self).count)
        }else{
            self.HowManyTasks.text = "0"
        }
        ap.tasks = [String]()
        let data = try! Realm()
        let BaseData = data.objects(Task.self).sorted(byKeyPath: "priority", ascending: true)
        if BaseData.count >= 1{
            for i in 0...BaseData.count-1 {
                ap.tasks.append(BaseData[i].TaskName)
            }
        }
        
        print(ap.tasks)
        
        self.cellTableView.reloadData()
        
    }
}

