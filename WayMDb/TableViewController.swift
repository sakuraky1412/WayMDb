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
    let movieTypeString = "MOVIE"
    let browseUrl = "http://api.themoviedb.org/3/discover/movie?api_key=71ab1b19293efe581c569c1c79d0f004"
    let searchController = UISearchController(searchResultsController: nil)
    let green = UIColor(red: 66/255, green: 244/255, blue: 128/255, alpha: 1)
    let blue = UIColor(red: 59/255, green: 197/255, blue: 247/255, alpha: 1)
    let red = UIColor(red: 252/255, green: 111/255, blue: 111/255, alpha: 1)
    var typeColor: UIColor?
    var defaultImage: UIImage = #imageLiteral(resourceName: "Default Poster")
    var browseShowList = [SearchResults.Media]()
    var searchShowList = [SearchResults.Media]()
    var detail = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Setup the Search Controller
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        parseJSON(url: browseUrl, completion: {(list: [SearchResults.Media]?, error: Error?) -> Void in
            self.browseShowList = list!})
        
        // self.tableView.dataSource = self
        // self.tableView.delegate = self
        let nib = UINib.init(nibName: "ResultCell", bundle: nil)
        self.tblResults.register(nib, forCellReuseIdentifier: "ResultCell")
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
    
    //    // TODO: implement scope according to wenderlich tutorial
    //    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    //
    //    }
    
    func parseJSON(url: String, completion: @escaping ([SearchResults.Media]?, Error?) -> Void) {
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
                completion(apiData.results, nil)
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch let error {
                completion(nil, error)
            }
            }.resume()
    }
}

extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchUrl = "https://api.themoviedb.org/3/search/multi?api_key=71ab1b19293efe581c569c1c79d0f004&query=" + searchBar.text!
        parseJSON(url: searchUrl, completion: {(list: [SearchResults.Media]?, error: Error?) -> Void in
            self.searchShowList = list!})
    }
}

//extension TableViewController: UISearchResultsUpdating {
//    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}

