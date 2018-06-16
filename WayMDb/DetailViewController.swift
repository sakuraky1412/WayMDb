//
//  DetailViewController.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/12/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var txtDetail: UITextView!
    @IBOutlet weak var starRating: CosmosView!
    
    var type: String?
    var showTitle: String?
    var posterUrl: URL?
    var detail: String?
    var rating: Double?
    var defaultImage: UIImage?
    var typeColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblType.text = type
        lblType.backgroundColor = typeColor
        lblType.frame.size = lblType.intrinsicContentSize

        lblTitle.text = showTitle
        
        if posterUrl != nil {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: self.posterUrl!), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imgPoster.image = image
                    }
                } else {
                    self.imgPoster.image = self.defaultImage
                }
            }
        } else {
            self.imgPoster.image = defaultImage
        }
        
        txtDetail.text = detail
        
        if rating != nil {
            starRating.isHidden = false
            starRating.rating = rating!
        } else {
            starRating.isHidden = true
            starRating.rating = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
