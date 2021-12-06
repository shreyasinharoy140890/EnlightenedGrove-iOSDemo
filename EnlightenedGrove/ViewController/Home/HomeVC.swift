//
//  HomeVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 23/04/21.
//

import UIKit
import Kingfisher
import DropDown
import StoreKit

class HomeVC: UIViewController,AlertDisplayer {
    
    @IBOutlet weak var collectionViewCourse: UICollectionView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var shadowSearchView: UIView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var textSearchHere: UITextField!
    @IBOutlet weak var lblFilter: UILabel!
    
    @IBOutlet weak var lblNodata: UILabel!
    @IBOutlet weak var viewBadge: UIView!
    @IBOutlet weak var lblBadge: UILabel!
    @IBOutlet weak var imageSearch: UIImageView!
    
    @IBOutlet weak var btnDonate: UIButton!
    @IBOutlet weak var tableHome: UITableView!
    
    var searchItem = ""
    
    var viewModelHome:HomeViewModel?
    var isFromFilter:Bool? = false
    
    var arrCouseDetails = [["ENVIRONMENT","box1"],["SCIENCE & TECHNOLOGY","box2"],["POLITY","box3"],["PHYSICAL GEOGRAPHY","box4"],["MODERN HISTORY","box5"],["COMPUTER SCIENCE","box6"]]
    let LiveHeaderId = "LiveHeaderId"
    var searchDataSourceArray = [String]()
    var dataSourceArray = [String]()
    let dropDown = DropDown()
    var strOrganizationName:String = ""
    var strLanguage:String = ""
    var strContentType:String = ""
    var strSubject:String = ""
    var isSearchClick = true
    var productsArray: Array<SKProduct?> = []
    var productid = ""
    
    func setupUI(){
        
        viewHeader.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        viewFilter.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        shadowSearchView.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        btnDonate.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        btnDonate.layer.cornerRadius = 15
        viewBadge.layer.cornerRadius = viewBadge.frame.size.height / 2
        viewBadge.isHidden = true
        lblBadge.text = ""
        lblNodata.text = ""
        dropDown.anchorView = self.textSearchHere
       // dropDown.anchorView = self.viewSearch
      //  searchdataHotelArray = dataHotelArray
        dataSourceArray  = viewModelHome?.titleArray ?? []
            //searchdataHotelArray.map {$0.name!}
        searchDataSourceArray = dataSourceArray
        dropDown.dataSource = searchDataSourceArray
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: self.textSearchHere.frame.origin.x, y:(dropDown.anchorView?.plainView.bounds.height)!-4)
        dropDown.width = self.textSearchHere.frame.size.width
     
