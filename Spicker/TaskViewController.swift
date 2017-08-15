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

class TaskViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var Bar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    let ap = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad(){
        super.viewDidLoad()
        let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = "Test"
        let path = Document_path + "/" + fileName + ".json"
        print(path)
        print(ap.tasks)
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.reloadData()
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
        cell.textLabel!.text = ap.tasks[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { //セクション数を返す（初期値は１）
        return 1 //今回は別に何かセクション分けする必要はないので必ず１を返す
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { //セクションタイトルを返す（初期値は空）
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セル番号：(indexPath.row) セルの内容：(fruits[indexPath.row])")
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
        self.tableView.reloadData()
    }

    
}

