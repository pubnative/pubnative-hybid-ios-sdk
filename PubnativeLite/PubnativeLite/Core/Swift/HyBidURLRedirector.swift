//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    
    public func drill(url: String) {
        guard !url.isEmpty else {
            invokeFail(url: url, error: NSError(domain: "HyBidURLRedirectError", code: 0, userInfo: [NSLocalizedDescriptionKey: "HyBidURLRedirector error: URL is null or empty"]))
            return
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
