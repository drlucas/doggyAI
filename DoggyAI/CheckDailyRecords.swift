//
//  CheckDailyRecords.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-08.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit
import OAuthSwift

class CheckDailyRecords:  UIViewController,EPCalendarPickerDelegate {

    
    @IBOutlet var DogTableList: UITableView!
    
     var passedtoken: String! //for authentication 
    
    var date1:NSDate! // this is the date we want to get our activity for
    var mydoglist:[String] = []  // a list of all the slugs that I'm an owner of from cloudkit
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userslug: String = "" //the slug we got from the registration program
    var userrecord:CKRecordID! //the user recordID we got from registration program
    let activityrecord = CKRecord(recordType: "ActivityRecord")
    let dogRecord = CKRecord(recordType: "Dogs")
    var dogcount:Int = 0 // number of dogs returned from the owner
      var my_fitbarkpts:Int = 0 //used to return a total
    var my_minacttotal:Int = 0
    @IBOutlet var selecteddatelabel: UILabel!
   
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
    
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
    
    //Since the dog's activity for the date selected is NOT in icloud, we need to go try to pull it from the fitbark website and then save it as a record - send in dogslug and date
    
    func getFitBarkDogActivity(dogslug: String, thedate: NSDate,
                          completion: (return_result: Int) -> Void)  //return_result = 1 have records
        
