//
//  CustomRouter.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation

public final class CustomRouter {
    
    private init() {}
    
    private var dispatcherMap = [String: RouteDispatcher]()
    private var groupMap = [String: NativeRouteGroup]()
    private var nativeRouteDispatcher: NativeRouter?
    
    public var undefinedRouteHandler = Delegate<RouteParameter, Void>()
    public var routePathWillOpen = Delegate<RouteParameter, Void>()
    public var routePathDidOpen = Delegate<RouteParameter, Void>()

    public static let shared = CustomRouter()
    
    /// 注册原生页面的分发器
    ///
    /// 原生页面分发器遵循 `NativeRouter`，而 `NativeRouter` 继承于 `RouteDispatcher`。
    /// 只要遵循 `RouteDispatcher`，就可以创建新的自定义分发器。
    ///
    /// - Parameters:
    ///     - dispatcher: 遵循 `NativeRouter` 协议的对象
    public static func registerNativeDispatcher(_ dispatcher: NativeRouter) {
        shared.nativeRouteDispatcher = dispatcher
        shared.dispatcherMap["native"] = dispatcher
    }

    public static func canOpen(by urlString: String) -> Bool {
        let routeParameter = RouteParameter(scheme: "native", fullPath: urlString)
        return canOpen(by: routeParameter)
    }

    public static func canOpen(by routeParameter: RouteParameter) -> Bool {
        let scheme = routeParameter.scheme
        guard let dispatcher = shared.dispatcherMap[scheme] else {
            return false
        }

        return dispatcher.canOpen(routeParameter)
    }

    public static func register(
        withClassName className: String,
        andPath path: RoutePath)
    {
        CustomRouter.shared.nativeRouteDispatcher?.register(className, with: path)
    }

    public static func open(_ urlString: String) {
        open(urlString, urlParameters: nil)
    }

    public static func open(
        _ urlString: String,
        urlParameters: [String: String]? = nil)
    {
        open(urlString,
             urlParameters: urlParameters,
             onViewDidDisappear: nil)
    }

    public static func open(
        _ urlString: String,
        urlParameters: [String: String]?,
        onViewDidDisappear: (([String : Any]?) -> Void)?)
    {
        open(urlString,
             urlParameters: urlParameters,
             ext: nil,
             onViewDidDisappear: onViewDidDisappear)
    }

    public static func open(
        _ urlString: String,
        urlParameters: [String: String]?,
        ext: [String: String]?,
        onViewDidDisappear: (([String : Any]?) -> Void)?)
    {
        open(
            urlString,
            urlParameters: urlParameters,
            ext: ext,
            routeStyle: .push,
            onViewDidDisappear: onViewDidDisappear)
    }

    
    /// 打开指定路由对应的 view controller
    ///
    /// - Parameters:
    ///   - urlString: 路由 String
    ///   - urlParameters: 对应页面所需携带的参数
    ///   - ext: 扩展字段
    ///   - routeStyle: `push` 或者是 `present`
    ///   - onViewDidDisappear: 对应的 view controller 移除时或某些操作出错时的回调。
    ///
    /// - Note: onViewDidDisappear 中还需处理出错的情况，请检查 key 为 "error" 对应的 value。
    public static func open(
        _ urlString: String,
        urlParameters: [String: String]?,
        ext: [String: String]?,
        routeStyle: RouteStyle,
        onViewDidDisappear: (([String : Any]?) -> Void)?)
    {
        if urlString.isEmpty {
            onViewDidDisappear?(["error": "url 为空"])
            return
        }

        let routeParameter = RouteParameter(
            scheme: "native",
            fullPath: urlString,
            path: urlString,
            addition: urlParameters,
            onViewDidDisappear: onViewDidDisappear,
            routeStyle: routeStyle)
        
        router(with: routeParameter)
    }

    
    /// 找到所有包含该路由的分组
    /// - Parameter fullPath: 指定路由 String
    public static func getGroupsByPath(fullPath: String) -> [NativeRouteGroup] {
        var ret = [NativeRouteGroup]()
        for (_, group) in CustomRouter.shared.groupMap {
            if group.paths.contains(fullPath) {
                ret.append(group)
            }
        }

        return ret
    }

