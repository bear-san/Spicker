//
//  AppDelegate.swift
//  Spicker
//
//  Created by KentaroAbe on 2017/08/03.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import UIKit
import CoreData
import NCMB
import RealmSwift
import UserNotifications
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    let applicationkey = "58f2e74ae4756806feaffeafd1f1dc91df9438b6471702ad1797702cd4f41e26"
    let clientkey = "d920d03343160df8aaff4ba1e7e3b4e601fe02632ba6eca9dbd2ebbedcaeaf2c"
    
    var tasks = [String]()
    
    var currentData_Name:String? = nil
    var currentData_Prioroty:Int? = nil
    var currentData_isNotification:Bool? = nil
    var currentData_notificationTime:Int? = nil
    
    var isDataDeleted = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in if granted {print("通知許可")}
        }
        if #available(iOS 10.0, *){
            /** iOS10以上 **/
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
                if error != nil {
                    // エラー時の処理
                    return
                }
                if granted {
                    // デバイストークンの要求
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            /** iOS8以上iOS10未満 **/
            //通知のタイプを設定したsettingを用意
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            //通知のタイプを設定
            application.registerUserNotificationSettings(setting)
            //DevoceTokenを要求
            UIApplication.shared.registerForRemoteNotifications()
        }
        application.registerForRemoteNotifications()

        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
        // Override point for customization after application launch.
        let userDefault = UserDefaults.standard
        // "firstLaunch"をキーに、Bool型の値を保持する
        let dict = ["firstLaunch": true]
        // デフォルト値登録
        // ※すでに値が更新されていた場合は、更新後の値のままになる
        userDefault.register(defaults: dict)
        
        // "firstLaunch"に紐づく値がtrueなら(=初回起動)、値をfalseに更新して処理を行う
        if userDefault.bool(forKey: "firstLaunch") {
            userDefault.set(false, forKey: "firstLaunch")
            print("初回起動の時だけ呼ばれるよ")
            let data = try! Realm()
            let AddData = AppMetaData()
            
            AddData.isFirstLaunch = true
            AddData.isSendDataPermission = false
            
            try! data.write() {
                data.add(AddData)
            }
        }else{
            print("初回起動じゃなくても呼ばれるアプリ起動時の処理だよ")
            let data = try! Realm()
            let BaseData = data.objects(Task.self).sorted(byKeyPath: "priority", ascending: true)
            
            if BaseData.count == 0{
                
            }else{
                for i in 0...BaseData.count-1 {
                    self.tasks.append(BaseData[i].TaskName)
                }
                
                print(tasks)
            }
            
            let date = Date()
            let dateInUNIX = Int(date.timeIntervalSince1970)
            
            let database = try! Realm()
            let metaData = database.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
            
            if dateInUNIX >= (metaData.first?.CloseTask)!{
                print("登録されているデータは古いものです！")
                let currentData = database.objects(Task.self).sorted(byKeyPath: "ID", ascending: true)
                if currentData.count >= 1{
                    var LastData = currentData.count - 1
                    for z in 0...LastData{
                        try! database.write() {
                            print("削除するデータ：\(currentData[0])")
                            database.delete(currentData[0])
                        }
                    }
                    
                }
                try! database.write() {
                    metaData.first?.CloseTask += 3600*24
                }
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
                
                let notification = UNMutableNotificationContent()
                
                let WantFireNotificationTime = TimeInterval((metaData.first?.CloseTask)! - Int(Date().timeIntervalSince1970))
                print(WantFireNotificationTime)
                notification.title = "タスクは全部終わった？"
                notification.body = "早速次の日の予定を追加しましょう！"
                notification.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: WantFireNotificationTime, repeats: false)
                let request = UNNotificationRequest.init(identifier: "Spicker_Daily", content: notification, trigger: trigger)
                center.add(request)
                
                return true
            }else{
                print("登録されているデータは今日のものです")
                return true
            }
        }
        return true
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("アプリケーションがバックグラウンドになりました")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("アプリケーションがフォアグラウンドになります")
        let date = Date()
        let dateInUNIX = Int(date.timeIntervalSince1970)
        
        let database = try! Realm()
        let metaData = database.objects(AppMetaData.self).sorted(byKeyPath: "ID", ascending: false)
        
        if dateInUNIX >= (metaData.first?.CloseTask)!{
            //print("登録されているデータは古いものです！")
            let currentData = database.objects(Task.self).sorted(byKeyPath: "ID", ascending: true)
            if currentData.count >= 1{
                var LastData = currentData.count - 1
                for z in 0...LastData{
                    try! database.write() {
                        print("削除するデータ：\(currentData[0])")
                        database.delete(currentData[0])
                    }
                }
                
            }
            try! database.write() {
                metaData.first?.CloseTask += 3600*24
            }
            
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
            
            let notification = UNMutableNotificationContent()
            
            let WantFireNotificationTime = TimeInterval((metaData.first?.CloseTask)! - Int(Date().timeIntervalSince1970))
            notification.title = "タスクは全部終わった？"
            notification.body = "早速次の日の予定を追加しましょう！"
            notification.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: WantFireNotificationTime, repeats: false)
            let request = UNNotificationRequest.init(identifier: "Spicker_Daily", content: notification, trigger: trigger)
            center.add(request)
            
        }else{
            print("登録されているデータは今日のものです")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Spicker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation = NCMBInstallation.current()
        // デバイストークンの設定
        installation?.setDeviceTokenFrom(deviceToken as Data!)
        // 端末情報をデータストアに登録
        installation?.saveInBackground { (error) -> Void in
            if (error != nil){
                // 端末情報の登録に失敗した時の処理
                if ((error as! NSError).code == 409001){
                    // 失敗した原因がデバイストークンの重複だった場合
                    // 端末情報を上書き保存する
                    self.updateExistInstallation(currentInstallation: installation!)
                }else{
                    // デバイストークンの重複以外のエラーが返ってきた場合
                }
            }else{
                // 端末情報の登録に成功した時の処理
            }
        }
    }
    
    
    // 端末情報を上書き保存するupdateExistInstallationメソッドを用意
    func updateExistInstallation(currentInstallation : NCMBInstallation){
        let installationQuery: NCMBQuery = NCMBInstallation.query()
        installationQuery.whereKey("deviceToken", equalTo:currentInstallation.deviceToken)
        do {
            let searchDevice = try installationQuery.getFirstObject()
            // 端末情報の検索に成功した場合
            // 上書き保存する
            currentInstallation.objectId = (searchDevice as AnyObject).objectId
            currentInstallation.saveInBackground { (error) -> Void in
                if (error != nil){
                    // 端末情報の登録に失敗した時の処理
                }else{
                    // 端末情報の登録に成功した時の処理
                }
            }
        } catch _ as NSError {
            // 端末情報の検索に失敗した場合の処理
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // MARK: アプリが起動しているときに実行される処理を追記する場所
        print("通知ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!")
        
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

}

