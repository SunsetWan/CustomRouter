//
//  NativeRouteGroup.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/22.
//

import Foundation


/// 原生页面的分组
public final class NativeRouteGroup {
    let name: String
    private(set) var paths: [String]
    
    /// 分组拦截器
    private var verifyDelegation = Delegate<(String, RouteParameter), Bool>()

    init(name: String,
         verifyClosure: ((String, RouteParameter) -> Bool)? = nil,
         paths: [String] = [String]()) {
        self.name = name
        self.paths = paths
        if let verifyClosure = verifyClosure {
            self.verifyDelegation.delegate(on: self) { (self, arg1) in
                let (path, routeParameter) = arg1
                return verifyClosure(path, routeParameter)
            }
        }
    }
    
    func add(path: RoutePath) {
        paths.append(path)
    }
    
    /// 该分组的拦截器开始执行
    func startVertify(routePath: String, routeParameter: RouteParameter) -> Bool {
        let tuple = (routePath, routeParameter)
        return verifyDelegation.call(tuple) ?? false
    }
    
    /// 设置该分组的拦截器的实现
    func setVerifyClosure(_ closure: @escaping ((_ path: String, _ routeParameter: RouteParameter) -> Bool)) {
        verifyDelegation.discharge()
        verifyDelegation.delegate(on: self) { (self, argv1) in
            let (path, routeParameter) = argv1
            return closure(path, routeParameter)
        }
    }
}
