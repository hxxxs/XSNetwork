//
//  NetworkManager.swift
//  NetworkTools
//
//  Created by LL on 2019/11/25.
//  Copyright © 2019 hxxxxs. All rights reserved.
//

@_exported import Alamofire
@_exported import HandyJSON

typealias NetSuccessBlock<T: Any> = (_ value: T?) -> Void
typealias NetSuccessJSONBlock = (_ json: [String: Any]) -> Void
typealias NetFailedBlock = (NSError) -> Void

//  MARK: - Tools

struct NetTools {
    static let shared = NetTools()
    private var sessionManager: SessionManager?
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        sessionManager = SessionManager(configuration: configuration,
                                        delegate: SessionDelegate(),
                                        serverTrustPolicyManager: nil)
        sessionManager?.adapter = NetAdapter()
        sessionManager?.retrier = NetRetrier()
    }
}

//  MARK: - Adapter

class NetAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
//        request.setValue("", forHTTPHeaderField: "models")
//        request.setValue("", forHTTPHeaderField: "uuid")
//        request.setValue("", forHTTPHeaderField: "versionNumber")
        request.setValue("1.0.0", forHTTPHeaderField: "systemVersion")
        request.setValue("iOS", forHTTPHeaderField: "equipmentType")
        if OAuthTokenModel.shared.access_token.count > 0 {
            request.setValue(OAuthTokenModel.shared.access_token, forHTTPHeaderField: "accessToken")
        }
        return request
    }
}

//  MARK: - Retrier

class NetRetrier: RequestRetrier {
    
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var count: Int = 0
    private var isRefreshing = false
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let data = request.delegate.data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
            let code = json["code"] as? Int,
            (code == 1002 || code == 1003 || code == 1009) {
            requestsToRetry.append(completion)
            if !isRefreshing {
                refreshToken()
            }
        } else {
            completion(false,0)
        }
    }
    
    func refreshToken() {
        isRefreshing = true
        NetTools.shared.send(request: OAuthTokenRequest.refresh, success: {[weak self] (objc: OAuthTokenModel?) in
            guard let `self` = self, let objc = objc else { return }
            self.isRefreshing = false
            print("refresh_token")
            OAuthTokenModel.shared.access_token = objc.access_token
            OAuthTokenModel.shared.refresh_token = objc.refresh_token
            self.requestsToRetry.forEach { $0(true, 0) }
            self.requestsToRetry.removeAll()
        }) { (error) in
            print(error)
            self.requestsToRetry.forEach { $0(false, 0) }
            self.requestsToRetry.removeAll()
            self.isRefreshing = false
        }
    }
}

// MARK: - RequestHandler

extension NetTools {
    
    func send(request r: NetRequest,
              success: @escaping NetSuccessJSONBlock,
              failure: @escaping NetFailedBlock) {
        request(url: r.host + r.path,
                params: r.parameters,
                method: r.method,
                encoding: r.encoding,
                success: success,
                failure: failure)
    }
    
    func send<T: Any>(request r: NetRequest,
                            success: @escaping NetSuccessBlock<T>,
                            failure: @escaping NetFailedBlock) {
        request(url: r.host + r.path,
                params: r.parameters,
                method: r.method,
                encoding: r.encoding,
                success: success,
                failure: failure)
    }
    
    func request(url: String,
                 params: Parameters?,
                 method: HTTPMethod,
                 encoding: ParameterEncoding,
                 success: @escaping NetSuccessJSONBlock,
                 failure: @escaping NetFailedBlock) {
        sessionManager?.request(url,
                                method: method,
                                parameters: params,
                                encoding: encoding)
            .responseJSON(completionHandler: { (response) in
                self.responseHandler(response: response, successJSONBlock: success, faliedBlock: failure)
            }).validate({ (request, response, data) -> Request.ValidationResult in
                if let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
                    let code = json["code"] as? Int,
                    (code == 1002 || code == 1003 || code == 1009) {
                    return .failure(NSError(domain: "登录已过期", code: code, userInfo: nil))
                }
                return .success
            })
    }
    
    func request<T: Any>(url: String,
                               params: Parameters?,
                               method: HTTPMethod,
                               encoding: ParameterEncoding,
                               success: @escaping NetSuccessBlock<T>,
                               failure: @escaping NetFailedBlock) {
        sessionManager?.request(url,
                                method: method,
                                parameters: params,
                                encoding: encoding)
            .responseJSON(completionHandler: { (response) in
                self.responseHandler(response: response, successBlock: success, faliedBlock: failure)
            }).validate({ (request, response, data) -> Request.ValidationResult in
                if let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
                    let code = json["code"] as? Int,
                    (code == 1002 || code == 1003 || code == 1009) {
                    return .failure(NSError(domain: "登录已过期", code: code, userInfo: nil))
                }
                return .success
            })
    }
    
}

//  MARK: - ResponseHandler

private extension NetTools {
    func responseHandler(response: DataResponse<Any>,
                         successJSONBlock: NetSuccessJSONBlock,
                         faliedBlock: NetFailedBlock) {
        if let value = response.result.value as? [String: Any] {
            successJSONBlock(value)
        } else if let error = response.result.error {
            failedHandler(error: error as NSError,
                          faliedBlock: faliedBlock)
        } else {
            faliedBlock(NSError(domain: "数据解析出错", code: -1, userInfo: nil))
        }
    }
    
    func responseHandler<T: Any>(response: DataResponse<Any>,
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
            faliedBlock(NSError(domain: "数据解析出错", code: -1, userInfo: nil))
        }
    }
    
    func failedHandler(error: NSError,
                       faliedBlock: NetFailedBlock) {
        var e = error
        if error.code == -1009 {
            e = NSError(domain: "无网络连接", code: error.code, userInfo: nil)
        } else if error.code == -1001 {
            e = NSError(domain: "请求超时", code: error.code, userInfo: nil)
        } else if error.code == -1005 {
            e = NSError(domain: "网络连接丢失(服务器忙)", code: error.code, userInfo: nil)
        } else if error.code == -1004 {
            e = NSError(domain: "服务器没有启动", code: error.code, userInfo: nil)
        } else if error.code == 404 || error.code == 3 {
        }
        faliedBlock(e)
    }
    
    func successHandler<T: Any>(value: [String: Any],
                                      successBlock: NetSuccessBlock<T>,
                                      faliedBlock: NetFailedBlock) {
        if let model = NetModel<T>.deserialize(from: value) {
            if model.code == 0 || model.code == 200 {
                successBlock(model.content)
            } else {
                faliedBlock(NSError(domain: model.message, code: model.code, userInfo: nil))
            }
        } else {
            faliedBlock(NSError(domain: "数据解析出错", code: -1, userInfo: nil))
        }
    }
 
}
