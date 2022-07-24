//
//  UiViewController+Extensiton.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 26/06/2022.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
extension UIViewController {
    static func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return keyWindow?.rootViewController?.topMostViewController()
    }
    
    func topMostViewController() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.topMostViewController()
        }
        else if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topMostViewController()
            }
            return tabBarController.topMostViewController()
        }
            
        else if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        else {
            return self
        }
    }
}



//https://github.com/facebook/facebook-ios-sdk/blob/main/samples/FacebookShareSample/FacebookShareSample/ShareViewController.swift
