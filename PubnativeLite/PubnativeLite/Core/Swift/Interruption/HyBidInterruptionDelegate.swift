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

@objc
public protocol HyBidInterruptionDelegate: NSObjectProtocol {
    
    @objc optional func adHasNoFocus()
    @objc optional func adHasFocus()
    
    @objc optional func vastEndCardWillShow()
    @objc optional func vastCustomEndCardWillShow()
    
    @objc optional func willEnterForeground()
    
    @objc optional func feedbackViewWillShow()
    @objc optional func feedbackViewDidDismiss()
    
    @objc optional func productViewControllerIsReadyToShow()
    @objc optional func productViewControllerWillShow()
    @objc optional func productViewControllerDidShow()
    @objc optional func productViewControllerDidFail(error: Error)
    @objc optional func productViewControllerDidFinish(_ viewController: SKStoreProductViewController)
    
    @objc optional func internalWebBrowserDidShow()
}
