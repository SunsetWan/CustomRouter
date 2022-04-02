//
//  NativeDispatcher.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation
import UIKit

public final class NativeDispatcher: NativeRouter {
    public static let shared = NativeDispatcher()

    /// - key: 路由 String
    /// - value: 对应的 view controller 名称
    private var pathDictionary = [String: [String]]()
    
    private init() {
        commonInit()
    }
    
    private func commonInit() {
        CustomRouter.registerNativeDispatcher(self)
    }

    private func open(_ page: RouteProtocol, with parameter: RouteParameter) {
        let animated = true
        let isViewController = page is UIViewController
        
        if !isViewController {
            return
        }
        
        let page = page as! UIViewController

        page.hidesBottomBarWhenPushed = true

        /// 获取 page 的类型信息
        let type = type(of: page)

        let addition = parameter.addition ?? [String: String]()

        for (key, value) in addition {
            // 利用 KVC 进行赋值
            if containIVAR(of: type, name: key) {
                page.setValue(value, forKey: key)
            }
        }
        
        let sourcePage = RouteUtility.topViewController?.routeParameter?.fullPath
        if let sourcePage = sourcePage {
            // 记录从哪个路由过来
            page.routeParameter?.addition?["from"] = sourcePage
        }
        
        let topViewController = RouteUtility.topViewController
        let currentNavigationController = topViewController?.navigationController
        let routeStyle: RouteStyle = parameter.routeStyle
        
        if routeStyle == .present {
            let willBePresentedViewController: UIViewController
            let isNavigationController = page is UINavigationController
            if isNavigationController {
                willBePresentedViewController = page as! UINavigationController
                RouteUtility.topViewController?.present(willBePresentedViewController, animated: animated, completion: {
                    // routingFinishWithValues
                })
            } else {
                willBePresentedViewController = UINavigationController(rootViewController: page)
                RouteUtility.topViewController?.present(willBePresentedViewController, animated: animated, completion: {
                    // routingFinishWithValues
                })
            }
        } else {
            if let currentNavigationController = currentNavigationController {
                // 找到当前的 UINavigationController
                // routingBeginWithValues
                print("willRoute")
                currentNavigationController.pushViewController(page, animated: true)
                print("didRoute")
                // routingFinishWithValues
            } else {
                // 未找到当前的 UINavigationController
                let navigationController = UINavigationController(rootViewController: page)
                navigationController.modalPresentationStyle = .fullScreen
                // routingBeginWithValues
                print("willRoute")
                topViewController?.present(navigationController, animated: true, completion: {
                    print("didRoute")
                    // routingFinishWithValues
                })
            }
        }
    }
    
    
    /// 在进行 KVC 赋值之前，检查是否有对应的 IVAR
    /// - Parameters:
    ///   - someClass: 类型信息
    ///   - name: 类名
    private func containIVAR(of someClass: AnyClass, name: String) -> Bool {
        let typeInfo = YYClassInfo(with: someClass)!
        let nameWithUnderscore = "_\(name)"

        let ivarInfo = typeInfo.ivarInfos
        let propertyInfo = typeInfo.propertyInfos

        if let ivarInfo = ivarInfo, ivarInfo[name] != nil || ivarInfo[nameWithUnderscore] != nil {
            return true
        }

        if let propertyInfo = propertyInfo, propertyInfo[name] != nil || propertyInfo[nameWithUnderscore] != nil {
            return true
        }

        guard let superClass = class_getSuperclass(someClass) else {
            return false
        }

        return containIVAR(of: superClass, name: name)
    }
}

// MARK: BBRouterDispatcher
extension NativeDispatcher: RouteDispatcher {
    public func canOpen(_ parameter: RouteParameter) -> Bool {
        let fullPath = parameter.fullPath
        if let _ = NativeDispatcher.shared.pathDictionary[fullPath] {
            return true
        } else {
            return false
        }
    }

