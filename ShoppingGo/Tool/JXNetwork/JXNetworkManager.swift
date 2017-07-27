//
//  JXNetworkManager.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

import AFNetworking

class JXNetworkManager: NSObject {
    
    var afmanager = AFHTTPSessionManager()
    
    var requestCache = [String:JXBaseRequest]()
    
    var networkStatus : AFNetworkReachabilityStatus = .reachableViaWiFi
    
    var sid : String? {
        return ""
    }
    
    
    static let manager = JXNetworkManager()
    
    override init() {
        super.init()
        //返回数据格式AFHTTPResponseSerializer(http) AFJSONResponseSerializer(json) AFXMLDocumentResponseSerializer ...
        afmanager.responseSerializer = AFHTTPResponseSerializer.init()
        afmanager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html","application/json") as? Set<String>
        
        afmanager.operationQueue.maxConcurrentOperationCount = 5
        //请求参数格式AFHTTPRequestSerializer（http） AFJSONRequestSerializer(json) AFPropertyListRequestSerializer (plist)
        afmanager.requestSerializer = AFHTTPRequestSerializer.init()
        afmanager.requestSerializer.timeoutInterval = 10
        
        
        //afmanager.requestSerializer.setValue("", forHTTPHeaderField: "")
        
        afmanager.reachabilityManager = AFNetworkReachabilityManager.shared()
        afmanager.reachabilityManager.startMonitoring()
        afmanager.reachabilityManager.setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) in
            print("网络状态变化 == \(status.rawValue)")
            self.networkStatus = AFNetworkReachabilityStatus(rawValue: status.rawValue)!
        }
    }

    func buildRequest(request:JXBaseRequest) {

        ///网络判断
        if networkStatus == .unknown || networkStatus == .notReachable {
            print("网络不可用")
            return
        }
        
        ///获取URL
        let url = buildUrl(url: request.requestUrl)
        
        if let customUrlRequest = request.buildCustomUrlRequest() {
            request.sessionTask = afmanager.dataTask(with: customUrlRequest, uploadProgress: nil, downloadProgress: nil, completionHandler: { (response, responseData, error) in
                //
                self.handleTask(task: nil, data: responseData, error: error)
            })
        }else{
            switch request.method {
            case .get:
                request.sessionTask = afmanager.get(url, parameters: request.param, progress: nil, success: { (task:URLSessionDataTask, responseData:Any?) in
                    self.handleTask(task: task, data: responseData, error: nil)
                }, failure: { (task:URLSessionDataTask?, error:Error) in
                    self.handleTask(task: task, data: nil, error: error)
                })
            case .post:
                if let constructBlock = request.customConstruct(), constructBlock != nil{
                    request.sessionTask = afmanager.post(url, parameters: request.param, constructingBodyWith: constructBlock, progress: nil, success: { (task:URLSessionDataTask, responseData:Any?) in
                        self.handleTask(task: task, data: responseData, error: nil)
                    }, failure: { (task:URLSessionDataTask?, error:Error) in
                        self.handleTask(task: task, data: nil, error: error)
                    })
                }else{
                    request.sessionTask = afmanager.post(url, parameters: request.param, progress: nil, success: { (task:URLSessionDataTask, responseData:Any?) in
                        self.handleTask(task: task, data: responseData)
                    }, failure: { (task:URLSessionDataTask?, error:Error) in
                        self.handleTask(task: task, error: error)
                    })
                }
                //            afmanager.post(url, parameters: request.param, constructingBodyWith: { (formdata) in
                //                //
                //
                //                let str = NSHomeDirectory() + "/Documents/userImage.jpg"
                //                let url = URL.init(fileURLWithPath: str)
                //                let data = try? Data.init(contentsOf: url)
                //                formdata.appendPart(withFileData: data!, name: "image", fileName: "userImage.jpg", mimeType: "image/jpeg")
                //
                //            }, progress: nil, success: { (task, res) in
                //                //
                //            }, failure: { (task, error) in
                //                //
                //            })
            case .delete:
                request.sessionTask = afmanager.delete(url, parameters: request.param, success: { (task:URLSessionDataTask, responseData:Any?) in
                    self.handleTask(task: task, data: responseData)
                }, failure: { (task:URLSessionDataTask?, error:Error) in
                    self.handleTask(task: task, error: error)
                })
            case .put:
                request.sessionTask = afmanager.put(url, parameters: request.param, success: { (task:URLSessionDataTask, responseData:Any?) in
                    self.handleTask(task: task, data: responseData)
                }, failure: { (task:URLSessionDataTask?, error:Error) in
                    self.handleTask(task: task, error: error)
                })
            case .head:
                request.sessionTask = afmanager.head(url, parameters: request.param, success: { (task:URLSessionDataTask) in
                    self.handleTask(task: task, data: nil)
                }, failure: { (task:URLSessionDataTask?, error:Error) in
                    self.handleTask(task: task, error: error)
                })
            default:
                assert(request.method == .unknow, "请求类型未知")
                break
            }
        }
        
        
        
        addRequest(request: request)
    }
    
}
//MARK: request add remove resume cancel
extension JXNetworkManager {
    
