//
//  EditorViewController.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

import UIKit
import CoreData

class EditorViewController: UIViewController {

    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var titleLabe:UILabel!
    @IBOutlet weak var colorsButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    
    
    let filtersFactory = FiltersFactory.sharedInstance
    let queue = NSOperationQueue()
    
    weak var delegate:ReSetupCaptureSessionDelegate?
    var filtersStore : [(name:String,filter:Filter)]!
    var colorsPalette :[UIColor]!
    var originalImage:UIImage?
    var isFilterButtonOn = false
    var isColorsButtonOn = false
    var currentFilter:Filter!
    var photoView:SWPhotoView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        guard let image = originalImage else {
            return
        }
        
        self.photoView = SWPhotoView(frame: self.containerView.bounds, image: image)
        self.photoView.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
        self.containerView.addSubview(photoView)
        
        filtersStore = filtersFactory.filtersStore
        currentFilter = filtersStore[0].filter
        
        titleLabe.text = "Photo Editor"
        indicator.hidden = true
        
        
    }
    
    @IBAction func onCamera(sender:UIButton){
        delegate?.reSetupCaptureSession()
        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showMenu(menuView:UICollectionView){
        
        self.view.addSubview(menuView)
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftCollectionViewEdgeConstraint = NSLayoutConstraint(item: menuView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightCollectionViewEdgeConstraint = NSLayoutConstraint(item: menuView, attribute:.Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0)
        let bottomCollectionViewEdgeConstraint = NSLayoutConstraint(item: menuView, attribute:.Bottom , relatedBy: .Equal, toItem: bottomToolbar , attribute: .Top , multiplier: 1.0, constant: 0)
        let hightCollectionViewConstraint = NSLayoutConstraint(item: menuView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 75)
        
        self.view.addConstraints([leftCollectionViewEdgeConstraint,rightCollectionViewEdgeConstraint,bottomCollectionViewEdgeConstraint,hightCollectionViewConstraint])
        
        view.layoutIfNeeded()
        
        menuView.alpha = 0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            menuView.alpha = 1
        })
        
    }
    
    func hideMenu(menuView:UICollectionView){
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            menuView.alpha = 0
            }) { (completed:Bool) -> Void in
                if completed {
                    menuView.removeFromSuperview()
                }
        }
        
    }
    
    
    @IBAction func onFilters(sender: UIButton) {
        
        if isColorsButtonOn{
            hideMenu(colorsCollectionView)
            isColorsButtonOn = !isColorsButtonOn
        }
        
        if isFilterButtonOn {
            hideMenu(filtersCollectionView)
        }else{
            showMenu(filtersCollectionView)
        }
        isFilterButtonOn = !isFilterButtonOn
        //sender.selected = sender.selected ? false:true
    }
    
    
    func applyFilter(filter:Filter){
        titleLabe.text = "Applying Filter..."
        indicator.hidden = false
        indicator.startAnimating()
        queue.addOperationWithBlock { () -> Void in
            let inputImage = CIImage(image: self.originalImage!)
            let output = filter(inputImage!)
            let ciContext = CIContext(options: [:])
            let cgImage = ciContext.createCGImage(output, fromRect: output.extent)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.titleLabe.text = "Photo Editor"
                self.indicator.hidden = true
                self.indicator.stopAnimating()
                self.photoView.imageView.image = UIImage(CGImage: cgImage).fixOrientation()
            })
        }
    }
    
    @IBAction func onColors(sender: UIButton) {
        
        if isFilterButtonOn{
            hideMenu(filtersCollectionView)
            isFilterButtonOn = !isFilterButtonOn
        }
        
        if isColorsButtonOn {
            hideMenu(colorsCollectionView)
        }else{
            titleLabe.text = "Extract Colors..."
            indicator.hidden = false
            indicator.startAnimating()
            queue.addOperationWithBlock { () -> Void in
                let (background, primary, secondary, detail) = (self.photoView.imageView.image!.colors())
                self.colorsPalette = [background, primary, secondary, detail]
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.titleLabe.text = "Photo Editor"
                    self.indicator.hidden = true
                    self.indicator.stopAnimating()
                    self.showMenu(self.colorsCollectionView)
                    self.colorsCollectionView.reloadData()
                })
            }
        }
        isColorsButtonOn = !isColorsButtonOn
        //sender.selected = sender.selected ? false:true
    }
    
    @IBAction func onSavePalette(sender: AnyObject) {
        
        // save alert
        let alert = UIAlertController(title: "Save", message: "Do You Want to save this Palette?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let coreDataStack = CoreDataStack.defaultStack
            let palette = NSEntityDescription.insertNewObjectForEntityForName("Palette", inManagedObjectContext: coreDataStack.managedObjectContext) as! Palette
            palette.date = NSDate()
            palette.background = self.colorsPalette[0].hex(withPrefix: true)
            palette.primary = self.colorsPalette[1].hex(withPrefix: true)
            palette.secondary = self.colorsPalette[2].hex(withPrefix: true)
            palette.detail = self.colorsPalette[3].hex(withPrefix: true)
            coreDataStack.saveContext()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler:nil))
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func onShare(sender:AnyObject) {
        let sharingImage = photoView.imageView.image
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", sharingImage!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
}

extension EditorViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filtersCollectionView {
            return self.filtersStore.count
        }else{
            return self.colorsPalette.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == filtersCollectionView {
            let filterCell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCellID", forIndexPath: indexPath) as! FilterCollectionViewCell
            let image = UIImage(named: "preview")
            let filter = self.filtersStore[indexPath.row].filter
            queue.addOperationWithBlock { () -> Void in
                let inputImage = CIImage(image: image!)
                let output = filter(inputImage!)
                let ciContext = CIContext(options: [:])
                let cgImage = ciContext.createCGImage(output, fromRect: output.extent)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    filterCell.image = UIImage(CGImage: cgImage).fixOrientation()
                })
            }
            return filterCell
        }else{
            let colorCell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCellID", forIndexPath: indexPath) as! ColorCollectionViewCell
            let color = self.colorsPalette[indexPath.row]
            colorCell.backgroundColor = color
            colorCell.hexLabel.text = color.hex(withPrefix: true)
            return colorCell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind , withReuseIdentifier: "HeaderID", forIndexPath: indexPath) as! SavePaletteCollectionReusableView
            reusableView = header
        }
        return reusableView
    }
}

extension EditorViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == filtersCollectionView{
            currentFilter = filtersStore[indexPath.row].filter
            applyFilter(currentFilter)
            
        }else{
            let alert = UIAlertController(title: "Copying?", message: "Do You Want to Copying Hex Color To Clipboard", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action:UIAlertAction) -> Void in
                let pasteboard = UIPasteboard.generalPasteboard()
                pasteboard.string = self.colorsPalette[indexPath.row].hex()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler:nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        UIView.animateWithDuration(1) { () -> Void in
            cell.alpha = 1
        }
    }
    
}

