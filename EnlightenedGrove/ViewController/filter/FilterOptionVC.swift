//
//  FilterOptionVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 30/04/21.
//

import UIKit

class FilterOptionVC: UIViewController,AlertDisplayer {
    
    @IBOutlet weak var tableFilter: UITableView!
    
    @IBOutlet weak var lblFilter: UILabel!
    
    @IBOutlet weak var viewShadow: UIView!
    
    @IBOutlet weak var btnApply: UIButton!
    
    @IBOutlet weak var btnClearFilter: UIButton!
    var viewModelFilter: FilterViewModel?
    var setindexOrganization = Set<Int>()
    var setindexContentType = Set<Int>()
    var setindexLanguage = Set<Int>()
    var setindexSubject = Set<Int>()
    var setindexOrganizationStr = Set<String>()
    var setindexContentTypeStr = Set<String>()
    var setindexLanguagestr = Set<String>()
    var setindexSubjectstr = Set<String>()
    var strOrganizationName:String = ""
    var strLanguage:String = ""
    var strContentType:String = ""
    var strSubject:String = ""
    var storeItem:StoreItemList?
    var storeItemCount:[Int] = []
    var valueArray = [[Contents]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelFilter = FilterViewModel()
        tableFilter.delegate = self
        tableFilter.dataSource = self
        tableFilter.register(FilterCell.self)
        if let subject = UserDefaults.standard.value(forKey: "FILTER1") {
            strSubject = subject as? String ?? ""
            
        }
        if let organization = UserDefaults.standard.value(forKey: "FILTER2") {
            strOrganizationName = organization as? String ?? ""
            
        }
        if let content = UserDefaults.standard.value(forKey: "FILTER3") {
            strContentType = content as? String ?? ""
            
        }
        if let lang = UserDefaults.standard.value(forKey: "FILTER4") {
            strLanguage = lang as? String ?? ""
            
        }
        viewShadow.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        callContentList()
        lblFilter.text = "Filter".localized()
        btnApply.setTitle("APPLY".localized(), for: .normal)
        btnClearFilter.setTitle("Clear Filter".localized(), for: .normal)
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
       
        if strSubject != "" || strOrganizationName != "" || strContentType != "" || strLanguage != "" {
            viewModelFilter?.storeItem = StoreItemList(subject: strSubject, organizationName: strOrganizationName, contentType: strContentType, language: strLanguage)
        }
//        let obj = UserDefaults.standard.retrieve(object: StoreItemList.self, fromKey: "YourKey")
//
      //  print(storeItem ?? "")
        print(viewModelFilter?.storeItem ?? 0)
        print(valueArray.count )
      
    }
    func callContentList(){
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelFilter?.CallFilterApi(completion: {(result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let result):
                    //            DispatchQueue.main.async {
                    print(self.viewModelFilter?.storeItem.subject as Any)
                    print(self.storeItem?.subject as Any)
                    print(self.storeItem?.organizationName as Any)
                    print(self.storeItem?.language as Any)
                    print(self.storeItem?.contentType as Any)
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        self.tableFilter.reloadData()
                    }else {
                        self.showAlertWith(message: "Some thing went wrong. Please try again later".localized())
                    }
                // }
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
            }
        })
    }
    func callFilterList(){
        strOrganizationName = setindexOrganizationStr.joined(separator: "")
        strContentType = setindexContentTypeStr.joined(separator: "")
        strLanguage = setindexLanguagestr.joined(separator: "")
        strSubject = setindexSubjectstr.joined(separator: "")
        // strOrganizationName = setindexOrganizationStr.
        print("\(strOrganizationName) \(strContentType) \(strLanguage) \(strSubject)")
        viewModelFilter?.storeItem = StoreItemList(subject: strSubject, organizationName: strOrganizationName, contentType: strContentType, language: strLanguage)
        print(viewModelFilter?.storeItem ?? "")
        storeItem = viewModelFilter?.storeItem
        UserDefaults.standard.setValue(strOrganizationName, forKey: "FILTER2")
        UserDefaults.standard.setValue(strContentType, forKey: "FILTER3")
        UserDefaults.standard.setValue(strLanguage, forKey: "FILTER4")
        UserDefaults.standard.setValue(strSubject, forKey: "FILTER1")
        storeItemCount.removeAll()
        if strSubject != "" {
            storeItemCount.append(1)
        }
        if strOrganizationName != "" {
            storeItemCount.append(2)
        }
        if strContentType != "" {
            storeItemCount.append(3)
        }
        if strLanguage != "" {
            storeItemCount.append(4)
        }
       print(storeItemCount.count)
        UserDefaults.standard.setValue(storeItemCount.count, forKey: "BADGE")
        
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: StoreItemList.self, requiringSecureCoding: false)
//        UserDefaults.standard.set(data, forKey: "FILTER")
//        }catch{
//            print(error)
//        }
        
      //  UserDefaults.standard.save(customObject: viewModelFilter?.storeItem, inKey: "FILTER")
        
        if strOrganizationName.trimmed.count == 0 && strContentType.trimmed.count == 0 && strLanguage.trimmed.count == 0 && strSubject.trimmed.count == 0 {
            showAlertWith(message:"Please select at least one option to continue.".localized())
        }else {
            _ = self.navigationController?.popViewController(animated: true)
            let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
            previousViewController?.strOrganizationName = strOrganizationName
            previousViewController?.strContentType = strContentType
            previousViewController?.strLanguage = strLanguage
            previousViewController?.strSubject = strSubject
            previousViewController?.isFromFilter = true
        }
        
