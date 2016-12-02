//
//  IssuesCell.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 12/1/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit

class IssuesCell: UITableViewCell {

    // MARK - IBOutlets
    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var whoSubmitedIssueLabel: UILabel!
    @IBOutlet weak var issueStatusLabel: UILabel!
    @IBOutlet weak var whoSubmitedIssueAvatar: UIImageView!
    
    
    // MARK - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
