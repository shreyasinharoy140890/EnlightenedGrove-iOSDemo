//
//  EmailValidationVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 16/07/21.
//

import UIKit

protocol EmailconfirmedDelegate: class {
    func emailconfirmed()
}

class EmailValidationVC: UIViewController,AlertDisplayer {
    
    @IBOutlet weak var textOTP6: UITextField!
    @IBOutlet weak var textOTP5: UITextField!
    @IBOutlet weak var textOTP4: UITextField!
    @IBOutlet weak var textOTP3: UITextField!
    @IBOutlet weak var textOTP2: UITextField!
    @IBOutlet weak var textOTP1: UITextField!
    
    @IBOutlet weak var lblEnterOtpMsg: UILabel!
    
    var str1 = ""
    var str2 = ""
    var str3 = ""
    var str4 = ""
    var str5 = ""
    var str6 = ""
    var inputOTP = ""
    var delegate:EmailconfirmedDelegate?
    var viewModelemail: EmailValidationViewModel?
    var username:String?
    var isdataFromForgotpass:Bool?
    var newPassword:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelemail = EmailValidationViewModel()
        setupUI()
        if (isdataFromForgotpass ?? true) {
            guard let usrname = username else {
                return
            }
            viewModelemail?.resetPassword(username: usrname )
            
        }else {
            
        }
        
    }
    
    func setupUI(){
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        lblEnterOtpMsg.text = "Please enter the OTP sent to your email".localized()
        textOTP1.delegate = self
        textOTP2.delegate = self
        textOTP3.delegate = self
        textOTP4.delegate = self
        textOTP5.delegate = self
        textOTP6.delegate = self
        
        
        textOTP1.tag = 0
        textOTP2.tag = 1
        textOTP3.tag = 2
        textOTP4.tag = 3
        textOTP5.tag = 4
        textOTP6.tag = 5
        
        textOTP1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textOTP2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textOTP3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textOTP4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textOTP5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textOTP6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnSubmitOtp(_ sender: Any) {
        if (isdataFromForgotpass ?? false) {
            callPasswordChangeapi(userName:username ?? "",OTP:inputOTP,newPassword:newPassword ?? "")
        }else {
            callEmailConfirmedApi(userName: username ?? "", OTP: inputOTP)
        }
        
    }
    
    //MARK:- call Confirm Email OTP From Signup
    func callEmailConfirmedApi(userName:String,OTP:String) {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        
        viewModelemail?.confirmSignUp(for: userName , with: OTP,  completion: {(result) in
            DispatchQueue.main.async { [self] in
                switch result{
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        delegate?.emailconfirmed()
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showAlertWith(message: "Something went wrong.Please try again later".localized())
                    }
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
            }
        })
    }
    
    
    
    //MARK:- Call ForgotPassword Api 
    
    func callPasswordChangeapi(userName:String,OTP:String,newPassword:String) {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        
        viewModelemail?.confirmResetPassword(username: userName,newPassword: newPassword,confirmationCode: OTP, completion: {(result) in
            DispatchQueue.main.async { [self] in
                switch result{
                case .success(let result):
                    
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        delegate?.emailconfirmed()
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showAlertWith(message: "Something went wrong.Please try again later".localized())
                    }
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
            }
        })
    }
    
    
}

extension EmailValidationVC : UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if (text?.utf16.count)! == 1{
            switch textField{
            case textOTP1:
                str1 = textOTP1.text!
                textOTP2.becomeFirstResponder()
                
            case textOTP2:
                str2 = textOTP2.text!
                textOTP3.becomeFirstResponder()
                
            case textOTP3:
                str3 = textOTP3.text!
                textOTP4.becomeFirstResponder()
                
            case textOTP4:
                str4 = textOTP4.text!
                textOTP5.becomeFirstResponder()
                
            case textOTP5:
                str5 = textOTP5.text!
                textOTP6.becomeFirstResponder()
                
            case textOTP6:
                str6 = textOTP6.text!
                textOTP6.resignFirstResponder()
              default:
                break
            }
        }
        else if  text?.count == 0 {
            switch textField{
            case textOTP1:
                str1 = textOTP1.text!
                textOTP1.becomeFirstResponder()
                
            case textOTP2:
                str2 = textOTP2.text!
                textOTP1.becomeFirstResponder()
                
            case textOTP3:
                str3 = textOTP3.text!
                textOTP2.becomeFirstResponder()
                
            case textOTP4:
                str4 = textOTP4.text!
                textOTP3.becomeFirstResponder()
                
            case textOTP5:
                str5 = textOTP5.text!
                textOTP4.becomeFirstResponder()
                
            case textOTP6:
                str6 = textOTP6.text!
                textOTP5.becomeFirstResponder()
                
                
            default:
                break
            }
        }
        else{
            
            if textField.tag == 0 {
                if (textField.text! == ""){
                    str1 = textField.text!
                }
                else {
                    textField.text! = ""
                    str1 = textField.text!
                }
                
            }
            else if textField.tag == 1 {
                if (textField.text! == ""){
                    str2 = textField.text!
                }
                else {
                    textField.text! = ""
                    str2 = textField.text!
                }
                
            }
            else if textField.tag == 2 {
                if (textField.text! == ""){
                    str3 = textField.text!
                }
                else {
                    textField.text! = ""
                    str3 = textField.text!
                }
                
            }
            else if textField.tag == 3 {
                if (textField.text! == ""){
                    str4 = textField.text!
                }
                else {
                    textField.text! = ""
                    str4 = textField.text!
                }
                
            }
            else if textField.tag == 4 {
                if (textField.text! == ""){
                    str5 = textField.text!
                }
                else {
                    textField.text! = ""
                    str5 = textField.text!
                }
                
            }
            else if textField.tag == 5 {
                if (textField.text! == ""){
                    str6 = textField.text!
                }
                else {
                    textField.text! = ""
                    str6 = textField.text!
                }
                
            }
            
            
            print("Already have value")
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            str1 = textField.text!
        }
        else if textField.tag == 1 {
            str2 = textField.text!
        }
        else if textField.tag == 2 {
            str3 = textField.text!
        }
        else if textField.tag == 3 {
            str4 = textField.text!
        }
        else if textField.tag == 4 {
            str5 = textField.text!
        }
        else if textField.tag == 5 {
            str6 = textField.text!
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.inputOTP = "\(str1)\(str2)\(str3)\(str4)\(str5)\(str6)"
        print(inputOTP)
        
        
    }
    //    class func isString10Digits(ten_digits: String) -> Bool{
    //
    //        if !ten_digits.isEmpty {
    //
    //            let numberCharacters = NSCharacterSet.decimalDigits.inverted
    //            return !ten_digits.isEmpty && ten_digits.rangeOfCharacter(from: numberCharacters) == nil
    //        }
    //        return false
    //    }
}