//        DispatchQueue.main.async {
//            showActivityIndicator(viewController: self)
//        }
//        viewModelFilter?.callFilteredContentList(organizationName: strOrganizationName, contentType: strContentType, language: strLanguage,subject:strSubject, completion: {(result) in
//            DispatchQueue.main.async {
//                switch result{
//                case .success(let result):
//                    //            DispatchQueue.main.async {
//
//                    hideActivityIndicator(viewController: self)
//                    if let success = result as? Bool , success == true {
//                        _ = self.navigationController?.popViewController(animated: true)
//                        let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
//                        previousViewController?.viewModelHome?.organizationName = self.viewModelFilter?.organizationName ?? [:]
//                        previousViewController?.viewModelHome?.valueArray = self.viewModelFilter?.valueArray ?? []
//                        previousViewController?.viewModelHome?.arrayOfSearchContent = self.viewModelFilter?.valueArray ?? []
//                        print(previousViewController?.viewModelHome?.valueArray as Any)
//                        previousViewController?.isFromFilter = true
//                        previousViewController?.viewModelHome?.storeItem = self.viewModelFilter?.storeItem ?? StoreItemList(subject: "", organizationName: "", contentType: "", language: "")
//
//                    }else {
//                        self.showAlertWith(message: "Some thing went wrong. Please try again later".localized())
//                    }
//                // }
//                case .failure(let error):
//                    hideActivityIndicator(viewController: self)
//                    self.showAlertWith(message: error.localizedDescription)
//                }
//            }
//        })
    }
    
    @IBAction func btnBack(_ sender: Any) {
       
        _ = self.navigationController?.popViewController(animated: true)
        let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
        if (strSubject == "" && strOrganizationName == "" && strContentType == "" && strLanguage == "") {
            previousViewController?.isFromFilter = false
        }else {
            previousViewController?.isFromFilter = true
            previousViewController?.strOrganizationName = strOrganizationName
            previousViewController?.strContentType = strContentType
            previousViewController?.strLanguage = strLanguage
            previousViewController?.strSubject = strSubject
           
        }
        
    }
    
    @IBAction func btnApply(_ sender: Any) {
        callFilterList()
       
//        _ = self.navigationController?.popViewController(animated: true)
//        let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
//        previousViewController?.strOrganizationName = setindexOrganizationStr.joined(separator: "")
//        previousViewController?.strContentType = setindexContentTypeStr.joined(separator: "")
//        previousViewController?.strLanguage = setindexLanguagestr.joined(separator: "")
//        previousViewController?.strSubject = setindexSubjectstr.joined(separator: "")
//        previousViewController?.isFromFilter = true
        
        
         }
    
    @IBAction func btnClearFilter(_ sender: Any) {
        setindexSubjectstr.removeAll()
        setindexSubject.removeAll()
        setindexLanguage.removeAll()
        setindexLanguagestr.removeAll()
        setindexOrganization.removeAll()
        setindexOrganizationStr.removeAll()
        setindexContentType.removeAll()
        setindexContentTypeStr.removeAll()
       
        viewModelFilter?.storeItem = StoreItemList(subject: "", organizationName: "", contentType: "", language: "")
        print(viewModelFilter?.storeItem ?? "")
       
        storeItem = viewModelFilter?.storeItem
        UserDefaults.standard.removeObject(forKey: "FILTER2")
        UserDefaults.standard.removeObject(forKey: "FILTER3")
        UserDefaults.standard.removeObject(forKey: "FILTER4")
        UserDefaults.standard.removeObject(forKey: "FILTER1")
        UserDefaults.standard.removeObject(forKey: "BADGE")
        strOrganizationName = ""
        strLanguage = ""
        strContentType = ""
        strSubject = ""
        tableFilter.reloadData()
        
    }
}

