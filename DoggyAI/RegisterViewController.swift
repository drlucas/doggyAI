//
//  RegisterViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-19.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//
// Here is what this registration/settings page does
// 
// Login to icloud & get user's recordID (if we can't log in - display a disconnected from network error)  (getusername function)
// Get users first name
// Get users last name
// Search for user token, account id, slug and picture in the cloud  //checkUserExists
// If token exists grab it for authtenication
// 
// If token doesnt exist then we need to create/save a new token
//


import UIKit
import CloudKit
import OAuthSwift
//import SwiftSpinner


class RegisterViewController: UIViewController {
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
   
    

    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userrecord:CKRecordID!
    let OwnerRecord = CKRecord(recordType: "Owners")
    var credentials:String!
    let debug = true   // used to print debug info to the All output screen
    var authtoken = "" as String! // my authentication token to use in fitbark
    var tokendate:NSDate! //date when token was originally created
    //var userslug = "" as String! // my users slug from fitbark
    var userslug:String = "" // my users slug from fitbark
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var firstnameLabel: UILabel!
    @IBOutlet var lastnameLabel: UILabel!
    
    var firstnametext = ""
    var lastnametext = ""
  
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func demoSpinner() {
        
        delay(seconds: 0.1, completion: {
            SwiftSpinner.show("Authenticating user account")
        })
    
    }
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.demoSpinner()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self,
                                               selector: #selector(RegisterViewController.updateData), userInfo: nil, repeats: true)
        
       // updateData() // just so it happens quickly the first time
        getusername()

        
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
        //all this does is update a lable 
        self.firstnameLabel.text = self.firstnametext
        self.lastnameLabel.text = self.lastnametext
    }
    
    func getusername() {
        //go get our username from icloud so we can pull up our records
        let container = CKContainer.defaultContainer()
        container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
            guard error == nil else {
                print ("Error: \(error)")
                return }
            
            if status == CKApplicationPermissionStatus.Granted {
                if self.debug {
                        print ("I have permission to icloud")
                }
            }
            
            container.fetchUserRecordIDWithCompletionHandler { (recordID, error) in
                guard error == nil else { return }
                guard let recordID = recordID else { return }
                print ("Record name: \(recordID.recordName) ")
                self.userrecord = recordID
                container.discoverUserInfoWithUserRecordID(recordID,
                    completionHandler: {
                        (userInfo: CKDiscoveredUserInfo?, error: NSError?) in
                        
                        if error != nil{
                            print("Error in fetching user. Error = \(error)")
                        } else {
                            let firstName = userInfo!.displayContact?.givenName ?? ""
                            let  lastName = userInfo!.displayContact?.familyName ?? ""
                            self.firstnametext = firstName
                            self.lastnametext = lastName
                            if self.debug {
                            print("First name = \(firstName)")
                            print("Last name = \(lastName)")
                           
                            }
                           
                            self.checkUserExists()
                        }
                        
                        
                }) } }
    } //end of getusername
    
    func checkUserExists() {
        let reference = CKReference(recordID: self.userrecord, action: .None)
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
        let query = CKQuery(recordType: "Owners", predicate: predicate)
        if self.debug {
            //print ("Query: \(query)")
        }
        publicDB.performQuery(query, inZoneWithID: nil) { (records, error) in
          if self.debug {
            print("Record count: \(records?.count)")
            }
            if records?.count == 0 {      //no user account exists, create it then
                        self.loginUser()  // go to fitbark and get token then save it
            
            }
            else   { //the user exists, so grab the token date and make sure it's less than a year old
                    // if token date > 1 year, then re-create a token, else token is fine to keep using so we can login
                
                for owner in records! {
                    if self.debug {
                       
                        print("Dog Owner  firstname: \(owner["first_name"])")
                        print("Dog Owner  token date: \(owner["token_date"])")
                        print("Dog Owner's slug: \(owner["slug"])")
                        self.userslug = String(owner["slug"]!)
                        SwiftSpinner.hide()  //we have authenticated
                    }
                    
                    //  let downloadedimage = user["image"] as! CKAsset
                    //  self.userImageView.image = UIImage(
                    //      contentsOfFile: downloadedimage.fileURL.path!
                    //  )
               
                  self.authtoken = String(owner["token"]!)
                  let mydate = owner["token_date"] as! NSDate
                 self.tokendate = mydate
                     if self.debug {
                        print ("Token creation/updated date: \(self.tokendate)")
                    }
                    let currentDateTime = NSDate()
                    let timeSince:[Int] = self.timeBetween(self.tokendate, endDate: currentDateTime)
                    if timeSince[0] < 365 {
                        if self.debug {
                            print("The difference between dates is: \(timeSince[0]). No need to get a new token")
                        }
                        else {
                            print ("we need a new token")
                        }
                    
                    }
                }
            
            }
        }
    }
    
    func timeBetween(startDate: NSDate, endDate: NSDate) -> [Int]
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day, .Month, .Year], fromDate: startDate, toDate: endDate, options: [])
        
        return [components.day, components.hour, components.minute]
    }
    
    
    func getuserslug() {
        print ("getuserslug")
        self.oauthswift.accessTokenBasicAuthentification = true
        let state: String = generateStateWithLength(20) as String
        self.oauthswift.client.get("https://app.fitbark.com/api/v2/user",  parameters: [:],
                              success: {
                                data, response in
                                let jsonDict: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
                                let curr_user = jsonDict["user"] as? NSDictionary?
                                let slug = curr_user!!["slug"] as? String
                                self.userslug = slug!
                                print("Slug- \(self.userslug)")
            }, failure: { error in
                
                print("Error getting user information from fitbark.com")
                print(error.localizedDescription)
                // put up alert
                SCLAlertView().showError("Error", subTitle:"\(error.localizedDescription)", closeButtonTitle:"OK")
        })
        print ("gotuserslug")

    }

    func SaveOwnerRecord() {
        /*SAVE*/
        //     self.keychain["the_token_key"] = self.oauthswift.client.credential.oauth_token
        authtoken = self.oauthswift.client.credential.oauth_token
        OwnerRecord["first_name"] = self.firstnameLabel.text
        OwnerRecord["last_name"] = self.lastnameLabel.text
        OwnerRecord["token"] = self.oauthswift.client.credential.oauth_token
        OwnerRecord["token_date"] = NSDate()
        OwnerRecord["slug"] = self.userslug
        publicDB.saveRecord(OwnerRecord) { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    
                    print(" Record saved")
                } else {
                    print("Error saving record for owner \(error)")
                }
            }
        }
    }
    
