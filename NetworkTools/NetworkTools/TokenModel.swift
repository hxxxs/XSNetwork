//
//  TokenModel.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import HandyJSON

struct TokenModel: HandyJSON {
    var access_token = ""
    var refresh_token = ""
    
    static var shared = TokenModel()
}
