//
//  APIRequest.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

protocol NetRequest {
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

struct NetModel<T: Any>: HandyJSON {
    var code = 0
    var message = ""
    var content: T?
}
