//
//  NetworkAPI.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import Alamofire

struct HomeRequest: APIRequest {
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var url: String {
        return APIURL.home
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return ["uuid": "A9AC5FFA-2E5D-4E54-97DA-EB82DD3164DE", "equipmentType": "ios", "models": "iPhone 11 Pro Max", "systemVersion": "13.2.2", "versionNumber": "1.0.0"]
    }
}