        // Action triggered on selection
        dropDown.selectionAction = { [ self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.textSearchHere.text = item
//            let hotel  = self.searchdataHotelArray[index]
//            self.searchModel.hotelId = hotel.id_hotel
//            self.searchModel.locationId = hotel.id
            self.dropDown.hide()
        }
        
        
        SKPaymentQueue.default().add(self)

          //Check if product is purchased
        if (UserDefaults.standard.bool(forKey: "purchased")){

              // Hide ads
             // adView.hidden = true

          } else {
              //print("Should show ads...")

          }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.delegate = self
        setupUI()
        SidePanelViewController.default.delegate = self
        viewModelHome = HomeViewModel()
        callContentList()
        collectionViewCourse?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LiveHeaderId)
        txtSearch.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        collectionViewCourse?.register(HomeHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LiveHeaderId)
        tableHome.delegate = self
        tableHome.dataSource = self
        tableHome.register(HomeCourseTableViewCell.self)
        
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = UserDefaults.standard.value(forKey: "ID") {
            SidePanelViewController.default.isloggedin = true
            SidePanelViewController.default.selectedIndex = 0
        }else {
            SidePanelViewController.default.isloggedin = false
            SidePanelViewController.default.selectedIndex = 0
        }
        languageSet()
        print(viewModelHome?.storeItem as Any)
        print(viewModelHome?.valueArray.count ?? 0)
            if (isFromFilter == true){
                callFilterList()

            }
            else {
                UserDefaults.standard.removeObject(forKey: "FILTER2")
                UserDefaults.standard.removeObject(forKey: "FILTER3")
                UserDefaults.standard.removeObject(forKey: "FILTER4")
                UserDefaults.standard.removeObject(forKey: "FILTER1")
                UserDefaults.standard.removeObject(forKey: "BADGE")
                viewBadge.isHidden = true
                imageSearch.image = UIImage(named: "search_icon")
            self.viewModelHome?.valueArray = viewModelHome?.dataService ?? []
                self.viewModelHome?.sortedarray = self.viewModelHome?.dataStoreOrganizationWise ?? []
        }
        collectionViewCourse.reloadData()
        tableHome.reloadData()
        searchItem = ""
        textSearchHere.text = ""
    }
    
    func languageSet () {
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        lblFilter.text = "Filter".localized()
        btnDonate.setTitle("Donate".localized(), for: .normal)
        textSearchHere.placeholder = "Search here".localized()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func callContentList(){
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
            self.view.isUserInteractionEnabled = false
        }
        viewModelHome?.callOrganizationName(completion: {(result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let result):
                    //            DispatchQueue.main.async {
                    
                    hideActivityIndicator(viewController: self)
                    self.view.isUserInteractionEnabled = true
                    if let success = result as? Bool , success == true {
                        self.imageSearch.image = UIImage(named: "search_icon")
                        self.collectionViewCourse.reloadData()
                        self.tableHome.reloadData()
                    }else {
                        self.showAlertWith(message: "Some thing went wrong. Please try again later".localized())
                    }
                // }
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.view.isUserInteractionEnabled = true
                    self.showAlertWith(message: error.localizedDescription)
                }
            }
        })
    }
    
    @IBAction func btnMenu(_ sender: UIButton) {
        
        if sender.isSelected {
            SidePanelViewController.default.hide()
            sender.isSelected = false
        }
        else {
            SidePanelViewController.default.show(on: self)
            SidePanelViewController.default.selectedIndex = 0
            sender.isSelected = true
            if let _ = UserDefaults.standard.value(forKey: "ID") {
                SidePanelViewController.default.isloggedin = true
            }else {
                SidePanelViewController.default.isloggedin = false
            }
            
        }
    }
    
    @IBAction func btnFilter(_ sender: Any) {
        if let FilterVC = UIApplication.getTopMostViewController()?.navigationController?.ifExitsOnStack(vc: FilterOptionVC.self) {
            UIApplication.getTopMostViewController()?.navigationController?.popToViewController(FilterVC, animated: true)
            let FilterVC = FilterOptionVC(nibName: "FilterOptionVC", bundle: nil)
            FilterVC.viewModelFilter?.storeItem = self.viewModelHome?.storeItem ?? StoreItemList(subject: self.viewModelHome?.storeItem?.subject ?? "", organizationName: self.viewModelHome?.storeItem?.organizationName ?? "", contentType: self.viewModelHome?.storeItem?.contentType ?? "", language: self.viewModelHome?.storeItem?.language ?? "")
            FilterVC.viewModelFilter?.valueArray = self.viewModelHome?.valueArray ?? []
            FilterVC.valueArray = self.viewModelHome?.valueArray ?? []
            FilterVC.storeItem = self.viewModelHome?.storeItem ?? StoreItemList(subject: self.viewModelHome?.storeItem?.subject ?? "", organizationName: self.viewModelHome?.storeItem?.organizationName ?? "", contentType: self.viewModelHome?.storeItem?.contentType ?? "", language: self.viewModelHome?.storeItem?.language ?? "")
        }
        else {

            let FilterVC = FilterOptionVC(nibName: "FilterOptionVC", bundle: nil)
           // print(self.viewModelHome?.storeItem as Any)
           // FilterVC.viewModelFilter?.storeItem = StoreItemList()
//            FilterVC.viewModelFilter?.storeItem = self.viewModelHome?.storeItem ?? StoreItemList(subject: self.viewModelHome?.storeItem?.subject ?? "", organizationName: self.viewModelHome?.storeItem?.organizationName ?? "", contentType: self.viewModelHome?.storeItem?.contentType ?? "", language: self.viewModelHome?.storeItem?.language ?? "")
//            FilterVC.viewModelFilter?.valueArray = self.viewModelHome?.valueArray ?? []
//            FilterVC.valueArray = self.viewModelHome?.valueArray ?? []
//            FilterVC.storeItem = self.viewModelHome?.storeItem ?? StoreItemList(subject: self.viewModelHome?.storeItem?.subject ?? "", organizationName: self.viewModelHome?.storeItem?.organizationName ?? "", contentType: self.viewModelHome?.storeItem?.contentType ?? "", language: self.viewModelHome?.storeItem?.language ?? "")
            
            self.navigationController?.pushViewController(FilterVC, animated: true)
         }

    }
    
    @IBAction func btnDonate(_ sender: Any) {
//        let webvc = DonateWebView(nibName: "DonateWebView", bundle: nil)
//        self.navigationController?.pushViewController(webvc, animated: true)
        guard let url = URL(string: "https://comdevnet.org/donate/") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func btnSearch(_ sender: Any) {
        if (textSearchHere.text == ""){
            showAlertWith(message: "Search field can not blank".localized())
            
        }else {
        if(isSearchClick == true) {
            imageSearch.image = UIImage(named: "close_icon")
            viewBadge.isHidden = true
            
            getSearchCourse()
        }else {
            imageSearch.image = UIImage(named: "search_icon")
            textSearchHere.text = ""
            viewBadge.isHidden = true
            callContentList()
            
            
        }
        isFromFilter = false
        isSearchClick = !isSearchClick
        UserDefaults.standard.removeObject(forKey: "FILTER2")
        UserDefaults.standard.removeObject(forKey: "FILTER3")
        UserDefaults.standard.removeObject(forKey: "FILTER4")
        UserDefaults.standard.removeObject(forKey: "FILTER1")
        UserDefaults.standard.removeObject(forKey: "BADGE")
        }
        
       
        
//        if (isFromFilter == true){
//            getSearchCourse()
//           // getSearchCourseOnFilter()
//           // collectionViewCourse.reloadData()
//        }else {
//            getSearchCourse()
//        }
    }
    
    
}

