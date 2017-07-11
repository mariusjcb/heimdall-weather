//
//  ViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var index = 0
    var params: DataManager.APIRequestParams = [:]
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    @IBOutlet weak var hourly: UICollectionView!
    
    @IBOutlet weak var daily: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

