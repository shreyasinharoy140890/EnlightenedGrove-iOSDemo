//
//  LogInVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 20/04/21.
//

import UIKit
import Amplify
import AmplifyPlugins
import FBSDKLoginKit
import FBSDKCoreKit
import AuthenticationServices
import JWTDecode
import PhoneNumberKit
import AWSMobileClient
import AWSPluginsCore


class LogInVC: UIViewController,UITextFieldDelegate,AlertDisplayer {
    
    
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var buttonLoginWithFb: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var textInputEmail: UITextField!
    @IBOutlet weak var textInputPassword: UITextField!
    @IBOutlet weak var btnForgotPAssword: UIButton!
    
    @IBOutlet weak var lblSignup: UILabel!
    @IBOutlet weak var lblor: UILabel!
    
    @IBOutlet weak var btnShowPassword: UIButton!
    
    @IBOutlet weak var stackViewAppleLogin: UIStackView!
    
    
    
    @IBOutlet weak var lblCreateAccount: UILabel!
    var viewModelLogin: loginViewModel?
    var arrCointainer = ["",""]
    var fbId : String = ""
    var fbEmail : String = ""
    var fbFName : String = ""
    var fbLName : String = ""
    var fbName : String = ""
    var fbPickUrl : String = ""
    var iconClick = true
    var countryCode:String?
    var onlyphoneNumber:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  changePassword(oldPassword: "Qwerty555$", newPassword: "Qwerty555%")
       
        signOutLocally()
        buttonSignup.addShadow(offset: CGSize.init(width: 0, height: 2), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        buttonLoginWithFb.addShadow(offset: CGSize.init(width: 0, height: 2), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        buttonLogin.addShadow(offset: CGSize.init(width: 0, height: 2), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        
        textInputEmail.delegate = self
        textInputPassword.delegate = self
        viewModelLogin = loginViewModel()
        textInputEmail.tag = 0
        textInputPassword.tag = 1
        textInputEmail.addTarget(self, action: #selector(textInputValue(_:)), for: .editingChanged)
        textInputPassword.addTarget(self, action: #selector(textInputValue(_:)), for: .editingChanged)
        setupProviderLoginView()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textInputEmail.text = ""
        textInputPassword.text = ""
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        
        arrCointainer = ["",""]
        setLanguage()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // performExistingAccountSetupFlows()
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.stackViewAppleLogin.addArrangedSubview(authorizationButton)
    }
    func setLanguage() {
        buttonSignup.setTitle("Sign up".localized(), for: .normal)
        textInputEmail.placeholder = "User Name".localized()
        textInputPassword.placeholder = "Password".localized()
        buttonLogin.setTitle("Login".localized(), for: .normal)
        // buttonLoginWithFb.setTitle("Log in with Facebook".localized(), for: .normal)
        
        let stringFP = "Forgot Password".localized()
        lblSignup.text = "Don't have an Account? Create an Account".localized()
        lblCreateAccount.text = "Create an Account".localized()
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ES" {
                
                
                
                
                let forgotPAssAttribute: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "CustomYellow")!]
                
                let attributedString = NSAttributedString(string: stringFP, attributes: forgotPAssAttribute)
                btnForgotPAssword.setAttributedTitle(attributedString, for: .normal)
                
                
            }else {
                
                
                
                
                let forgotPAssAttribute: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "CustomYellow")!]
                
                let attributedString = NSAttributedString(string: stringFP, attributes: forgotPAssAttribute)
                btnForgotPAssword.setAttributedTitle(attributedString, for: .normal)
                
            }
            
        }
        
        //        let forgotPAssAttribute: [NSAttributedString.Key : Any] = [
        //            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        //            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),
        //            NSAttributedString.Key.foregroundColor: UIColor(named: "CustomYellow")!]
        //
        //        let attributedString = NSAttributedString(string: stringFP, attributes: forgotPAssAttribute)
        //        btnForgotPAssword.setAttributedTitle(attributedString, for: .normal)
        //let str = "Don't have an Account? Create an Account".localized()
        
        
        //        var myMutableString = NSMutableAttributedString()
        //
        //        myMutableString = NSMutableAttributedString(string: str)
        //
        //        myMutableString.setAttributes([ NSAttributedString.Key.foregroundColor : UIColor(red: 6 / 255.0, green: 68 / 255.0, blue: 108 / 255.0, alpha: 1.0)], range: NSRange(location:27,length:15)) // What ever range you want to give
        //
        //        lblSignup.attributedText = myMutableString
    }
    
    /// - Tag: perform_appleid_request for AppleSignin
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    //    func performExistingAccountSetupFlows() {
    //        // Prepare requests for both Apple ID and password providers.
    //        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
    //                        ASAuthorizationPasswordProvider().createRequest()]
    //
    //        // Create an authorization controller with the given requests.
    //        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    //        authorizationController.delegate = self
    //        authorizationController.presentationContextProvider = self
    //        authorizationController.performRequests()
    //    }
    
    func facebookLogin(){
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, last_name, picture, short_name, name"], tokenString: token, version: nil, httpMethod: .get)
            request.start { (connection, result, error) in
                print("\(String(describing: result))")
                
            }
        }else{
            //            btnFacebook.permissions = ["public_profile", "email"]
            //            btnFacebook.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textInputValue(_ textfield:UITextField) {
        arrCointainer[textfield.tag] = textfield.text!
    }
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnCreateAccount(_ sender: Any) {
        //        let signupVC = SignupVc(nibName: "SignupVc", bundle: nil)
        //        self.navigationController?.pushViewController(signupVC, animated: true)
        socialSignInWithWebUIApple()
    }
    
    
    @IBAction func btnShowHidePassword(_ sender: Any) {
        
        if(iconClick == true) {
            
            textInputPassword.isSecureTextEntry = false
            btnShowPassword.setImage(UIImage(named: "view"), for: .normal)
        } else {
            textInputPassword.isSecureTextEntry = true
            btnShowPassword.setImage(UIImage(named: "invisible"), for: .normal)
        }
        
        iconClick = !iconClick
    }
    
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        if textInputEmail.text == "" {
            showAlertWith(message: "Please enter registered email address".localized())
        }else {
            callforgotPass()
        }
        
    }
    @IBAction func btnSignUp(_ sender: Any) {
        //
        
        let signupVC = SignupVc(nibName: "SignupVc", bundle: nil)
        self.navigationController?.pushViewController(signupVC, animated: true)
        
        //         let VC = UsertypeViewController(nibName: "UsertypeViewController", bundle: nil)
        //         VC.modalPresentationStyle = .overCurrentContext
        //         VC.delegate = self
        //         self.navigationController?.present(VC, animated: true, completion: nil)
    }
    
    
    @IBAction func btnFacebook(_ sender: Any) {
        
        loginButtonClicked()
     
     //   socialSignInWithWebUI()
       
       
        
    }
