//
//  webViewController.swift
//  Abercrombie
//
//  Created by Varun Gupta on 11/13/16.
//  Copyright © 2016 Varun GuptaAbercrombie. All rights reserved.
//

import UIKit

class webViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var webViewURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scalesPageToFit = true

        if let urlStr = webViewURL {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: urlStr)!))
        } else {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.google.com")!))
        }
    }
}
