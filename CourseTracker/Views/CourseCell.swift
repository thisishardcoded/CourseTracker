//
//  CourseCell.swift
//  CourseTracker
//
//  Created by Jim on 17/05/2021.
//

import UIKit

class CourseCell: UITableViewCell {

    @IBOutlet weak var courseLogo: UIImageView!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
