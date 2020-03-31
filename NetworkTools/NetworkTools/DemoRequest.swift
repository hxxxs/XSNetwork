//
//  DemoRequest.swift
//  NetworkTools
//
//  Created by LL on 2019/11/26.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

struct HomeRequest: NetRequest {
    var host: String {
        return "https://uat.jinjiwo.com:25013/lsj-business"
    }
    
    var path: String {
        return "/app/lsj/v1.0/home"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}

enum UserRequest {
    case getCode(_ params: Parameters)
    case top(_ params: Parameters)
}

extension UserRequest: NetRequest {
    var host: String {
        return "https://uat.jinjiwo.com:25013/lsj-business"
    }
    
    var path: String {
        switch self {
        case .getCode:
            return "/sms/code/req"
        default:
            return "/lsj/fame/income/v1.0/top"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCode:
            return .post
        default:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getCode(let p):
            return p
        case .top(let p):
            return p
        }
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