    public func router(with parameter: RouteParameter) {
        let _ = parameter.fullPath

        let path = parameter.path

        guard let pages = NativeDispatcher.shared.pathDictionary[path] else {
            parameter.onViewDidDisappear(["error": "path 未注册"])
            return
        }

        // FIXME: 初步实现，一个 path 对应一个页面
        // 🔗: https://stackoverflow.com/questions/24030814/swift-language-nsclassfromstring
        let className = pages.first ?? ""
        guard let classType = className.namespacedSwiftClassName else {
            parameter.onViewDidDisappear(["error": "根据类名找不到对应类"])
            return
        }

        let ifComforms = classType is RouteService.Type
        if ifComforms {
            // 交由这个类自己处理
            let type = classType as! RouteService
            type.router(with: parameter)
            return
        }

        // 🔗: https://stackoverflow.com/questions/24119501/how-to-convert-anyclass-to-a-specific-class-and-init-it-dynamically-in-swift
        let viewControllerType = classType as? UIViewController.Type
        if let viewControllerType = viewControllerType {
            let viewController = viewControllerType.init()
            viewController.routeParameter = parameter
            open(viewController, with: parameter)
        } else {
            parameter.onViewDidDisappear(["error": "类型信息错误"])
        }
    }
}

// MARK: BBNativeRouter
extension NativeDispatcher {
    public func register(_ viewControllerName: String, with path: String) {
        if let _ = pathDictionary[path] {
            // 已经有对应的页面
            pathDictionary[path]!.append(viewControllerName)
        } else {
            pathDictionary[path] = [viewControllerName]
        }
    }

    public func unregister(_ viewControllerName: String, with path: String) {
        assertionFailure("Not implemented!")
    }

    public func backward(animated: Bool, _ completion: (() -> Void)?) {
        backward(RouteUtility.topViewController) { _ in
            return true
        } completion: {
            completion?()
        }
    }

    public func backward(
        _ count: Int,
        animated: Bool,
        _ completion: (() -> Void)?)
    {
        if count <= 0 {
            completion?()
            return
        }

        while count != 0 {
            backward(animated: animated) { [self] in
                backward(count - 1, animated: animated, completion)
            }
        }
    }

    public func backward(
        toPath path: String,
        animated: Bool,
        completion: (() -> Void)?)
    {
        if let target = RouteUtility.findViewControllerByPath(path) {
            backward(target) { _ in
                return true
            } completion: {
                completion?()
            }
        } else {
            completion?()
        }
    }

    public func backward(
        _ viewControllerToBeKilled: UIViewController?,
        animation: (_ topPath: String?) -> Bool,
        completion: (() -> Void)?) {
        guard let viewControllerToBeKilled = viewControllerToBeKilled else {
            assertionFailure()
            return
        }

        // 由 `animation` 决定是否需要动画效果
        let _ = animation(viewControllerToBeKilled.routeParameter?.fullPath)

        if let navigationViewController = viewControllerToBeKilled.navigationController,
           let topViewController = navigationViewController.topViewController {
            if topViewController == viewControllerToBeKilled { // viewControllerToBeKilled 为栈顶页面
                if navigationViewController.viewControllers.count == 1 {
                    // 当前 viewControllerToBeKilled 在 navigationViewController 中，
                    // 且 viewControllerToBeKilled 为 rootViewController
                    if let presentingViewController = navigationViewController.presentingViewController {
                        // 找到当前 viewControllerToBeKilled 所在的 navigationViewController 的 presentingViewController
                        // routingBeginWithValues
                        presentingViewController.dismiss(animated: true, completion: completion)
                        // routingFinishWithValues
                        // routingDismissWithValues
                        print("routingDismissWithValues")
                    } else {
                        assertionFailure()
                        completion?()
                    }
                } else {
                    // viewControllerToBeKilled 是当前 topViewController，
                    // 且不是 navigationStack 中唯一的元素，直接 pop 即可。
                    // routingBeginWithValues
                    navigationViewController.popViewController(animated: true)
                    // routingFinishWithValues
                    completion?()
                }
            }
        } else {
            // viewControllerToBeKilled 是 present 出来的
            if let presentingViewController = viewControllerToBeKilled.presentingViewController {
                // routingBeginWithValues
                presentingViewController.dismiss(animated: true, completion: completion)
                // routingFinishWithValues
                // routingDismissWithValues
            } else {
                assertionFailure()
                completion?()
            }
        }
    }

    public func openViewController(_ viewController: UIViewController, _ routeParameter: RouteParameter) {
        open(viewController, with: routeParameter)
    }
}



