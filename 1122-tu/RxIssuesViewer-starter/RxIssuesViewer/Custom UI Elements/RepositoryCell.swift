//
//  RepositoryCell.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 11/29/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {

    @IBOutlet weak var repositoryTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
