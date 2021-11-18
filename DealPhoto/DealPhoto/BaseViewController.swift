//
//  BaseViewController.swift
//  DealPhoto
//
//  Created by maqiqing on 2021/11/5.
//

import UIKit
import HBDNavigationBar

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        hbd_barTintColor = .theme
//        hbd_barStyle = .black
//        hbd_tintColor = .white
        navigationItem.backButtonTitle = " "
//        view.backgroundColor = .customBackground
    }

}

class BaseNavigationController: HBDNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