func loginUser() {
        //get our main token from FitBark authorization. 
        //if we fail to get a token, try again, otherwise we save the token record into CloudKit
        self.oauthswift.accessTokenBasicAuthentification = true
        let state: String = generateStateWithLength(20) as String
        self.oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/fitbark")!, scope: "", state: state, success: {
            credential, response, parameters in
            if self.debug {
            print ("Credential: \(credential.oauth_token)")
            print ("Paramters: \(parameters)")
            print ("Response: \(response)")
            print ("State: \(state)")
            print ("Token: \(credential.oauth_token)")
            
            }
            self.getuserslug()
            self.delay(3.0) {
            print ("delayed")
                self.SaveOwnerRecord()
            }
            
            
            }, failure: { error in
                if error.localizedDescription == "Missing state" {
                    //i think we need to try to login again.
                print("Error : \(error.localizedDescription)")
            self.loginUser()
                }
        })
    }
    
   
    
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "loadmain" {
            if authtoken == "" {
                // put up alert if we aren't logged in yet
                SCLAlertView().showError("Error", subTitle:"You have yet authenticated", closeButtonTitle:"OK")
                return false
            }
            else {
        return true
            }
        }
        return true
    }
    
    @IBAction func cancelfromCheckDailyRecords(segue:UIStoryboardSegue) {
        print ("go back from Dailyrecords")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loadmain" {
            print ("Prepare to segue to doggy world main menu")
            let destination = segue.destinationViewController as! ViewController
            destination.passedtoken = authtoken
            destination.userslug = self.userslug
            print ("User passed over is \(self.userslug)")
        }
        
        if segue.identifier == "savesettings" {
            let destination = segue.destinationViewController as! CloudViewController
                      print ("Prepare to segue to save settings")
        }
        
        if segue.identifier == "dogactivity" {
            let destination = segue.destinationViewController as! CloudViewController
          //  destination.passedtoken = authtoken
            print ("Prepare to dog activity...segue to save settings")
        }
        
        if segue.identifier == "checkdailyrecords" {
            let destination = segue.destinationViewController as! CheckDailyRecords
            print ("Prepare to pass user slug to checkdaily")
            destination.userslug = self.userslug
            destination.userrecord = self.userrecord
            destination.passedtoken = authtoken

        }

        
    }
    
    
}
