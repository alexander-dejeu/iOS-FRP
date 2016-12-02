//
//  Repository.swift
//  RxIssuesViewer
//
//  Created by Nikolas Burk on 21/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import Foundation

struct Repository {
    
    // MARK - Properties
    let identifier: Int
    let language: String
    let name: String
    let fullName: String
    
    
    // MARK - Init
    init(identifier: Int, language: String, name: String, fullName: String) {
        self.identifier = identifier
        self.language = language
        self.name = name
        self.fullName = fullName
    }
    
}
