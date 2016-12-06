//
//  User.swift
//  RxIssuesViewer
//
//  Created by Nikolas Burk on 21/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import Foundation

struct User {
    
    // MARK - Properties
    let identifier: Int
    let login: String
    let name: String
    let email: String
    let avatarURLString : String
    let type: Type
    let publicRepoCount: Int
    
    
    // MARK - Init
    init(identifier: Int, login: String, name: String, email: String, avatarURLString: String, type: Type, publicRepoCount: Int){
        self.identifier = identifier
        self.login = login
        self.name = name
        self.email = email
        self.avatarURLString = avatarURLString
        self.type = type
        self.publicRepoCount = publicRepoCount
    }
}

enum Type : String{
    case user = "User"
    case organization = "Organization"
}
