//
//  UIViewController+Router.swift
//  BBRouterChenxiImpl
//
//  Created by chenxi on 2022/2/23.
//

import Foundation

protocol RouteProtocol {}

extension UIViewController: RouteProtocol {
    private enum AssociatedKey {
        static var RouteParameter = "RouteParameter"
    }

    public var routeParameter: RouteParameter? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.RouteParameter) as? RouteParameter
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.RouteParameter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public static func methodSwizzle() {
        let aClass = self
        let originMethod0 = class_getInstanceMethod(aClass, #selector(viewWillAppear(_:)))
        let swizzledMethod0 = class_getInstanceMethod(aClass, #selector(chenxi_viewWillAppear(_:)))

        if let originMethod0 = originMethod0, let swizzledMethod0 = swizzledMethod0 {
            method_exchangeImplementations(originMethod0, swizzledMethod0)
        }

        let originMethod1 = class_getInstanceMethod(aClass, #selector(viewDidDisappear(_:)))
        let swizzledMethod1 = class_getInstanceMethod(aClass, #selector(chenxi_viewDidDisAppear(_:)))

        if let originMethod1 = originMethod1, let swizzledMethod1 = swizzledMethod1 {
            method_exchangeImplementations(originMethod1, swizzledMethod1)
        }
    }

    @objc func chenxi_viewWillAppear(_ animated: Bool) {
        self.chenxi_viewWillAppear(animated)
        print("chenxi_viewWillAppear")
    }
    
    /// 方法交换后的 `viewDidDisAppear`
    ///
    /// 当前页面所在 navigationController 被移除了，该页面也视为被移除了。
    /// 页面成功打开后，在它被移除后的时机，
    /// 回调其 `routeParameter` 的 `onViewDidDisappear`，可用来回传一些信息
    @objc func chenxi_viewDidDisAppear(_ animated: Bool) {
        self.chenxi_viewDidDisAppear(animated)
        print("chenxi_viewDidDisAppear")
        if let navigationController = navigationController {
            if isBeingDismissed || navigationController.isBeingDismissed || isMovingFromParent {
                onViewDidDisappear()
            }
        } else {
            if isBeingDismissed || isMovingFromParent {
                onViewDidDisappear()
            }
        }
    }

    @objc func onViewDidDisappear() {
        print(#function)
        if let routeParameter = routeParameter {
            routeParameter.onViewDidDisappear(routeParameter.response)
            // TODO: reusable onViewDidDisappear
        }
    }
    
    /// 异步 `onViewDidDisappear` 回调
    ///
    /// 回调的时机在该 viewController 被移除时
    public func asyncOnViewDidDisappearCallback(_ response: [String: Any]?) {
        routeParameter?.setResponse(response)
    }
    
    /// 同步 `onViewDidDisappear` 回调
    ///
    /// 得考虑回调是否复用的问题，
    /// 如果不考虑，同步回调结束后，异步回调还会执行一次。
    /// 默认无法复用。
    public func syncOnViewDidDisappearCallback(_ response: [String: Any]?) {
        routeParameter?.setResponse(response)
        onViewDidDisappear()
        routeParameter?.onViewDidDisappear.discharge()
    }
}
