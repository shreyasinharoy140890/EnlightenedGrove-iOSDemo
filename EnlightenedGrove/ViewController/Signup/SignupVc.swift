//
//  SignupVc.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 20/04/21.
//

import UIKit
import AmplifyPlugins
import Amplify
import MRCountryPicker
import AWSMobileClient
import AWSPluginsCore



class SignupVc: UIViewController,AlertDisplayer,MRCountryPickerDelegate {
    
    @IBOutlet weak var countryCodePicker: MRCountryPicker!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var tableSignup: UITableView!
    
    private var activeTextField:UITextField!
    
    
    var viewModelSignup: SignupViewModel?
    var iconClick = true
    var countryCode: String?
    var tempcountryCode = "+233"
    var emailOTP:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelSignup = SignupViewModel()
        tableSignup.delegate = self
        tableSignup.dataSource = self
        tableSignup.register(InputTableViewCell.self)
        tableSignup.register(UserTypeTableCell.self)
        tableSignup.register(SubmitTableViewCell.self)
        tableSignup.register(PhoneWithCountrycodeTableCell.self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUpCountryPicker()
        // activeTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK:- Picker Setup -------------------
    func setUpCountryPicker() {
        
        countryCodePicker.countryPickerDelegate = self
        countryCodePicker.showPhoneNumbers = true
        //        textfieldCountryCode.text = tempcountryCode
        countryCode = "+233"
        countryCodePicker.setCountry("+233")
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
    }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.tempcountryCode = phoneCode
        
    }
    
    @IBAction func btnClickPickerDone(_ sender: UIButton) {
        self.view.endEditing(true)
        self.countryCode = self.tempcountryCode
        // textfieldCountryCode.text = self.countryCode
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
        tableSignup.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
    
    @IBAction func btnClickPickerCancel(_ sender: UIButton) {
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
    }
    
    
    // MARK:- Keyboard Setup-----------------
    @objc private func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            if activeTextField != nil {
                // UIScreen.main.nativeBounds.height <= 1334
                if activeTextField.tag == 3 {
                    moveView(keyboardSize:keyboardSize)
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            tableSignup.setContentInsetAndScrollIndicatorInsets(to: 0)
        }
    }
    
    private func moveView(keyboardSize:CGSize) {
        if let cellView = activeTextField.superview?.superview {
            let rect = tableSignup.convert(activeTextField.bounds, from: activeTextField)
            
            let bottomPadding = UIApplication.key?.safeAreaInsets.bottom ?? 0.0
            let keyboardHeight = keyboardSize.height - (AppConstant.defaultToolbarHeight + bottomPadding)
            
            
            if rect.origin.y + cellView.frame.height >= keyboardHeight {
                tableSignup.setContentInsetAndScrollIndicatorInsets(to: keyboardHeight)
            }else {
                tableSignup.setContentInsetAndScrollIndicatorInsets(to: 80)
            }
        }
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK:- API Call -------------------
    func callSignup() {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelSignup?.callSignup(fullName: viewModelSignup?.arrayContainer[0] ?? "", email: viewModelSignup?.arrayContainer[1] ?? "", phone: viewModelSignup?.arrayContainer[3] ?? "", password: viewModelSignup?.arrayContainer[2] ?? "", loginType: viewModelSignup?.arrayContainer[4] ?? "", completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Users , success.phone != "" {
                        print(success.phone as Any)
                        let alertOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
                            let VC = EmailValidationVC(nibName: "EmailValidationVC", bundle: nil)
                            VC.modalPresentationStyle = .overCurrentContext
                            VC.delegate = self
                            VC.username = success.email
                            VC.isdataFromForgotpass = false
                            self.navigationController?.present(VC, animated: true, completion: nil)
                            
                            //                            let forgotpassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
                            //                            let countrycode = success.phone?.components(separatedBy: " ")
                            //                            forgotpassVC.phoneNumber = countrycode?[1] ?? ""
                            //                            forgotpassVC.countryCode = countrycode?[0] ?? ""
                            //
                            //                            forgotpassVC.isComingFromloginVC = false
                            //                            self.navigationController?.pushViewController(forgotpassVC, animated: true)
                        }
                        self.showAlertWith(message: "Sign up successful".localized(), type: .custom(actions: [alertOkAction]))
                        
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                    
                }
            }
        })
    }
    
    
    func callSignupAuth() {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelSignup?.signUpAuth(username: viewModelSignup?.arrayContainer[0] ?? "", password: viewModelSignup?.arrayContainer[2] ?? "", email: viewModelSignup?.arrayContainer[1] ?? "",phonenumber: viewModelSignup?.arrayContainer[3] ?? "",logintype:viewModelSignup?.arrayContainer[4] ?? "", completion: {(result) in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let result):
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Users , success.phone != "" {
                        print(success.phone as Any)
                        let alertOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
                            let VC = EmailValidationVC(nibName: "EmailValidationVC", bundle: nil)
                            VC.modalPresentationStyle = .overCurrentContext
                            VC.delegate = self
                            VC.username = success.email
                            VC.isdataFromForgotpass = false
                            self.navigationController?.present(VC, animated: true, completion: nil)
                            
                            //                            let forgotpassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
                            //                            let countrycode = success.phone?.components(separatedBy: " ")
                            //                            forgotpassVC.phoneNumber = countrycode?[1] ?? ""
                            //                            forgotpassVC.countryCode = countrycode?[0] ?? ""
                            //
                            //                            forgotpassVC.isComingFromloginVC = false
                            //                            self.navigationController?.pushViewController(forgotpassVC, animated: true)
                        }
                        self.showAlertWith(message: "Sign up successful".localized(), type: .custom(actions: [alertOkAction]))
                        
                    }
                    
                    
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                    
                }
            }
        })
    }
    
    
    
}