//    func awsSignInFacebook(fbAuthToken: String){
//            let logins = ["graph.facebook.com" : fbAuthToken]
//            let customIdentityProvider = CustomIdentityProvider(tokens: logins)
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1,
//                                                                identityPoolId:"dk70it2gqa9jb",
//                                                                identityProviderManager: customIdentityProvider)
//
//
//        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
//            AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//            credentialsProvider.getIdentityId().continueWith { (task: AWSTask!) -> AnyObject? in
//
//                if (task.error != nil) {
//                    print("Error: " + (task.error?.localizedDescription)!)
//
//                } else {
//                    // the task result will contain the identity id
//                    let cognitoId = task.result
//
//                }
//                return nil
//            }
//        }
//
    @IBAction func btnLogin(_ sender: Any) {
        // callSignin()
        callAuthSignin()
        
    }
    
    @IBAction func btnSkiplogin(_ sender: Any) {
        //        let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        //        self.navigationController?.pushViewController(homeVC, animated: true)
        
    }
    
    
    func callSignin(){
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelLogin?.callSigninApi(email: arrCointainer[0], password: arrCointainer[1], completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    
                    if let success = result as? Bool , success == true {
                        if let unitwebVC = UIApplication.getTopMostViewController()?.navigationController?.ifExitsOnStack(vc: UnitWebVC.self) {
                            UIApplication.getTopMostViewController()?.navigationController?.popToViewController(unitwebVC, animated: true)
                            
                        } else {
                            let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
                            UIApplication.getTopMostViewController()?.navigationController?.pushViewController(homeVC, animated: true)
                        }
                        
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                    
                }
            }
        })
        
        
    }
    
    func callforgotPass(){
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelLogin?.callForgotApi(email: arrCointainer[0], completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    
                    if let user = result as? Users {
                        
                        
                        if user.phone != "" || user.phone != nil {
                            let phone = user.phone ?? ""
                            if ((phone.contains("-"))){
                                // let onlyNumber = phone.components(separatedBy: "-")
                                let countryCodeOnly = user.phone?.components(separatedBy: "-")
                                self.countryCode = countryCodeOnly?[0]
                                self.onlyphoneNumber = countryCodeOnly?[1]
                            }else {
                                // countryCodePicker.setCountry("+233")
                                self.phoneNumberParse(phoneNo: phone)
                                
                            }
                        }
                        let forgotPassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
                        forgotPassVC.isComingFromloginVC = true
                        forgotPassVC.ComingFromVC = "login"
                        forgotPassVC.phoneNumber = self.onlyphoneNumber
                        forgotPassVC.countryCode = self.countryCode ?? ""
                        forgotPassVC.userName = user.email ?? ""
                        forgotPassVC.userId = user.id
                        
                        self.navigationController?.pushViewController(forgotPassVC, animated: true)
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                    
                }
            }
        })
        
        
    }
    
    
    func phoneNumberParse(phoneNo:String) -> String {
        var phNo:String = ""
        let phoneNumberKit = PhoneNumberKit()
        
        do {
            
            let phoneNumber = try phoneNumberKit.parse(phoneNo)
            
            phNo  = String(describing:phoneNumber.nationalNumber)
            print(phNo)
            let onlyNumber = phoneNo.components(separatedBy: phNo)
            //tempcountryCode = onlyNumber[0]
            countryCode = onlyNumber[0]
            onlyphoneNumber = phNo
            // phoneNumberOnly = phNo
            
        }
        
        catch {
        }
        return phNo
    }
    
}


