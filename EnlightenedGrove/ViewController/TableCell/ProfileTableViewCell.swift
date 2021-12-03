//
//  ProfileTableViewCell.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 07/09/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var lblheader: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var imgprofile: UIImageView!
    @IBOutlet weak var imgSideWarning: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBorder.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