    {
        //get dog activity based on two dates https://app.fitbark.com/api/v2/activity_series
        /*
         {"activity_series":{
         "slug":"1ba28be9-4e9e-4583-b7d8-b6bb84b17da7",  //Archie's slug
         "from":"2013-03-02",
         "to":"2014-09-02",
         "resolution":"DAILY"
         }}
         {"activity_series" =     {
         records =         (
         {
         "activity_value" = 49;
         date = "2016-04-01 00:00:00";
         "min_active" = 13;
         
         ActivityRecord (cloudkit record format - )
         activity_list - Int(64) List
         date - Date/Time
         minute_activity_list - Int(64) List
         minute_play_list - Int(64) List
         minute_rest_list - Int(64) List
         slug - String
    
         */
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let date1 = dayTimePeriodFormatter.stringFromDate(thedate)
        let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
        let jsonparameters = ["activity_series":
            ["slug": "\(dogslug)",
                "from":"\(date1)",
                 "to":"\(date1)",
                "resolution":"HOURLY"
            ]
        ]
        
        //var daily_goals = [DailyGoal] () // an array that will contain all our daily goals
        oauthswift.client.credential.oauth_token = self.passedtoken
       
        oauthswift.client.post(dogactivityURL, parameters: jsonparameters, headers: ["Content-Type":"application/json"],        success: { data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers)
            
            if let dict = jsonDict as? [String: AnyObject] {
                
                var play_list: [Int] =  []
                var rest_list: [Int] =  []
                var active_list: [Int] =  []
                var date_time_list: [String] =  []
                var fitbarkpoints_list: [Int] =  []
                
                if let actseries = dict["activity_series"]!["records"] as? [AnyObject] {
                
                   
                    for (index, dict2) in actseries.enumerate() {
                        let fbp_value = dict2["activity_value"] as? Int
                        let act_date = dict2["date"] as? String
                        let min_active_value = dict2["min_active"] as? Int
                        let min_play_value = dict2["min_play"] as? Int
                        let min_rest_value = dict2["min_rest"] as? Int
                        play_list.append(min_play_value!)
                        rest_list.append(min_rest_value!)
                        active_list.append(min_active_value!)
                        fitbarkpoints_list.append(fbp_value!)
                        date_time_list.append(act_date!)
                    }
                    if (actseries.count != 24) {
                       print ( "No records")
                        // put up alert
                        SCLAlertView().showError("Error", subTitle:"No records in fitbark", closeButtonTitle:"OK")
                        
                        completion(return_result: -1 )
                    }
                    else {
                //  print (  actseries.count)
                    //Go save the record now --
                    print ("save record")
                    print (rest_list, active_list, play_list, fitbarkpoints_list, date_time_list, dogslug)
                    // let dogslug = "1ba28be9-4e9e-4583-b7d8-b6bb84b17da7"
                    CloudViewController().SaveDailyActivity(dogslug, thedate:date_time_list[0], min_active:active_list, min_play:play_list, min_rest:rest_list, fitbarkpts: fitbarkpoints_list)
                        completion(return_result: 0 )
                    }
                }
                
            
            }
            
            }, failure: { error in
                print("Bad error: \(error)")
        })
        
    }
    
    
    
    
    //check icloud for the selected date and dog record, then in completion block return info
    func GetDailyActivity(dogslug: String, thedate: NSDate,
                          completion: (return_fitbarkpts: Int, return_minacttotal: Int) -> Void)

    {
        var fitbptlist:[Int] = []   // the fitbark points we received for each hour
        var minute_active_list:[Int] = []  //the number of minutes active each hour
        var minute_play_list:[Int] = []  //the number of minutes playing each hour
        var minute_rest_list:[Int] = []  //the number of minutes resting each hour
        var minresttotal = 0
        var minacttotal = 0
        var minplaytotal = 0
        //double check before we save the record for the dog that we didn't already do it
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        //  let mydate = dateFormatter.dateFromString(startdate)
        //print("Savelist of activities - dog date is: \(thedate) and \(mydate)")
        //let adogslug = "AAAA"
        var fitbarkpts:Int = 0
      
        
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, thedate)
        let query = CKQuery(recordType: "ActivityRecord", predicate: predicate)
        //  print ("Query: \(query)")
        
        self.publicDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    //  let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                    //print ("we have a record \(records)")
                    for activity in records! {
                        fitbptlist = activity.objectForKey("fitbarkpts") as! [Int]
                        minute_active_list = activity.objectForKey("minute_active_list") as! [Int]
                        minute_rest_list = activity.objectForKey("minute_rest_list") as! [Int]
                        minute_play_list = activity.objectForKey("minute_play_list") as! [Int]
                        
                        //  print("Dog Owner  token date: \(activity["fitbarkpts"])")
                        //   fitbptlist = Intactivity["fitbarkpts"]
                    }
                   // print("List of points: \(fitbptlist)")
                    // print("MInutes of active: \(self.minute_active_list)")
                    for counter in fitbptlist {
                        fitbarkpts = fitbarkpts + counter
                    }
                    
                    for hours in minute_active_list {
                        minacttotal = minacttotal + hours
                    }
                    
                    for hours in minute_rest_list {
                        minresttotal = minresttotal + hours
                    }
                    
                    for hours in minute_play_list {
                        minplaytotal = minplaytotal + hours
                    }
                    
                   // print ("Fitbark points: \(fitbarkpts)")
                 //   return (fitbarkpts, minacttotal)
                    self.my_fitbarkpts = fitbarkpts
                    self.my_minacttotal =  minacttotal
                    completion(return_fitbarkpts:  self.my_fitbarkpts, return_minacttotal:self.my_minacttotal )

                }
                else {
                    self.my_fitbarkpts = -1
                    self.my_minacttotal =  -1
                   // print ("else - That dog has no records for that day: \(self.my_fitbarkpts)")  //we have no records
                     //from here return nadda
                    completion(return_fitbarkpts:  self.my_fitbarkpts, return_minacttotal:self.my_minacttotal )

                }
                
            }
            
        })
        //if we already have saved it, we may want to see if it changed and modify it
        // return (self.my_fitbarkpts, self.my_minacttotal)
      //  completion(return_fitbarkpts: self.my_fitbarkpts, return_minacttotal:self.my_minacttotal )
        
      //  completion(return_fitbarkpts:  self.my_fitbarkpts, return_minacttotal:self.my_minacttotal )
        
}
    


    func application(application: UIApplication!, performFetchWithCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        loadShows() {
            completionHandler(UIBackgroundFetchResult.NewData)
            print("Background Fetch Complete")
        }
    }
    
    func loadShows(completionHandler: (() -> Void)!) {
        //....
        //DO IT
        //....
        completionHandler()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // print("You selected cell #\(indexPath.row)!")
        //  let indexPath = tableView.indexPathForSelectedRow!
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! DogTableViewCell
        
        if self.date1 == nil {
            print ("No date")
        }
        else {
            // we have dog selected from table and we have a date in the past so get the dog's activity 
            print ("Date Selected: \(self.date1)")
            print ("Selected Dog: \(self.mydoglist[indexPath.row])")
            
            // check icloud for records, if records don't exist (fitbarkpts = -1) then get info from fitbark website, if records
            let activity = GetDailyActivity(self.mydoglist[indexPath.row], thedate:self.date1) {
                (return_fitbarkpts, return_minacttotal) -> () in
                 print ("fit bark points: \(return_fitbarkpts)")
                 print ("minutes of activity: \(return_minacttotal)")
                
                if (return_fitbarkpts == -1) {
                    let activityFB = self.getFitBarkDogActivity(self.mydoglist[indexPath.row], thedate:self.date1) {
                        (return_fitbarkstatus) -> () in
                        
                        print ("fit bark status \(return_fitbarkstatus)")
                        //if status =0 no errors
                        //if status =-1 there was no fitbark records
                    }
                    
            
                }
            
            
            }
            
                // still do not exist in fitbark, then we probably have no records that old, we should alert the
                // user and let them know
                //  self.mydogtopass = self.dogs[indexPath.row]
                 //   print("Fitbark Points: \(activity.return_fitbarkpts) and minutes of activity is \(activity.return_minacttotal)")
            }
        
       
            
            performSegueWithIdentifier("dailychart", sender: indexPath)
        
    }

    /*
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     if segue.identifier == "dogdailychart" {
     print ("Prepare to segue to dog daily chart screen \(thepasseddog.slug)")
     let destination = segue.destinationViewController as! DogDailyChart
     destination.dogslug = thepasseddog.slug//self.userslug
     destination.startdate = date1
     destination.enddate = date2
     }
     }
 */
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
       let today = NSDate()
        if date > today {
            print ("Can't get dog info in the future")
        }
        else {
            print ("User selected date: \n\(date)")
            self.date1 = date
            
        }
    
    }
    
}
