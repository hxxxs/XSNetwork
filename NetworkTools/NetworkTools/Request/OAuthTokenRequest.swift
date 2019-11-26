//
//  TokenRequest.swift
//  NetworkTools
//
//  Created by LL on 2019/11/26.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import Alamofire

enum OAuthTokenRequest {
    case refresh
    case token(_ username: String, password: String)
}

extension OAuthTokenRequest: NetRequest {
    var host: String {
        return "https://uatjinjiwo.1shitou.cn:16444"
    }
    
    var path: String {
        return "/oauth/token"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        switch self {
        case .refresh:
            return ["refresh_token": "0fb4569b-b3ea-4972-9d91-e0a73e2a2541",
                    "grant_type": "refresh_token",
                    "scope": "app",
                    "client_id": "client_fund_password",
                    "client_secret": "123456",
                    "login_type": "mobile",
                    "identifier": UIDevice.current.identifierForVendor?.uuidString ?? ""]
        case .token(let username, let password):
            return [
                "username": username,
                "password": password,
                "grant_type": "password",
                "scope": "app",
                "client_id": "client_fund_password",
                "client_secret": "123456",
                "login_type": "mobile",
                "identifier": UIDevice.current.identifierForVendor?.uuidString ?? ""
            ]
        }
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    
}
