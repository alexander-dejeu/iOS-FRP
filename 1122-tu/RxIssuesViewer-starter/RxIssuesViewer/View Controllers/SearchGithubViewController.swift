//
//  SearchGithubViewController.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 11/22/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit

class SearchGithubViewController: UIViewController {

    let githubAPI = RxGitHubAPI()
    
    // MARK: - Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        githubAPI.createUserObservable(for: "Alexander-Dejeu")
    }

   
    // MARK: - Navigation
}
