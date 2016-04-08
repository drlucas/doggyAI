//
//  ViewController.swift
//  DoggyAI
//
//
/*
 
 Application Id: fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c
 Secret: 4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120
 Callback urls: urn:ietf:wg:oauth:2.0:oob
 
 Access: Read
 URL: https://app.fitbark.com/api/v2/dog_relations
 HTTP Method: GET
 Response fields
 
 date is the time of creation of the relationship with the dog (expressed in GMT)
 activity_date is the last sync time for the dog (expressed in the dog’s local time)
 last_min_time is the time of the last valid minute available in the server
 last_min_activity is the value of the last minute available in the serve
 
 User is redirected to the authentication page (GET https://app.fitbark.com/oauth/authorize) passing:
 response_type=code: must have the value “client_credentials” to obtain the authorization code
 client_id: unique identifier obtained from the developer portal
 redirect_uri: URI where to redirect the user after he/she grants permissions. This URI must match one of the URI prefixes defined when setting up API access
 Get various information about the specified user including name, username (email address), profile picture and Facebook ID.
 
 Access: Readƒ
 URL: https://app.fitbark.com/api/v2/user
 HTTP Method: GET
 User Profiles
 
 “Owners” can edit a dog profile and view all the historical activity
 “Friends” can view a dog’s profile and view the last 30 days of activity
 Json Requirements
 
 Requests with a Json body must set the “content-type” header to “application/json”
 
 */

import OAuthSwift
import UIKit
import Prephirences



class ViewController: UIViewController {

    var picture = ""
   // var dogs = ["Archie", "Rosie", "Oliver", "Timber"]  //used for testig table
    var slugs = [String]() // an array that matches the dog's slug so we can get other info about our dogs
    var dogs = [Dog]()  // an array of dog records - names/slugs/ages/etc that we get back from related dogs
    var fromdate:NSDate!
    var todate:NSDate!
    var numberofdogrelations = 0
    var ownderdogcount = 0
   // var dognameToPass:String!  //from table
    var mydogtopass:Dog!  //the dog in the table
    let defaults = NSUserDefaults.standardUserDefaults()
 //   var keychain = KeychainPreferences.sharedInstance
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
    var havevalidtoken = false
    
    @IBOutlet var dogname: UILabel!
    @IBOutlet var dogpic: UIImageView!
    @IBOutlet var dogtableview: UITableView!

    @IBAction func FetchDogs(sender: AnyObject) {
       
     
      print ("Fetch")
 
      self.ownderdogcount = 0
        //self.Authenticate()
        self.testFitbark(self.oauthswift)
        // this retreives all the user's related dogs
        oauthswift.client.get("https://app.fitbark.com/api/v2/dog_relations", parameters: [:], success: {
            data, response in
            let json = JSON(data: data)
            for item in json["dog_relations"].arrayValue {
                //   print("Name: \(item["dog"]["name"].stringValue)")
                //   print("Status: \(item["status"].stringValue)")
                if ( item["status"].stringValue == "OWNER" ) {
                    let dogname = item["dog"]["name"].stringValue
                    let dogslug = item["dog"]["slug"].stringValue
                    let dogweight = item["dog"]["weight"].int
                    let doggender = item["dog"]["gender"].stringValue
                    let dogbirth = item["dog"]["birth"].stringValue
                  //  print("Dog name: \(dogname)")
                  //  print("Dog slug: \(dogslug)")
                    let mydog = Dog(birth:dogbirth, gender:doggender, weight:dogweight!, name: dogname, slug:dogslug, image:"")
                   // self.dogs[self.ownderdogcount].name = dogname
                    // self.dogs[self.ownderdogcount].slug = dogslug
                    self.dogs.append(mydog)
                    self.ownderdogcount = self.ownderdogcount + 1
                }
            }
            
            self.numberofdogrelations = json["dog_relations"].count
            self.dogtableview.reloadData()
            print ("Count of related dogs: \(self.numberofdogrelations)")
            if let weight = json["dog_relations"][2]["dog"]["weight"].int {
                print("dog #3 weight: \(weight)")
            }
            if let name = json["dog_relations"][1]["dog"]["name"].string {
                print("dog #2 name: \(name)")
            }
            }, failure: { error in
                print(error.localizedDescription)
        })
        
        /*  https://app.fitbark.com/api/v2/dog_relations
         "dog_relations": [
         {
         "id": 13,
         "status": "OWNER",
         "date": "2014-08-19T20:23:52.000Z",
         "dog": {
         "slug": "ad7c7166-4cf5-4284-aa56-2cf4df305b31",
         "name": "Barley",
         
         */
        
    
    
    }
    
