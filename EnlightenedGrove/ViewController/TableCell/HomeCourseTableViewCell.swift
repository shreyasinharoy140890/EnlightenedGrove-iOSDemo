//
//  HomeCourseTableViewCell.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 07/10/21.
//

import UIKit
import Kingfisher

protocol CourseSelectDelegate: class {
    func selectCourse(index:Int,section:Int)
}

class HomeCourseTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionViewCourse: UICollectionView!
    var viewModelHome = HomeViewModel()
    var sections:Int = 0
    var valueArray:[Contents] = [Contents]()
    weak var delegateHome:CourseSelectDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewCourse.dataSource = self
        collectionViewCourse.delegate = self
        collectionViewCourse.register(CourseCollectionCell.self)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeCourseTableViewCell: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//       return self.valueArray.count
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.valueArray.count
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       // print((collectionViewCourse.frame.width - 10)/2.6)
        return CGSize(width: (collectionViewCourse.frame.width - 10)/2.6, height:185) //(collectionViewCourse.frame.width )/1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CourseCollectionCell.self), for: indexPath) as! CourseCollectionCell
        let imgurl = (valueArray[indexPath.row].content_url ?? "").components(separatedBy: "?")
        _ = URL(string: imgurl[0])

        if let imagUrl = URL(string: imgurl[0]){
            KingfisherManager.shared.retrieveImage(with: imagUrl, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                cell.imageCourse.image = image

            })
        }
        let bookName = (valueArray[indexPath.row].title ?? "").components(separatedBy: "(")
        cell.lblCourseName.text = bookName[0]
            "\(valueArray[indexPath.row].title ?? "")"
        if (valueArray[indexPath.row].premium  == true){
            cell.imgPremium.isHidden = false
            cell.widthOfImgPremium.constant = 30.0
            cell.heightOfLblPremium.constant = 15.0
            cell.lblpremium.text = "Premium"

        }else {
            cell.imgPremium.isHidden = true
            cell.lblpremium.text = ""
            cell.heightOfLblPremium.constant = 0.0
            cell.widthOfImgPremium.constant = 0.0
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegateHome?.selectCourse(index: indexPath.row, section: sections)
//        print(viewModelHome?.valueArray[indexPath.section][indexPath.row] as Any)
//        let coursedetailsVC = CourseDetailsVC(nibName: "CourseDetailsVC", bundle: nil)
//        coursedetailsVC.courseId = viewModelHome?.valueArray[indexPath.section][indexPath.row].id ?? ""
//        coursedetailsVC.imageUrl = viewModelHome?.valueArray[indexPath.section][indexPath.row].content_url ?? ""
//        coursedetailsVC.courseDetails = "\(viewModelHome?.valueArray[indexPath.section][indexPath.row].title ?? "") \n\(viewModelHome?.valueArray[indexPath.section][indexPath.row].description ?? "")"
//        coursedetailsVC.organizationName = viewModelHome?.valueArray[indexPath.section][indexPath.row].organization_name ?? ""
//        self.navigationController?.pushViewController(coursedetailsVC, animated: true)
    }
    
    
}
