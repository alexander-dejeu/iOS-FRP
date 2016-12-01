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
    
    @IBAction func TappedOnSeeRepositories(sender:UIButton){
        performSegue(withIdentifier: "SegueFromUserToRepos", sender: nil)
    }
    
    let githubAPI = RxGitHubAPI()
    let disposeBag = DisposeBag()
    var inputUser : User? = nil
    
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var searchResultNameLabel: UILabel!
    @IBOutlet weak var resultTypeLabel: UILabel!
    @IBOutlet weak var respositoryResultCount: UILabel!
    @IBOutlet weak var seeRepositoriesButton: UIButton!
    // MARK: - Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservables()
    }
    
    func setUser(newUser: User?){
        inputUser = newUser
    }
    
    func setupObservables(){
        let maybeUserObservable: Observable<User?> = userInputTextField.rx.text.asObservable().throttle(0.75, scheduler: MainScheduler.instance).flatMapLatest {
            (searchText: String?) in
            return self.githubAPI.createUserObservable(for: searchText!)
        }
        
        
        maybeUserObservable.subscribe(onNext: setUser).addDisposableTo(disposeBag)
        
        maybeUserObservable.map { (user: User?) in
            if let user = user{
//                self.inputUser = user
                
                return user.name
            }
            return ""
            }.bindTo(searchResultNameLabel.rx.text).addDisposableTo(disposeBag)
        
        
        maybeUserObservable.map { (user: User?) in
            if let user = user{
                if user.type == "User"{
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
            destinationController.inputUser = self.inputUser
        }
    }
}