  func getDogActivity(date1: NSDate, date2: NSDate) {
        //  func getDogActivity() {
        
        //get dog based on two dates https://app.fitbark.com/api/v2/activity_series
        /*
         {
         "activity_series":{
         "slug":"1ba28be9-4e9e-4583-b7d8-b6bb84b17da7",  //Archie's slug
         "from":"2013-03-02",
         "to":"2014-09-02",
         "resolution":"DAILY"
         }
         }
         */
        let date1 = self.fromdate
        let date2 = self.todate
        //let dogactivity = activity_series(slug:"1ba28be9-4e9e-4583-b7d8-b6bb84b17da7" , from:"2016-04-10", to:"2016-04-02", resolution:"DAILY")
        let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
        // let dogactivityURL = "https://app.fitbark.com/api/v2/activity_totals"
        //let dogactivityURL = "https://app.fitbark.com/api/v2/similar_dogs_stats"
        
        //   let dogactivityURL = "https://app.fitbark.com/api/v2/activity_totals"
        
        //let jsonUpdate = ["slug": "1ba28be9-4e9e-4583-b7d8-b6bb84b17da7"]
        let date1str = String(date1)
        let date2str = String(date2)
        
        let jsonparameters = ["activity_series":
            ["slug": "1ba28be9-4e9e-4583-b7d8-b6bb84b17da7",
                "from":date1str,
                "to":date2str,
                "resolution":"DAILY"
            ]
        ]
        
        //  print("URL: \(dogactivityURL)"
        
        oauthswift.client.post(dogactivityURL, parameters: jsonparameters, headers: ["Content-Type":"application/json"],        success: {
            data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            print("SUCCESS: \(jsonDict)")
            
            }, failure: { error in
                print("Bad error: \(error)")
        })
        
    }
    
