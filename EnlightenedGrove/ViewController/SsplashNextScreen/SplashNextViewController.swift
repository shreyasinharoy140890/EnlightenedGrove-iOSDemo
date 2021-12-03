//
//  SplashNextViewController.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 22/10/21.
//

import UIKit

class SplashNextViewController: UIViewController {
 var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(moveNextScreen) , userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnNextScreen(_ sender: Any) {
        moveNextScreen()
    }
    
    @objc func moveNextScreen() {
        timer.invalidate()
        let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    
    


}
