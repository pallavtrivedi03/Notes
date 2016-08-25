//
//  NotesViewController.swift
//  Notes
//
//  Created by Pallav Trivedi on 22/08/16.
//  Copyright © 2016 CodeIt. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    enum CellMode
    {
        case Shake
        case Stable
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var notesCollectionView: UICollectionView!
    var notes = [NSManagedObject]()
    var appDelegate:AppDelegate!
    var managedContext:NSManagedObjectContext!
    var fetchRequest:NSFetchRequest!
    var cellMode:CellMode!
    var titleOfCellToBeDeleted:String?
    @IBOutlet weak var deletionDoneButton: UIBarButtonItem!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cellMode = .Stable
    }
    
    override func viewWillAppear(animated: Bool)
    {
        deletionDoneButton.title = ""
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        fetchRequest = NSFetchRequest(entityName: "Note")
        do
        {
            let noteResults = try managedContext.executeFetchRequest(fetchRequest)
            notes = noteResults as! [NSManagedObject]
        }catch let error as NSError
        {
            print("Cannot fetch data \(error)")
        }
        notesCollectionView.reloadData()
    }
    
    @IBAction func didLongPressOccurred(sender: AnyObject)
    {
        cellMode = .Shake
        deletionDoneButton.title = "Cancel"
        addButton.title = ""
        notesCollectionView.reloadData()
    }
    
    @IBAction func didClickOnDeletionDone(sender: AnyObject)
    {
        deletionDoneButton.title = ""
        addButton.title = "✚"
        cellMode = .Stable
        notesCollectionView.reloadData()
    }
    
    func deleteRecord(tag:Int)
    {
        
        let noteToDelete = notes[tag]
        notes.removeAtIndex(tag)
        managedContext.deleteObject(noteToDelete)
        do
        {
            try managedContext.save()
        }catch let error as NSError
        {
            print(error)
        }
        if notes.count == 0
        {
            cellMode = .Stable
            deletionDoneButton.title = ""
            addButton.title = "✚"
        }
    }
    
    func perfomDeleteAnimation(cell:NoteCell)
    {
        cell.alpha = 1.0;
        let cellFrame = cell.frame
        
        var viewOrigin = cell.frame.origin
        viewOrigin.y = viewOrigin.y + cellFrame.size.height / 2.0
        viewOrigin.x = viewOrigin.x + cellFrame.size.width / 2.0
        
        cell.layer.position = viewOrigin;
        
        let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
        fadeOutAnimation.toValue = 0.3
        fadeOutAnimation.fillMode = kCAFillModeForwards
        fadeOutAnimation.removedOnCompletion = false
        
        let resizeAnimation = CABasicAnimation.init(keyPath: "bounds.size")
        resizeAnimation.toValue = NSValue.init(CGSize: CGSizeMake(40.0, cellFrame.size.height * (40.0 / cellFrame.size.width)))
        resizeAnimation.fillMode = kCAFillModeForwards
        resizeAnimation.removedOnCompletion = false
        
        let pathAnimation = CAKeyframeAnimation.init(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        
        let endPointX = UIScreen.mainScreen().bounds.width - (UIScreen.mainScreen().bounds.width)/2
        let endPoint = CGPointMake(endPointX, 760.0);
        
        let curvedPath = CGPathCreateMutable();
        CGPathMoveToPoint(curvedPath, nil, viewOrigin.x, viewOrigin.y);
        CGPathAddCurveToPoint(curvedPath, nil, endPoint.x, viewOrigin.y, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
        pathAnimation.path = curvedPath;
        
        
        let group = CAAnimationGroup()
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = false;
        group.animations = [fadeOutAnimation,pathAnimation,resizeAnimation]
        group.duration = 0.7;
        group.delegate = self;
        group.setValue(cell, forKey: "noteCellBeingDeleted")
        cell.layer.addAnimation(group, forKey: "savingAnimation")
        
    }
    
    func performShakeAnimation(cell:NoteCell)
    {
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.rotation")
        shakeAnimation.toValue = 0.0
        shakeAnimation.fromValue = M_PI/64
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = FLT_MAX
        shakeAnimation.autoreverses = true
        cell.layer.shouldRasterize = true
        cell.layer.addAnimation(shakeAnimation, forKey: "noteCellsShaking")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//Mark: CollectionView delegate,datasource
extension NotesViewController:UICollectionViewDataSource,UICollectionViewDelegate
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return notes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
        let note = notes[indexPath.row]
        cell.delegate = self
        cell.titleLabel.text = note.valueForKey("title") as? String
        cell.messageLabel.text = note.valueForKey("message") as? String
        cell.dateLabel.text = note.valueForKey("lastModifiedOn") as? String
        cell.deleteButton.tag = indexPath.row
        
        cellMode == .Shake ? (cell.deleteButton.hidden = false) : (cell.deleteButton.hidden = true)
        if cellMode == .Shake
        {
           self.performShakeAnimation(cell)
        }
        
        if cell.titleLabel.text == titleOfCellToBeDeleted
        {
            self.perfomDeleteAnimation(cell)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let note = notes[indexPath.row]
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let detailsViewController = storyBoard.instantiateViewControllerWithIdentifier("NotesDetailVC") as! NotesDetailViewController
        detailsViewController.getNoteModal(note)
        self.navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

//MARK: - NoteCellDelegate
extension NotesViewController:NoteCellDelegate
{
    func didClickOnDeletebutton(tag: Int)
    {
        let indexPath = NSIndexPath(forRow: tag, inSection: 0)
        let cell = self.notesCollectionView.cellForItemAtIndexPath(indexPath) as! NoteCell
        titleOfCellToBeDeleted = cell.titleLabel.text!
        notesCollectionView.reloadData()
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
//            self.deleteRecord(tag)
//        })
        
        
    }
}
