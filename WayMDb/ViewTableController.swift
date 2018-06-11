//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    //TODO: Chang url according to search query
    var url = "http://api.themoviedb.org/3/discover/movie?api_key=71ab1b19293efe581c569c1c79d0f004"
    
    var showList = [Data.Show]()
    
    // The JSON data gotten from the IMDb api
    struct Data: Codable{
        let results: [Show]
        // Movie and TV Shows
        struct Show: Codable {
            // let label: String
            let title: String?
            let posterPath: String?
            let voteAverage: Double?
            let voteCount: Int?
            let overview: String?
            
            private enum CodingKeys: String, CodingKey {
                case title
                case posterPath = "poster_path"
                case voteAverage = "vote_average"
                case voteCount = "vote_count"
                case overview
            }
        }
    }
    
    // TODO: Need to finish this
    // Actors and Actresses
    struct People: Decodable {
        // let label: String
        let fullName: String
        let imageUrl: String
        let detail: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        parseJSON()
        self.tableView.dataSource = self
        self.tableView.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseJSON(){
        
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
            
            do {
                let decoder = JSONDecoder()
                let apiData = try decoder.decode(Data.self, from: content)
                print(apiData.results)
                self.showList = apiData.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let err {
                print("Error", err)
            }
            }.resume()
    }
    
}

extension TableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.showList[indexPath.row].title
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showList.count
    }
}