    func Authenticate() {
        print ("Start authenticating")
        //authenticate and pull in the user information
        
    
        if let mytoken = self.defaults.objectForKey("oauth_token")  {
           //check to see if I have a token, if I do, check to make sure it's still active (they only last a year)
            // Calculate the expiration date so we know if the token is invalid
          //  NSDate *expDate = [NSDate dateWithTimeIntervalSinceNow:[[params objectForKey:@"expires_in"] integerValue]];
          //  [[NSUserDefaults standardUserDefaults] setObject:expDate forKey:OADTokenExpirationDefaultsName];
            
  /*RETRIEVE*/
 //            if let token = self.keychain["the_token_key"] as? String { print ("got token \(token)")}
            // if let token_secret = keychain["the_secret_token_key"] as? String { print ("got token") }
            
            
            print ("Token: \(mytoken)")
            oauthswift.client.credential.oauth_token = mytoken as! String
            oauthswift.client.get("https://app.fitbark.com/api/v2/user",  parameters: [:],
                                  success: {
                                    data, response in
                                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                    //  print ("Dictionary time: \(jsonDict)")
                                    let curr_user = jsonDict["user"] as? NSDictionary?
                                    // print("current user: \(curr_user)")
                                    let fname = curr_user!!["first_name"] as? String
                                    self.dogname.text = fname
                                    if let slug = curr_user!!["slug"]  {
                                        print("User's Slug: \(slug)")
                                        self.picture = "https://app.fitbark.com/api/v2/picture/user/\(slug)"
                                        print("User's Slug URL: \(self.picture)")                               }
                                    
                }, failure: { error in
                    print("New error")
                    print(error.localizedDescription)
            })
            
            //
            self.havevalidtoken = true
            
        }
        else {
        print ("No token")
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
            self.defaults.setObject(credential.oauth_token, forKey: "oauth_token")
            print ("Token: \(credential.oauth_token)")
           //  self.getDogowner(self.oauthswift)
            }, failure: { error in
                print("Error : \(error.localizedDescription)")
        })
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func getDogowner(oauthswift: OAuth2Swift) {
        //get dog owner name
        oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:],
                              success: {
                                data, response in
                                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                //  print ("Dictionary time: \(jsonDict)")
                                let curr_user = jsonDict["user"] as? NSDictionary?
                                // print("current user: \(curr_user)")
                                let fname = curr_user!!["first_name"] as? String
                                self.dogname.text = fname
                                if let slug = curr_user!!["slug"]  {
                                  //  print("User's Slug: \(slug)")
                                    self.picture = "https://app.fitbark.com/api/v2/picture/user/\(slug)"
                                 //   print("User's Slug URL: \(self.picture)")         
                                }
                                
            }, failure: { error in
                print(error.localizedDescription)
        })

    }
    // self.pictureURL = "https://app.fitbark.com/api/v2/picture/user/\(slug)"
    // URL: https://app.fitbark.com/api/v2/picture/dog/{dog_slug} 
    
    func testFitbark(oauthswift: OAuth2Swift) {
        //print("Inside fitbark - go get user name")
        /*
         {
         "user": {
         "slug": "a0a19044-3fca-40ad-a2d2-8670cffebfa0",
         "username": "pippo@pippo.com",
         "name": "Pippo Pippone",
         "first_name": "Pippo",
         "last_name"
         
         /// https://app.fitbark.com/api/v2/picture/user/{user_slug}
         {
         "image": {
         "data": "9j/4AAQSkZJRgABAQAAAQABAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4w ICh1c2luZyBJSkcgSlBFRyB2NjIpLCBxdWFsaXR5ID0gOTUK/9sAQwACAQEB AQECAQEBAgICAgIEAwICAgIFBAQDBAYFBgYGBQYGBgcJCAYHCQcGBggLCAkK CgoKCgYICwwLCgwJCgoK/9sAQwECAgICAgIFAwMFCgcGBwoKCgoKCgoKCgoK CgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoK/8AAEQgE cAKAAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkK C//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGh CCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNE. . .RUZHSElKU1RV"
         }
         }
 
    
        
        oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:],
                              success: {
                                data, response in
                                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                //  print ("Dictionary time: \(jsonDict)")
                                let curr_user = jsonDict["user"] as? NSDictionary?
                                // print("current user: \(curr_user)")
                                let fname = curr_user!!["first_name"] as? String
                                self.dogname.text = fname
                                if let slug = curr_user!!["slug"]  {
                                print("User's Slug: \(slug)")
                                self.picture = "https://app.fitbark.com/api/v2/picture/user/\(slug)"
                                print("User's Slug URL: \(self.picture)")                               }
                                
            }, failure: { error in
                print(error.localizedDescription)
        })
        */
        
 // this captures the user's profile picture
        oauthswift.client.get(self.picture, parameters: [:], success: {
                                data, response in
                                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                let image = jsonDict["image"] as? NSDictionary?
                                let encodedImageData = image!!["data"] as? String
                                let decodedData = NSData(base64EncodedString: encodedImageData!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                                let decodedImage = UIImage(data: decodedData!)
                                self.dogpic.image = decodedImage
            }, failure: { error in
                print(error.localizedDescription)
        })

    }
    
    
  
    func getDogpicture(oauthswift: OAuth2Swift) {
        //get dog picture base64 and store to array for dog details screen
        let dogpicURL = "https://app.fitbark.com/api/v2/picture/dog/\(self.mydogtopass.slug)"
        print("Dogname: \(self.mydogtopass.name)")
        print("dogpicURL: \(dogpicURL)")
        oauthswift.client.get(dogpicURL, parameters: [:], success: {
            data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            let image = jsonDict["image"] as? NSDictionary?
            let encodedImageData = image!!["data"] as? String
            self.mydogtopass.image = encodedImageData!
            //print("worked?")
            //print(self.mydogtopass.image)
            //use the next two lines to show the picture from the image data
            //let decodedData = NSData(base64EncodedString: encodedImageData!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
           // let decodedImage = UIImage(data: decodedData!)
           // self.dogpic.image = decodedImage
            }, failure: { error in
                print(error.localizedDescription)
        })
        
    }




    @IBAction func canceltoViewContoller(segue:UIStoryboardSegue) {
        print ("go back")
        let view2:DoggyDetailsViewController = segue.sourceViewController as! DoggyDetailsViewController
        self.fromdate = view2.date1
        self.todate = view2.date2
        getDogActivity(self.fromdate, date2: self.todate)
        
    }
    
    @IBAction func saveDogDetails(segue:UIStoryboardSegue) {
        let view2:DoggyDetailsViewController = segue.sourceViewController as! DoggyDetailsViewController
        self.fromdate = view2.date1
        self.todate = view2.date2
        getDogActivity(self.fromdate, date2: self.todate)
        
        
        
    }
    
}




