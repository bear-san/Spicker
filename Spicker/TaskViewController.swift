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
let tasks = ["今日やること1","今日やること2"]

class TaskViewController : UIViewController/*, UITableViewDelegate, UITableViewDataSource */{
    
    
    
    @IBOutlet weak var Bar: UINavigationBar!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let Document_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = "Test"
        let path = Document_path + "/" + fileName + ".json"
        print(path)
        
        
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
    
   // public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{ //セクションごとの行数を返す
       /* let sectionData = tableData[section]
 return sectionData.count:?
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{ //各行に表示するセルを返す
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") //セルを作る
        let sectionData = tasks[(IndexPath() as NSIndexPath).section]
        let cellData = tasks[(IndexPath() as NSIndexPath).row]
        cell.textLabel?.text = cellData.0
        cell.detailTextLabel?.text = cellData.1
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int { //セクション数を返す（初期値は１）
        return 1 //今回は別に何かセクション分けする必要はないので必ず１を返す
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { //セクションタイトルを返す（初期値は空）
        return tasks[section]
    }
    
 */
}