extension LogInVC{
    //    func loginManagerDidComplete(_ result: LoginResult) {
    //
    //        switch result {
    //        case .cancelled:
    //            //showAlertMessage(title: "Ooops", message: "User cancelled login.", vc: self)
    //            print("")
    //        case .failed(let error):
    //            print(error.localizedDescription)
    //        // showAlertMessage(title: "Ooops", message: "Login failed with error \(error)", vc: self)
    //
    //        case .success( _, _, _):
    //            //print(token.userID)
    //            self.getFBUserData()
    //
    //        }
    //
    //
    //    }
    func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self, handler: { result, error in
            if error != nil {
                print("ERROR: Trying to get login results")
            } else if result?.isCancelled != nil {
                print("The token is \(result?.token?.tokenString ?? "")")
                if result?.token?.tokenString != nil {
                    print("Logged in")
                    self.getUserProfile(token: result?.token, userId: result?.token?.userID)
                } else {
                    print("Cancelled")
                }
            }
        })
    }
    func getUserProfile(token: AccessToken?, userId: String?) {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
        graphRequest.start { _, result, error in
            if error == nil {
                let data: [String: AnyObject] = result as! [String: AnyObject]
                print(data)
                // Facebook Id
                if let facebookId = data["id"] as? String {
                    print("Facebook Id: \(facebookId)")
                } else {
                    print("Facebook Id: Not exists")
                }
                
                // Facebook First Name
                if let facebookFirstName = data["first_name"] as? String {
                    print("Facebook First Name: \(facebookFirstName)")
                } else {
                    print("Facebook First Name: Not exists")
                }
                
                // Facebook Middle Name
                if let facebookMiddleName = data["middle_name"] as? String {
                    print("Facebook Middle Name: \(facebookMiddleName)")
                } else {
                    print("Facebook Middle Name: Not exists")
                }
                
                // Facebook Last Name
                if let facebookLastName = data["last_name"] as? String {
                    print("Facebook Last Name: \(facebookLastName)")
                } else {
                    print("Facebook Last Name: Not exists")
                }
                
                // Facebook Name
                if let facebookName = data["name"] as? String {
                    self.fbName = facebookName
                    print("Facebook Name: \(facebookName)")
                } else {
                    self.fbName = ""
                    print("Facebook Name: Not exists")
                }
                
                // Facebook Profile Pic URL
                let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                
                // Facebook Email
                if let facebookEmail = data["email"] as? String {
                    self.fbEmail = facebookEmail
                    print("Facebook Email: \(facebookEmail)")
                } else {
                    self.fbEmail = ""
                    print("Facebook Email: Not exists")
                }
                
                print("Facebook Access Token: \(token?.tokenString ?? "")")
                
                if (self.fbEmail != "") {
                    self.callSignup(strFullName:self.fbName,strEmail:self.fbEmail, loginWith: "facebook" )
                }else {
                    self.showAlertWith(message: "We are unable to fetch your email id from Facebook. Please try other processes of sign up.".localized())
                }
            } else {
                print("Error: Trying to get user's info")
            }
        }
        
    }
    
    func getFBUserData(){
        
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result as Any)
                }
            })
        }else {
            print("null")
        }
        //
        let loginManager = LoginManager()
        
        
        
        //  UIApplication.shared.statusBarStyle = .default  // remove this line if not required
        /*   loginManager.logIn(permissions: [ .publicProfile,.email ], viewController: self) { loginResult in
         print(loginResult)
         
         //            let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name, picture.type(large)"])
         //            request.start { (response, result)   in
         //                                switch result {
         //                                case .success(let value):
         //                                    print(value.dictionaryValue!)
         //                                    self.responseJSON = JSON(value.dictionaryValue!)
         //                                    let fullName = self.responseJSON["first_name"].stringValue
         //                                    let firstName = self.responseJSON["first_name"].stringValue
         //                                    let lastName = self.responseJSON["last_name"].stringValue
         //                                    let email = self.responseJSON["email"].stringValue
         //                                    let idFb = self.responseJSON["id"].stringValue
         //                                    let picture = self.responseJSON["picture"]["data"]["url"].stringValue
         //
         //                                    print("user id: \(idFb), firstName: \(firstName), fullname: \(fullName), lastname: \(lastName), picture: \(picture), email: \(email)")
         //
         //                                print("ALL FIELDS PUBLISHED")
         //
         //
         //                                if let delegate = self.responseDelegate {
         //                                    delegate.responseUpdated(self.responseJSON, forLogin: "FB")
         //                                }
         //
         //                            case .failed(let error):
         //                                print(error)
         //                            }
         //                        }
         //                    }
         
         //use picture.type(large) for large size profile picture
         _ = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name, picture.type(large)"]).start { (connection, result, error) -> Void in
         if (error == nil){
         //everything works print the user data
         print("Result111:\(String(describing: result)) "as Any)
         }
         let dict = result as? NSDictionary
         print("FB Email1st:\(String(describing: dict))")
         
         if let id = dict?["id"] as? String{
         self.fbId = id
         }
         if let fname = dict?["first_name"] as? String{
         self.fbFName = fname
         }
         if let lname = dict?["last_name"] as? String{
         self.fbLName = lname
         }
         if let fName = dict?["name"] as? String {
         self.fbName = fName
         }
         if let Email = dict?["email"] as? String{
         self.fbEmail = Email
         }
         var getPhone = ""
         if let phone = dict?["phone"] as? String {
         getPhone = phone
         }
         //get user picture url from dictionary
         //                if let  fbPickUrl = (((dict?["picture"] as? [String: Any])?["data"] as? [String:Any])?["url"] as? String){
         //                self.downloadImage(with: fbPickUrl) {
         //
         //                }
         //                }
         print("FB ID: \(self.fbId)\n FB Email:\(self.fbEmail) \n FbFName:\(self.fbName) \n fbLName:\(self.fbLName) \n \(getPhone)")
         self.getFbUserProfileInfo()
         ////CALL API BY LOGIN WITH FB
         if (self.fbEmail != "") {
         self.callSignup(strFullName:self.fbName,strEmail:self.fbEmail )
         }else {
         self.showAlertWith(message: "We are unable to fetch your email id from Facebook. Please try other processes of sign up.".localized())
         }
         
         }
         } */
        
        /*  if((AccessToken.current) != nil){
         GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
         if (error == nil){
         //everything works print the user data
         print("Result111:\(String(describing: result)) "as Any)
         }
         let dict = result as? NSDictionary
         print("FB Email1st:\(String(describing: dict))")
         //                var fbId = ""
         //                var fbFName = ""
         //                var fbLName = ""
         //                var fbEmail = ""
         //                var fbName  = ""
         if let id = dict?["id"] as? String{
         self.fbId = id
         }
         if let fname = dict?["first_name"] as? String{
         self.fbFName = fname
         }
         if let lname = dict?["last_name"] as? String{
         self.fbLName = lname
         }
         if let fName = dict?["name"] as? String {
         self.fbName = fName
         }
         if let Email = dict?["email"] as? String{
         self.fbEmail = Email
         }
         var getPhone = ""
         if let phone = dict?["phone"] as? String {
         getPhone = phone
         }
         //get user picture url from dictionary
         //                if let  fbPickUrl = (((dict?["picture"] as? [String: Any])?["data"] as? [String:Any])?["url"] as? String){
         //                self.downloadImage(with: fbPickUrl) {
         //
         //                }
         //                }
         print("FB ID: \(self.fbId)\n FB Email:\(self.fbEmail) \n FbFName:\(self.fbFName) \n fbLName:\(self.fbLName) \n \(getPhone)")
         ////CALL API BY LOGIN WITH FB
         
         self.callSignup(strFullName:self.fbFName,strEmail:self.fbEmail )
         
         })
         
         } */
        
        getFbUserProfileInfo()
        
        
    }
    
    
    
    func getFbUserProfileInfo() {
        let connection  = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields" : "id,first_name,last_name,email,name"], tokenString: AccessToken.current?.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)) { (connection, values, error) in
            if let res = values {
                if let response = res as? [String: Any] {
                    let username = response["name"]
                    let email = response["email"]
                    print("\(email ?? "") \(username ?? "")")
                }
            }
        }
        connection.start()
        guard let accessToken = FBSDKLoginKit.AccessToken.current else { return }
        let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                      parameters: ["fields": "email, name"],
                                                      tokenString: accessToken.tokenString,
                                                      version: nil,
                                                      httpMethod: .get)
        graphRequest.start { (connection, result, error) -> Void in
            if error == nil {
                print("result \(String(describing: result))")
            }
            else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    func callSignup(strFullName:String,strEmail:String,loginWith: String ) {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelLogin?.callSignup(fullName: strFullName, email: strEmail, loginWith: loginWith,  completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    
                    if let success = result as? Bool , success == true {
                        if let loginType = UserDefaults.standard.value(forKey: "LOGINTYPE") {
                            let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        }else {
                            let VC = UsertypeViewController(nibName: "UsertypeViewController", bundle: nil)
                            VC.modalPresentationStyle = .overCurrentContext
                            VC.delegate = self
                            self.navigationController?.present(VC, animated: true, completion: nil)
                        }
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                    
                }
            }
        })
        
        
    }
}

