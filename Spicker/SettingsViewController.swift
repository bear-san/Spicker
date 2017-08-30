//
//  SettingsViewController.swift
//  Spicker
//
//  Created by KentaroAbe on 2017/08/04.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import NCMB
import RealmSwift
import Alamofire

class SettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TodayOrTom: UIPickerView!
    @IBOutlet weak var Time: UIDatePicker!
    @IBOutlet weak var isAgree: UISwitch!
    @IBOutlet weak var TableView: UITableView!
    
    var items: [JSON] = []
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let kurasu = CreateViewController()
        kurasu.permitCreate()
        let currentSettingsDB = try! Realm()
        let currentSettings = currentSettingsDB.objects(AppMetaData.self)
        
        if currentSettings.first?.isSendDataPermission != nil{
            isAgree.setOn((currentSettings.first?.isSendDataPermission)!, animated: false)
        }else{
            isAgree.setOn(false, animated: false)
        }
        if currentSettings.first?.CloseTask != nil{
            let currentTime = (currentSettings.first?.CloseTask)!
            let date = Date(timeIntervalSince1970: TimeInterval(currentTime))
            Time.date = date
        }else{
        }
        TableView.dataSource = self
        TableView.delegate = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.TableView.addSubview(refreshControl)
        announce()
        TableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func announce() {
        items = []
        let url = "https://mb.api.cloud.nifty.com/2013-09-01/applications/GaasaqXiXrxQLyN6/publicFiles/oshirase.json"
        Alamofire.request(url).responseJSON{response in
            let json = JSON(response.result.value ?? 0)
            json.forEach{(_, data) in
                self.items.append(data)
            }
            self.TableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //セクション内の行数を返す
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Announce")
        cell.textLabel?.text = items[indexPath.row]["Contents"].string
        cell.detailTextLabel?.text = "掲載日：\(items[indexPath.row]["Date"].stringValue)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { //セクションタイトルを返す（"お知らせ"）
        return "運営からのお知らせ"
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        announce()
        
        self.TableView.reloadData()
        
        sender.endRefreshing()
    }
    
}

