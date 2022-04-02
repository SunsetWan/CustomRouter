//
//  LoginViewController.swift
//  CustomRouter_Example
//
//  Created by sunsetwan on 2022/3/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CustomRouter

class LoginViewController: UIViewController {

    private let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登陆页面"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "login_Back", style: .plain, target: nil, action: #selector(backward))
        view.backgroundColor = .darkGray
        
        setUpButton()
        initLayouts()

        if let navigationController = navigationController, let top = navigationController.topViewController {
            if top == self {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backward))
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setUpButton() {
        button.setTitle("模拟登录成功", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
    }
    
    private func initLayouts() {
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 80),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func buttonDidPress() {
        let memberID = "123456"
        RouterHelper.testLoginSuccess(memberID)
        asyncOnViewDidDisappearCallback(["success": "登录成功",
                       "memeberID": memberID])
        CustomRouter.backward(self)
    }
    
    @objc func backward() {
        CustomRouter.backward(self)
    }

}
