//
//  WebView.swift
//  OAuthSwift

import OAuthSwift
import UIKit
typealias WebView = UIWebView

class WebViewController: OAuthWebViewController {
    
    var targetURL : NSURL = NSURL()
    var webView : UIWebView = UIWebView()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        webView.autoresizingMask =
            [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleHeight]
        webView.scalesPageToFit = true
        view.addSubview(webView)
        loadAddressURL()
    }
    
    func setUrl(url: NSURL) {
        targetURL = url
    }
    
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
       // self.webView.loadRequest(req)    //ORIGINAL
        webView.loadRequest(req)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where (url.scheme == "oauth-swift"){
            self.dismissWebViewController()
        }
        return true
    }
}


 



