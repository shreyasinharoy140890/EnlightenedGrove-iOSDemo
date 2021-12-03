//
//  ProfileVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 06/09/21.
//

import UIKit
import MRCountryPicker
import PhoneNumberKit


class ProfileVC: UIViewController,AlertDisplayer,MRCountryPickerDelegate {
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tableProfile: UITableView!
    
    @IBOutlet weak var countryCodePicker: MRCountryPicker!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var btnSaveChange: UIButton!
    
    var arrayInputField = [["Full Name".localized(),"user_icon"], ["Email Id".localized(),"email_icon"],["Phone Number".localized(),"mobile_icon"]]
    var viewModelProfile:ProfileViewModelProtocol?
    var tempcountryCode = "+233"
    var phoneNumberOnly = ""
    var countryCode: String?
    private var activeTextField:UITextField!
    var isdatacomingfromotp:Bool? = false
    var phNo:String = ""
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableProfile.delegate = self
        tableProfile.dataSource = self
        tableProfile.register(ProfileTableViewCell.self)
        tableProfile.register(PhoneWithCountrycodeTableCell.self)
        viewHeader.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        viewModelProfile = ProfileViewModel()
        setupData()
        setUpCountryPicker()
        setUI()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (isdatacomingfromotp == true){
            self.callupdate()
        }
    }
    
    func setUI(){
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        btnSaveChange.setTitle("SAVE CHANGES".localized(), for: .normal)
    }
    
    
    func phoneNumberParse(phoneNo:String) -> String {
        
        
        var phNo:String = ""
        
        
        let phoneNumberKit = PhoneNumberKit()
        
        do {
            
            let phoneNumber = try phoneNumberKit.parse(phoneNo)
            
            phNo  = String(describing:phoneNumber.nationalNumber)
            print(phNo)
            let onlyNumber = phoneNo.components(separatedBy: phNo)
            tempcountryCode = onlyNumber[0]
            countryCode = tempcountryCode
            viewModelProfile?.arrayInputField[2][2] = phNo
            phoneNumberOnly = phNo
            
        }
        
        catch {
        }
        return phNo
    }
    
    //MARK:- Picker Setup -------------------
    func setUpCountryPicker() {
        
        countryCodePicker.countryPickerDelegate = self
        countryCodePicker.showPhoneNumbers = true
        //        textfieldCountryCode.text = tempcountryCode
        if let phone = UserDefaults.standard.string(forKey: "PHONE")  {
            if (phone.contains("-")){
                let onlyNumber = phone.components(separatedBy: "-")
                viewModelProfile?.arrayInputField[2][2] = onlyNumber[1]
                phoneNumberOnly = onlyNumber[1]
                
                
                if (onlyNumber[0] == ""){
                    tempcountryCode = "+233"
                    countryCode = tempcountryCode
                }else {
                    tempcountryCode = onlyNumber[0]
                    countryCode = onlyNumber[0]
                    
                }
                countryCodePicker.setCountry(countryCode!)
            }else {
                // countryCodePicker.setCountry("+233")
                self.phoneNumberParse(phoneNo: phone)
            }
        }else {
            countryCodePicker.setCountry("+233")
        }
        //countryCode = "+233"
        
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
    }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.tempcountryCode = phoneCode
        self.countryCode = self.tempcountryCode
        
    }
    
    func setupData(){
        if let username = UserDefaults.standard.string(forKey: "NAME") {
            viewModelProfile?.arrayInputField[0][2] = username
        }
        if let email = UserDefaults.standard.string(forKey: "EMAIL")  {
            viewModelProfile?.arrayInputField[1][2] = email
        }
        if let phone = UserDefaults.standard.string(forKey: "PHONE")  {
            
            if phone.contains("-"){
                let onlyNumber = phone.components(separatedBy: "-")
                viewModelProfile?.arrayInputField[2][2] = onlyNumber[1]
            }else {
                self.phoneNumberParse(phoneNo: phone)
            }
        }
    }
    
    @IBAction func btnSaveChanges(_ sender: Any) {
        
        if (viewModelProfile?.arrayValueContainer[2] == ""){
            if let phone = UserDefaults.standard.string(forKey: "PHONE"){
                viewModelProfile?.arrayInputField[2][2] = phone
            }
            callupdate ()
        }else {
            viewModelProfile?.arrayInputField[2][2] = "\(viewModelProfile?.arrayValueContainer[3] ?? "")-\(viewModelProfile?.arrayValueContainer[2] ?? "")"
            phoneNumberOnly = viewModelProfile?.arrayValueContainer[2] ?? ""
            gotoFortotpass()
            // callupdate ()
        }
        // viewModelProfile?.CallUpdate()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClickPickerDone(_ sender: UIButton) {
        self.view.endEditing(true)
        self.countryCode = self.tempcountryCode
        viewModelProfile?.arrayValueContainer[3] = self.countryCode ?? ""
        // textfieldCountryCode.text = self.countryCode
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
        tableProfile.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
    }
    
    @IBAction func btnClickPickerCancel(_ sender: UIButton) {
        countryCodePicker.isHidden = true
        viewPicker.isHidden = true
    }
    
}

