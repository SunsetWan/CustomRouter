//
//  RouteDispatcher.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation

public protocol RouteDispatcher {
    func canOpen(_ parameter: RouteParameter) -> Bool
    func router(with parameter: RouteParameter)
}

public extension RouteDispatcher {
    func canOpen(_ routeParameter: RouteParameter) -> Bool {
        return false
    }

    func router(with parameter: RouteParameter) {}
}