extension LogInVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            
            print(userIdentifier)
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email ?? ""
            
            if let identityTokenData = appleIDCredential.identityToken,let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
                do {
                    let jwt = try decode(jwt: identityTokenString)
                    let decodedBody = jwt.body as Dictionary
                    print(decodedBody)
                    print("Decoded email: "+(decodedBody["email"] as? String ?? "n/a"))
                    let getEmail = (decodedBody["email"] as? String ?? "n/a")
                    let Name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
                    print(getEmail, "\(Name)")
                    if (Name != ""){
                        
                        callSignup(strFullName:Name,strEmail:getEmail, loginWith: "apple" )
                    }
                } catch {
                    print("decoding failed")
                }
                
            }
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    
    
    
}
extension LogInVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK:- Auth Signin Api Call

extension LogInVC {
    func callAuthSignin() {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelLogin?.authsignIn(email: arrCointainer[0], password: arrCointainer[1], completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        let alertOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
                            let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        }
                        self.showAlertWith(message: "Login successful".localized(), type: .custom(actions: [alertOkAction]))
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    if (error.localizedDescription == "User does not exist."){
                        self.showAlertWith(message: "User does not exist.".localized())
                    }else if (error.localizedDescription == "Incorrect username or password."){
                        self.showAlertWith(message: "Incorrect username or password.".localized())
                    }else {
                        self.showAlertWith(message: error.localizedDescription)
                    }
                    
                }
            }
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String) {
        Amplify.Auth.update(oldPassword: oldPassword, to: newPassword) { result in
            switch result {
            case .success:
                print("Change password succeeded")
            case .failure(let error):
                print("Change password failed with error \(error)")
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                //                    DispatchQueue.main.async {
                //
                //                    let manager = LoginManager()
                //                    manager.logOut()
                //                    if let editpassVC = UIApplication.getTopMostViewController()?.navigationController?.ifExitsOnStack(vc: LogInVC.self) {
                //                        UIApplication.getTopMostViewController()?.navigationController?.popToViewController(editpassVC, animated: true)
                //
                //                    }else {
                //                        let myCartVC = LogInVC(nibName: "LogInVC", bundle: nil)
                //                        UIApplication.getTopMostViewController()?.navigationController?.pushViewController(myCartVC, animated: true)
                //                    }
                //                    }
                // self.hide()
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}

extension LogInVC:UITextViewDelegate {
    //MARK:Terms and condition click
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == "terms") {
            let signupVC = SignupVc(nibName: "SignupVc", bundle: nil)
            self.navigationController?.pushViewController(signupVC, animated: true)
        }
        
        return true
    }
    
}