    public static func router(with parameter: RouteParameter) {
        let scheme = parameter.scheme
        let fullPath = parameter.fullPath
        
        shared.routePathWillOpen(parameter)

        let groups = getGroupsByPath(fullPath: fullPath)
        var isExistingInOneGroup = !groups.isEmpty

        if !isExistingInOneGroup {
            // 检查有没有对应的分发器可以打开该路由
            isExistingInOneGroup = canOpen(by: parameter)
        }

        if !isExistingInOneGroup {
            // 没有对应的分发器可以处理该路由
            parameter.onViewDidDisappear(["error": "路由不存在, 已重定向到默认页面"])
            CustomRouter.shared.undefinedRouteHandler.call(parameter)
            return
        }

        // 如果处于某个分组内，该分组拦截器开始工作
        for group in groups {
            
            let verificationResult = group.startVertify(
                routePath: fullPath,
                routeParameter: parameter)
            
            if !verificationResult {
                print("被 \(group.name) 分组拦截器拦截")
                return
            }
        }

        
        if let dispatcher = CustomRouter.shared.dispatcherMap[scheme] {
            // 交由对应的分发器处理
            dispatcher.router(with: parameter)
            shared.routePathDidOpen(parameter)
        } else {
            // 未找到对应的调度器
            parameter.onViewDidDisappear(["error": "未找到对应的调度器"])
        }
    }

    /// 添加 path 到指定分组
    public static func addPath(_ path: String, toGroup name: String) {
        if let _ = shared.groupMap[name] {
            // 已经有对应的 group
            if shared.groupMap[name]!.paths.contains(path) {
                // group 里面已经有这个 path
                return
            }
            shared.groupMap[name]!.add(path: path)
        } else {
            let group = NativeRouteGroup(name: name)
            group.add(path: path)
            shared.groupMap[name] = group
        }
    }

    /// 添加一组路径到指定分组
    public static func addPath(_ paths: [String], toGroup name: String) {
        paths.forEach { path in
            addPath(path, toGroup: name)
        }
    }

    /// 指定分组下所有路由
    public static func pathsIn(group name: String) -> [String] {
        if let group = shared.groupMap[name] {
            return group.paths
        }

        return [String]()
    }

    
    /// 设置分组的拦截器
    ///
    /// - Parameters:
    ///   - groupName: 分组名
    ///   - verifyClosure: 拦截器的实现
    ///
    /// - Note: 如果分组不存在，会创建对应的分组
    public static func setGroup(
        _ groupName: String,
        _ verifyClosure: @escaping (_ path: String, _ routeParameter: RouteParameter) -> Bool)
    {
        if let group = shared.groupMap[groupName] {
            group.setVerifyClosure(verifyClosure)
        } else {
            let group = NativeRouteGroup(name: groupName)
            group.setVerifyClosure(verifyClosure)
            shared.groupMap[groupName] = group
        }
    }

    
    /// 回退某个页面
    /// - Parameters:
    ///   - viewControllerToBeKilled: 将被移除的页面
    public static func backward(
        _ viewControllerToBeKilled: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil)
    {
        CustomRouter.shared.nativeRouteDispatcher?.backward(viewControllerToBeKilled, animation: { _ in
            return animated
        }, completion: {
            completion?()
        })
    }

    /// 回退指定数量的页面
    /// - Parameters:
    ///   - count: 数量
    public static func backward(
        _ count: Int,
        animated: Bool = true,
        completion: (() -> Void)?)
    {
        CustomRouter.shared.nativeRouteDispatcher?.backward(
            count,
            animated: animated,
            completion)
    }

    /// 回退至指定路由的页面
    public static func backward(
        toPath path: String,
        animated: Bool = true,
        completion: (() -> Void)?)
    {
        CustomRouter.shared.nativeRouteDispatcher?.backward(
            toPath: path,
            animated: animated,
            completion: completion)
    }
}
