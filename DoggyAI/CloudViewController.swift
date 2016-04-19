//
//  CloudViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-13.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit


class CloudViewController: UIViewController {

    
    var thepasseddog:Dog!
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userrecord:CKRecordID!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getusername()
        doSubmission()
  
        
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
           print("Record: \(records)")
            print("Record: \(records?.count)")
        }
    }
    
    func doSubmission() {
        
        let dogRecord = CKRecord(recordType: "Dogs")
        dogRecord["title"] = thepasseddog.name
        dogRecord["title"] = thepasseddog.birth
        dogRecord["slug"] = thepasseddog.slug
        dogRecord["name"] = thepasseddog.name
        dogRecord["weight"] = thepasseddog.weight
        // dogRecord[""] = thepasseddog.image
        dogRecord["gender"] = thepasseddog.gender
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