extension ProfileVC: UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelProfile?.arrayInputField.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: PhoneWithCountrycodeTableCell.self), for: indexPath) as! PhoneWithCountrycodeTableCell
            cell.viewBorder.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
            cell.lblHeader.text = viewModelProfile?.arrayInputField[indexPath.row][0]
            cell.viewBorder.backgroundColor = .white
            cell.textfieldPhoneNumber.tag = indexPath.row
            cell.textFieldCountryCode.tag = 3
            cell.textFieldCountryCode.text = self.tempcountryCode
            cell.textfieldPhoneNumber.text = viewModelProfile?.arrayInputField[indexPath.row][2]
            cell.btnPickerShow.addTarget(self, action: #selector(btnPickerShow(_:)), for: .touchUpInside)
            cell.textfieldPhoneNumber.delegate = self
            cell.textfieldPhoneNumber.autocorrectionType = .no
            cell.textfieldPhoneNumber.addToolBar(self, selector: #selector(donePressed))
            cell.textfieldPhoneNumber.addTarget(self, action: #selector(textFiledValueChange(_:)), for: .editingChanged)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: ProfileTableViewCell.self), for: indexPath) as! ProfileTableViewCell
            cell.lblheader.text = viewModelProfile?.arrayInputField[indexPath.row][0]
            cell.imgprofile.image = UIImage(named: arrayInputField[indexPath.row][1])
            if (indexPath.row == 1){
                cell.textInput.isUserInteractionEnabled = false
            }else {
                cell.textInput.isUserInteractionEnabled = true
            }
            cell.textInput.delegate = self
            cell.textInput.text = viewModelProfile?.arrayInputField[indexPath.row][2]
            cell.textInput.tag = indexPath.row
            cell.textInput.addTarget(self, action: #selector(textFiledValueChange(_:)), for: .editingChanged)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func textFiledValueChange(_ sender:UITextField){
        viewModelProfile?.arrayInputField[sender.tag][2] = sender.text!
        viewModelProfile?.arrayValueContainer[sender.tag] = sender.text!
        viewModelProfile?.arrayValueContainer[3] = self.countryCode ?? ""
        print(viewModelProfile?.arrayInputField as Any)
        print(viewModelProfile?.arrayValueContainer as Any)
    }
    
    @objc func btnPickerShow(_ sender:UIButton){
        viewPicker.isHidden = false
        countryCodePicker.isHidden = false
    }
    @objc private func donePressed() {
        self.view.endEditing(true)
        activeTextField?.resignFirstResponder()
    }
    
    func gotoFortotpass(){
        let forgotpassVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
        let countrycode = self.countryCode
        //viewModelSignup?.user.phone?.components(separatedBy: "-")
        forgotpassVC.phoneNumber = viewModelProfile?.arrayValueContainer[2] ?? ""
        forgotpassVC.countryCode = countrycode ?? ""
        forgotpassVC.isComingFromloginVC = false
        forgotpassVC.ComingFromVC = "profile"
        self.navigationController?.pushViewController(forgotpassVC, animated: true)
    }
    
}

extension ProfileVC {
    func callupdate () {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelProfile?.CallUpdate(fullName:  viewModelProfile?.arrayInputField[0][2],  phone: phoneNumberOnly, completion: {(result) in
            switch result {
            case .success(let result):
                if let success = result as? Bool , success == true {
                    DispatchQueue.main.async {
                        hideActivityIndicator(viewController: self)
                        self.showAlertWith(message: "Profile updated successfully".localized())
                        //self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
                
            }
        })
    }
}

//MARK:- Text filed Methods-----------------
extension ProfileVC {
    
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
