//
//  CheckDailyRecords.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-08.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit


class CheckDailyRecords: UIViewController,EPCalendarPickerDelegate {

    var date1:NSDate! // this is the date we want to get our activity for
    var mydoglist:[String] = []  // a list of all the slugs that I'm an owner of from cloudkit
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userslug: String! //the slug we got from the registration program
    var userrecord:CKRecordID! //the user recordID we got from registration program
    let activityrecord = CKRecord(recordType: "ActivityRecord")
    let dogRecord = CKRecord(recordType: "Dogs")
    
    @IBOutlet var selecteddatelabel: UILabel!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // go list all my dogs using my userslug that was passed to us
        // then select a dog and then select a date, then go get that record
        
        getdoglist()
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

    func getdoglist ()  {
        //grab all the records from Dogs that have my owner slug
        //let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", userslug)
      //  let name = "99745d34-0731-4f43-9285-58026b424e15"
       //  let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", name)
        let mytempstring:String = "\(userslug) ";
        print (mytempstring)
        let predicate = NSPredicate(format: "owner_slug BEGINSWITH %@", mytempstring)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        
     //  99745d34-0731-4f43-9285-58026b424e15
     //  99745d34-0731-4f43-9285-58026b424e15
      //  let reference = CKReference(recordID: userrecord, action: .None)
  //      let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
  //      let query = CKQuery(recordType: "Dogs", predicate: predicate)
        
        
        print ("Query: \(query)")
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler:  { results, error in
            if let err = error {
                print ("Error with query: \(err)")
            }
            print (results)
            if results?.count == 0 {
                print ("Owner has no dogs")
                
            }
                
            else {
                print ("Dog record \(self.userslug) was in CloudKit")
                print("so lets check to see if it was changed since last checked ")
            }
        })
    
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
