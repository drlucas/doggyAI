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

        doSubmission()
        saveDog()
        
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

    
    func saveDog() {
        
        
        let dogRecord = CKRecord(recordType: "Dogs")
        dogRecord["slug"] = thepasseddog.slug
        dogRecord["name"] = thepasseddog.name
       // dogRecord[""] = thepasseddog.image
        dogRecord["gender"] = thepasseddog.gender
        publicDB.saveRecord(dogRecord) { (record, error) in }

    
    }
    
    func doSubmission() {
        let whistleRecord = CKRecord(recordType: "Dogs")
        
        let saveRecordsOperation = CKModifyRecordsOperation()
        saveRecordsOperation.recordsToSave = [whistleRecord]
      //  saveRecordsOperation.tag
        saveRecordsOperation.savePolicy = .IfServerRecordUnchanged
        
        whistleRecord["slug"] = "aaaaahahahahahahahhah"
        whistleRecord["name"] = "Doggy bark"
        
     //   let audioURL = RecordWhistleViewController.getWhistleURL()
     //   let whistleAsset = CKAsset(fileURL: audioURL)
     //   whistleRecord["audio"] = whistleAsset
        
        CKContainer.defaultContainer().publicCloudDatabase.saveRecord(whistleRecord) { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
   //                 self.status.text = "Done!"
  //                  self.spinner.stopAnimating()
                    print(" Record saved")
                    
  //                  ViewController.dirty = true
                } else {
  //                  self.status.text = "Error: \(error!.localizedDescription)"
  //                  self.spinner.stopAnimating()
                }
                
      //          self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneTapped")
            }
        }
    }
    
}
