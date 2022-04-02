//
//  RouteParameter.swift
//  CustomRouter
//
//  Created by chenxi on 2022/2/20.
//

import Foundation

public enum RouteStyle {
    case push
    case present
}

public final class RouteParameter: NSObject {
    public var scheme: String
    public var fullPath: String
    public var path: String
    
    /// viewController 所携带的参数
    public var addition: [String: String]?
    
    private(set) var onViewDidDisappear = Delegate<[String: Any]?, Void>()
    public var routeStyle: RouteStyle = .push
    public var response: [String: Any]?

    public init(scheme: String = "",
                  fullPath: String = "",
                  path: String = "",
                  addition: [String : String]? = nil,
                  onViewDidDisappear: (([String : Any]?) -> Void)? = nil,
                  routeStyle: RouteStyle = .push) {
        
        self.scheme = scheme
        self.fullPath = fullPath
        self.path = path
        self.addition = addition
        self.routeStyle = routeStyle
        
        super.init()
        
        if let onViewDidDisappear = onViewDidDisappear {
            setOnViewDidDisappear(onViewDidDisappear)
        }
    }

    public func setResponse(_ response: [String: Any]?) {
        self.response = response
    }
    
    private func setOnViewDidDisappear(_ closure: @escaping ([String : Any]?) -> Void) {
        onViewDidDisappear.delegate(on: self) { (self, dictionary) in
            closure(dictionary)
        }
    }
    
    public override var description: String {
        return """
        ==== RouteParameter start ====
        scheme: \(scheme)
        fullPath: \(fullPath)
        addition: \(String(describing: addition))
        routeStyle: \(routeStyle)
        response: \(String(describing: response))
        ==== RouteParameter end ====
        """
    }
}
