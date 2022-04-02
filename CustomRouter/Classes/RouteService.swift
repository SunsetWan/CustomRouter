//
//  RouteService.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation

/// 适用于打开某个 SDK 中提供的页面等
protocol RouteService {
    func router(with parameter: RouteParameter)
}

extension RouteService {
    func router(with parameter: RouteParameter) {}
}
