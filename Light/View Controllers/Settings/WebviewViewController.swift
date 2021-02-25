//
//  WebviewViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import WebKit

class WebviewViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var webview: WKWebView!
    var isPrivacy = true
    var titleText = ""
    var isPresented = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = titleText
        var urlRequest:URLRequest!
        if isPrivacy == true {
             label.text = "Privacy Policy"
             urlRequest = URLRequest(url: URL(string: "https://api.lightforcancer.com/privacy")!)
        } else {
            label.text = "Term And Conditions"
            urlRequest = URLRequest(url: URL(string: "https://api.lightforcancer.com/terms")!)
        }
        ServiceHelper.shared.showIndicator()
        webview.navigationDelegate = self
        webview.load(urlRequest)
        
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
        
        
        if self.isPresented
        {
            self.backButton.isHidden = true
        }
        else
        {
            self.closeButton.isHidden = true
        }
        
        
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WebviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,didFail navigation: WKNavigation!, withError error: Error) {
        ServiceHelper.shared.stopIndicator()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ServiceHelper.shared.stopIndicator()
    }
}