extension HomeVC:SidePanelDelegate {
    func showLanguagePopUP(status: Bool) {
        if status == true {
            let VC = LanguageVC(nibName: "LanguageVC", bundle: nil)
            VC.modalPresentationStyle = .overCurrentContext
            VC.delegate = self
            self.navigationController?.present(VC, animated: true, completion: nil)
        }
    }
    
    
    func didDisplayMenu(status: Bool) {
        if status == false {
            btnMenu.isSelected = false
        }
    }
    
    
    
    
}

extension HomeVC:LanguageSelectProtocol {
    func setLanguageHome() {
        languageSet()
    }
    
    
}

//extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
////        if let sortedKeys = viewModelHome?.organizationName.sorted( by: { $0.0 ?? "" < $1.0 ?? "" }){
////        print(sortedKeys)
////        //organizeName = s
////            return sortedKeys.count
////        }else {
////            return 0
////        }
//       return viewModelHome?.sortedarray.count ?? 0
//    }
//
//
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let liveHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LiveHeaderId, for: indexPath) as! HomeHeaderCollectionReusableView
//
//        if let favArray = viewModelHome?.organizationName.compactMap(\.key) {
//        print(favArray as Any)
//            liveHeader.titleLabel.text = "  \(viewModelHome?.sortedarray[indexPath.section].key ?? "")"
//                //"   \(favArray[indexPath.section])"
//        }
//        return liveHeader
//    }
//
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
////
////        return CGSize(width: self.collectionViewCourse.bounds.width, height: liveHeader.titleLabel.bounds.height)
////    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: self.collectionViewCourse.frame.width, height: 50)
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.viewModelHome?.valueArray[section].count ?? 0
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (collectionViewCourse.frame.width - 10)/2, height: (collectionViewCourse.frame.width )/2)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CourseCollectionCell.self), for: indexPath) as! CourseCollectionCell
//        let imgurl = (viewModelHome?.valueArray[indexPath.section][indexPath.row].content_url ?? "").components(separatedBy: "?")
//        _ = URL(string: imgurl[0])
//
//        if let imagUrl = URL(string: imgurl[0]){
//            KingfisherManager.shared.retrieveImage(with: imagUrl, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
//                cell.imageCourse.image = image
//
//            })
//        }
//        let bookName = (viewModelHome?.valueArray[indexPath.section][indexPath.row].title ?? "").components(separatedBy: "(")
//        cell.lblCourseName.text = bookName[0]
//            //"\(viewModelHome?.valueArray[indexPath.section][indexPath.row].title ?? "")"
//        return cell
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(viewModelHome?.valueArray[indexPath.section][indexPath.row] as Any)
//        let coursedetailsVC = CourseDetailsVC(nibName: "CourseDetailsVC", bundle: nil)
//        coursedetailsVC.courseId = viewModelHome?.valueArray[indexPath.section][indexPath.row].id ?? ""
//        coursedetailsVC.imageUrl = viewModelHome?.valueArray[indexPath.section][indexPath.row].content_url ?? ""
//        coursedetailsVC.courseDetails = "\(viewModelHome?.valueArray[indexPath.section][indexPath.row].title ?? "") \n\(viewModelHome?.valueArray[indexPath.section][indexPath.row].description ?? "")"
//        coursedetailsVC.organizationName = viewModelHome?.valueArray[indexPath.section][indexPath.row].organization_name ?? ""
//        self.navigationController?.pushViewController(coursedetailsVC, animated: true)
//    }
//}

