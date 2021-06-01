//
//  OtherSiteCell.swift
//  CourseTracker
//
//  Created by Jim on 24/05/2021.
//

import UIKit

class OtherSiteCell: UITableViewCell {

    @IBOutlet weak var siteLogo: UIImageView!
    @IBOutlet weak var siteName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
