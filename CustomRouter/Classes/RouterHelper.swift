//
//  RouterHelper.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/23.
//

import Foundation

public enum AppEnvironment: String {
    case none
    
    /// 开发环境
    case development
    
    /// 测试环境
    case test
    
    /// 预发环境
    case preProduction
    
    /// 正式环境
    case production
}

public final class RouterHelper {
    
    public static let shared = RouterHelper()
    
    public var getMemberIDDelegation = Delegate<Void, String>()

    public static func setup(_ env: AppEnvironment = .production) {
        UIViewController.methodSwizzle()

        /// 1. 读取 JSON，更新 route path

        /// 2. 设置全局回调
        setUpGlobalCallback()

        /// 3. 注册原生页面
        registerNativeRoutePath()

        /// 4. 注册服务
        registerService()
        
        /// 5. 设置路由分组
        registerGroup()
    }

    private static func registerNativeRoutePath() {
        CustomRouter.registerNativeDispatcher(NativeDispatcher.shared)
        CustomRouter.register(withClassName: "LoginViewController", andPath: RoutePaths.login)
        CustomRouter.register(withClassName: "PaymentViewController", andPath: RoutePaths.payment)
        CustomRouter.register(withClassName: "TestViewController", andPath: RoutePaths.test)
    }
    
    /// 注册服务
    ///
    /// 何谓注册服务？举个例子，使用第三方提供的手机号一键登录 SDK（如闪验等）。
    /// 这种服务提供商一般不会把 viewController 暴露出来，
    /// 而是直接提供打开 viewController 的 API。
    /// 对应的类需要遵循 `RouteService` 协议
    private static func registerService() {
        
    }

    /// 设置路由分组
    ///
    /// 给路由进行分组，每个组有一个拦截器。
    /// 想打开处于某个分组的路由时，必须通过该分组的拦截器的筛选。
    /// 举个例子，常见的组就是 `needLogin`，
    /// 在打开处于该分组的路由时，
    /// 如果用户已登陆，通过筛选，放行。
    /// 如果用户未登录，跳转到登陆页面的路由，
    /// 登陆成功后，再跳转指定的路由。
    private static func registerGroup() {
        let loginGroup = "needLogin"
        // 举个例子，进入支付页面前需要登录才行。
        CustomRouter.addPath(["payment"], toGroup: "needLogin")
        CustomRouter.setGroup(loginGroup) { path, routeParameter in
            let memberID = shared.getMemberIDDelegation() ?? ""
            if memberID.isEmpty {
                CustomRouter.open("login",
                                  urlParameters: nil,
                                  ext: nil,
                                  routeStyle: .present)
                { dict in
                    let memberID = shared.getMemberIDDelegation() ?? ""
                    if !memberID.isEmpty {
                        print("login onViewDidDisappear info: \(String(describing: dict))")
                        print("登录成功后，即将前往：\(routeParameter.fullPath)")
                        CustomRouter.router(with: routeParameter)
                    }
                }
                return false
            }
            return true
        }
    }
    
    /// 设置全局路由回调
    ///
    /// 如 `undefinedRouteHandler`、`routePathWillOpen` 和 `routePathDidOpen`
    private static func setUpGlobalCallback() {
        shared._setUpGlobalCallback()
    }
    
    private func _setUpGlobalCallback() {
        CustomRouter.shared.undefinedRouteHandler.delegate(on: self) { (self, _) in
            assertionFailure("undefinedRoute Error")
        }
        
        CustomRouter.shared.routePathWillOpen.delegate(on: self) { (self, _) in
            print("routePathWillOpen")
        }
        
        CustomRouter.shared.routePathDidOpen.delegate(on: self) { (self, _) in
            print("routePathDidOpen")
        }
    }
    
    public static func testLoginSuccess(_ memberID: String) {
        shared._testLoginSuccess(memberID)
    }
    
    private func _testLoginSuccess(_ memberID: String) {
        getMemberIDDelegation.delegate(on: self) { (self, _) in
            return memberID
        }
    }
    
    public static func testLogout() {
        shared._testLogout()
    }
    
    private func _testLogout() {
        getMemberIDDelegation.discharge()
    }
}
