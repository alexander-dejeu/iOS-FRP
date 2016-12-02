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
    
    func setRepos(repos: [Repository]){
        self.repos = repos
    }
    // MARK: - Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var repoObservable = self.githubAPI.createRepositoryObservable(for: inputUser!)
        
        repoObservable.asObservable().bindTo(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType : RepositoryCell.self)) { (index :  Int, repository: Repository, cell : RepositoryCell) in
            cell.repositoryTitleLabel.text = repository.fullName
            }.addDisposableTo(disposeBag)
        
        repoObservable.subscribe(onNext: setRepos).addDisposableTo(disposeBag)
//        tableView.rx.itemSelected
    }
    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let issuesTableViewController = segue.destination as! ProjectIssuesViewController
        issuesTableViewController.inputUser = self.inputUser
        let selectedRow = tableView.indexPathForSelectedRow!.row
        issuesTableViewController.inputRepo = repos[selectedRow]
    }
}
