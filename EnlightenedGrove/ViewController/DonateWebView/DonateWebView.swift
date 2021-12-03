//
//  DonateWebView.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 07/10/21.
//

import UIKit
import WebKit

class DonateWebView: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var webviewDonate: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://comdevnet.org/donate/")!
        webviewDonate.load(URLRequest(url: url))
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
