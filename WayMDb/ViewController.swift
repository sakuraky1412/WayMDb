//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let url = "http://api.themoviedb.org/3/discover/movie?api_key=71ab1b19293efe581c569c1c79d0f004"
    var movie = [Show]()
    var imdbdata: [String: Any] = [:]

    // Actors
    struct People: Decodable {
        let label: String
        let fullName: String
        let imageUrl: String
        let detail: String
    }
    
    // Movie and TV Shows
    struct Show: Codable {
//        let label: String
        let title: String
        let posterPath: String
        let voteAverage: Double
        let voteCount: Int
        let overview: String
    }
    
    struct MovieList: Codable {
        let results: [Show]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addGradientToView(view: self.view)
        parseJSON()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseJSON(){
        
        
//        //TODO: Change the url according to query
//        guard let apiUrl = URL(string: url) else { return }
//        URLSession.shared.dataTask(with: apiUrl) {(data, response, error) in
//            guard let data = data else { return }
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                // ERROR: Cannot decode [String: Any]
//                self.imdbdata = try decoder.decode([String: String].self, from: data)
//                // TODO: Do the requirement if there is no data, such as
//                // print(gitData.name ?? "Empty Name")
//
//                print(self.imdbdata)
//
//            } catch let err {
//                print("Error", err)
//            }
//        }.resume()
        
        guard let apiUrl = URL(string: url) else { return }
        URLSession.shared.dataTask(with: apiUrl) {(data, response, error) in
            
            guard error == nil else {
                print("returning error")
                return
            }
            
            guard let content = data else {
                print("not returning data")
                return
            }
            
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) else {
                print("Not containing JSON")
                return
            }
            
            if let array = json as? MovieList {
                self.movie = array.results
            }
            
            print(self.movie)
            
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
        }.resume()
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

