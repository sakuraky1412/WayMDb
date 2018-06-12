//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var tblResults: UITableView!
    
    //TODO: Chang url according to search query
    var url = "http://api.themoviedb.org/3/discover/movie?api_key=71ab1b19293efe581c569c1c79d0f004"
    
    var showList = [ShowList.Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        parseJSON()
        // self.tableView.dataSource = self
        // self.tableView.delegate = self
        let nib = UINib.init(nibName: "ResultCell", bundle: nil)
        self.tblResults.register(nib, forCellReuseIdentifier: "ResultCell")
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
                let apiData = try decoder.decode(ShowList.self, from: content)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        cell.layer.cornerRadius = 12.5
        cell.layer.masksToBounds = true
        
        cell.lblType?.text = "Movie"
        cell.lblTitleName?.text = self.showList[indexPath.row].title
        let ratingOfScaleTen = self.showList[indexPath.row].voteAverage
        cell.starRating?.rating = ratingOfScaleTen!/2
        
        let posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + self.showList[indexPath.row].posterPath!)
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: posterUrl!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imgPoster?.image = image
                        cell.imgPoster?.contentMode = UIViewContentMode.scaleAspectFill
                    }
                }
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