    /// 缓存request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func addRequest(request:JXBaseRequest) {
        
        guard let task = request.sessionTask
               else {
            return
        }
        let key = requestHashKey(task: task)
        requestCache[key] = request
    }
    
    /// 删除缓存中request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func removeRequest(request:JXBaseRequest) {
        guard let task = request.sessionTask
            else {
                return
        }
        let key = requestHashKey(task: task)
        requestCache.removeValue(forKey: key)
    }
    
    /// 取消request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func cancelRequest(request:JXBaseRequest) {
        guard (request.sessionTask as? URLSessionDataTask) != nil
            else {
                return
        }
        request.sessionTask?.cancel()
        removeRequest(request: request)
    }
    /// 取消所有request
    func cancelRequests() {
        for (_,value) in requestCache {
            let request = value as JXBaseRequest
            cancelRequest(request: request)
        }
    }
    /// 重发request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func resumeRequest(request:JXBaseRequest) {
        buildRequest(request: request)
    }
    /// 重发所有缓冲中的request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func resumeRequests() {
        for (_,value) in requestCache {
            let request = value as JXBaseRequest
            
            removeRequest(request: request)
            if request.requestUrl != ApiString.getTokenByKey.rawValue && request.requestUrl != ApiString.refreshToken.rawValue{
                resumeRequest(request: request)
            }
        }
    }
    
}

extension JXNetworkManager{
    /// 对请求任务hash处理
    ///
    /// - Parameter task: 当前请求task
    /// - Returns: hash后的字符串
    func requestHashKey(task:URLSessionTask) -> String {
        return String(format: "%lu", task.hash)
    }
}

extension JXNetworkManager {
    
    func buildUrl(url:String?) -> String {
        
        guard let url = url else {
            return ""
        }
        
        if url.hasPrefix("http") == true{
            afmanager.requestSerializer = AFJSONRequestSerializer.init()
            afmanager.requestSerializer.timeoutInterval = 10
            afmanager.requestSerializer.setValue("ceccm", forHTTPHeaderField: "source")
            print("afmanager.requestSerializer = \(afmanager.requestSerializer)")
            return url
        }else{
            afmanager.requestSerializer = AFHTTPRequestSerializer.init()
            afmanager.requestSerializer.timeoutInterval = 10
        }
       
        let longitude = 0
        let latitude = 0
        var parameters = ""
        let Channel = "appStore"
        let Mac = ""
        let IP = ""
        let City = "北京市"
        let token = UserManager.default.userModel.Token ?? ""
        
        parameters = "Version=2.0.6&Package=GjieGo&Channel=\(Channel)&Longitude=\(longitude)&Latitude=\(latitude)&Mac=\(Mac)&IP=\(IP)&City=\(City)&Token=\(token)"
        //let ssss = "https://appc.guangjiego.com/v1/UserLogin/GetTokenByKey?\(parameters)"
        let ssss = "https://appc.guangjiego.com/v1\(url)?\(parameters)"
        let sssss = ssss.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        return sssss!
    }
}
//MARK: 结果处理 response handle
extension JXNetworkManager {
    
    func handleTask(task:URLSessionDataTask?, data:Any? = nil, error:Error? = nil) {
        ///
        guard let task = task else {
                return
        }
        //
        let key = requestHashKey(task: task)
        guard let request = requestCache[key] else {
            return
        }
        let succeed = checkResult(request: request)
        
        if succeed && error == nil{
            request.requestSuccess(responseData: data!)
        } else {
            request.requestFailure(error: error!)
        }

        requestCache.removeValue(forKey: key)
    }
    
    func checkResult(request:JXBaseRequest) -> Bool {
        let result = request.statusCodeValidate()
        return result
    }
   
}

extension JXNetworkManager {
    
}
