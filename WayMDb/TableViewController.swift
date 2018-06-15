//
//  ViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/7/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

var asyncImagesCashArray = NSCache<NSString, UIImage>()

class TableViewController: UITableViewController {
    
    @IBOutlet weak var tblResults: UITableView!
    
    //TODO: Chang url according to search query
    let movieTypeString = "MOVIE"
    var url = "http://api.themoviedb.org/3/discover/movie?api_key=71ab1b19293efe581c569c1c79d0f004"
    var showList = [SearchResults.Media]()
    var image: UIImage = #imageLiteral(resourceName: "Default Poster")
    var completionHandlers: [(UIImage) -> ()] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        parseJSON(url: url)
        // self.tableView.dataSource = self
        // self.tableView.delegate = self
        let nib = UINib.init(nibName: "ResultCell", bundle: nil)
        self.tblResults.register(nib, forCellReuseIdentifier: "ResultCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseJSON(url: String) {
        let apiUrl = URL(string: url)
        URLSession.shared.dataTask(with: apiUrl!) {(data, response, error) in
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
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let apiData = try decoder.decode(SearchResults.self, from: content)
                self.showList = apiData.results
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch let err {
                print("Error", err)
            }
            }.resume()
    }
}

extension TableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                //Type
                if let mediaType = self.showList[indexPath.row].mediaType {
                    controller.type = getMediaTypeShown(mediaType: mediaType)
                } else {
                    controller.type = movieTypeString
                }
                // Title
                controller.showTitle = self.showList[indexPath.row].title
                // Rating
                controller.rating = self.showList[indexPath.row].voteAverage!/2
                // Poster
                controller.posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + self.showList[indexPath.row].posterPath!)
                // Detail
                controller.detail = self.showList[indexPath.row].overview
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = CGFloat(10)
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        
        if let mediaType = self.showList[indexPath.row].mediaType {
            cell.lblType?.text = getMediaTypeShown(mediaType: mediaType)
        } else {
            cell.lblType?.text = movieTypeString
        }
        
        cell.lblTitle?.text = self.showList[indexPath.row].title
        cell.starRating?.rating = self.showList[indexPath.row].voteAverage!/2
        
        let posterUrl = "https://image.tmdb.org/t/p/w342/" + self.showList[indexPath.row].posterPath!
        loadAsyncFrom(url: posterUrl, placeholder: #imageLiteral(resourceName: "Default Poster"))
        cell.imgPoster?.image = image

//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: posterUrl!) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        cell.imgPoster?.image = image
//                    }
//                }
//            }
//        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    // async method to load image from url
    func loadAsyncFrom(url: String, placeholder: UIImage, completion: @escaping (UIImage) -> ()) {
        completionHandlers.append(completion)
        
        // store url as key string
        let imageURL = url as NSString
        // return cashed image if not nil
        if let cashedImage = asyncImagesCashArray.object(forKey: imageURL) {
            image = cashedImage
        }
        // otherwise request image from url
        guard let requestURL = URL(string: url) else { image = placeholder; return }
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    if let imageData = data {
                        if let imageToPresent = UIImage(data: imageData) {
                            asyncImagesCashArray.setObject(imageToPresent, forKey: imageURL)
                            self?.image = imageToPresent
                        } else{
                            self?.image = placeholder
                        }
                    } else{
                        self?.image = placeholder
                    }
                } else{
                    self?.image = placeholder
                }
            }
        }.resume()
    }
    
    func getMediaTypeShown(mediaType: String) -> String {
        let mediaTypeShown: String
        switch mediaType {
        case "movie":
            mediaTypeShown = movieTypeString
        case "tv":
            mediaTypeShown = "TV SHOW"
        case "person":
            mediaTypeShown = "THE ACTOR"
        default:
            mediaTypeShown = "UNKNOWN MEDIA"
        }
        return mediaTypeShown
    }
}
