//
//  HelpViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 16/11/15.
//  Copyright © 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit

protocol HelpControllerEndDelegate {
    func helpDone(controller: HelpViewController)
}

class HelpViewController : UIViewController {
    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    var delegate: HelpControllerEndDelegate?
    var htmlFile = "helptext"

    override func viewDidLoad() {
        if let theActualFile =  NSBundle.mainBundle().pathForResource(htmlFile, ofType: "html") {
            let mainBundleURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
            do {
                try webview.loadHTMLString(NSString(contentsOfFile: theActualFile, encoding: NSUTF8StringEncoding) as String, baseURL: mainBundleURL)
            } catch let error as NSError {
                print("Error \(error.domain)")
            }
        }
    }

    @IBAction func donePressed(button: UIBarButtonItem) {
        if let realDelegate = delegate {
            realDelegate.helpDone(self)
        }
    }
}