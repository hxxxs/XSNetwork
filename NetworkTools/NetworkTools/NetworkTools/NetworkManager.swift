//
//  NetworkManager.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

import Alamofire
import HandyJSON

typealias NetSuccessBlock<T: HandyJSON> = (_ value: T, _ json: [String: Any]) -> Void
typealias NetFailedBlock = (APIErrorInfo) -> Void

struct NetworkManager {
    static let shared = NetworkManager()
    private var sessionManager: SessionManager?
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        sessionManager = SessionManager(configuration: configuration,
                                        delegate: SessionDelegate(),
                                        serverTrustPolicyManager: nil)
    }
}

// MARK: - request handler

extension NetworkManager {
    
    func send<T: HandyJSON>(request r: APIRequest,
                            success: @escaping NetSuccessBlock<T>,
                            failure: @escaping NetFailedBlock) {
        request(url: r.host + r.path,
                params: r.parameters,
                method: r.method,
                headers: r.headers,
                encoding: r.encoding,
                success: success,
                failure: failure)
    }
    
    func request<T: HandyJSON>(url: String,
                               params: Parameters?,
                               method: HTTPMethod,
                               headers: HTTPHeaders,
                               encoding: ParameterEncoding,
                               success: @escaping NetSuccessBlock<T>,
                               failure: @escaping NetFailedBlock) {
        debugPrint("url: \(url)\n" +
            "params: \(String(describing: params ?? nil))\n" +
            "headers: \(headers)")
        sessionManager?.request(url,
                                method: method,
                                parameters: params,
                                encoding: encoding,
                                headers: headers)
            .responseJSON(completionHandler: { (response) in
                self.responseHandler(response: response, successBlock: success, faliedBlock: failure)
            })
    }
    
}

//  MARK: - response handle

private extension NetworkManager {
    func responseHandler<T: HandyJSON>(response: DataResponse<Any>,
                                       successBlock: NetSuccessBlock<T>,
                                       faliedBlock: NetFailedBlock){
        if let value = response.result.value as? [String: Any] {
            successHandler(value: value,
                           successBlock: successBlock,
                           faliedBlock: faliedBlock)
        } else if let error = response.result.error {
            failedHandler(error: error as NSError,
                          faliedBlock: faliedBlock)
        } else {
            dataFormatFaliure(faliedBlock: faliedBlock)
        }
    }
    
    func failedHandler(error: NSError,
                       faliedBlock: NetFailedBlock) {
        var errorInfo = APIErrorInfo()
        errorInfo.code = error.code
        errorInfo.error = error
        if errorInfo.code == -1009 {
            errorInfo.message = "无网络连接"
        } else if errorInfo.code == -1001 {
            errorInfo.message = "请求超时"
        } else if errorInfo.code == -1005 {
            errorInfo.message = "网络连接丢失(服务器忙)"
        } else if errorInfo.code == -1004 {
            errorInfo.message = "服务器没有启动"
        } else if errorInfo.code == 404 || errorInfo.code == 3 {
        }
        faliedBlock(errorInfo)
    }
    
    func successHandler<T: HandyJSON>(value: [String: Any],
                                      successBlock: NetSuccessBlock<T>,
                                      faliedBlock: NetFailedBlock) {
        if let model = APIModel<T>.deserialize(from: value) {
            if model.code == 0 || model.code == 200 {
                successBlock(model.content, value)
            } else {
                var errorInfo = APIErrorInfo()
                errorInfo.code = model.code
                errorInfo.message = model.message
                faliedBlock(errorInfo)
            }
        } else {
            dataFormatFaliure(faliedBlock: faliedBlock)
        }
    }
    
    func dataFormatFaliure(faliedBlock: NetFailedBlock) {
        var errorInfo = APIErrorInfo()
        errorInfo.code = -1
        errorInfo.message = "数据解析出错"
        faliedBlock(errorInfo)
    }
 
}
