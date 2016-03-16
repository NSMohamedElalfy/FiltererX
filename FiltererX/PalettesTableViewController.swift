//
//  PalettesTableViewController.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/6/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

import UIKit
import CoreData

class PalettesTableViewController: UITableViewController {
    
    
    weak var delegate:ReSetupCaptureSessionDelegate?
    var colorsPalettes = [Palette]()
    
    lazy var fetchedResultController : NSFetchedResultsController = {
        let coreDataStack = CoreDataStack.defaultStack
        let fetchRequest  = self.entryListFetchRequest()
        let _fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil , cacheName: nil)
        _fetchedResultController.delegate = self
        return _fetchedResultController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        do{
            try fetchedResultController.performFetch()
            self.colorsPalettes = fetchedResultController.fetchedObjects as! [Palette]
        }catch{
            print("error : in fetching results from core Data Stack")
        }
    }
    
    func entryListFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName: "Palette")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return fetchRequest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.delegate?.reSetupCaptureSession()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Table view DataSource & Delegate Protocols
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let count = self.fetchedResultController.sections?.count else {
            return 1
        }
        return count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionsInfo = self.fetchedResultController.sections else {
            return 0
        }
        return sectionsInfo[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PaletteCellID", forIndexPath: indexPath) as! PaletteTableViewCell
        
        let palette = self.fetchedResultController.objectAtIndexPath(indexPath) as! Palette
        
        cell.colorsPalette = [palette.background! , palette.primary! , palette.secondary! , palette.detail!]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /*override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }*/
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //colorsPalettes.removeAtIndex(indexPath.row)
            let palette = self.fetchedResultController.objectAtIndexPath(indexPath) as! Palette
            let coreDataStack = CoreDataStack.defaultStack
            coreDataStack.managedObjectContext.deleteObject(palette)
            coreDataStack.saveContext()
        }
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.setEditing(false, animated: true)
        self.editing = false
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Social Sharing Button
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Share", handler: { (action, indexPath) -> Void in
            
            let palette = self.colorsPalettes[indexPath.row]
            let activityController = UIActivityViewController(activityItems: ["Check out this really cool Palette :", "\(palette.background!),\(palette.primary!),\(palette.secondary!),\(palette.detail!)"], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
    
        })
        
        // Delete button
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete",handler: { (action, indexPath) -> Void in
            
            // Delete the row from the database
            let palette = self.fetchedResultController.objectAtIndexPath(indexPath) as! Palette
            let coreDataStack = CoreDataStack.defaultStack
            coreDataStack.managedObjectContext.deleteObject(palette)
            coreDataStack.saveContext()
        })
        
        // Set the button color
        shareAction.backgroundColor = UIColor.hex("#4F5D73")
        deleteAction.backgroundColor = UIColor.hex("#c75c5c")
        return [deleteAction, shareAction]
    }
    
    
    
}

extension PalettesTableViewController : NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        default :
            tableView.reloadData()
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

