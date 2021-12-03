//
//  UnitWebVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 26/05/21.
//

import UIKit
import WebKit
import Photos

class UnitWebVC: UIViewController,WKNavigationDelegate,AlertDisplayer {
    
    @IBOutlet weak var webviewUnit: WKWebView!
    @IBOutlet weak var btnDownload: UIButton!
    
    
    var urlstr:String? = ""
    var contentType:String? = ""
    var activityIndicator: UIActivityIndicatorView!
    var isSelectRotation:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        webviewUnit.navigationDelegate = self
        btnDownload.layer.cornerRadius = btnDownload.frame.size.height/2
        btnDownload.backgroundColor = .gray

       // self.rotateToLandsScapeDevice()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        let url = URL(string: urlstr ?? "")!
        webviewUnit.load(URLRequest(url: url))
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.rotateToPotraitScapeDevice()
      }
    
    func rotateToLandsScapeDevice(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.myOrientation = .landscapeLeft
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIView.setAnimationsEnabled(true)
        }

        func rotateToPotraitScapeDevice(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.myOrientation = .portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIView.setAnimationsEnabled(true)
        }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    func setupUI(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.isHidden = true
        view.addSubview(activityIndicator)
    }
    
    
    func showActivityIndicator(show: Bool) {
        if (Reachability.isConnectedToNetwork()){
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        }else {
            showAlertWith(message: "Please check your internet connection")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRotate(_ sender: UIButton) {
      
      
        if (isSelectRotation == false){
     
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .landscapeLeft
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
            
        }
        else {
         
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.myOrientation = .portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIView.setAnimationsEnabled(true)
        }
        self.isSelectRotation = !self.isSelectRotation
        
        
      //  let value = UIInterfaceOrientation.landscapeRight.rawValue
        //    UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    
    
    @IBAction func buttonDownload(_ sender: Any) {
        if let _ = UserDefaults.standard.value(forKey: "ID") {
            if (Reachability.isConnectedToNetwork()){
            if (contentType == "Video") {
                downloadVideoLinkAndCreateAsset(urlstr ?? "")
            }else {
                downloadFile()
            }
            }else {
                showAlertWith(message: "Please check your internet connection".localized())
            }
        }else {
            let alertOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
                
                let loginVc = LogInVC(nibName: "LogInVC", bundle: nil)
                self.navigationController?.pushViewController(loginVc, animated: true)
            }
            self.showAlertWith(message: "You need to login to download".localized(), type: .custom(actions: [alertOkAction]))
       }
        
    }
    
    func downloadFile(){
        showActivityIndicator(show: true)
        
        let url = URL(string: urlstr ?? "")
        let fileName = String((url!.lastPathComponent)) as NSString
        
        savePdf(urlString: urlstr ?? "", fileName: fileName as String)
        
    }
    
    func savePdf(urlString:String, fileName:String) {
        
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "OC4D-\(fileName)"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                
                print("pdf successfully saved!")
                
                self.showActivityIndicator(show: false)
                self.showAlertWith(message: "Download Completed")
                
                //file is downloaded in app data container, I can find file from x code > devices > MyApp > download Container >This container has the file
            } catch {
                print("Pdf could not be saved")
                self.showActivityIndicator(show: false)
            }
        }
    }
    
    
    
    
    
    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                if completed {
                                    DispatchQueue.main.async {
                                        self.showAlertWith(message: "Download Completed")
                                        print("Video asset created")
                                    }
                                    
                                } else {
                                    print(error ?? "")
                                    DispatchQueue.main.async {
                                        self.showAlertWith(message: "Unable to download")
                                    }
                                }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
            }.resume()
            
        } else {
            DispatchQueue.main.async {
                print("File already exists at destination url")
                self.showAlertWith(message: "Download Completed")
            }
        }
        
    }
    
}



