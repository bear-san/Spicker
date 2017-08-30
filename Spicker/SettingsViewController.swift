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

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var TodayOrTom: UIPickerView!
    @IBOutlet weak var Time: UIDatePicker!
    @IBOutlet weak var isAgree: UISwitch!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let currentSettingsDB = try! Realm()
        let currentSettings = currentSettingsDB.objects(AppMetaData.self)
        
        if currentSettings.first?.isSendDataPermission != nil{
            isAgree.isOn = (currentSettings.first?.isSendDataPermission)!
        }else{
            isAgree.isOn = false
        }
        if currentSettings.first?.CloseTask != nil{
            let currentTime = (currentSettings.first?.CloseTask)!
            let date = Date(timeIntervalSince1970: TimeInterval(currentTime))
            Time.date = date
        }else{
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func Settings() {
        
    }
    
}