//MARK:- TableView related Methods -------------------
extension SignupVc:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return viewModelSignup?.arrayInputField.count ?? 0
        }else if (section == 1){
            return 1
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if (indexPath.row == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: PhoneWithCountrycodeTableCell.self), for: indexPath) as! PhoneWithCountrycodeTableCell
                cell.lblHeader.isHidden = true
                cell.textfieldPhoneNumber.tag = indexPath.row
                cell.textFieldCountryCode.text = tempcountryCode
                cell.textfieldPhoneNumber.placeholder = viewModelSignup?.arrayInputField[indexPath.row][0]
                cell.btnPickerShow.addTarget(self, action: #selector(btnPickerShow(_:)), for: .touchUpInside)
                cell.textfieldPhoneNumber.delegate = self
                cell.textfieldPhoneNumber.autocorrectionType = .no
                cell.textfieldPhoneNumber.addToolBar(self, selector: #selector(donePressed))
                cell.textfieldPhoneNumber.addTarget(self, action: #selector(textInputValue(_:)), for: .editingChanged)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: InputTableViewCell.self), for: indexPath) as! InputTableViewCell
                cell.textInputType.tag = indexPath.row
                cell.textInputType.placeholder = viewModelSignup?.arrayInputField[indexPath.row][0]
                cell.imageInputType.image = UIImage(named: viewModelSignup?.arrayInputField[indexPath.row][1] ?? "")
                cell.btnShowPassword.isHidden = true
                if (cell.textInputType.tag == 2) {
                    
                    cell.textInputType.isSecureTextEntry = true
                    cell.textInputType.keyboardType = .default
                    cell.textInputType.textContentType = .oneTimeCode
                    cell.btnShowPassword.isHidden = false
                    cell.btnShowPassword.addTarget(self, action: #selector(showHidePassword(_:)), for: .touchUpInside)
                    cell.btnShowPassword.tag = indexPath.row
                    cell.lblPasswordDeclaration.text = "Password should be of min 8 characters including upper string,lower string,alphanumeric and special symbols".localized()
                }
                
                else {
                    cell.textInputType.isSecureTextEntry = false
                    cell.textInputType.keyboardType = .emailAddress
                    cell.lblPasswordDeclaration.text = ""
                }
                
                cell.textInputType.delegate = self
                cell.textInputType.autocorrectionType = .no
                cell.textInputType.addToolBar(self, selector: #selector(donePressed))
                cell.textInputType.addTarget(self, action: #selector(textInputValue(_:)), for: .editingChanged)
                
                return cell
            }
        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: UserTypeTableCell.self), for: indexPath) as! UserTypeTableCell
            cell.btnStudent.addTarget(self, action: #selector(btnStudentClicked(_:)), for: .touchUpInside)
            cell.btnTeacher.addTarget(self, action: #selector(btnTeacherClicked(_:)), for: .touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: SubmitTableViewCell.self), for: indexPath) as! SubmitTableViewCell
            cell.btnSubmit.addTarget(self, action: #selector(btnSubmitClick(_:)), for: .touchUpInside)
            cell.btnSubmit.setTitle("Sign up".localized(), for: .normal)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:  switch indexPath.row {
        case 0: return 70
        case 1: return 70
        case 2: return 90
        case 3: return 70
        default:
            return 0
        }
        
        case 1: return 100
        case 2: return 90
        default:
            return 0
        }
        
    }
    @objc private func donePressed() {
        self.view.endEditing(true)
        activeTextField?.resignFirstResponder()
    }
    
    @objc func onDoneButtonTapped() {
        toolbar.removeFromSuperview()
    }
    @objc func btnStudentClicked(_ sender: UIButton){
        viewModelSignup?.arrayContainer[4] = "Student"
        let cell = tableSignup.cellForRow(at: IndexPath(row: 0, section: 1)) as? UserTypeTableCell
        cell?.imageStudent.image = UIImage(named: "active_radio_btn")
        cell?.imageViewTeacher.image = UIImage(named: "inactive_radio_btn")
    }
    @objc func btnTeacherClicked(_ sender: UIButton){
        let cell = tableSignup.cellForRow(at: IndexPath(row: 0, section: 1)) as? UserTypeTableCell
        cell?.imageStudent.image = UIImage(named: "inactive_radio_btn")
        cell?.imageViewTeacher.image = UIImage(named: "active_radio_btn")
        viewModelSignup?.arrayContainer[4] = "Teacher"
    }
    @objc func textInputValue(_ textfield:UITextField) {
        if (textfield.tag == 3){
            viewModelSignup?.arrayContainer[textfield.tag] = "\(tempcountryCode)-\(textfield.text!)"
        }else {
            viewModelSignup?.arrayContainer[textfield.tag] = textfield.text!
        }
        print(viewModelSignup?.arrayContainer[textfield.tag] ?? "")
        let countrycode = viewModelSignup?.arrayContainer[textfield.tag].components(separatedBy: "-")
        print(countrycode ?? "")
    }
    
    @objc func btnSubmitClick(_ sender:UIButton){
          callSignup()
        // get()
       // callSignupAuth()
    }
    @objc func btnPickerShow(_ sender:UIButton){
        viewPicker.isHidden = false
        countryCodePicker.isHidden = false
    }
    
    
    @objc func showHidePassword(_ sender:UIButton){
        let cell = tableSignup.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! InputTableViewCell
        if(iconClick == true) {
            
            cell.textInputType.isSecureTextEntry = false
            cell.btnShowPassword.setImage(UIImage(named: "view"), for: .normal)
        } else {
            cell.textInputType.isSecureTextEntry = true
            cell.btnShowPassword.setImage(UIImage(named: "invisible"), for: .normal)
        }
        
        iconClick = !iconClick
    }
}

//MARK:- Text filed Methods-----------------
extension SignupVc: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeTextField = nil
        toolbar.removeFromSuperview()
        
        
    }
}

extension SignupVc:EmailconfirmedDelegate {
    func emailconfirmed() {
        let forgotpassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
        let countrycode = viewModelSignup?.user.phone?.components(separatedBy: "-")
        forgotpassVC.phoneNumber = countrycode?[1] ?? ""
        forgotpassVC.countryCode = countrycode?[0] ?? ""
        forgotpassVC.isComingFromloginVC = false
        forgotpassVC.ComingFromVC = "signup"
        self.navigationController?.pushViewController(forgotpassVC, animated: true)
    }
    
    
}





