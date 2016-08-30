//
//  NotesDetailViewController.swift
//  Notes
//
//  Created by Pallav Trivedi on 24/08/16.
//  Copyright © 2016 CodeIt. All rights reserved.
//

import UIKit
import CoreData

class NotesDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    let existingNote = Note()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(NotesDetailViewController.didClickOnSaveButton(_:))), animated: true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        titleTextField.text = existingNote.title
        detailTextView.text = existingNote.message
        self.navigationItem.rightBarButtonItem?.tintColor = colorFromHexString("#FF8000")
        self.navigationController?.navigationBar.tintColor = colorFromHexString("#FF8000")
    }
    func didClickOnSaveButton(sender:UIBarButtonItem) -> Void
    {
        
        let note = Note()
        note.title = self.titleTextField.text!
        note.message = self.detailTextView.text!
        note.lastModifiedOn = String(NSDate())
        let status = self.saveNoteToDB(note)
        status == true ? print("Saved") : print("cant save")
        
        if let navController = self.navigationController
        {
            navController.popViewControllerAnimated(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveNoteToDB(noteModal:Note) -> Bool
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let noteEntity = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedContext)
        if (existingNote.id != nil)
        {
            let predicate = NSPredicate(format: "SELF = %@" ,existingNote.id!)
            let request = NSFetchRequest(entityName:"Note")
            request.predicate = predicate
            do
            {
                let results = try managedContext.executeFetchRequest(request)
                let resultNotes = results as! [NSManagedObject]
                let note = resultNotes[0]
                note.setValue(noteModal.title, forKey: "title")
                note.setValue(noteModal.message, forKey: "message")
                note.setValue(noteModal.lastModifiedOn, forKey: "lastModifiedOn")
                do
                {
                    try managedContext.save()
                }catch let error as NSError
                {
                    print(error)
                    return false
                }
                
            }
            catch
            {
                
            }
            

        }
        else
        {
        
        let note = NSManagedObject(entity: noteEntity!,insertIntoManagedObjectContext: managedContext)
        
        note.setValue(noteModal.title, forKey: "title")
        note.setValue(noteModal.message, forKey: "message")
        note.setValue(noteModal.lastModifiedOn, forKey: "lastModifiedOn")
        
        do
        {
            try managedContext.save()
        }catch let error as NSError
        {
            print(error)
            return false
        }
        }
        return true
    }
    
    func getNoteModal(modal:NSManagedObject) -> Void
    {
        existingNote.title = modal.valueForKey("title") as? String
        existingNote.message = modal.valueForKey("message") as? String
        existingNote.id = modal.objectID
    }
    
}
