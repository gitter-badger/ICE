//
//  contactsTVC.swift
//  ICE
//
//  Created by Felix Gruber on 25.03.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import UIKit
import AddressBook
import CoreData

class contactsTVC: UITableViewController {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let numbersRequest = NSFetchRequest(entityName: "NumberString")
    var chosenNr: String? = nil
    
    struct Person{
        var name: String
        var numbers: [String]
        
        init(name: String, numbers: [String]){
            self.name = name
            self.numbers = numbers
        }
    }
    
    var src: [Person] = []
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            println("authorized")
            self.readFromAddressBook(addressBook)
            tableView.reloadData()
            
        case .Denied:
            println("denied")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook, {[weak self] (granted: Bool, error: CFError!) in
                if granted{
                    let strongSelf = self!
                    println("user granted")
                    strongSelf.readFromAddressBook(strongSelf.addressBook)
                    strongSelf.tableView.reloadData()
                } else {
                    println("user denied")
                }
                })
            
        case .Restricted:
            println("restricted")
            
        default:
            println("unhandled")
        }
    }
    
    func readFromAddressBook(addressBook: ABAddressBookRef){
        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        src = []
        
        for personRef: ABRecordRef in allPeople{
            let name = ABRecordCopyCompositeName(personRef).takeRetainedValue() as String
            var numbers: [String] = []
            let unmanagedPhones = ABRecordCopyValue(personRef, kABPersonPhoneProperty)
            let phones: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValueRef
            
            let countOfPhones = ABMultiValueGetCount(phones)
            for index in 0..<countOfPhones{
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                let phone: String = Unmanaged.fromOpaque(
                    unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                numbers.append(phone)
            }
            src.append(Person(name: name, numbers: numbers))
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return src.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = src[indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var alert = MyAlertController(title: src[indexPath.row].name, message: "choose the number to add", preferredStyle: UIAlertControllerStyle.Alert)
        
        for num in src[indexPath.row].numbers{
            alert.addAction(UIAlertAction(title: "add \(num)", style: .Default, handler: { action -> Void in
                self.chosenNr = num
                self.performSegueWithIdentifier("unwindSegue", sender: self)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        var error: NSError?
        if(chosenNr != nil){
            var entry = NSEntityDescription.insertNewObjectForEntityForName("NumberString", inManagedObjectContext: context!) as! NumberString
            entry.number = chosenNr!
            context!.save(nil)
        }else{
            println("choosing of number didn't work")
        }
    }
}