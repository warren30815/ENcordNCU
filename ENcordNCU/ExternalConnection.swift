//
//  ExternalConnection.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/31.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class ExternalConnection: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    
    var external_url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: external_url)
        webview.loadRequest(URLRequest(url: url!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
