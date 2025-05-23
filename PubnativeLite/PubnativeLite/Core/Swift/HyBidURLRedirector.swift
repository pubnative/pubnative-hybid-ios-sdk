// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc public protocol HyBidURLRedirectorDelegate: AnyObject {
    func onURLRedirectorStart(url: String)
    func onURLRedirectorRedirect(url: String)
    func onURLRedirectorFinish(url: String)
    func onURLRedirectorFail(url: String, withError error: Error)
}

@objcMembers
public class HyBidURLRedirector: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    public weak var delegate: HyBidURLRedirectorDelegate?
    public var userAgent: String?
    
    public func drill(url: String, skanModel: HyBidSkAdNetworkModel?) {
        guard !url.isEmpty else {
            invokeFail(url: url, error: NSError(domain: "HyBidURLRedirectError", code: 0, userInfo: [NSLocalizedDescriptionKey: "HyBidURLRedirector error: URL is null or empty"]))
            return
        }
        
        if let skan = skanModel {
            let productParams = skan.getStoreKitParameters()
            
            if productParams != nil && productParams!.count > 0 && skan.isSKAdNetworkIDVisible(productParams) {
                invokeFail(url: url, error: NSError(code: HyBidErrorCodeUnknown, localizedDescription: "This ad contains StoreKit data. Cancelling redirection."))
                return
            }
        }
        
        if url.lowercased().contains("apps.apple.com") {
            DispatchQueue.main.async {
                self.delegate?.onURLRedirectorStart(url: url)
                self.delegate?.onURLRedirectorFinish(url: url)
            }
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.invokeStart(url: url)
            self.doRedirect(url: url)
        }
    }
    
    private func doRedirect(url: String) {
        guard let urlObj = URL(string: url) else { return }
        
        var request = URLRequest(url: urlObj)
        if let userAgent = self.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        request.httpMethod = "GET"
        request.httpShouldHandleCookies = false
        request.httpShouldUsePipelining = true
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.urlCache = nil
        
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }

    
    // URLSessionTaskDelegate method
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let newURL = request.url?.absoluteString, response.statusCode >= 300 && response.statusCode <= 399 {
            invokeRedirect(url: newURL)
            
            if newURL.lowercased().contains("apps.apple.com") {
                invokeFinish(url: newURL)
                task.cancel()
                completionHandler(nil)
            } else {
                invokeFinish(url: newURL)
                completionHandler(request)
            }
        } else {
            completionHandler(request)
        }
    }
    
    // URLSessionDataDelegate method
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            invokeFail(url: dataTask.currentRequest?.url?.absoluteString ?? "", error: NSError(domain: "HyBidURLRedirectError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Received HTTP \(httpResponse.statusCode)"]))
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            invokeFail(url: task.currentRequest?.url?.absoluteString ?? "", error: error)
        } else {
            invokeFail(url: task.currentRequest?.url?.absoluteString ?? "", error: NSError(code: HyBidErrorCodeUnknown, localizedDescription: "Something went wrong"))
        }
    }
    
    private func invokeStart(url: String) {
        DispatchQueue.main.async {
            self.delegate?.onURLRedirectorStart(url: url)
        }
    }
    
    private func invokeRedirect(url: String) {
        DispatchQueue.main.async {
            self.delegate?.onURLRedirectorRedirect(url: url)
        }
    }
    
    private func invokeFinish(url: String) {
        DispatchQueue.main.async {
            self.delegate?.onURLRedirectorFinish(url: url)
            self.delegate = nil
        }
    }
    
    private func invokeFail(url: String, error: Error) {
        DispatchQueue.main.async {
            self.delegate?.onURLRedirectorFail(url: url, withError: error)
            self.delegate = nil
        }
    }
}
