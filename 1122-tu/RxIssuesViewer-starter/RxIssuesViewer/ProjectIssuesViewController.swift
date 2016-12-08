//
//  ProjectIssuesViewController.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 11/22/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProjectIssuesViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Properties
    var inputRepo : Repository?
    var inputUser: User?
    let githubAPI = RxGitHubAPI()
    let disposeBag = DisposeBag()
    var issues : Variable<[Issue]?> = Variable([])
    
    //MARK:  - Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let issueObservable = self.githubAPI.createIssueObservable(for: inputUser!, repo: inputRepo!)
        
        issueObservable.asObservable().bindTo(tableView.rx.items(cellIdentifier: "IssuesCell", cellType : IssuesCell.self)) { (index :  Int, issue: Issue, cell : IssuesCell) in
            cell.issueLabel.text = issue.title
            cell.whoSubmitedIssueLabel.text = "Created by: \(issue.postedBy.login)"
            
            switch issue.open{
            case true:
                cell.issueStatusLabel.text = "✅"
            case false:
                cell.issueStatusLabel.text = "⚪"
            }
            
            let avatarURL = URL(string: issue.postedBy.avatarURLString)
            let imageObservable : Observable<UIImage?> = URLSession.shared.rx.data(request: URLRequest(url: avatarURL!)).map { (data : Data) in
                return UIImage(data: data)
                }.observeOn(MainScheduler.instance).catchErrorJustReturn(nil)
        
            imageObservable.bindTo(cell.whoSubmitedIssueAvatar.rx.image).addDisposableTo(self.disposeBag)
            
            }.addDisposableTo(disposeBag)
        
        issueObservable.bindTo(issues).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: openURL).addDisposableTo(disposeBag)
        
    }
    
    
    // MARK: - Helpers
    func openURL(indexPath: IndexPath){
        if let url = URL(string: (issues.value?[indexPath.row].url)!) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}
