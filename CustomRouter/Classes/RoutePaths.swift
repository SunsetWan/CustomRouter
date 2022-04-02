//
//  RoutePaths.swift
//  CustomRouter
//
//  Created by sunsetwan on 2022/3/31.
//

import Foundation

public typealias RoutePath = String

/// 利用 KVC 更新 BBRoutePaths 的属性
@objcMembers public final class RoutePaths: NSObject {
    public static var login = "login"
    public static var payment = "payment"
    public static var test = "test"
    
    public override class func setValue(_ value: Any?, forUndefinedKey key: String) {
        assertionFailure("未找到对应的 key: \(key)，请更新路由 JSON 文件")
    }
}
