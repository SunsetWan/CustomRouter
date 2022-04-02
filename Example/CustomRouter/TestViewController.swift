//
//  TestViewController.swift
//  CustomRouter_Example
//
//  Created by sunsetwan on 2022/3/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CustomRouter

class TestViewController: UIViewController {

    @objc public var testTitle: String?
    
    private let buttonStackView = UIStackView()
    private let payButton = UIButton(type: .custom)
    private let resetLoginStatusButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        assert(navigationController != nil , "找不到 navigationController")

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "t_Back", style: .plain, target: nil, action: #selector(backward))
        navigationItem.title = "Test"

        print("testTitle: \(String(describing: testTitle))")
        
        if let navigationController = navigationController, let top = navigationController.topViewController {
            if top == self {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backward))
            }
        }
        
        setUpButton()
        initLayouts()
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
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(payButton)
        buttonStackView.addArrangedSubview(resetLoginStatusButton)
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 20
        
        payButton.setTitle("去支付", for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        payButton.setTitleColor(.darkGray, for: .normal)
        payButton.addTarget(self, action: #selector(payButtonDidPress), for: .touchUpInside)
        
        resetLoginStatusButton.setTitle("重置登录状态", for: .normal)
        resetLoginStatusButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        resetLoginStatusButton.setTitleColor(.darkGray, for: .normal)
        resetLoginStatusButton.addTarget(self, action: #selector(resetLoginStatusButtonDidPress), for: .touchUpInside)
        
    }
    
    private func initLayouts() {
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func payButtonDidPress() {
        CustomRouter.open(RoutePaths.payment)
    }
    
    @objc func resetLoginStatusButtonDidPress() {
        RouterHelper.shared.getMemberIDDelegation.discharge()
    }
    
    @objc func backward() {
        CustomRouter.backward(self)
    }
}
