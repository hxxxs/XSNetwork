//
//  APIURL.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import Foundation

enum NetworkMode {
    case dev
    case uat
    case pdt
    case release
    
    var host: String {
        switch self {
        case .dev:
            return ""
        case .uat:
            return "https://uatjinjiwo.1shitou.cn:25013/lsj-business"
        case .pdt:
            return ""
        case .release:
            return ""
        }
    }
}

struct APIURL {
    static var currentMode: NetworkMode = .uat
}

//  MARK: - User Module URL
extension APIURL {
    static var home: String {
        return currentMode.host + "/app/lsj/v1.0/home"
    }
}
