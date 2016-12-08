//
//  RxGitHubAPI.swift
//  RxIssuesView
//
//  Created by Nikolas Burk on 21/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//
//  inspired by Octokit.swift

import Foundation
import UIKit
import RxCocoa
import RxSwift

class RxGitHubAPI {
    
    // MARK: - Properties
    static private let clientID = "b5ddb1d98aa21662a427"
    static private let clientSecret = "707c85532d2510d8c071dff60b3d04768edb4fd4"
    static private var userAccessToken = ""
    
    let baseURL = "https://api.github.com"
    static let githubWebURL = "https://github.com"
    
    enum GitHubEndpoint {
        case user(String)
        case organization(String)
        case repos(User)
        case issues(User, Repository)
    }
    
    
    // MARK: Authentication
    
    static func authenticate(with code: String) {
        
        let path = "login/oauth/access_token"
        let params = ["client_id": clientID, "client_secret": clientSecret, "code": code]
        
        let urlString = githubWebURL + "/" + path + "?" + params.toURLArguments()
        
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print(#file.lastPathComponent()!, #line, #function, "ERROR: no token, code \(response.statusCode)")
                    return
                } else {
                    if let data = data, let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                        let accessToken = string.retrieveAccessToken()
                        if let accessToken = accessToken {
                            print(#file.lastPathComponent()!, #line, #function, "received access token: \(accessToken)")
                            userAccessToken = accessToken
                            DispatchQueue.main.async {
                                let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "navigationController")
                                UIApplication.shared.delegate?.window??.rootViewController = viewController
                            }
                        }
                        else {
                            print(#file.lastPathComponent()!, #line, #function, "ERROR: could not get access token, code \(response.statusCode)")
                        }
                    }
                    else {
                        print(#file.lastPathComponent()!, #line, #function, "ERROR: could not parse data, code \(response.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
    
    static func loginURL() -> String {
        let baseURL = "https://github.com/login/oauth/authorize"
        let callback = "rxissuesviewer://success"
        let scope = "user%20repo"
        let urlString = baseURL + "?client_id=\(clientID)&redirect_url=\(callback)&scope=\(scope)" //
        return urlString
    }
    
    
    // MARK: URLs
    
    func url(for endpoint: GitHubEndpoint) -> URL? {
        var urlString = baseURL
        switch endpoint {
        case .user(let username):
            urlString = urlString + "/users/" + username
            if RxGitHubAPI.userAccessToken.characters.count > 0 {
                urlString = urlString + "?access_token=" + RxGitHubAPI.userAccessToken
            }
        case .organization(let organizationName):
            urlString = urlString + "/orgs/" + organizationName
            if RxGitHubAPI.userAccessToken.characters.count > 0 {
                urlString = urlString + "?access_token=" + RxGitHubAPI.userAccessToken
            }
        case .repos(let user):
            urlString = urlString + "/users/" + user.login + "/repos"
            if RxGitHubAPI.userAccessToken.characters.count > 0 {
                urlString = urlString + "?access_token=" + RxGitHubAPI.userAccessToken
            }
        case .issues(let user, let repository):
            urlString = urlString + "/repos/" + user.login + "/" + String(repository.name) + "/issues?state=all"
            if RxGitHubAPI.userAccessToken.characters.count > 0 {
                urlString = urlString + "&access_token=" + RxGitHubAPI.userAccessToken
            }
        }
        return URL(string: urlString)
    }
    
    
    // MARK: Helpers
    // ************  USERS  ************
    func createUserObservable(for user: String) -> Observable<User?> {
        guard let url = url(for: .user(user))
            else{
                print(#function, "invalid URL")
                return Observable<User?>.just(nil)
        }
        
        let jsonObservable : Observable<Any> = URLSession.shared.rx.json(url: url)
        print(jsonObservable)
        let userInfoObservable : Observable<[String: Any]> = jsonObservable.map { (json: Any) in
            print(json)
            return (json as? [String: Any])!
        }
        print(userInfoObservable)
        
        
        let userObservable : Observable<User?> = userInfoObservable.map { (userInfo : [String: Any]?) in
            guard let user = userInfo
                else{
                    print(#function, "There is no data")
                    return nil
            }
            print(user)
            return self.jsonToMaybeUser(userInfo: user)
        }
        
        return userObservable.observeOn(MainScheduler.instance).catchErrorJustReturn(nil)
    }
    
    // MARK: Parsing
    
    fileprivate func jsonToMaybeUser(userInfo: [String: Any]) -> User? {
        
        guard let userInfoID = userInfo["id"] as? Int else {
            print("could not get user name")
            return nil
        }
        
        guard let userInfoLogin = userInfo["login"] as? String else {
            print("could not get user login")
            return nil
        }
        
        guard let userInfoUserName = userInfo["name"] as? String else {
            print("could not get user name")
            return nil
        }
        
        guard let userInfoUserAvatarURLString = userInfo["avatar_url"] as? String else {
            print("could not get user avatar info")
            return nil
        }
        
        guard let userInfoUserType = userInfo["type"] as? String else {
            print("could not get user type")
            return nil
        }
        
        var userType : Type = Type(rawValue: userInfoUserType)!
        
        guard let userInfoUserPublicRepoCount = userInfo["public_repos"] as? Int else {
            print("could not get user public repo count")
            return nil
        }
        
        
        return User(identifier: userInfoID, login: userInfoLogin, name: userInfoUserName, email: "", avatarURLString: userInfoUserAvatarURLString, type: userType, publicRepoCount: userInfoUserPublicRepoCount)
    }
    
    // ************  REPOSITORIES  ************
    func createRepositoryObservable(for user: User) -> Observable<[Repository]> {
        print("entered la function")
        guard let url = url(for: .repos(user))
            else{
                print(#function, "invalid URL")
                return Observable.just([])
        }
        
        let jsonObservable : Observable<Any> = URLSession.shared.rx.json(url: url)
        print(jsonObservable)
        let repositoryInfoObservable : Observable<[Any]> = jsonObservable.map { (json: Any) in
            print(json)
            guard let json = json as? [Any]
                else{
                    print(#function, "Bad Json")
                    return []
            }
            return json
        }
        print(repositoryInfoObservable)
        
        
        let repositoryObservable : Observable<[Repository]> = repositoryInfoObservable.map { (reposInfo : [Any]?) in
            guard let repos = reposInfo
                else{
                    print(#function, "There is no data")
                    return []
            }
            print(repos)
            return self.jsonToMaybeRepos(reposInfo: repos)
        }
        
        return repositoryObservable.observeOn(MainScheduler.instance).catchErrorJustReturn([])
    }
    
    fileprivate func jsonToMaybeRepos(reposInfo: [Any]) -> [Repository] {
        
        var resultRepositories: [Repository] = []
        
        for i in 0..<reposInfo.count{
            guard let data : [String: Any] = reposInfo[i] as! [String: Any]
                else{
                    print(#function, "Bad data at index \(i) skipping data")
                    continue
            }
            print("We are at index \(i) here is the data: \(data)")
            
            guard let repoID = data["id"] as? Int else {
                print("could not get repo identifier")
                continue
            }
            
            guard let repoLanguage = data["language"] as? String else {
                print("could not get repo language")
                continue
            }
            
            guard let repoName = data["name"] as? String else {
                print("could not get repo name")
                continue
            }
            guard let repoFullName = data["full_name"] as? String else {
                print("could not get repo fullName")
                continue
            }
            
            let newRepo = Repository(identifier: repoID, language: repoLanguage, name: repoName, fullName: repoFullName)
            resultRepositories.append(newRepo)
            
        }
        
        return resultRepositories
    }
    
    // ************  ISSUES  ************
    func createIssueObservable(for user: User, repo: Repository) -> Observable<[Issue]> {
        guard let url = url(for: .issues(user, repo))
            else{
                print(#function, "invalid URL")
                return Observable.just([])
        }
        
        let jsonObservable : Observable<Any> = URLSession.shared.rx.json(url: url)
        print(jsonObservable)
        let issueInfoObservable : Observable<[Any]> = jsonObservable.map { (json: Any) in
            print(json)
            guard let json = json as? [Any]
                else{
                    print(#function, "Bad Json")
                    return []
            }
            return json
        }
        print(issueInfoObservable)
        
        
        let issueObservable : Observable<[Issue]> = issueInfoObservable.map { (issueInfo : [Any]?) in
            guard let issues = issueInfo
                else{
                    print(#function, "There is no data")
                    return []
            }
            print(issues)
            return self.jsonToMaybeIssues(issuesInfo: issues)
        }
        
        return issueObservable.observeOn(MainScheduler.instance).catchErrorJustReturn([])
    }
    
    fileprivate func jsonToMaybeIssues(issuesInfo: [Any]) -> [Issue] {
        
        var resultIssues: [Issue] = []
        
        for i in 0..<issuesInfo.count{
            guard let data : [String: Any] = issuesInfo[i] as! [String: Any]
                else{
                    print(#function, "Bad data at index \(i) skipping data")
                    continue
            }
            print("We are at index \(i) here is the data: \(data)")
            
            guard let issueID = data["id"] as? Int else {
                print("could not get issue identifier")
                continue
            }
            
            guard let issueTitle = data["title"] as? String else {
                print("could not get issue title")
                continue
            }
            guard let userJSON = data["user"] as? [String: Any] else {
                print("could not get user JSON")
                continue
            }
            
            guard let issuePostedBy = jsonToUser(userJSON: userJSON) else {
                print("could not convert json to user")
                continue
            }
            
            guard let issueOpen = data["state"] as? String else {
                print("could not get repo fullName")
                continue
            }
            guard let issueURL = data["html_url"] as? String else {
                print("could not get issue url")
                continue
            }
            
            var openStatus = false
            if issueOpen == "open" {
                openStatus = true
            }
            
            
            let newIssue = Issue(identifier: issueID, title: issueTitle, postedBy: issuePostedBy, open: openStatus, url: issueURL)
            resultIssues.append(newIssue)
            
        }
        
        return resultIssues
    }
    
    // Helper
    func jsonToUser(userJSON: [String: Any]) -> User?{
        guard let userID = userJSON["id"] as? Int else {
            print("could not get user id")
            return nil
        }
        guard let userLogin = userJSON["login"] as? String else {
            print("could not get user login")
            return nil
        }
        guard let userAvatarURL = userJSON["avatar_url"] as? String else {
            print("could not get user avatar")
            return nil
        }
        guard let userTypeString = userJSON["type"] as? String else {
            print("could not get issue identifier")
            return nil
        }
        var userType : Type = Type(rawValue: userTypeString)!
        return User(identifier: userID, login: userLogin, name: "", email: "", avatarURLString: userAvatarURL, type: userType, publicRepoCount: -1)
    }
}






