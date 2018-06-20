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
    let partialPosterUrl = "https://image.tmdb.org/t/p/w342/"
    let searchController = UISearchController(searchResultsController: nil)
    let green = UIColor(red: 66/255, green: 244/255, blue: 128/255, alpha: 1)
    let blue = UIColor(red: 59/255, green: 197/255, blue: 247/255, alpha: 1)
    let red = UIColor(red: 252/255, green: 111/255, blue: 111/255, alpha: 1)
    var typeColor: UIColor?
    var defaultImage: UIImage = #imageLiteral(resourceName: "Default Poster")
    var browseShowList = [SearchResults.Media]()
    var searchShowList = [SearchResults.Media]()
    var detail = "Detail"
    var initialSearch = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
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
        if initialSearch{
            searchBarSearchButtonClicked(searchController.searchBar)
            initialSearch = false
        } else {
            parseJSON(url: browseUrl, person: false, completion1: {(list: [SearchResults.Media]?, error: Error?) -> Void in self.browseShowList = list!}, completion2: {(detail: String?, error: Error?) -> Void in self.detail = detail!} )
        }
        
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
    
    func parseJSON(url: String, person: Bool, completion1: @escaping ([SearchResults.Media]?, Error?) -> Void, completion2: @escaping (String?, Error?) -> Void) {
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
                if !person{
                    let apiData = try decoder.decode(SearchResults.self, from: content)
                    DispatchQueue.main.async { [weak self] in
                        completion1(apiData.results, nil)
                        self?.tableView.reloadData()
                        if apiData.results.count != 0 {
                            let indexPath = IndexPath(row: 0, section: 0)
                            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
                else {
                    let apiData = try decoder.decode(People.self, from: content)
                    DispatchQueue.main.async { 
                        completion2(apiData.biography, nil)
                    }
                }
                
            } catch let error {
                completion1(nil, error)
            }
            }.resume()
    }
}

extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let trimmed = searchBar.text?.replacingOccurrences(of: " ", with: "")
        let searchUrl = "https://api.themoviedb.org/3/search/multi?api_key=71ab1b19293efe581c569c1c79d0f004&query=" + trimmed!
        if initialSearch {
            parseJSON(url: searchUrl, person: false, completion1: {(list: [SearchResults.Media]?, error: Error?) -> Void in self.browseShowList = list!}, completion2: {(detail: String?, error: Error?) -> Void in self.detail = detail!})
        } else {
        parseJSON(url: searchUrl, person: false, completion1: {(list: [SearchResults.Media]?, error: Error?) -> Void in self.searchShowList = list!}, completion2: {(detail: String?, error: Error?) -> Void in self.detail = detail!})
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension TableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                
                let media: SearchResults.Media
                if isFiltering() || initialSearch {
                    media = searchShowList[indexPath.row]
                } else {
                    media = browseShowList[indexPath.row]
                }
                var imagePath = "nil"

                func setDetailPageFields(type: String, typeColor: UIColor, title: String, imageUrl: String, defaultImage: UIImage) {
                    controller.type = type
                    controller.typeColor = typeColor
                    controller.showTitle = title
                    if imagePath != "nil" {
                        loadAsyncFrom(url: partialPosterUrl + imageUrl, placeholder: defaultImage, completion: {(imageToPresent: UIImage?, error: Error?) -> Void in
                            controller.imgPoster.image = imageToPresent!})
                    } else {
                        controller.poster = defaultImage
                    }
                }
                
                // Detail
                if media.mediaType == "person"{
                    let personUrl = "https://api.themoviedb.org/3/person/\(media.id ?? 0)?api_key=71ab1b19293efe581c569c1c79d0f004"
                    parseJSON(url: personUrl, person: true, completion1: {(list: [SearchResults.Media]?, error: Error?) -> Void in
                        self.searchShowList = list!}, completion2: {(detail: String?, error: Error?) -> Void in controller.txtDetail.text = detail!})
                } else {
                    controller.detail = media.overview!
                }
                
                if let mediaType = media.mediaType {
                    switch mediaType {
                    case "movie":
                        if media.posterPath != nil {
                            imagePath = media.posterPath!
                        }
                        setDetailPageFields(type: movieTypeString, typeColor: red, title: media.title!, imageUrl: imagePath, defaultImage: #imageLiteral(resourceName: "Default Poster"))
                    case "tv":
                        if media.posterPath != nil {
                            imagePath = media.posterPath!
                        }
                        setDetailPageFields(type: "TV SHOW", typeColor: green, title: media.name!, imageUrl: imagePath, defaultImage: #imageLiteral(resourceName: "Default Poster"))
                    case "person":
                        if media.profilePath != nil {
                            imagePath = media.profilePath!
                        }
                        setDetailPageFields(type: "THE ACTOR", typeColor: blue, title: media.name!, imageUrl: imagePath, defaultImage: #imageLiteral(resourceName: "Default Profile"))
                    default:
                        setDetailPageFields(type: "UNKNOWN MEDIA", typeColor: UIColor.black, title: "", imageUrl: imagePath, defaultImage: #imageLiteral(resourceName: "Default Poster"))
                    }
                } else {
                    if media.posterPath != nil {
                        imagePath = media.posterPath!
                    }
                    setDetailPageFields(type: movieTypeString, typeColor: red, title: media.title!, imageUrl: imagePath, defaultImage: #imageLiteral(resourceName: "Default Poster"))
                }
                
                // Rating
                if media.voteAverage != nil {
                    controller.rating = media.voteAverage!/2
                } else {
                    controller.rating = 0
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
                    let posterUrl = partialPosterUrl + media.posterPath!
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
                    let posterUrl = partialPosterUrl + media.posterPath!
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
                    let posterUrl = partialPosterUrl + media.profilePath!
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
                let posterUrl = partialPosterUrl + media.posterPath!
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numOfRows = isFiltering() ? searchShowList.count : browseShowList.count
        
        if numOfRows == 0 {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Results Found"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfRows
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
