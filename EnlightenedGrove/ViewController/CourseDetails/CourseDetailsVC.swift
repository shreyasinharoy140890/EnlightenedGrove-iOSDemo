//
//  CourseDetailsVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 28/04/21.
//

import UIKit
import Amplify
import AmplifyPlugins
import Kingfisher

class CourseDetailsVC: UIViewController , AlertDisplayer {
    
    
    @IBOutlet weak var viewCourse: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var unitCollectionView: UICollectionView!
    @IBOutlet weak var additionalCourseCollectionView: UICollectionView!
    @IBOutlet weak var txtSearchUnit: UITextField!
    @IBOutlet weak var imageCourse: UIImageView!
    @IBOutlet weak var textViewCourseDetails: UITextView!
    
    @IBOutlet weak var lblAdditionalcourse: UILabel!
    
    @IBOutlet weak var collHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var scrollViewCourseDetails: UIScrollView!
    
    @IBOutlet weak var lblNoUnitFounds: UILabel!
    
    @IBOutlet weak var imageArrow: UIImageView!
    
    
    var courseId:String?
    var viewmodelCourseDetails:CourseDetailsViewModel?
    var imageUrl:String?
    var courseDetails:String?
    var organizationName:String?
    var searchItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lang = UserDefaults.standard.value(forKey: "LANG") {
            if lang as? String == "ENG" {
                Bundle.setLanguage("en")
            }else if lang as? String == "ES" {
                Bundle.setLanguage("es")
            }else {
                Bundle.setLanguage("fr")
            }
            
        }
        viewmodelCourseDetails = CourseDetailsViewModel()
        unitCollectionView.delegate = self
        unitCollectionView.dataSource = self
        unitCollectionView.register(UnitCollectionViewCell.self)
        
        additionalCourseCollectionView.delegate = self
        additionalCourseCollectionView.dataSource = self
        additionalCourseCollectionView.register(AdditionalCourseCollectionCell.self)
        
        viewHeader.addShadow(offset: CGSize.init(width: -1, height: 2), color: UIColor.gray, radius: 2.0, opacity: 0.5)
        viewSearch.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        viewCourse.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        txtSearchUnit.delegate = self
        txtSearchUnit.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
                guard let courseid = courseId else {
                    self.showAlertWith(message: "Something went wrong, Please try again")
                    return
                }
        callapi(strcourseId: courseid)
        SetUPData(imageUrl:imageUrl ?? "",courseDetails:courseDetails ?? "")
        lblAdditionalcourse.text = "Additional Course".localized()
        txtSearchUnit.placeholder = "Search here".localized()
       // callAdditionalCourse()
        
      //  heightCollection.constant = cell.searchCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        // Do any additional setup after loading the view.
    }
    
    func SetUPData(imageUrl:String,courseDetails:String){
//        imageCourse.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
//        imageCourse.contentMode = .scaleAspectFit // OR .scaleAspectFill
//        imageCourse.clipsToBounds = true
        let imgurl = (imageUrl ).components(separatedBy: "?")
        _ = URL(string: imgurl[0])

        imageCourse.downloaded(from: imgurl[0])

        let desc = courseDetails.components(separatedBy: "\n")
        lblTitle.text = desc[0]
        textViewCourseDetails.text = desc[1]
    }
    
    @IBAction func btnBack(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
        let previousViewController = self.navigationController?.viewControllers.last as? HomeVC
        
       // previousViewController?.isFromFilter = false
    }
    
    
    @IBAction func btnSearch(_ sender: Any) {
        
        
        if (searchItem != ""){
            
            viewmodelCourseDetails?.searchUnitString = searchItem
            viewmodelCourseDetails?.getSearchUnit(completion: { (result) in
                switch result {
                case .success(let result):
                    if let success = result as? Bool , success == true {
                        DispatchQueue.main.async {
                            self.lblNoUnitFounds.text = ""
                            self.unitCollectionView.isHidden = false
                           
                        }
                        
                    }
                case .failure( _):
                    DispatchQueue.main.async {
                        
                        self.lblNoUnitFounds.text = "No unit(s) available".localized()
                        self.unitCollectionView.isHidden = true
                    }
                    
                }
            })
            
        }else {
            self.lblNoUnitFounds.text = ""
            self.unitCollectionView.isHidden = false
            self.viewmodelCourseDetails?.arrayUnit = viewmodelCourseDetails?.arrayStoreUnit ?? []
            
        }
         self.unitCollectionView.reloadData()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CourseDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionView.tag == 0 ? viewmodelCourseDetails?.arrayUnit.count ?? 0 : viewmodelCourseDetails?.arrayAdditionalCourse.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0){
            
            return CGSize(width: (unitCollectionView.frame.width - 5)/3.3, height: (55))
        }else {
            return CGSize(width: (additionalCourseCollectionView.frame.width - 10)/1.7, height: (250))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UnitCollectionViewCell.self), for: indexPath) as! UnitCollectionViewCell
            
            cell.lblUnitName.text =  viewmodelCourseDetails?.arrayUnit[indexPath.row].title ?? ""
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdditionalCourseCollectionCell.self), for: indexPath) as! AdditionalCourseCollectionCell
            cell.lblCourseName.text = viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].title ?? ""
            let imgurl = (viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].content_url ?? "").components(separatedBy: "?")
            _ = URL(string: imgurl[0])
            
            if let imagUrl = URL(string: imgurl[0]){
                KingfisherManager.shared.retrieveImage(with: imagUrl, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    
                    cell.imageAdditionalCourse.image = image
                    
                })
            }
           
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0){
        let imgurl = (viewmodelCourseDetails?.arrayUnit[indexPath.row].content_url ?? "").components(separatedBy: "?")
        let webvc = UnitWebVC(nibName: "UnitWebVC", bundle: nil)
        webvc.urlstr =  imgurl[0]
        webvc.contentType = viewmodelCourseDetails?.arrayUnit[indexPath.row].content_type ?? ""
        self.navigationController?.pushViewController(webvc, animated: true)
        }else {
            SetUPData(imageUrl:viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].content_url ?? "",courseDetails:"\(viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].title ?? "") \n\(viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].subject ?? "")")
            callapi(strcourseId: viewmodelCourseDetails?.arrayAdditionalCourse[indexPath.row].id ?? "")
        }
    }
}