extension HomeVC:UITextFieldDelegate{
    @objc func textFieldValueChange(_ txt: UITextField){
        searchItem = txt.text!
        if (searchItem == ""){
            self.lblNodata.text = ""
            self.collectionViewCourse.isHidden = false
            self.tableHome.isHidden = false
            self.dropDown.hide()

            callContentList()

        }else {

        }
        
//        if (searchItem != ""){
//
//            viewModelHome?.searchLocString = searchItem
//            viewModelHome?.getSearchLocation(completion: { (result) in
//                switch result {
//                case .success(let result):
//                    if let success = result as? Bool , success == true {
//                        DispatchQueue.main.async {
//                            self.viewModelHome?.valueArray.forEach() { card in
//                                if (card.count > 0) {
//                                self.lblNodata.text = ""
//                                self.collectionViewCourse.isHidden = false
//                                }
//                                else {
//                                    self.collectionViewCourse.isHidden = true
//                                    self.lblNodata.text = "No course matched according to your search".localized()
//                                }
//                            }
//
//                          //  }
//                        }
//
//                    }
//                case .failure( _):
//                    DispatchQueue.main.async {
//                        self.collectionViewCourse.isHidden = true
//                        self.lblNodata.text = "No course matched according to your search".localized()
//                    }
//               }
//            })
//
//        }else {
//            self.lblNodata.text = ""
//            self.collectionViewCourse.isHidden = false
//            self.viewModelHome?.valueArray = viewModelHome?.dataService ?? []
//        }
//        self.collectionViewCourse.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
    
            print(searchDataSourceArray)
        searchItem = textField.text!
        let filteredArray = viewModelHome?.titleArray.filter { (modelObject) -> Bool in
            return modelObject.range(of: searchItem, options: String.CompareOptions.caseInsensitive) != nil
        }
          
        print(filteredArray?.count as Any)
        searchDataSourceArray = filteredArray ?? []
            //viewModelHome?.titleArray ?? []
            if searchDataSourceArray.count > 0 {
                self.dropDown.dataSource = searchDataSourceArray
                //                self.dropDown.reloadInputViews()
                //                self.dropDown.reloadAllComponents()
                self.dropDown.show()
            }else{
                self.dropDown.hide()
               // else {
                    self.lblNodata.text = ""
                    self.collectionViewCourse.isHidden = false
                self.tableHome.isHidden = false
                self.collectionViewCourse.reloadData()
                self.tableHome.reloadData()
            
               // }
            }
        
        return true
    }
    
    
    
    
    func getSearchCourse (){
        self.view.endEditing(true)
       if (searchItem != ""){
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
            self.view.isUserInteractionEnabled = false
        }
        viewModelHome?.searchLocString = self.textSearchHere.text!
            viewModelHome?.getSearchResult(completion: { (result) in
                switch result {
                case .success(let result):
                    if let success = result as? Bool , success == true {
                        DispatchQueue.main.async {
                            hideActivityIndicator(viewController: self)
                            self.view.isUserInteractionEnabled = true
                            if (self.viewModelHome?.valueArray.count ?? 0 > 0){
                                self.lblNodata.text = ""
                                self.collectionViewCourse.isHidden = false
                                self.tableHome.isHidden = false
                                self.collectionViewCourse.reloadData()
                                self.tableHome.reloadData()
                            }else {
                                self.collectionViewCourse.isHidden = true
                                self.tableHome.isHidden = true
                                self.lblNodata.text = "No course matched according to your search".localized()
                            }
                          
                        }
                       
                    }
                case .failure( _):
                    DispatchQueue.main.async {
                        hideActivityIndicator(viewController: self)
                        self.view.isUserInteractionEnabled = true
                        self.collectionViewCourse.isHidden = true
                        self.tableHome.isHidden = true
                        self.lblNodata.text = "No course matched according to your search".localized()
                    }
               }
            })
            
        }else {
            self.lblNodata.text = ""
            self.collectionViewCourse.isHidden = false
            self.tableHome.isHidden = false
            self.viewModelHome?.valueArray = viewModelHome?.dataService ?? []
        }
        self.collectionViewCourse.reloadData()
        self.tableHome.reloadData()
    }
    
    func getSearchCourseOnFilter (){
        if (searchItem != ""){
            
            viewModelHome?.searchLocString = searchItem
            viewModelHome?.getSearchFilterContent(completion: { (result) in
                switch result {
                case .success(let result):
                    if let success = result as? Bool , success == true {
                        DispatchQueue.main.async {
                            var arrcontent = [Contents]()
                            self.viewModelHome?.valueArray.forEach() { card in
                                print(card.isEmpty)
                                if (!card.isEmpty) {
                                    arrcontent = card

                                }

                            }
                            if (arrcontent.count > 0){
                                self.lblNodata.text = ""
                                self.collectionViewCourse.isHidden = false
                                self.tableHome.isHidden = false
                            }else {
                                self.collectionViewCourse.isHidden = true
                                self.tableHome.isHidden = true
                                self.lblNodata.text = "No course matched according to your search".localized()
                            }
                           
                        }
                       
                    }
                case .failure( _):
                    DispatchQueue.main.async {
                        self.collectionViewCourse.isHidden = true
                        self.tableHome.isHidden = true
                       // self.tableHome.isHidden = true
                        self.lblNodata.text = "No course matched according to your search".localized()
                    }
               }
            })
            
        }else {
            self.lblNodata.text = ""
            self.collectionViewCourse.isHidden = false
            self.tableHome.isHidden = false
            self.viewModelHome?.valueArray = viewModelHome?.arrayOfSearchContent ?? []
        }
        self.collectionViewCourse.reloadData()
        self.tableHome.reloadData()
    }
}
// MARK:- Filter Related Api
extension HomeVC {
    func callFilterList(){

        print("\(strOrganizationName) \(strContentType) \(strLanguage) \(strSubject)")
//        if (strOrganizationName != "" && strContentType != "" && strLanguage != "" && strSubject != ""){
//            viewBadge.isHidden = false
//            lblBadge.text = "4"
//        }
        if let count = UserDefaults.standard.value(forKey: "BADGE") {
            viewBadge.isHidden = false
            lblBadge.text = "\(count)"
        }
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
        viewModelHome?.callFilteredContentList(organizationName: strOrganizationName, contentType: strContentType, language: strLanguage,subject:strSubject, completion: {(result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let result):
                    //            DispatchQueue.main.async {
                    
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        if (self.viewModelHome?.valueArray.count ?? 0 > 0){
                        self.collectionViewCourse.reloadData()
                        self.tableHome.reloadData()
                        }else {
                            self.showAlertWith(message: "No data found".localized())
                            self.collectionViewCourse.reloadData()
                            self.tableHome.reloadData()
                        }
                        
//                        _ = self.navigationController?.popViewController(animated: true)
//                        let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
//                        previousViewController?.viewModelHome?.organizationName = self.viewModelFilter?.organizationName ?? [:]
//                        previousViewController?.viewModelHome?.valueArray = self.viewModelFilter?.valueArray ?? []
//                        previousViewController?.viewModelHome?.arrayOfSearchContent = self.viewModelFilter?.valueArray ?? []
//                        print(previousViewController?.viewModelHome?.valueArray as Any)
//                        previousViewController?.isFromFilter = true
//                        previousViewController?.viewModelHome?.storeItem = self.viewModelFilter?.storeItem ?? StoreItemList(subject: "", organizationName: "", contentType: "", language: "")
                        
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
}

extension HomeVC :UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerHeading = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.width, height: 40))
       // let imageView = UIImageView(frame: CGRect(x: self.view.frame.width - 30, y: 20, width: 20, height: 20))
       // imageView.tintColor = UIColor(named: "CustomYellow")
        
//        if (viewModelFilter?.items[section].collapsed == true){
//            imageView.image = UIImage(named: "remove")
//        }else{
//            imageView.image = UIImage(named: "plus")
//        }
        let headerView = UIView(frame: CGRect(x: 10, y: 0, width: self.view.frame.width - 10, height: 60))
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 5
        headerView.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
      //  let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped))
      //  tapGuesture.numberOfTapsRequired = 1
      //  headerView.addGestureRecognizer(tapGuesture)
        // headerView.backgroundColor = UIColor.red
        headerView.tag = section
        headerHeading.font = UIFont(name: "system", size: 10)
        headerHeading.numberOfLines = 0
        headerHeading.text = "\(viewModelHome?.sortedarray[section].key ?? "")"
        headerHeading.textColor = .black
       
        
        headerView.addSubview(headerHeading)
       // headerView.addSubview(imageView)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModelHome?.sortedarray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: HomeCourseTableViewCell.self), for: indexPath) as! HomeCourseTableViewCell
        cell.sections = indexPath.section
        cell.collectionViewCourse.reloadData()
        cell.valueArray = viewModelHome?.valueArray[indexPath.section] ?? []
        cell.delegateHome = self
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
}
extension HomeVC : CourseSelectDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        <#code#>
//    }
    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        <#code#>
