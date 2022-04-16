//
//  ViewController.swift
//  CustomRouter
//
//  Created by sunset wan on 03/31/2022.
//  Copyright (c) 2022 sunset wan. All rights reserved.
//

import UIKit
import CustomRouter

class ViewController: UIViewController {
    
    private let button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        setUpNavigationBar()
        setUpButton()
        initLayouts()
        setRouteParameter()
    }
    
    private func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "v_Back", style: .plain, target: nil, action: nil)
    }
    
    private func setUpButton() {
        button.setTitle("Go! Go! Go!", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
        view.addSubview(button)
    }
    
    private func initLayouts() {
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setRouteParameter() {
        let parameter = RouteParameter(scheme: "native", fullPath: "firstViewController")
        routeParameter = parameter
    }
    
    @objc func buttonDidPress() {
        CustomRouter.open(
            RoutePaths.test,
            urlParameters: ["testTitle": "testTitle KVC 赋值成功！"])
    }
}

