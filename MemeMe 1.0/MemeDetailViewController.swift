//
//  MemeDetailView.swift
//  MemeMe 1.0
//
//  Created by Tri Mai on 9/7/18.
//  Copyright © 2018 Tri Mai. All rights reserved.
//

import Foundation
import UIKit

class MemeDetaiViewController: UIViewController {
    
    var memes: Meme!
    
    @IBOutlet weak var memeDetailImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        memeDetailImage.image = memes.memedImage
        tabBarController?.tabBar.isHidden = true
    }
  
}
