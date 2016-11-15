//
//  GamesTableViewController.swift
//  TicTacToe
//
//  Created by Alex Dejeu on 11/15/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GamesTableViewController: UITableViewController {

    let games : Variable<[Board]> = Variable([])
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        games.asObservable().bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType : UITableViewCell.self)) { (index :  Int, board : Board, cell : UITableViewCell) in
            if let winner = board.winner(){
                cell.textLabel?.text = "The winner is: \(winner.rawValue)"
            }
            else{
                cell.textLabel?.text = "The current turn is: \(board.playerWithCurrentTurn().rawValue)"
            }
            }.addDisposableTo(disposeBag)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? ViewController{
            destinationController.addBoard = { (board: Board) in
                self.games.value.append(board)
            }
        }
    }
    

    
}