extension TableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let media: SearchResults.Media
                if isFiltering() {
                    media = searchShowList[indexPath.row]
                } else {
                    media = browseShowList[indexPath.row]
                }
                
                // Type
                if let mediaType = media.mediaType {
                    switch mediaType {
                    case "movie":
                        controller.type = movieTypeString
                        // Title
                        controller.showTitle = media.title
                        controller.defaultImage = #imageLiteral(resourceName: "Default Poster")
                        controller.typeColor = red
                        if media.posterPath != nil {
                            controller.posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + media.posterPath!)
                        }
                    case "tv":
                        controller.type = "TV SHOW"
                        controller.showTitle = media.name
                        controller.defaultImage = #imageLiteral(resourceName: "Default Poster")
                        controller.typeColor = green
                        if media.posterPath != nil {
                            controller.posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + media.posterPath!)
                        }
                    case "person":
                        controller.type = "THE ACTOR"
                        controller.showTitle = media.name
                        controller.defaultImage = #imageLiteral(resourceName: "Default Profile")
                        controller.typeColor = blue
                        if media.profilePath != nil {
                            controller.posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + media.profilePath!)
                        }
                    default:
                        controller.type = "UNKNOWN MEDIA"
                    }
                } else {
                    controller.type = movieTypeString
                    controller.showTitle = media.title
                    controller.typeColor = red
                    if media.posterPath != nil {
                        controller.posterUrl = URL(string: "https://image.tmdb.org/t/p/w342/" + media.posterPath!)
                    }
                }
                
                // Rating
                if media.voteAverage != nil {
                    controller.rating = media.voteAverage!/2
                } else {
                    controller.rating = 0
                }
                
                // Detail
                if (media.mediaType == "person"){
                    controller.detail = detail
                    print(controller.detail)

                }
               else {
                    controller.detail = media.overview
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let media: SearchResults.Media
        if isFiltering(){
            media = searchShowList[indexPath.row]
        } else {
            media = browseShowList[indexPath.row]
        }
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = CGFloat(10)
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        
        // Type
        if let mediaType = media.mediaType {
            switch mediaType {
            case "movie":
                cell.lblType?.text = movieTypeString
                // Title
                cell.lblTitle?.text = media.title
                defaultImage = #imageLiteral(resourceName: "Default Poster")
                typeColor = red
                // Poster
                if media.posterPath != nil {
                    let posterUrl = "https://image.tmdb.org/t/p/w342/" + media.posterPath!
                    loadAsyncFrom(url: posterUrl, placeholder: #imageLiteral(resourceName: "Default Poster"), completion: {(imageToPresent: UIImage?, error: Error?) -> Void in
                        cell.imgPoster?.image = imageToPresent!})
                } else {
                    cell.imgPoster?.image = defaultImage
                }
            case "tv":
                cell.lblType?.text = "TV SHOW"
                cell.lblTitle?.text = media.name
                defaultImage = #imageLiteral(resourceName: "Default Poster")
                typeColor = green
                if media.posterPath != nil {
                    let posterUrl = "https://image.tmdb.org/t/p/w342/" + media.posterPath!
                    loadAsyncFrom(url: posterUrl, placeholder: #imageLiteral(resourceName: "Default Poster"), completion: {(imageToPresent: UIImage?, error: Error?) -> Void in
                        cell.imgPoster?.image = imageToPresent!})
                } else {
                    cell.imgPoster?.image = defaultImage
                }
            case "person":
                cell.lblType?.text = "THE ACTOR"
                cell.lblTitle?.text = media.name
                defaultImage = #imageLiteral(resourceName: "Default Profile")
                typeColor = blue
                if media.profilePath != nil {
                    let posterUrl = "https://image.tmdb.org/t/p/w342/" + media.profilePath!
                    loadAsyncFrom(url: posterUrl, placeholder: #imageLiteral(resourceName: "Default Poster"), completion: {(imageToPresent: UIImage?, error: Error?) -> Void in
                        cell.imgPoster?.image = imageToPresent!})
                } else {
                    cell.imgPoster?.image = defaultImage
                }
            default:
                cell.lblType?.text = "UNKNOWN MEDIA"
            }
        } else {
            cell.lblType?.text = movieTypeString
            cell.lblTitle?.text = media.title
            typeColor = red
            if media.posterPath != nil {
                let posterUrl = "https://image.tmdb.org/t/p/w342/" + media.posterPath!
                loadAsyncFrom(url: posterUrl, placeholder: #imageLiteral(resourceName: "Default Poster"), completion: {(imageToPresent: UIImage?, error: Error?) -> Void in
                    cell.imgPoster?.image = imageToPresent!})
            } else {
                cell.imgPoster?.image = defaultImage
            }
        }
        
        cell.lblType?.backgroundColor = typeColor
        
        // Rating
        if media.voteAverage != nil{
            cell.starRating?.rating = media.voteAverage!/2
            cell.starRating.isHidden = false
        } else {
            cell.starRating?.rating = 0
            cell.starRating.isHidden = true
        }
        
        if media.mediaType == "person"{
            let personUrl = "https://api.themoviedb.org/3/person/\(media.id ?? 0)?api_key=71ab1b19293efe581c569c1c79d0f004"
            let apiUrl = URL(string: personUrl)
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
                    let apiData = try decoder.decode(People.self, from: content)
                    self.detail = apiData.biography!
                } catch let error {
                    print(error)
                }
                }.resume()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return searchShowList.count
        }
        return browseShowList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // async method to load image from url
    func loadAsyncFrom(url: String, placeholder: UIImage, completion: @escaping (UIImage?, Error?) -> Void) {
        let requestURL = URL(string: url)
        URLSession.shared.dataTask(with: requestURL!) { (data, response, error) in
            DispatchQueue.main.async {
                if error == nil, let imageData = data, let imageToPresent = UIImage(data: imageData) {
                    completion(imageToPresent, nil)
                } else{
                    completion(placeholder, error)
                }
            }
            }.resume()
    }
}
