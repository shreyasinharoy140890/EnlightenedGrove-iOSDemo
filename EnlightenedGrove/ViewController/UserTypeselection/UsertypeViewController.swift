//
//  UsertypeViewController.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 08/10/21.
//

import UIKit
protocol UserTypeDelegate: class {
    func userTypeConfirm()
}

class UsertypeViewController: UIViewController,AlertDisplayer {
    @IBOutlet weak var LblLogin: UILabel!
    @IBOutlet weak var lblTeacher: UILabel!
    @IBOutlet weak var lblStudent: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    var id:String?
    @IBOutlet weak var imgActiveInactiveStudent: UIImageView!
    
    @IBOutlet weak var imgActiveInactiveTeacher: UIImageView!
    
    @IBOutlet weak var lblLoginAs: UILabel!
   
    @IBOutlet weak var viewShadow: UIView!
    
    
    
    var viewModelProfile:userTypeViewModelProtocol?
    var selecteduserType:String? = ""
    weak var delegate:UserTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelProfile = UserTypeViewModel()
        viewShadow.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        setup()

        // Do any additional setup after loading the view.
    }
    
    func setup(){
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        lblStudent.text = "Student".localized()
        lblTeacher.text = "Teacher".localized()
        lblLoginAs.text = "You want to Login as ?".localized()
        btnSave.setTitle("Save".localized(), for: .normal)
        
        
    }

    @IBAction func btnTeacher(_ sender: Any) {
        imgActiveInactiveTeacher.image = UIImage(named: "active_radio_btn")
        imgActiveInactiveStudent.image = UIImage(named: "inactive_radio_btn")
        selecteduserType = "Teacher"
        
    }
    @IBAction func btnStudent(_ sender: Any) {
        imgActiveInactiveStudent.image = UIImage(named: "active_radio_btn")
        imgActiveInactiveTeacher.image = UIImage(named: "inactive_radio_btn")
        selecteduserType = "Student"
    }
    @IBAction func btnSave(_ sender: Any) {
        callUpdateUserType(selectedUserType: selecteduserType ?? "")
       
    }
    
  

}

extension UsertypeViewController{
    func callUpdateUserType(selectedUserType:String){
        if (selecteduserType != "") {
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelProfile?.CallUpdate(userType: selectedUserType, completion: {(result) in
            switch result {
            case .success(let result):
                if let success = result as? Bool , success == true {
                    DispatchQueue.main.async {
                        hideActivityIndicator(viewController: self)
                        self.delegate?.userTypeConfirm()
                        self.dismiss(animated: true, completion: nil)
         }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
          
            }
        })
        }else {
            showAlertWith(message: "Please select one Option.".localized())
        }
    }
}
