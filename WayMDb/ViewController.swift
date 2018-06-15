//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var showList = [SearchResults.Media]()
    let tableViewController = TableViewController()
    let searchController = UISearchController(searchResultsController: TableViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addGradientToView(view: self.view)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        // searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // TODO: implement scope according to wenderlich tutorial
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let url = "https://api.themoviedb.org/3/search/multi?api_key=71ab1b19293efe581c569c1c79d0f004&query=" + searchText
        tableViewController.parseJSON(url: url)
        print(showList)
        tableViewController.tableView.reloadData()
    }
    
    func addGradientToView(view: UIView)
    {
        //gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //define colors
        gradientLayer.colors = [UIColor(red: 67, green: 239, blue: 179, alpha: 1).cgColor, UIColor(red: 1, green: 210, blue: 119, alpha: 1)]
        
        //define locations of colors as NSNumbers in range from 0.0 to 1.0
        //if locations not provided the colors will spread evenly
        //gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        //gradientLayer.endPoint = CGPoint(x: 0.6, y: 1)
        gradientLayer.locations = [-0.8, 0.5]
        
    }
    
}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

