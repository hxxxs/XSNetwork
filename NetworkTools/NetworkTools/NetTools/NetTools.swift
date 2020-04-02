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
    private var sessionManager: Session?
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        sessionManager = Session(configuration: configuration, delegate: SessionDelegate(), interceptor: NetRequestInterceptor())
    }
}

// MARK: - RequestInterceptor

class NetRequestInterceptor: RequestInterceptor {
    
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private var count: Int = 0
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if OAuthTokenModel.shared.access_token.count > 0 {
            request.setValue(OAuthTokenModel.shared.access_token, forHTTPHeaderField: "accessToken")
        }
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let tempError = error.asAFError?.underlyingError as NSError? {
            if tempError.code == 1002 || tempError.code == 1003 || tempError.code == 1009 {
                requestsToRetry.append(completion)
                if !isRefreshing {
                    refreshToken()
                }
            } else {
                completion(.doNotRetry)
            }
        } else {
            completion(.doNotRetry)
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
            self.requestsToRetry.forEach { $0(.retry)}
            self.requestsToRetry.removeAll()
        }) { (error) in
            self.requestsToRetry.forEach { $0(.doNotRetry) }
            self.requestsToRetry.removeAll()
            self.isRefreshing = false
        }
    }
}

// MARK: - RequestHandler

extension NetTools {
    
    static func send(request r: NetRequest,
                     success: @escaping NetSuccessJSONBlock,
                     failure: @escaping NetFailedBlock) {
        shared.request(url: r.host + r.path,
                       params: r.parameters,
                       method: r.method,
                       encoding: r.encoding,
                       success: success,
                       failure: failure)
    }
    
    static func send<T: Any>(request r: NetRequest,
                             success: @escaping NetSuccessBlock<T>,
                             failure: @escaping NetFailedBlock) {
        shared.request(url: r.host + r.path,
                       params: r.parameters,
                       method: r.method,
                       encoding: r.encoding,
                       success: success,
                       failure: failure)
    }
    
    static func request(url: String,
                        params: Parameters?,
                        method: HTTPMethod,
                        encoding: ParameterEncoding,
                        success: @escaping NetSuccessJSONBlock,
                        failure: @escaping NetFailedBlock) {
        shared.sessionManager?.request(url,
                                       method: method,
                                       parameters: params,
                                       encoding: encoding)
            .responseJSON(completionHandler: { (response) in
                self.shared.responseHandler(response: response, successJSONBlock: success, faliedBlock: failure)
            }).validate({ (_, _, data) -> Request.ValidationResult in
                self.shared.validate(data: data)
            })
    }
    
    static func request<T: Any>(url: String,
                                params: Parameters?,
                                method: HTTPMethod,
                                encoding: ParameterEncoding,
                                success: @escaping NetSuccessBlock<T>,
                                failure: @escaping NetFailedBlock) {
        shared.sessionManager?.request(url,
                                       method: method,
                                       parameters: params,
                                       encoding: encoding)
            .responseJSON(completionHandler: { (response) in
                self.shared.responseHandler(response: response, successBlock: success, faliedBlock: failure)
            }).validate({ (_, _, data) -> Request.ValidationResult in
                self.shared.validate(data: data)
            })
    }
    
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
            }).validate({ (_, _, data) -> Request.ValidationResult in
                self.validate(data: data)
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
            }).validate({ (_, _, data) -> Request.ValidationResult in
                self.validate(data: data)
            })
    }
    
    private func validate(data: Data?) -> Request.ValidationResult {
        if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
            let code = json["code"] as? Int {
            if code == 1002 || code == 1003 || code == 1009 {
                return .failure(NSError(domain: "登录已过期", code: code, userInfo: nil))
            } else if code == 1001 {
                return .failure(NSError(domain: "您还没有登录", code: code, userInfo: nil))
            }
        }
        return .success(Void())
    }
    
}

//  MARK: - ResponseHandler

private extension NetTools {
    func responseHandler(response: AFDataResponse<Any>,
                         successJSONBlock: NetSuccessJSONBlock,
                         faliedBlock: NetFailedBlock) {
        if let value = response.value as? [String: Any] {
            successJSONBlock(value)
        } else if let error = response.error {
            failedHandler(error: error,
                          faliedBlock: faliedBlock)
        } else {
            faliedBlock(NSError(domain: "数据解析出错", code: -1, userInfo: nil))
        }
    }

    func responseHandler<T: Any>(response: AFDataResponse<Any>,
                                       successBlock: NetSuccessBlock<T>,
                                       faliedBlock: NetFailedBlock){
        if let value = response.value as? [String: Any] {
            successHandler(value: value,
                           successBlock: successBlock,
                           faliedBlock: faliedBlock)
        } else if let error = response.error {
            failedHandler(error: error,
                          faliedBlock: faliedBlock)
        } else {
            faliedBlock(NSError(domain: "数据解析出错", code: -1, userInfo: nil))
        }
    }
    
    func failedHandler(error: AFError,
                       faliedBlock: NetFailedBlock) {
        var err = NSError()
        if error.isSessionTaskError,
            let typeError = error.underlyingError as NSError? {
            if typeError.code == -1009 {
                err = NSError(domain: "无网络连接", code: typeError.code, userInfo: nil)
            } else if typeError.code == -1001 {
                err = NSError(domain: "请求超时", code: typeError.code, userInfo: nil)
            } else if typeError.code == -1005 {
                err = NSError(domain: "网络连接丢失(服务器忙)", code: typeError.code, userInfo: nil)
            } else if typeError.code == -1004 {
                err = NSError(domain: "网络异常，请稍后重试", code: typeError.code, userInfo: nil)
            } else if typeError.code == 404 || typeError.code == 3 || typeError.code == 4 {
                err = NSError(domain: "系统异常，请稍后重试", code: typeError.code, userInfo: nil)
            }
        }
        
        faliedBlock(err)
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
