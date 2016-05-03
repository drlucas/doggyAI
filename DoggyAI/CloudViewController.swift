//
//  CloudViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-13.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit
import Charts

class CloudViewController: UIViewController {

    
    var thepasseddog:Dog!
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userrecord:CKRecordID!
    let activityrecord = CKRecord(recordType: "ActivityRecord")
    let dogRecord = CKRecord(recordType: "Dogs")
    @IBOutlet var dogImageView: UIImageView!
    var dogs = [Dog]()  // an array of dog records - names/slugs/ages/etc that we get back from related dogs

    
    /*
     struct Dog {
     var birth = String();
     var gender = String();
     var weight = Int()
     var name = String();
     var slug = String();
     var image = String(); //this is an uuencoded file
     }
 */
    
    @IBAction func ReturnHome(sender: UIButton) {
        //exit back maybe need this function in home view controller 
        
    }
    

    public func saveRecord
        (fitbarkdogs: [Dog]) -> Int  {
        //if dog record doesnt exits save it
        print ("----- debug saveRecord -----")
        print ("Total number of dogs \(fitbarkdogs.count)")
        for eachdog in fitbarkdogs {
            // for each dog that I have downloaded from fitbark.com - search CloudKit to see if they already exist
            // if they already exist then I'll want to update any changes, but if they don't exist then I'll need to create them
            // print("Dog Slug: \(dog.slug)")
           // print ("First loop of each dog slug: \(eachdog.slug)")
            let predicate = NSPredicate(format: "slug BEGINSWITH %@", eachdog.slug)
            let query = CKQuery(recordType: "Dogs", predicate: predicate)
            print ("Query: \(query)")
            publicDB.performQuery(query, inZoneWithID: nil, completionHandler:  { results, error in
                if let err = error {
                    print ("Error with query: \(err)")
                }
                //print (results?.count)
                if results?.count == 0 {
                    print ("Dog record \(eachdog.slug) was not in CloudKit")
                    print("Start saving dog record from fitbark: \(eachdog.name)")
                    self.SaveDogRecord(eachdog)
                }
                    
                else {
                print ("Dog record \(eachdog.slug) was in CloudKit")
                print("so lets check to see if it was changed since last checked ")
                }
            })
        }
        
        return 1
    }
    
    func SaveDailyActivity(dogslug:String, thedate:String, min_active:[Int], min_play:[Int], min_rest:[Int], fitbarkpts:[Int]) {
        print("Savelist")
        //double check before we save the record for the dog that we didn't already do it
        
        //if we already have saved it, we may want to see if it changed and modify it 
        
        
        //otherwise, lets save the record
        activityrecord["fitbarkpts"] = fitbarkpts
        activityrecord["minute_active_list"] =  min_active
        activityrecord["minute_play_list"] = min_play
        activityrecord["minute_rest_list"] = min_rest
        activityrecord["slug"] = dogslug
        
        publicDB.saveRecord(activityrecord, completionHandler: ({returnRecord, error in
            if let err = error {
                print("Error saving record for owner \(error)")
                
            }
            else {
                //self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                print("Dog activity saved")
            }
            
        }))

    }
    


    func SaveDailyGoals(dog2save:String, mygoals:[DailyGoal] ) {
        //get the recordID for the dogslug (which is dog2save)
        //then replace the Dog record field with the new dailygoals string list
        var shoppingList: [String] = ["bacons","Googles" ,"Milk"]
        let predicate = NSPredicate(format: "slug BEGINSWITH %@", dog2save)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        //
       // let predicate = yourPredicate // better be accurate to get only the record you need
       // var query = CKQuery(recordType: YourRecordType, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record.setObject(shoppingList, forKey: "daily_goals")
                    
                    // Save this record again
                    self.publicDB.saveRecord(record, completionHandler: { (savedRecord, saveError)in
                        if saveError != nil {
                        print("Error saving record: \(saveError!.localizedDescription)")
                        } else {
                        print("Successfully updated record!")
                        }
                    })
                }
            }
        })
        
    }
    
    func SaveDogRecord(dog2save: Dog) {
        /*SAVE*/
        
        dogRecord["name"] = dog2save.name
        dogRecord["gender"] =  dog2save.gender
        dogRecord["last_sync"] = NSDate()
        dogRecord["owner_slug"] = dog2save.owner
        dogRecord["slug"] = dog2save.slug

        publicDB.saveRecord(dogRecord, completionHandler: ({returnRecord, error in
                if let err = error {
                    print("Error saving record for owner \(error)")

            }
                else {
                    //self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    print("Dog  saved")
            }
        
    }))
    }



    override func viewDidLoad() {
        super.viewDidLoad()
      //  getusername()
     //   doSubmission()   /////save a record
  
        
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getdogimage () {
        
        let downloadedimage = dogRecord["image"] as! CKAsset
        dogImageView.image = UIImage(
            contentsOfFile: downloadedimage.fileURL.absoluteString
        )
    }
    
func getusername() {
        //go get our username from icloud so we can pull up our records
        print ("I'm in get username now")
        let container = CKContainer.defaultContainer()
        container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
            guard error == nil else {
                print ("Error: \(error)")
                return }
            
            if status == CKApplicationPermissionStatus.Granted {
               print ("I have permission")
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
                            print("First name = \(firstName)")
                            print("Last name = \(lastName)")
                            self.printrecords()
                        }
                }) } }
    } //end of getusername

    
    
    func printrecords() {
        let reference = CKReference(recordID: self.userrecord, action: .None)
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (records, error) in
            for user in records! {
               
                print("User: \(user)")
                print("User firstname: \(user["name"])")
                print("Record: \(records?.count)")
                let downloadedimage = user["image"] as! CKAsset
                self.dogImageView.image = UIImage(
                    contentsOfFile: downloadedimage.fileURL.path!
                )
                
                
            }
            
        }
    }
    
    func doSubmission() {
        
        
        dogRecord["title"] = thepasseddog.name
        dogRecord["title"] = thepasseddog.birth
        dogRecord["slug"] = thepasseddog.slug
        dogRecord["name"] = thepasseddog.name
        dogRecord["weight"] = thepasseddog.weight
      //  dogRecord["image"] = thepasseddog.image
        dogRecord["gender"] = thepasseddog.gender
        
     //   func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    //        guard let mediaURL = info[UIImagePickerControllerMediaURL] as? NSURL else { return }
    //        dogRecord["image"] = CKAsset(fileURL: mediaURL)
    //        print("Image picker")
   //     }
       
        
        
            publicDB.saveRecord(dogRecord) { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
  
                    print(" Record saved")
                } else {
                }
            }
        }
    }
    
    

    
    
}