let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
let FileManager: NSFileManager = NSFileManager.defaultManager()

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Authenticate()
        self.fromdate = NSDate()
        self.todate = NSDate ()
        
        // Load config from files
//        initConf()
//        get_url_handler()
//        self.navigationItem.title = "Doggy AI"
//        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .Plain)
//        tableView.delegate = self
//        tableView.dataSource = self
//        self.view.addSubview(tableView)
        
    }
    
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExistsAtPath(appPath) {
            do {
                try FileManager.createDirectoryAtPath(appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func initConf() {
        
        // print("Load configuration from: \(self.confPath)")
        if let path = NSBundle.mainBundle().pathForResource("Services", ofType: "plist") {
            services.loadFromFile(path)
            if !FileManager.fileExistsAtPath(confPath) {
                do {
                    try FileManager.copyItemAtPath(path, toPath: confPath)
                }catch {
                    print("Failed to copy empty conf to\(confPath)")
                }
            }
        }
        services.loadFromFile(confPath)
    }
    
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauth_token)"
        if !credential.oauth_token_secret.isEmpty {
            message += "\n\noauth_toke_secret:\(credential.oauth_token_secret)"
        }
        self.showAlertView(name ?? "Service", message: message)
        
        if let service = name {
            services.updateService(service, dico: ["authentified":"1"])
            // TODO refresh graphic
        }
    }
    
    // MARK: create an optionnal internal web view to handle connection
    func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }
    
    func get_url_handler() -> OAuthSwiftURLHandlerType {
        // Create a WebViewController with default behaviour from OAuthWebViewController
        let url_handler = createWebViewController()
        
        return url_handler
        
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
 
 func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//print ("Table rows: \(self.ownderdogcount)")
 return self.ownderdogcount
   
 }
 
 func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
 
    let cellIdentifier = "dognamescell"
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DogTableViewCell
    let dog = self.dogs[indexPath.row].name
    // let dog = dogs[indexPath.row]
    cell.dogname.text = dog
    return cell
 }

 func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // print("You selected cell #\(indexPath.row)!")
      //  let indexPath = tableView.indexPathForSelectedRow!
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
       // let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! DogTableViewCell
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
        let group = dispatch_group_create()
        
        dispatch_group_enter(group)
        self.mydogtopass = self.dogs[indexPath.row]
        dispatch_group_leave(group)
        
        dispatch_group_enter(group)
        self.getDogpicture(self.oauthswift)
        dispatch_group_leave(group)
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("done dispatch")
            //self.mydogtopass = dogs[indexPath.row]
            //self.getDogpicture(self.oauthswift)
            print ("ready to segue with: \(self.mydogtopass)")
           
        }
    }
    
    performSegueWithIdentifier("dogsegue", sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dogsegue" {
            print ("Prepare to segue")
            let destination = segue.destinationViewController as! DoggyDetailsViewController
       //     let selectedRow = tableView.indexPathForSelectedRow()!.row
           // destination.passedName = self.dognameToPass
            destination.thepasseddog = self.mydogtopass
        }
 
 
    }
    
    


}
