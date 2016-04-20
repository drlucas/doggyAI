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
    let debug = true   // used to print debug info to the All output screen
    var authtoken = "" // my authentication token to use in fitbark
    var tokendate = "" //date when token was originally created
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var firstnameLabel: UILabel!
    @IBOutlet var lastnameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var userslugLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                            self.firstnameLabel.text = firstName
                            self.lastnameLabel.text = lastName
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
            print ("Query: \(query)")
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
                        print("Dog Owner: \(owner)")
                        print("Dog Owner  firstname: \(owner["name"])")
                    }
                    
                    //  let downloadedimage = user["image"] as! CKAsset
                    //  self.userImageView.image = UIImage(
                    //      contentsOfFile: downloadedimage.fileURL.path!
                    //  )
                  self.usernameLabel.text = String(owner["username"])  //this is stored in icloud as we stored it after we logged in originally
                  self.userslugLabel.text = String(owner["slug"]) //this is stored in icloud as we stored it after we logged in
                  self.authtoken = String(owner["token"])
                  self.tokendate = String(owner["token_date"]) //this needs to be NSDate so I can check >1 year old
               
                
                }
            
            }
        }
    }
    

    
    func loginUser() {
        //get
        self.oauthswift.accessTokenBasicAuthentification = true
        let state: String = generateStateWithLength(20) as String
        self.oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/fitbark")!, scope: "", state: state, success: {
            credential, response, parameters in
            // we have now authenticated so save into user defaults or keychain for quicker use
            /*SAVE*/
            //     self.keychain["the_token_key"] = self.oauthswift.client.credential.oauth_token
            //      self.keychain["the_secret_token_key"] = self.oauthswift.client.credential.oauth_token_secret
            //       self.keychain["the_credential_key", .Archive] = self.oauthswift.client.credential
            
            print ("Credential: \(credential)")
            print ("Paramters: \(parameters)")
            print ("Response: \(response)")
            print ("State: \(state)")
            
            //now save to NSDEfaults, but for this i'll now want to save to Owners Record
            //self.defaults.setObject(credential.oauth_token, forKey: "oauth_token")
            print ("Token: \(credential.oauth_token)")
            //  self.getDogowner(self.oauthswift)
            }, failure: { error in
                if error.localizedDescription == "Missing state" {
                    //i think we need to try to login again.
                print("Error : \(error.localizedDescription)")
            self.loginUser()
                }
        })
    }
    
}
