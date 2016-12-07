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
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    //MARK: - Properties
    var inputUser : User?
    let githubAPI = RxGitHubAPI()
    let disposeBag = DisposeBag()
    var repos : Variable<[Repository]> = Variable([])
    var filteredRepos: Variable<[Repository]> = Variable([])
    
    
    // MARK: - Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var repoObservable = self.githubAPI.createRepositoryObservable(for: inputUser!)
    
        repoObservable.subscribe(onNext: setRepo).addDisposableTo(disposeBag)
        
        let searchbarObservable: Observable<String?> = searchBar.rx.text.asObservable()
        searchbarObservable.subscribe(onNext: filterRepos).addDisposableTo(disposeBag)
    
        filterRepos(prefix: nil)
        
        filteredRepos.asObservable().bindTo(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType : RepositoryCell.self)) { (index :  Int, repository: Repository, cell : RepositoryCell) in
            cell.repositoryTitleLabel.text = repository.fullName
            }.addDisposableTo(disposeBag)
        
        
        
        
        //        repoObservable.subscribe(onNext: setRepos).addDisposableTo(disposeBag)
    }
    
    
    //MARK: - Helpers
    //    func setRepos(repos: [Repository]){
    //        self.repos = repos
    //    }
    func filterRepos(prefix: String?){
        self.filteredRepos.value = []
        if prefix == nil {
            self.filteredRepos.value = repos.value
        }
        else{
            for repo in repos.value{
                if repo.fullName.hasPrefix(prefix!){
                    self.filteredRepos.value.append(repo)
                }
            }
        }
    }
    
    func setRepo(result: [Repository]){
        self.repos.value = result
        filterRepos(prefix: nil)
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let issuesTableViewController = segue.destination as! ProjectIssuesViewController
        issuesTableViewController.inputUser = self.inputUser
        let selectedRow = tableView.indexPathForSelectedRow!.row
        issuesTableViewController.inputRepo = filteredRepos.value[selectedRow]
    }
}