extension CourseDetailsVC{
    func callapi (strcourseId:String) {
        
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }

        viewmodelCourseDetails?.callUnitapi(courseId: strcourseId, completion: {(result) in
            DispatchQueue.main.async { [self] in
                switch result{
                case .success(let result):
                    //            DispatchQueue.main.async {
                    
                    hideActivityIndicator(viewController: self)
                    if let success = result as? Bool , success == true {
                        if (viewmodelCourseDetails?.arrayUnit.count ?? 0 > 0){
                        self.unitCollectionView.reloadData()
                        self.unitCollectionView.layoutIfNeeded()
//                        self.heightOfScrollView.constant = (1100 + (self.unitCollectionView.collectionViewLayout.collectionViewContentSize.height + CGFloat(55*(self.viewmodelCourseDetails?.arrayStoreUnit.count)!)))
                        self.collHeightConstant.constant = (self.unitCollectionView.collectionViewLayout.collectionViewContentSize.height )
                           // + CGFloat(55*(self.viewmodelCourseDetails?.arrayStoreUnit.count)!))
                            print(self.collHeightConstant.constant)
                        self.heightOfScrollView.constant = (700 + collHeightConstant.constant)
                        print(self.heightOfScrollView.constant)
                            lblNoUnitFounds.text = ""
                            self.unitCollectionView.isHidden = false
                        }else {
                            lblNoUnitFounds.text = "No unit(s) available".localized()
                            self.unitCollectionView.isHidden = true
                        }
                        callAdditionalCourse(strCourseId: strcourseId)
                        
                    }else {
                        self.showAlertWith(message: "Something went wrong.Please try again later")
                    }
                // }
                case .failure(let error):
                    hideActivityIndicator(viewController: self)
                    self.showAlertWith(message: error.localizedDescription)
                }
            }
        })
        
        
        
    }
    
    func callAdditionalCourse(strCourseId:String){
        guard let organizationName = organizationName else {
            self.showAlertWith(message: "Something went wrong, Please try again")
            return
        }
        DispatchQueue.main.async {
            showActivityIndicator(viewController: self)
        }
       
        viewmodelCourseDetails?.callAdditionalCourse(organizationName: organizationName,id:strCourseId , completion: {(result) in
            DispatchQueue.main.async { [self] in
            switch result {
            case .success(let result):
                //            DispatchQueue.main.async {
                
                hideActivityIndicator(viewController: self)
                if let success = result as? Bool , success == true {
                    if (viewmodelCourseDetails?.arrayAdditionalCourse.count ?? 0 > 0){
                    self.additionalCourseCollectionView.reloadData()
                    scrollViewCourseDetails.scrollToTop()
                        self.lblAdditionalcourse.isHidden = false
                        self.imageArrow.isHidden = true
                    }else {
                        self.lblAdditionalcourse.isHidden = true
                        self.imageArrow.isHidden = true
                    }
                
                }else {
                    self.showAlertWith(message: "Something went wrong.Please try again later")
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

extension CourseDetailsVC:UITextFieldDelegate{
    @objc func textFieldValueChange(_ txt: UITextField)  {
        searchItem = txt.text!
        print(searchItem)
        if (searchItem == ""){
            self.lblNoUnitFounds.text = ""
            self.unitCollectionView.isHidden = false
            self.viewmodelCourseDetails?.arrayUnit = viewmodelCourseDetails?.arrayStoreUnit ?? []
            
//            viewmodelCourseDetails?.searchUnitString = txt.text!
//            viewmodelCourseDetails?.getSearchUnit(completion: { (result) in
//                switch result {
//                case .success(let result):
//                    if let success = result as? Bool , success == true {
//                        DispatchQueue.main.async {
//                            self.lblNoUnitFounds.text = ""
//                            self.unitCollectionView.isHidden = false
//
//                        }
//
//                    }
//                case .failure( _):
//                    DispatchQueue.main.async {
//
//                        self.lblNoUnitFounds.text = "No unit(s) available".localized()
//                        self.unitCollectionView.isHidden = true
//                    }
//
//                }
//            })
            
        }
//        else {
//            self.lblNoUnitFounds.text = ""
//            self.unitCollectionView.isHidden = false
//            self.viewmodelCourseDetails?.arrayUnit = viewmodelCourseDetails?.arrayStoreUnit ?? []
//
//        }
         self.unitCollectionView.reloadData()
    }
    
}

