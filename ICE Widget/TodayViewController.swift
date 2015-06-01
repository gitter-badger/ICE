//
//  TodayViewController.swift
//  ICE Widget
//
//  Created by Felix Gruber on 01.06.15.
//  Copyright (c) 2015 Felix Gruber. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelNumbers: UILabel!
    @IBOutlet weak var labelBloodType: UILabel!
    @IBOutlet weak var labelAllergies: UILabel!
    @IBOutlet weak var labelMedHist: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaults();
    }
    
    override func viewWillAppear(animated: Bool) {
        loadDefaults();
    }
    
    override func viewDidAppear(animated: Bool) {
        loadDefaults();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        loadDefaults();
        completionHandler(NCUpdateResult.NewData)
    }
    
    func loadDefaults(){
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.at.fhooe.mc.MOM4.ICE")!
        if let name = defaults.stringForKey("name"){
            labelName.text = name
        }
        if let bloodtype = defaults.stringForKey("bloodtype"){
            labelBloodType.text = bloodtype
        }
        if let allergies = defaults.stringForKey("allergies"){
            labelAllergies.text = allergies
        }
        if let medhist = defaults.stringForKey("medhist"){
            labelMedHist.text = medhist
        }
        if let numbers = defaults.stringArrayForKey("numbers") as? [String] {
            labelNumbers.text = "\n".join(numbers)
        }
    }
}
