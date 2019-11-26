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
    
    @IBAction func login(_ sender: Any) {
        NetTools.shared.send(request: OAuthTokenRequest.token("13704010027", password: "111111a"), success: { (objc: OAuthTokenModel?) in
            guard let objc = objc else { return }
            OAuthTokenModel.shared.access_token = objc.access_token
            OAuthTokenModel.shared.refresh_token = objc.refresh_token
            print("login")
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func request(_ sender: Any) {
        let params = ["username": "13704010027", "tag": "1"]
        NetTools.shared.send(request: UserRequest.top(params), success: { (json) in
            print(json)
        }) { (error) in
            print(error.domain)
        }
    }
}

