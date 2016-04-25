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
    
    public func saveRecord(records: [Dog]) -> Int  {
        //if dog record doesnt exits save it
        for dog in records {
            print("Dog Slug: \(dog.slug)")
            
            let query = CKQuery(recordType: "Dogs", predicate: NSPredicate(format: "slug = %@", dog.slug ))
            
            print ("Query: \(query)")
            publicDB.performQuery(query, inZoneWithID: nil) { (therecords, error) in
                print("Record: \(therecords?.count)")
                    for user in therecords! {
                        
                        print("User: \(user)")
                        print("User firstname: \(user["name"])")
                        
                        let downloadedimage = user["image"] as! CKAsset
                        self.dogImageView.image = UIImage(
                            contentsOfFile: downloadedimage.fileURL.path!
                        )
                        
                        
                    }
                    
                }
            }
            
        

        return 0
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getusername()
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
