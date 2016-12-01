//
//  SearchRepositoriesViewController.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 11/22/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchRepositoriesViewController: UIViewController {

    var inputUser : User?
    let githubAPI = RxGitHubAPI()
    let disposeBag = DisposeBag()
    var repos : [Repository] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HERE WE ARE")
        var repoObservable = self.githubAPI.createRepositoryObservable(for: inputUser!)
        
        repoObservable.asObservable().bindTo(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType : RepositoryCell.self)) { (index :  Int, repository: Repository, cell : RepositoryCell) in
                cell.repositoryTitleLabel.text = repository.fullName
            }.addDisposableTo(disposeBag)
    }
    

    // MARK: - Navigation

}
