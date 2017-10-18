//
//  NewsController.swift
//  RadioT
//
//  Created by Den on 28.06.17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation
import UIKit


class NewsController: UIViewController, UIWebViewDelegate {
    
    var boxView:UIView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        var w: UIWebView = {
            let web = UIWebView()
            web.frame = self.view.frame
            let url = NSURL (string: "https://news.radio-t.com/");
            let requestObj = NSURLRequest(url: url! as URL);
            web.loadRequest(requestObj as URLRequest);
           return web
        }()
        
        w.delegate = self
        
        
        var cl: UIButton = {
            var button = UIButton(frame: CGRect(x: w.frame.width - 30, y: 20, width: 25, height: 25))
            button.setImage(UIImage(named: "close_blue"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(closeController), for: UIControlEvents.touchUpInside)
            // button.layer.zPosition = 1
            return button
        }()
        
        
        self.view.addSubview(w)
        w.addSubview(cl)
        
    }
    
    func webViewDidStartLoad(webView_Pages: UIWebView) {
        
        // Box config:
        boxView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
        boxView.backgroundColor = .black
        boxView.alpha = 0.9
        boxView.layer.cornerRadius = 10
        
        // Spin config:
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        activityView.startAnimating()
        
        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."
        
        // Activate:
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        view.addSubview(boxView)
    }
    
    func webViewDidFinishLoad(webView_Pages: UIWebView) {
        
        // Removes it:
        boxView.removeFromSuperview()
        
    }
    
    func closeController()  {
        print("disss")
        self.dismiss(animated:true)
    }
}
