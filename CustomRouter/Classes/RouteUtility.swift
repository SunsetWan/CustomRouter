//
//  RouteUtility.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/21.
//

import Foundation
import UIKit

struct RouteUtility {
    static var mainWindow: UIWindow? {
        if case let window?? = UIApplication.shared.delegate?.window {
            return window
        } else {
            return nil
        }
    }

    static var topViewController: UIViewController? {
        return getTopViewController(mainWindow?.rootViewController)
    }

    /// 获取当前 viewController 的 topViewController
    private static func getTopViewController(_ viewController: UIViewController?) -> UIViewController? {
        var ret: UIViewController? = nil
        ret = _getTopViewController(viewController)

        if let presentedViewController = ret?.presentedViewController {
            ret = _getTopViewController(presentedViewController)
        }

        return ret
    }

    public static func findViewControllerByPath(_ path: String) -> UIViewController? {
        let rootViewController = mainWindow?.rootViewController
        return _findViewControllerByPath(path, start: rootViewController)
    }

    
    /// 根据路由 String，寻找对应的 viewController
    /// - Parameters:
    ///   - path: 路由 String
    ///   - start: 开始寻找的出发点
    private static func _findViewControllerByPath(_ path: String, start: UIViewController?) -> UIViewController? {
        var ret: UIViewController? = nil
        guard let start = start else {
            return nil
        }
        
        if start.routeParameter?.fullPath ?? "" == path {
            ret = start
            return ret
        }

        if let tabBarController = start as? UITabBarController {
            let selectedViewController = tabBarController.selectedViewController
            return _findViewControllerByPath(path, start: selectedViewController)
        } else if let navigationController = start as? UINavigationController {
            navigationController.viewControllers.forEach { childViewController in
                if let result = _findViewControllerByPath(path, start: childViewController) {
                    ret = result
                }
            }
        } else if let presentedViewController = start.presentedViewController {
            if let result = _findViewControllerByPath(path, start: presentedViewController) {
                ret = result
            }
        }

        return ret
    }

    
    /// 寻找 viewController 所在的 navigation stack 顶端的 UIViewController
    /// - Parameter viewController: 指定的 viewController
    /// - Returns: 当前 navigation stack 顶端的 UIViewController
    private static func _getTopViewController(_ viewController: UIViewController?) -> UIViewController? {
        if let viewController = viewController as? UINavigationController {
            let topViewControllerInNavigationStack = viewController.topViewController
            return _getTopViewController(topViewControllerInNavigationStack)
        } else if let viewController = viewController as? UITabBarController {
            let selectedViewController = viewController.selectedViewController
            return _getTopViewController(selectedViewController)
        } else {
            return viewController
        }
    }
}

extension String {
    /// Swift class 带有命名空间
    /// 需要获取完整的 Swift 类的类名
    public var namespacedSwiftClassName: AnyClass? {
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            let swiftClassName = appName + "." + self
            return NSClassFromString(swiftClassName)
        }
        return nil
    }
}




