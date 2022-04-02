//
//  NativeRouter.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation

public protocol NativeRouter: RouteDispatcher {
    /// 注册方法
    func register(_ viewControllerName: String, with path: String)
    func unregister(_ viewControllerName: String, with path: String)

    /// 页面回退方法
    func backward(animated: Bool, _ completion: (() -> Void)?)
    func backward(_ count: Int, animated: Bool, _ completion: (() -> Void)?)
    func backward(toPath path: String, animated: Bool , completion: (() -> Void)?)
    func backward(_ viewControllerToBeKilled: UIViewController?, animation: (_ topPath: String?) -> Bool, completion: (() -> Void)?)

    /// 设置路由分组方法
    func addPath(_ path: String, toGroup name: String)
    func pathsIn(group name: String) -> [String]
    func setGroup(_ groupName: String, _ verifyClosure: ((_ path: String, _ routeParameter: RouteParameter) -> Bool)?)

    func openViewController(_ viewController: UIViewController, _ routeParameter: RouteParameter)
}

    /// 提供默认实现
public extension NativeRouter {
    func register(_ viewControllerName: String, with path: String) {}
    func unregister(_ viewControllerName: String, with path: String) {}

    func backward(animated: Bool, _ completion: (() -> Void)?) {}
    func backward(_ count: Int, animated: Bool, _ completion: (() -> Void)?) {}
    func backward(toPath path: String, animated: Bool, completion: (() -> Void)?) {}
    func backward(_ viewControllerToBeKilled: UIViewController?, animation: (_ topPath: String?) -> Bool, completion: (() -> Void)?) {}

    func addPath(_ path: String, toGroup name: String) {}
    func pathsIn(group name: String) -> [String] { return [String]() }
    func setGroup(_ groupName: String, _ verifyClosure: ((_ path: String, _ routeParameter: RouteParameter) -> Bool)?) {}

    func openViewController(_ viewController: UIViewController, _ routeParameter: RouteParameter) {}
}
