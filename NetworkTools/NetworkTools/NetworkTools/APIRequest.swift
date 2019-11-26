//
//  APIRequest.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import Alamofire
import HandyJSON

protocol APIRequest {
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders { get }
}

struct APIErrorInfo {
    var code = 0
    var message = ""
    var error = NSError()
}

struct APIModel<T: HandyJSON>: HandyJSON {
    var code = 0
    var message = ""
    var content = T()
}
