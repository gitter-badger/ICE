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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell.textLabel!.text = numbers[indexPath.row]
        cell.textLabel!.numberOfLines = 2
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func loadPersonDataFromDB(){
        var error: NSError?
        var recordCount = context!.countForFetchRequest(personDataRequest, error: &error)
        var fetchedResults = context!.executeFetchRequest(personDataRequest, error: &error) as! [NSManagedObject]?
        if let results = fetchedResults {
            for result in results {
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
            fetchedResults = context!.executeFetchRequest(numbersRequest, error: &error) as! [NSManagedObject]?
            if let results = fetchedResults {
                numbers.removeAll(keepCapacity: false)
                for result in results {
                    var number = result as! NumberString
                    addNumber(number.number)
                }
            }
        }else{
            numbers = ["here will be the numbers you choose","they will show up on the homescreen in this order","swipe left to remove"]
        }
    }
    
    func addNumber (number: String){
        if !contains(numbers,number){
            numbers.append(number)
        }
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue){ // kinda useless
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            numbers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        var error: NSError?
        let fetchedResults = context!.executeFetchRequest(numbersRequest, error: &error) as! [NSManagedObject]?
        if let results = fetchedResults {
            for result in results {
                context!.deleteObject(result as NSManagedObject)
            }
        }
        context!.save(nil)
        
        for num in numbers {
            var entry = NSEntityDescription.insertNewObjectForEntityForName("NumberString", inManagedObjectContext: context!) as! NumberString
            entry.number = num
            context!.save(nil)
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