extension LogInVC:UserTypeDelegate {
    func userTypeConfirm(){
        let forgotpassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
        let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    
}


extension LogInVC{
    func socialSignInWithWebUI() {
      
        Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                AWSMobileClient.default().getUserAttributes { (attributes, error) in
                     if(error != nil){
                        print("ERROR: \(String(describing: error))")
                     }else{
                        if let attributesDict = attributes{
                            print(attributesDict)
                            print(attributesDict["email"]!)
                            let fbemail = attributesDict["email"]!
                            let fbname =  attributesDict["name"]!
                            let loginwith = "facebook"
                            UserDefaults.standard.setValue(loginwith, forKey: "LOGINTYPE")
                            UserDefaults.standard.setValue(fbemail, forKey: "EMAIL")
                            UserDefaults.standard.setValue(fbname, forKey: "NAME")
                            self.callSignup(strFullName:fbname, strEmail: fbemail, loginWith: loginwith)
                        }
                     }
                }
               
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
       
    }
        
    
    func socialSignInWithWebUIApple() {
        Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                Amplify.Auth.fetchAuthSession { result in
                    do {
                        let session = try result.get()
            
                        // Get user sub or identity id
                        if let identityProvider = session as? AuthCognitoIdentityProvider {
                            let usersub = try identityProvider.getUserSub().get()
                            let identityId = try identityProvider.getIdentityId().get()
                            //print("User sub - \(usersub) and identity id \(identityId)")
                        }
            
                        // Get aws credentials
                        if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                            let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                            print("Access key - \(credentials.accessKey) ")
                        }
            
                        // Get cognito user pool token
                        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                            let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                            print("Id token - \(tokens.idToken) ")
                        }
                        
                        let user = Users.keys
                        print(user.email)
                       // let predicate = user.email == email
//                        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
//                            switch event {
//                            case .success(let result):
//                                switch result {
//                                case .success(let user):
//                //                    print("Successfully retrieved list of todos: \(String(describing: user[0].is_phone_valid))")
//                                //    print(user[0])
//                                    if (user.count == 1) {
//                                        let defaults = UserDefaults.standard
//                                       // defaults.synchronize()
//                                        defaults.removeObject(forKey: "ID")
//                                        defaults.removeObject(forKey: "EMAIL")
//                                        defaults.removeObject(forKey: "NAME")
//                                        defaults.removeObject(forKey: "LOGINTYPE")
//                                        defaults.removeObject(forKey: "PHONE")
//                                        defaults.removeObject(forKey: "LOGINWITH")
//
//                                        UserDefaults.standard.setValue(user[0].email, forKey: "EMAIL")
//                                        UserDefaults.standard.setValue(user[0].full_name, forKey: "NAME")
//                                        UserDefaults.standard.setValue(user[0].id, forKey: "ID")
//                                        UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
//                                        UserDefaults.standard.setValue(user[0].phone, forKey: "PHONE")
//                                        UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
//                //                        UserDefaults.standard.setValue(user[0].is_phone_valid, forKey: "PHONEVALIDATE")
//                                      //  completion(.success(true))
//                                    }else if (user.count == 0) {
//                                        completion(.failure(NeidersError.customMessage("Wrong credential! \nPlease check your Email or Password".localized())))
//                                    }else {
//                                        UserDefaults.standard.setValue(user[0].email, forKey: "EMAIL")
//                                        UserDefaults.standard.setValue(user[0].full_name, forKey: "NAME")
//                                        UserDefaults.standard.setValue(user[0].id, forKey: "ID")
//                                        UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
//                                        UserDefaults.standard.setValue(user[0].phone, forKey: "PHONE")
//                                        UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
//                //                        UserDefaults.standard.setValue(user[0].is_phone_valid, forKey: "PHONEVALIDATE")
//                                       // completion(.success(true))
//                                    }
//                                case .failure(let error):
//                                  //  completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//
//                                    print("Got failed result with \(error.errorDescription)")
//                                }
//                            case .failure(let error):
//                             //   completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//
//                                print("Got failed event with error \(error)")
//                            }
//                        }
                     } catch {
                        print("Fetch auth session failed with error - \(error)")
                       // completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    }
                }
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    
}
class CustomIdentityProvider: NSObject, AWSIdentityProviderManager {
    var tokens : [String : String]?
    
    init(tokens: [String : String]) {
        self.tokens = tokens
    }
    
    @objc func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: tokens! as NSDictionary)
    }
}
