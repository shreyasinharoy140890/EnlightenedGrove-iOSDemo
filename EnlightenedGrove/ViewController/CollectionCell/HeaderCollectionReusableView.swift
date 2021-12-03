//
//  HeaderCollectionReusableView.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 23/08/21.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var lblHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getlabelheader(headerText:String){
        //self.lblHeader.text! = headerText
    }
    
}