extension FilterOptionVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerHeading = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.width, height: 40))
        let imageView = UIImageView(frame: CGRect(x: self.view.frame.width - 30, y: 20, width: 20, height: 20))
        imageView.tintColor = UIColor(named: "CustomYellow")
        
        if (viewModelFilter?.items[section].collapsed == true){
            imageView.image = UIImage(named: "remove")
        }else{
            imageView.image = UIImage(named: "plus")
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped))
        tapGuesture.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tapGuesture)
        // headerView.backgroundColor = UIColor.red
        headerView.tag = section
        headerHeading.text = viewModelFilter?.items[section].name
        headerHeading.textColor = .black
        
        headerView.addSubview(headerHeading)
        headerView.addSubview(imageView)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModelFilter?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itms = viewModelFilter?.items[section]
        return !(itms?.collapsed ?? true) ? 0 : itms?.items.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: FilterCell.self), for: indexPath) as! FilterCell
//        do {
//                   if let data = UserDefaults.standard.data(forKey: "FILTER"),
//                       let filtervalue = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? StoreItemList {
////                    filtervalue.forEach({print( $0.subject, $0.content_type , $0.language , $0.organization_name)})  // Joe 10
//                    viewModelFilter?.storeItem = filtervalue
//                    print(viewModelFilter?.storeItem as Any)
//                   } else {
//                       print("There is an issue")
//                   }
//               } catch {
//                   print(error)
//               }
        cell.lblFilterOption.text = viewModelFilter?.items[indexPath.section].items[indexPath.row]
        if (indexPath.section == 0){
            let itms = viewModelFilter?.items[indexPath.section]
            if (strSubject == itms?.items[indexPath.row]){
                setindexSubject.insert(indexPath.row)
                setindexSubjectstr.insert(viewModelFilter?.items[0].items[indexPath.row] ?? "")
            }
            if (setindexSubject.contains(indexPath.row)) {
                cell.imgSelectOption.image = UIImage(named: "active_radio_btn")
            }else {
                cell.imgSelectOption.image = UIImage(named: "inactive_radio_btn")
            }
        }
        else if (indexPath.section == 1){
            let itms = viewModelFilter?.items[indexPath.section]
            if (strOrganizationName == itms?.items[indexPath.row]){
                setindexOrganization.insert(indexPath.row)
                setindexOrganizationStr.insert(viewModelFilter?.items[1].items[indexPath.row] ?? "")
            }
            if (setindexOrganization.contains(indexPath.row)) {
                cell.imgSelectOption.image = UIImage(named: "active_radio_btn")
            }else {
                cell.imgSelectOption.image = UIImage(named: "inactive_radio_btn")
            }
        }
        else if (indexPath.section == 2){
            let itms = viewModelFilter?.items[indexPath.section]
            if (strContentType == itms?.items[indexPath.row]){
                setindexContentType.insert(indexPath.row)
                setindexContentTypeStr.insert(viewModelFilter?.items[2].items[indexPath.row] ?? "")
            }
            if (setindexContentType.contains(indexPath.row)) {
                cell.imgSelectOption.image = UIImage(named: "active_radio_btn")
            }else {
                cell.imgSelectOption.image = UIImage(named: "inactive_radio_btn")
            }
        }else {
            let itms = viewModelFilter?.items[indexPath.section]
            if (strLanguage == itms?.items[indexPath.row]){
                setindexLanguage.insert(indexPath.row)
                setindexLanguagestr.insert(viewModelFilter?.items[3].items[indexPath.row] ?? "")
            }
            if (setindexLanguage.contains(indexPath.row)) {
                cell.imgSelectOption.image = UIImage(named: "active_radio_btn")
            }else {
                cell.imgSelectOption.image = UIImage(named: "inactive_radio_btn")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            storeItem?.subject = ""
            if (setindexSubject.count == 0){
                setindexSubject.insert(indexPath.row)
                setindexSubjectstr.insert(viewModelFilter?.items[0].items[indexPath.row] ?? "")
            }
            else if setindexSubject.count == 1 {
                
                // setindexOrganization.insert(indexPath.row)
                if setindexSubject.contains(indexPath.row) {
                    
                    setindexSubject.removeAll()
                    setindexSubjectstr.remove(viewModelFilter?.items[0].items[indexPath.row] ?? "")
                }else {
                    setindexSubject.removeAll()
                    setindexSubjectstr.removeAll()
                    setindexSubject.insert(indexPath.row)
                    setindexSubjectstr.insert(viewModelFilter?.items[0].items[indexPath.row] ?? "")
                 
                }
            }
            else {

            }
        }
       else if (indexPath.section == 1){
        storeItem?.organizationName = ""
            if (setindexOrganization.count == 0){
                setindexOrganization.insert(indexPath.row)
                setindexOrganizationStr.insert(viewModelFilter?.items[1].items[indexPath.row] ?? "")
            }
            else if setindexOrganization.count == 1 {
                
                // setindexOrganization.insert(indexPath.row)
                if setindexOrganization.contains(indexPath.row) {
                    
                    setindexOrganization.removeAll()
                    setindexOrganizationStr.remove(viewModelFilter?.items[1].items[indexPath.row] ?? "")
                }else {
                    setindexOrganization.removeAll()
                    setindexOrganizationStr.removeAll()
                    setindexOrganization.insert(indexPath.row)
                    setindexOrganizationStr.insert(viewModelFilter?.items[1].items[indexPath.row] ?? "")
                 
                }
            }
            else {

            }
        }else if (indexPath.section == 2){
            storeItem?.contentType = ""
            if (setindexContentType.count == 0){
                setindexContentType.insert(indexPath.row)
                setindexContentTypeStr.insert(viewModelFilter?.items[2].items[indexPath.row] ?? "")
            }else if (setindexContentType.count == 1){
                if setindexContentType.contains(indexPath.row) {
                    
                    setindexContentType.removeAll()
                    setindexContentTypeStr.remove(viewModelFilter?.items[2].items[indexPath.row] ?? "")
                }else {
                    setindexContentType.removeAll()
                    setindexContentTypeStr.removeAll()
                    setindexContentType.insert(indexPath.row)
                    setindexContentTypeStr.insert(viewModelFilter?.items[2].items[indexPath.row] ?? "")
                }
            }
        }else {
            storeItem?.language = ""
            if (setindexLanguage.count == 0){
                setindexLanguage.insert(indexPath.row)
                setindexLanguagestr.insert(viewModelFilter?.items[3].items[indexPath.row] ?? "")
            }else {
                if setindexLanguage.contains(indexPath.row) {
                    
                    setindexLanguage.removeAll()
                    setindexLanguagestr.remove(viewModelFilter?.items[3].items[indexPath.row] ?? "")
                }else {
                    setindexLanguage.removeAll()
                    setindexLanguagestr.removeAll()
                    setindexLanguage.insert(indexPath.row)
                    setindexLanguagestr.insert(viewModelFilter?.items[3].items[indexPath.row] ?? "")
                }
            }
        }
        tableFilter.reloadData()
    }
    @objc func headerViewTapped(tapped:UITapGestureRecognizer){
        print(tapped.view?.tag ?? 0)
        if viewModelFilter?.items[tapped.view!.tag].collapsed == true{
            viewModelFilter?.items[tapped.view!.tag].collapsed = false
        }else{
            viewModelFilter?.items[tapped.view!.tag].collapsed = true
        }
        if let imView = tapped.view?.subviews[1] as? UIImageView{
            if imView.isKind(of: UIImageView.self){
                if (viewModelFilter?.items[tapped.view!.tag].collapsed == true){
                    imView.image = UIImage(named: "collapsed")
                }else{
                    imView.image = UIImage(named: "expand")
                }
            }
        }
        tableFilter.reloadData()
    }
   
}
