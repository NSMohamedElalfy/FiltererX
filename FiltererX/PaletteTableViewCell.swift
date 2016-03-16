//
//  PaletteTableViewCell.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/6/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

import UIKit

class PaletteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorsCollectionView:UICollectionView!
    
    var colorsPalette = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PaletteTableViewCell : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colorsPalette.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCellID", forIndexPath: indexPath) as! ColorCollectionViewCell
        let colorString = self.colorsPalette[indexPath.row]
        cell.backgroundColor = UIColor.hex(colorString)
        cell.hexLabel.text = colorString
        
        return cell
    }
    
}

extension PaletteTableViewCell : UICollectionViewDelegate {
    
}
