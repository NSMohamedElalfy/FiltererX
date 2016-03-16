//
//  ToolCollectionViewCell.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterImageView: UIImageView!
    
    var image:UIImage! {
        didSet{
            filterImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        filterImageView.image = nil
    }
    
}
