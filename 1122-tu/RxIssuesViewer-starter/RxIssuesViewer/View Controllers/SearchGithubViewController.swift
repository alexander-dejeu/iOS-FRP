//
//  SearchGithubViewController.swift
//  RxIssuesViewer
//
//  Created by Alex Dejeu on 11/22/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchGithubViewController: UIViewController {

    // MARK - IBOutlets
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var searchResultNameLabel: UILabel!
    @IBOutlet weak var resultTypeLabel: UILabel!
    @IBOutlet weak var respositoryResultCount: UILabel!
    @IBOutlet weak var seeRepositoriesButton: UIButton!
    
    
    // MARK - Properties
    let githubAPI = RxGitHubAPI()
    let disposeBag = DisposeBag()
    var user : Variable<User?> = Variable(nil)
    /*
  rather than creating `var inputUser : User? = nil` you could wrap the `User?` in a `Variable`, this would allow you to use `bindTo` as follows: `maybeUserObservable.bindTo(user)`; in these situations bindings are preferrable over regular subscriptions as they're more concise and expressive
 */
    
    // MARK - IBActions
    @IBAction func tappedOnSeeRepositories(sender:UIButton){
        performSegue(withIdentifier: "SegueFromUserToRepos", sender: nil)
    }
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservables()
    }
    
    
    // MARK: - RxSwift
    func setupObservables(){
        
        let maybeUserObservable: Observable<User?> = userInputTextField.rx.text.asObservable().throttle(0.75, scheduler: MainScheduler.instance).flatMapLatest {
            (searchText: String?) in
            return self.githubAPI.createUserObservable(for: searchText!)
        }
        
//        maybeUserObservable.subscribe(onNext: setUser).addDisposableTo(disposeBag)
        maybeUserObservable.bindTo(user).addDisposableTo(disposeBag)
        
        maybeUserObservable.map { (user: User?) in
            if let user = user{
                return user.name
            }
            return ""
            }.bindTo(searchResultNameLabel.rx.text).addDisposableTo(disposeBag)
        
        maybeUserObservable.map { (user: User?) in
            if let user = user{
                if user.type == .user{
                    return "👤"
                }
                return "👥"
            }
            return ""
            }.bindTo(resultTypeLabel.rx.text).addDisposableTo(disposeBag)
        
        maybeUserObservable.map{ (user: User?) in
            if let user = user {
                if user.publicRepoCount == 0{
                    return "No public repositories, yet!"
                }
                else if user.publicRepoCount == 1{
                    return "1 public repository"
                }
                else{
                    return "\(user.publicRepoCount) public repositories"
                }
            }
            return ""
            }.bindTo(respositoryResultCount.rx.text).addDisposableTo(disposeBag)
        
        // Disable results button
        maybeUserObservable.map{ (user: User?) in
            return user != nil
            }.bindTo(seeRepositoriesButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        // Hide elements if no valid user object
        maybeUserObservable.map{ (user: User?) in
            return user == nil
            }.bindTo(searchResultNameLabel.rx.isHidden).addDisposableTo(disposeBag)
        maybeUserObservable.map{ (user: User?) in
            return user == nil
            }.bindTo(resultTypeLabel.rx.isHidden).addDisposableTo(disposeBag)
        maybeUserObservable.map{ (user: User?) in
            return user == nil
            }.bindTo(respositoryResultCount.rx.isHidden).addDisposableTo(disposeBag)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? SearchRepositoriesViewController{
            destinationController.inputUser = self.user.value
        }
    }
}
