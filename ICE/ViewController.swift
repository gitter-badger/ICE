//
//  ViewController.swift
//  ICE
//
//  Created by Felix Gruber on 25.03.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{
    var numbers = [String]()
    var persondata: PersonData?
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let personDataRequest = NSFetchRequest(entityName: "PersonData")
    let numbersRequest = NSFetchRequest(entityName: "NumberString")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self;
        tableView.delegate = self;
        loadPersonDataFromDB()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadPersonDataFromDB()
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        cell!.textLabel!.text = numbers[indexPath.row]
        cell!.textLabel!.numberOfLines = 2
        return cell!
    }
    
    func loadPersonDataFromDB(){
        var error: NSError?
        var recordCount = context!.countForFetchRequest(personDataRequest, error: &error)
        var fetchedResults: [NSManagedObject]? = nil;
        if(recordCount>0){
            do{
                fetchedResults = try context!.executeFetchRequest(personDataRequest) as? [NSManagedObject]
            }catch _{}
            if let results = fetchedResults {
                persondata = results[0] as? PersonData
                if persondata != nil{
                    firstName.text = persondata!.firstName
                    lastName.text = persondata!.lastName
                    if let temp = UIImage(data: persondata!.img as NSData){
                        imageView.image = temp
                    }
                }
                
            }
        }
        
        recordCount = context!.countForFetchRequest(numbersRequest, error: &error)
        if(recordCount>0){
            do{
                fetchedResults = try context!.executeFetchRequest(numbersRequest) as? [NSManagedObject]
            }catch _{}
            if let results = fetchedResults {
                numbers.removeAll(keepCapacity: false)
                for result in results {
                    addNumber((result as! NumberString).number)
                }
            }
        }else{
            numbers = ["here will be the numbers you choose","they will show up on the homescreen in this order","swipe left to remove"]
        }
    }
    
    func addNumber(number: String){
        if !numbers.contains(number){
            numbers.append(number)
        }
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue){ /*kinda useless*/ }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            numbers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        var fetchedResults: [NSManagedObject]? = nil
        do{
            fetchedResults = try context!.executeFetchRequest(numbersRequest) as? [NSManagedObject]
        }catch _{}
        if let results = fetchedResults {
            for result in results {
                context!.deleteObject(result as NSManagedObject)
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
        
        for num in numbers {
            (NSEntityDescription.insertNewObjectForEntityForName("NumberString", inManagedObjectContext: context!) as! NumberString).number=num
            do {
                try context!.save()
            } catch _ {
            }
        }
        
        // save to userdefaults
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.at.fhooe.mc.MOM4.ICE")!
        defaults.setObject(numbers, forKey: "numbers")
        if persondata != nil{
            defaults.setObject(persondata!.firstName + " " + persondata!.lastName, forKey: "name")
            defaults.setObject(persondata!.bloodType, forKey: "bloodtype")
            defaults.setObject(persondata!.medHist, forKey: "medhist")
            defaults.setObject(persondata!.allergies, forKey: "allergies")
        }
        defaults.synchronize()
    }
}