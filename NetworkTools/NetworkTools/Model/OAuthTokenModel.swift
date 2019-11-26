//
//  OAuthTokenModel.swift
//  NetworkTools
//
//  Created by LL on 2019/11/26.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import HandyJSON

struct OAuthTokenModel: HandyJSON {
    static var shared = OAuthTokenModel()
    var access_token = ""
    var refresh_token = ""
}
