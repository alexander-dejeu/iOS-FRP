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
        
        guard let descriptionDataArray = userInfo["weather"] as? NSArray else {
            print("could not get description data array")
            return nil
        }
        
        guard let descriptionData = descriptionDataArray[0] as? [String: Any] else {
            print("could not get description data")
            return nil
        }
        
        guard let description = descriptionData["description"] as? String else {
            print("could not get description")
            return nil
        }
        
        guard let dateSeconds = userInfo["dt"] as? Double else {
            print("could not get date")
            return nil
        }
        
        guard let temperatureInfo = userInfo["main"] as? [String: Any] else {
            print("could not get temperature info")
            return nil
        }
        
        guard let min = temperatureInfo["temp_min"] as? Float else {
            print("could not get min temperature")
            return nil
        }
        
        guard let max = temperatureInfo["temp_max"] as? Float else {
            print("could not get max temperature")
            return nil
        }
        
        guard let avg = temperatureInfo["temp"] as? Float else {
            print("could not get avg temperature")
            return nil
        }
    
        
        return User(identifier: 2, login: "test", name: "test", email: "string")
    }
    
}






