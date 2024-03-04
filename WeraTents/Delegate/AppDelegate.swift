//
//  AppDelegate.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import Firebase
import FirebaseCore
import FirebaseAppCheck
class AppDelegate: UIResponder,UIApplicationDelegate{
    
    static private(set) var instance: AppDelegate! = nil
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var providerFactory:AppCheckProviderFactory
#if targetEnvironment(simulator)
        providerFactory = AppCheckDebugProviderFactory()
#else
        providerFactory = WeraAppCheckProvider()
#endif
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        AppDelegate.instance = self
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication){
        PersistenceController.deleteAllDataFromEntity("ScreenshotModel")
        debugLog(object: "free up core data")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication){
        debugLog(object: "Oops I Daisy. Memory is an issue")
    }
    
}

class WeraAppCheckProvider:NSObject,AppCheckProviderFactory{
    func createProvider(with app:FirebaseApp) ->AppCheckProvider?{
        if #available(iOS 14.0, *){
            return AppAttestProvider(app:app)
        } else{
            return DeviceCheckProvider(app: app)
        }
    }
}
