//
//  Issue.swift
//  RxIssuesViewer
//
//  Created by Nikolas Burk on 21/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import Foundation

struct Issue {
    
    // MARK - Properties
    let identifier: Int
    let title: String
    let postedBy: User
    let open: Bool
    let url: String
    
    
    // MARK - Init
    init(identifier: Int, title: String, postedBy: User, open: Bool, url: String){
        self.identifier = identifier
        self.title = title
        self.postedBy = postedBy
        self.open = open
        self.url = url
    }
}
