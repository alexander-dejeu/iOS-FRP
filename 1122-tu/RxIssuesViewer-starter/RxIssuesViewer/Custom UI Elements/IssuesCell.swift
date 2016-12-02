//
//  IssuesCell.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 12/1/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit

class IssuesCell: UITableViewCell {

    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var whoSubmitedIssueLabel: UILabel!
    @IBOutlet weak var whoSubmitedIssueAvatar: UIImageView!
    
    @IBOutlet weak var issueStatusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
