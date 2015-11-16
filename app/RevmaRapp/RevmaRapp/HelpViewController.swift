//
//  HelpViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 16/11/15.
//  Copyright © 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit

class HelpViewController : UIViewController {
    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!

    override func viewDidLoad() {
        if let htmlFile = NSBundle.mainBundle().pathForResource("test", ofType: "html") {
            do {
                try webview.loadHTMLString(NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding) as String, baseURL: nil)
            } catch let error as NSError {
                print("Error \(error.domain)")
            }
        }
    }
}