//    }
    
    func selectCourse(index: Int, section: Int) {
        
        if (viewModelHome?.valueArray[section][index].premium == true){
            if let _ = UserDefaults.standard.value(forKey: "ID") {
                self.productid = viewModelHome?.valueArray[section][index].id ?? ""
            let refreshAlert = UIAlertController(title: "OC4D", message: "Do you want to purchase this course?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                 // print("Handle Ok logic here")
//                let price = 0.6
//                PKIAPHandler.shared.purchase(product: price)) { (alert, product, transaction) in
//                   if let tran = transaction, let prod = product {
//                     //use transaction details and purchased product as you want
//                   }
//                   Globals.shared.showWarnigMessage(alert.message)
//                   }
//                if (SKPaymentQueue.canMakePayments())
//                           {
//                    let productID:NSSet = NSSet(object: self.productid);
//                               let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
//                               productsRequest.delegate = self;
//                               productsRequest.start();
//                               print("Fetching Products");
//                           }else{
//                               print("Can't make purchases");
//                           }
                let myCartVC = SubsCriptionVC(nibName: "SubsCriptionVC", bundle: nil)
                UIApplication.getTopMostViewController()?.navigationController?.pushViewController(myCartVC, animated: true)
                
                
            }))

            refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle Cancel Logic here")
            }))

            present(refreshAlert, animated: true, completion: nil)
            }else {
                let alertOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    
                    let loginVc = LogInVC(nibName: "LogInVC", bundle: nil)
                    self.navigationController?.pushViewController(loginVc, animated: true)
                }
                self.showAlertWith(message: "You need to login to purchase".localized(), type: .custom(actions: [alertOkAction]))
           }
        }else {
        let coursedetailsVC = CourseDetailsVC(nibName: "CourseDetailsVC", bundle: nil)
        coursedetailsVC.courseId = viewModelHome?.valueArray[section][index].id ?? ""
        coursedetailsVC.imageUrl = viewModelHome?.valueArray[section][index].content_url ?? ""
        coursedetailsVC.courseDetails = "\(viewModelHome?.valueArray[section][index].title ?? "") \n\(viewModelHome?.valueArray[section][index].description ?? "")"
        coursedetailsVC.organizationName = viewModelHome?.valueArray[section][index].organization_name ?? ""
        self.navigationController?.pushViewController(coursedetailsVC, animated: true)
        }
    }
    
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        let count : Int = response.products.count
        if (count>0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productid) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(product: validProduct)
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            print("nothing")
        }
    }


    private func request(request: SKRequest!, didFailWithError error: NSError!) {
        print("Error Fetching product information");
    }
    
    
    func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);

     }

        func paymentQueue(_ queue: SKPaymentQueue,
    updatedTransactions transactions: [SKPaymentTransaction])

    {
        print("Received Payment Transaction Response from Apple");

        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    // Handle the purchase
                    UserDefaults.standard.set(true , forKey: "purchased")
                   // adView.hidden = true
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;



                case .restored:
                    print("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()


                     // Handle the purchase
                    UserDefaults.standard.set(true , forKey: "purchased")
                       // adView.hidden = true
                        break;
                default:
                    break;
                }
            }
        }

    }
    
    
    func restore(){
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    
}






