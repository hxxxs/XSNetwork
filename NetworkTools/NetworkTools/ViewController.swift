//
//  ViewController.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NetworkManager.shared.sendRequest(HomeRequest(), success: { (objc: ProductIndexModel, json) in
            print(objc.toJSON())
        }) { (info) in
            print(info.message)
        }
    }

}

