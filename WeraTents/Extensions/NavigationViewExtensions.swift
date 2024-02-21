//
//  NavigationViewExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

extension UIApplication{
    static func connectedScenes() -> [UIWindow]{
        self.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
    }
    static func rootViewController() -> UIViewController?{
        let scenes = self.connectedScenes()
        return scenes.first{ $0.isKeyWindow }?.rootViewController
    }
}

struct NavigationUtil {
    static func popToRootView(animated: Bool = false) {
        let rootUIViewController = UIApplication.rootViewController()
        if let uiNavController = findNavigationController(viewController:rootUIViewController){
            uiNavController.popViewController(animated: animated)
        }
    }
    
    static private func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}
