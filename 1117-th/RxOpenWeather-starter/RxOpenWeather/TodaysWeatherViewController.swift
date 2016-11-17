//
//  TodaysWeatherViewController.swift
//  RxOpenWeather
//
//  Created by Nikolas Burk on 17/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TodaysWeatherViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var forecastButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var avgTemperatureLabel: UILabel!
    
    
    //MARK: - Class variables
    let disposeBag = DisposeBag()
    let openWeatherAPI = RxOpenWeatherMapAPI()
    
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservables()
    }
    
    
    //MARK: - Observables
    func setupObservables(){
        
        let maybeWeatherObservable: Observable<Weather?> = cityTextField.rx.text.asObservable().throttle(0.75, scheduler: MainScheduler.instance).flatMapLatest {
            (searchText : String?) in
            return self.openWeatherAPI.createWeatherObservable(for: searchText!)
        }
        
        maybeWeatherObservable.map { (weather: Weather?) in
            if let weather = weather {
                return weather.description
            }
            return "-"
        }.bindTo(descriptionLabel.rx.text).addDisposableTo(disposeBag)
        
        
        maybeWeatherObservable.map { (waether : Weather?) in
            return waether != nil
        }.bindTo(forecastButton.rx.isEnabled).addDisposableTo(disposeBag)
    
        
        maybeWeatherObservable.map { (weather: Weather?) in
            if let weather = weather {
                return String(weather.temperature.avg)
            }
            return "-"
            }.bindTo(avgTemperatureLabel.rx.text).addDisposableTo(disposeBag)
        
        maybeWeatherObservable.map { (weather: Weather?) in
            if let weather = weather {
                return String(weather.temperature.min)
            }
            return "-"
            }.bindTo(minTemperatureLabel.rx.text).addDisposableTo(disposeBag)
        
        maybeWeatherObservable.map { (weather: Weather?) in
            if let weather = weather {
                return String(weather.temperature.max)
            }
            return "-"
            }.bindTo(maxTemperatureLabel.rx.text).addDisposableTo(disposeBag)
        
        
    }
    
    
    
    
    
}

