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
    var issues : [Issue] = []
    
    
    //MARK:  - Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("User = \(inputUser)")
        print("Repo = \(inputRepo)")
        
        var issueObservable = self.githubAPI.createIssueObservable(for: inputUser!, repo: inputRepo!)
        
        issueObservable.asObservable().bindTo(tableView.rx.items(cellIdentifier: "IssuesCell", cellType : IssuesCell.self)) { (index :  Int, issue: Issue, cell : IssuesCell) in
                cell.issueLabel.text = issue.title
            cell.whoSubmitedIssueLabel.text = "Created by: \(issue.postedBy.login)"
            
            switch issue.open{
            case true:
                cell.issueStatusLabel.text = "✅"
            case false:
                cell.issueStatusLabel.text = "⚪"
            }
            
            cell.whoSubmitedIssueAvatar.downloadedFrom(link: issue.postedBy.avatarURLString)
            
            }.addDisposableTo(disposeBag)
        
        
    }
    
    

    // MARK: - Navigation

}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
