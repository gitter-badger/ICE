//
//  personDetailViewViewController.swift
//  ICE
//
//  Created by Felix Gruber on 28.03.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import UIKit
import CoreData

class personEditDetailsVC: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate{
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "PersonData")
    var data = [PersonData]()
    var entry: PersonData?
    let libraryPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    let TEXTFIELD_PLUS_SPACE: CGFloat = 38
    let MOVE_BASE: CGFloat = 15
    
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
        libraryPicker.delegate = self
        cameraPicker.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        textFirstName.delegate = self
        textLastName.delegate = self
        textBloodType.delegate = self
        textAllergies.delegate = self
        textMedHist.delegate = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func imageTapped(img: AnyObject){
        let alert = UIAlertController(title: "choose source", message: nil, preferredStyle:
            .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "camera", style: .Default) { (action) -> Void in
            self.shootPhoto()
            })
        
        alert.addAction(UIAlertAction(title: "library", style: .Default) { (action) -> Void in
            self.showPhotoPicker(.PhotoLibrary)
            })
        
        alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        
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
            
            // NSOperationQueue.mainQueue().addOperationWithBlock(<#block: () -> Void##() -> Void#>)
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
    
    /*
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
    */
    
    func showPhotoPicker(source: UIImagePickerControllerSourceType) {
        presentViewController(libraryPicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shootPhoto() {
        cameraPicker.allowsEditing = false
        cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
        cameraPicker.cameraCaptureMode = .Photo
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //self.view.frame.origin.y -= 50 //keyboardFrame.height
    }
    
    func keyboardWillHide(notification: NSNotification){
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //self.view.frame.origin.y += 50 //keyboardFrame.height
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch(textField){
        case textFirstName:
            self.view.frame.origin.y -= MOVE_BASE
            
        case textLastName:
            self.view.frame.origin.y -= MOVE_BASE+TEXTFIELD_PLUS_SPACE
            
        case textBloodType:
            self.view.frame.origin.y -= MOVE_BASE+2*TEXTFIELD_PLUS_SPACE
            
        case textAllergies:
            self.view.frame.origin.y -= MOVE_BASE+3*TEXTFIELD_PLUS_SPACE
            
        case textMedHist:
            self.view.frame.origin.y -= MOVE_BASE+4*TEXTFIELD_PLUS_SPACE
            
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch(textField){
        case textFirstName:
            self.view.frame.origin.y += MOVE_BASE
            
        case textLastName:
            self.view.frame.origin.y += MOVE_BASE+TEXTFIELD_PLUS_SPACE
            
        case textBloodType:
            self.view.frame.origin.y += MOVE_BASE+2*TEXTFIELD_PLUS_SPACE
            
        case textAllergies:
            self.view.frame.origin.y += MOVE_BASE+3*TEXTFIELD_PLUS_SPACE
            
        case textMedHist:
            self.view.frame.origin.y += MOVE_BASE+4*TEXTFIELD_PLUS_SPACE
            
        default:
            break
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        textFirstName.resignFirstResponder()
        textLastName.resignFirstResponder()
        textBloodType.resignFirstResponder()
        textAllergies.resignFirstResponder()
        textMedHist.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"{
            switch(textField){
            case textFirstName:
                textLastName.becomeFirstResponder()
                
            case textLastName:
                textBloodType.becomeFirstResponder()
                
            case textBloodType:
                textAllergies.becomeFirstResponder()
                
            case textAllergies:
                textMedHist.becomeFirstResponder()
                
            case textMedHist:
                textFirstName.becomeFirstResponder()
                
            default:
                break
            }
        }
        return true
    }
}