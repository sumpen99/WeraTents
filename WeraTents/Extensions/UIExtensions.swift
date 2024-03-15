//
//  UIExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.backgroundColor = UIColor(named: "light-green")
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    static func changeAppearance(){
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = UIColor(named:"dark-green")

        let attrsLarge: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            //.font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .black)
        ]
        let attrsSmall: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            //.font: UIFont.monospacedSystemFont(ofSize: 20, weight: .black)
        ]
        appearance.titleTextAttributes = attrsSmall
        appearance.largeTitleTextAttributes = attrsLarge
        //appearance.shadowColor = UIColor(named:"dark-green")
      
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        UINavigationBar.appearance().titleTextAttributes = attrsLarge
        UINavigationBar.appearance().largeTitleTextAttributes = attrsLarge
    }
}

extension UIView{
    
    static func changeUIAlertTintColor(){
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        .tintColor = UIColor.blue
    }
}


extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
