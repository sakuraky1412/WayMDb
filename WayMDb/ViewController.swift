//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var SearchBar: UISearchBar!
    var searchButtonClicked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addGradientToView(view: self.view)
        SearchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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

extension ViewController: UISearchBarDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue" && searchButtonClicked {
            searchButtonClicked = false
            let controller = segue.destination as! TableViewController
            controller.searchController.searchBar.text = SearchBar.text
            controller.initialSearch = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonClicked = true
        self.performSegue(withIdentifier: "SearchSegue", sender: nil)
    }
}
