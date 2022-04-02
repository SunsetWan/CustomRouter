//
//  PaymentViewController.swift
//  CustomRouter_Example
//
//  Created by sunsetwan on 2022/3/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CustomRouter

class PaymentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "pay_Back", style: .plain, target: nil, action: #selector(backward))
        navigationItem.title = "支付页面"
        view.backgroundColor = .lightGray

        if let navigationController = navigationController, let top = navigationController.topViewController {
            if top == self {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backward))
            }
        }
    }

    @objc func backward() {
        CustomRouter.backward(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

