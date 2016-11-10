//
//  ViewController.swift
//  RxCalculator
//
//  Created by Nikolas Burk on 09/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var operationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var firstValueTextField: UITextField!
    @IBOutlet weak var secondValueTextField: UITextField!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    var calculator = Calculator()
    let disposeBag = DisposeBag()
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let firstValueObservable: Observable<Int> = firstValueTextField.rx.text.map { (text : String?) in
            return Int(text!)!
        }
        
        let secondValueObservable: Observable<Int> = secondValueTextField.rx.text.map { (text: String?) in
            return Int(text!)!
        }
        
        let operationObservable: Observable<Calculator.Operation> = operationSegmentedControl.rx.value.map { (selectedIndex: Int) in
            return Calculator.Operation(rawValue: selectedIndex)!
        }
        
        let signObservable : Observable<String> = operationObservable.map { (operation : Calculator.Operation) in
            return self.calculator.sign(for: operation)
        }
        
        let resultObservable = Observable.combineLatest(operationObservable, firstValueObservable, secondValueObservable) { (operation : Calculator.Operation, firstValue : Int, secondValue : Int) in
            switch operation {
                case .addition: return self.calculator.add(a: firstValue, b: secondValue)
                case .subtraction: return self.calculator.subtract(a: firstValue, b: secondValue)
            }
            }.map { (resultInt: Int) in
                return String(resultInt)
        }
        
        signObservable.bindTo(operationLabel.rx.text).addDisposableTo(disposeBag)
        resultObservable.bindTo(resultLabel.rx.text).addDisposableTo(disposeBag)
    }
    
}

