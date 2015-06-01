//
//  personDetailViewViewController.swift
//  ICE
//
//  Created by Felix Gruber on 28.03.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import UIKit
import CoreData

class personEditDetailsVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "PersonData")
    var data = [PersonData]()
    var entry: PersonData?
    
    @IBOutlet weak var textFirstName: UITextField!
    @IBOutlet weak var textLastName: UITextField!
    @IBOutlet weak var textBloodType: UITextField!
    @IBOutlet weak var textAllergies: UITextField!
    @IBOutlet weak var textMedHist: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromDB()
        var tgr = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        imageView.addGestureRecognizer(tgr)
    }
    
    func imageTapped(img: AnyObject){
        let alert = UIAlertController(title: "choose source", message: nil, preferredStyle:
            .ActionSheet)
        
        /*
        let cameraAction = UIAlertAction(title: "camera", style: .Default) { (action) -> Void in
        self.showPhotoPicker(.Camera)
        }
        
        alert.addAction(cameraAction)
        */
        
        let libraryAction = UIAlertAction(title: "library", style: .Default) { (action) -> Void in
            self.showPhotoPicker(.PhotoLibrary)
        }
        
        alert.addAction(libraryAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        /* batch update
        var batchRequest = NSBatchUpdateRequest(entityName: "PersonData")
        batchRequest.propertiesToUpdate = ["firstName": textFirstName.text, "lastName": textLastName.text, "medHist": textMedHist.text, "allergies": textAllergies.text, "bloodType": textBloodType.text]
        batchRequest.resultType = NSBatchUpdateRequestResultType.UpdatedObjectsCountResultType
        var error : NSError?
        var results = context!.executeRequest(batchRequest, error: &error) as! NSBatchUpdateResult
        NSLog("updated objects: \(results.result)")
        */
        
        var error: NSError?
        let fetchedResults = context!.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        if let results = fetchedResults {
            for result in results {
                context!.deleteObject(result as NSManagedObject)
            }
        }
        context!.save(nil)
        
        entry = NSEntityDescription.insertNewObjectForEntityForName("PersonData", inManagedObjectContext: context!) as? PersonData
        if entry != nil{
            entry!.firstName = textFirstName.text
            entry!.lastName = textLastName.text
            entry!.medHist = textMedHist.text
            entry!.allergies = textAllergies.text
            entry!.bloodType = textBloodType.text
            entry!.img = UIImageJPEGRepresentation(imageView.image, 1)
            context!.save(nil)
            
            // save to userdefaults
            let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.at.fhooe.mc.MOM4.ICE")!
            
            defaults.setObject(entry!.firstName + " " + entry!.lastName, forKey: "name")
            defaults.setObject(entry!.bloodType, forKey: "bloodtype")
            defaults.setObject(entry!.medHist, forKey: "medhist")
            defaults.setObject(entry!.allergies, forKey: "allergies")
            defaults.synchronize()
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func loadDataFromDB(){
        var error : NSError?
        let recordCount = context!.countForFetchRequest(fetchRequest, error: &error)
        let fetchedResults = context!.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        if let results = fetchedResults {
            for result in results {
                var person = result as! PersonData
                textFirstName.text = person.firstName
                textLastName.text = person.lastName
                textBloodType.text = person.bloodType
                textAllergies.text = person.allergies
                textMedHist.text = person.medHist
                let temp = UIImage(data: person.img as NSData)
                imageView.image = temp
            }
        }
    }
    
    @IBAction func linkToDBButtonTouched(sender: UIButton) {
        NSLog("link to dropbox touched")
        let accMan = DBAccountManager.sharedManager()
        if((accMan) != nil){
            accMan.linkFromController(self)
            NSLog("account linked")
        }else{
            NSLog("accountManager was nil - not linked")
        }
    }
    
    func showPhotoPicker(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
    }
}