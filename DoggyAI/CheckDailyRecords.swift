//
//  CheckDailyRecords.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-08.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit


class CheckDailyRecords:  UIViewController,EPCalendarPickerDelegate {

    
    @IBOutlet var DogTableList: UITableView!
    
    var date1:NSDate! // this is the date we want to get our activity for
    var mydoglist:[String] = []  // a list of all the slugs that I'm an owner of from cloudkit
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userslug: String = "" //the slug we got from the registration program
    var userrecord:CKRecordID! //the user recordID we got from registration program
    let activityrecord = CKRecord(recordType: "ActivityRecord")
    let dogRecord = CKRecord(recordType: "Dogs")
    var dogcount:Int = 0 // number of dogs returned from the owner
    
    @IBOutlet var selecteddatelabel: UILabel!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // go list all my dogs using my userslug that was passed to us
        // then select a dog and then select a date, then go get that record
        
        getdoglist()
        
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self,
                                               selector: #selector(CheckDailyRecords.updateData), userInfo: nil, repeats: true)
       
             }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func updateData () {
        //update table data
        self.DogTableList.reloadData()
    
    }
    
    func getdoglist ()  {
        //grab all the records from Dogs that have my owner slug
        //let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", userslug)
        //let name = "99745d34-0731-4f43-9285-58026b424e15"
        //let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", name)
       
    
        let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", self.userslug)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler:  { results, error in
            if let err = error {
                print ("Error with query: \(err)")
            }
           // print (results)
            if results?.count == 0 {
                print ("Owner has no dogs")
                
            }
                
            else {
                self.dogcount = (results?.count)!
                print ("Total number of dogs = \(self.dogcount)")
                for dogs in results! {
                    let dogslug = (dogs["slug"]!)
                    print("Dog: \(dogslug)")
                    self.mydoglist.append(dogslug as! String)
                   
                }
               // print ("User record \(self.userslug) was in CloudKit")
               // print("so lets check to see if it was changed since last checked ")
                
            }
            
        })
 
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print ("Table rows: \(self.dogcount)")
        //DogTableList
        return self.dogcount
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) ->Int
    {
    return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "dogslugcell", forIndexPath: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = self.mydoglist[indexPath.row]
        
        return cell
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "dailydetail"
        {
            let detailViewController = ((segue.destinationViewController) as! CheckDailyRecords)
            //let indexPath = self.tvCars!.indexPathForSelectedRow!
            //let strImageName = car[indexPath.row]
           // detailViewController.strImageName = strImageName
          //  detailViewController.title = strImageName
            print("move to details")
        }
    }
    
    
    
    @IBAction func PickDate(sender: UIButton) {
        
        print ("show calendar")
        let calendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: false, selectedDates: [])
        calendarPicker.calendarDelegate = self
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = true
        calendarPicker.tintColor = UIColor.orangeColor()
        //        calendarPicker.barTintColor = UIColor.greenColor()
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        calendarPicker.title = "Activity Date"
        //        calendarPicker.backgroundImage = UIImage(named: "background_image")
        //        calendarPicker.backgroundColor = UIColor.blueColor()
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        print ( "User cancelled selection")
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        print ("User selected date: \n\(date)")
          self.date1 = date
    }
    
}
