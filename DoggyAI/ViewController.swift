//
//
//  DoggyAI
//
// Created April 2016
// Ryan Lucas
// aussies.ca
//  ViewController.swift
//  https://github.com/drlucas/doggyAI
//
/*
 //added and user https://github.com/danielgindi/Charts   (import Charts)
 
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
//import CloudKit
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
    var passedtoken: String!
    var ownderdogcount = 0
    var user:User! // our user record
    var useremail: String!
    var userfullname: String!
    var userslug: String! //the slug we got from the registration program
    
    var mydogtopass:Dog!  //the dog in the table
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    @IBAction func settingsbutton(sender: UIButton) {
        //func getDogActivity(date1: NSDate, date2: NSDate) {
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
                              {
         "activity_series" =     {
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
            let date1 = self.fromdate
            let date2 = self.todate
            let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
            //let date1str = String(date1)
            //let date2str = String(date2)
            let jsonparameters = ["activity_series":
                ["slug": "1ba28be9-4e9e-4583-b7d8-b6bb84b17da7", //archie slug
                    "from":"2016-04-15",
                    "to":"2016-04-15",
                    "resolution":"HOURLY"
                ]
            ]
            oauthswift.client.post(dogactivityURL, parameters: jsonparameters, headers: ["Content-Type":"application/json"],        success: { data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers)
           
            if let dict = jsonDict as? [String: AnyObject] {
                    if let actseries = dict["activity_series"]!["records"] as? [AnyObject] {
                        var play_list: [Int] =  []
                        var rest_list: [Int] =  []
                        var active_list: [Int] =  []
                        var date_time_list: [String] =  []
                        var fitbarkpoints_list: [Int] =  []
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
                       //Go save the record now --
                        //print ( rest_list, active_list, play_list, fitbarkpoints_list, date_time_list, dog_slug)
                        let dogslug = "1ba28be9-4e9e-4583-b7d8-b6bb84b17da7"
                        CloudViewController().SaveDailyActivity(dogslug, thedate:date_time_list[0], min_active:active_list, min_play:play_list, min_rest:rest_list, fitbarkpts: fitbarkpoints_list)

                        
                    }
                }
                
                }, failure: { error in
                    print("Bad error: \(error)")
            })
            
        }
        
    
    
    
    
    func getDailyGoals () // need to use an input of dogslug {
    {
    
        print ("Get dog's current daily and future goals")
        /*         Get a dog’s current daily goal and future daily goals set by an authorized user (if any).
         URL: https://app.fitbark.com/api/v2/daily_goal/{dog_slug}
         HTTP Method: GET
         Response example
         {"daily_goals":[
         {"goal": 3000,
         "date" : "2014-08-15"
         },{
         "goal": 4000,
         "date" : "2014-08-20" /* previous daily goal of 3000 applies until 2014-08-19 */
         },{
         "goal": 4500,
         "date" : "2014-09-15" /* previous daily goal of 4000 applies until 2014-09-14 */
         },...]}
 
         //MAY HAVE TO USE AN ARRAY vs struct...string list and then do a string --> int cast
         struct DailyGoal {
            var goaldate = String();
            var goaltarget = Int()
        }
 
 */
        
        var daily_goals = [DailyGoal] () // an array that will contain all our daily goals
        oauthswift.client.credential.oauth_token = self.passedtoken
        oauthswift.client.get("https://app.fitbark.com/api/v2/daily_goal/ac8116d7-3c6c-4029-ad73-7feedcc18239", parameters: [:], success: {
            data, response in
            let json = JSON(data: data)
            print ("Count: \(json.count)")
            for item in json["daily_goals"].arrayValue {
                    let dogdate = item["date"].stringValue
                    let doggoal = item["goal"].int
                   // print("Dog date: \(dogdate)")
                   // print("Dog goal: \(doggoal)")
                
            let mydailygoal = DailyGoal(goaldate:dogdate, goaltarget:doggoal!)
            // self.dogs[self.ownderdogcount].name = dogname
            // self.dogs[self.ownderdogcount].slug = dogslug
            daily_goals.append(mydailygoal)
                print (mydailygoal)
                let dogslug = "ac8116d7-3c6c-4029-ad73-7feedcc18239"
                CloudViewController().SaveDailyGoals(dogslug, mygoals:daily_goals)
               
            }
        
        
            }, failure: { error in
                print(error.localizedDescription)
        })
        
}

        
    
   
    @IBOutlet var dogname: UILabel!
    @IBOutlet var dogpic: UIImageView!
    @IBOutlet var dogtableview: UITableView!
    
    @IBAction func GetCloud(sender: AnyObject) {
        print ("Get User's dogs from cloudkit")
        //use the slug info from the user to pull like slugs from dogs
        
    }
    
    @IBAction func FetchDogs(sender: AnyObject) {
     
      print ("Fetch Dogs")
        self.dogname.text = useremail
        self.ownderdogcount = 0
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
                    let mydog = Dog(birth:dogbirth, gender:doggender, weight:dogweight!, name: dogname, slug:dogslug, image:"", owner:"")
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
    
    }
    
 func Authenticate() {
        print ("Start authenticating and get info")
        //authenticate and pull in the user information from fitbark
        oauthswift.client.credential.oauth_token = self.passedtoken
        oauthswift.client.get("https://app.fitbark.com/api/v2/user",  parameters: [:],
                                  success: {
                                    data, response in
                                    let jsonDict: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
                                      //  print ("Dictionary time: \(jsonDict)")
                                    let curr_user = jsonDict["user"] as? NSDictionary?
                                    let fname = curr_user!!["first_name"] as? String
                                    let lname = curr_user!!["last_name"] as? String
                                    let pichash = curr_user!!["picture_hash"] as! String
                                    let fullname = curr_user!!["name"] as? String
                                    let email = curr_user!!["username"] as? String
                                    let slug = curr_user!!["slug"] as? String
                                    
                                    self.getOwnerPic(self.oauthswift, userslug:slug!)
                                    self.GetOwnerDogs(slug!)
                                    self.useremail = email
                                    self.userfullname = fullname
                                }, failure: { error in
                   
                                    print("Error getting user information from fitbark.com")
                                    print(error.localizedDescription)
                                    // put up alert
                                    SCLAlertView().showError("Error", subTitle:"\(error.localizedDescription)", closeButtonTitle:"OK")
                    })
    }


    func getOwnerPic(oauthswift: OAuth2Swift, userslug: String)
    {
        // this captures the user's profile picture
        let pictureURL = "https://app.fitbark.com/api/v2/picture/user/\(userslug)"
        oauthswift.client.get(pictureURL, parameters: [:], success: {
            data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            let image = jsonDict["image"] as? NSDictionary?
            let encodedImageData = image!!["data"] as? String
            let decodedData = NSData(base64EncodedString: encodedImageData!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData!)
            ///    self.dogpic.clipsToBounds = true
            self.dogpic.image = decodedImage
            }, failure: { error in
                print(error.localizedDescription)
        })
        
    }
    
func GetOwnerDogs(userslug: String) {
        self.dogname.text = useremail
        self.ownderdogcount = 0
        // this retreives all the user's related dogs
        oauthswift.client.get("https://app.fitbark.com/api/v2/dog_relations", parameters: [:], success: {
            data, response in
            let json = JSON(data: data)
            for item in json["dog_relations"].arrayValue {
                if ( item["status"].stringValue == "OWNER" ) {
                    let dogname = item["dog"]["name"].stringValue
                    let dogslug = item["dog"]["slug"].stringValue
                    let dogweight = item["dog"]["weight"].int
                    let doggender = item["dog"]["gender"].stringValue
                    let dogbirth = item["dog"]["birth"].stringValue
                    let breed1id = item["dog"]["breed1"]["id"].int
                    let breed1name = item["dog"]["breed1"]["name"].stringValue
                    print ("Breed: \(breed1name)")
                    let mydog = Dog(birth:dogbirth, gender:doggender, weight:dogweight!, name: dogname, slug:dogslug, image:"", owner:userslug)
                    self.dogs.append(mydog)
                    self.ownderdogcount = self.ownderdogcount + 1
                }
            }
        
            self.dogtableview.reloadData()
            //now go save the records to the cloud
            CloudViewController().saveRecord(self.dogs)
             // SCLAlertView().showError("Error", subTitle:"You have yet authenticated", closeButtonTitle:"OK")
            
            
          /* this is how we print out items from each dog
            self.numberofdogrelations = json["dog_relations"].count
            print ("Count of related dogs: \(self.numberofdogrelations)")
            if let weight = json["dog_relations"][2]["dog"]["weight"].int {
                print("dog #3 weight: \(weight)")
            }
            if let name = json["dog_relations"][1]["dog"]["name"].string {
                print("dog #2 name: \(name)")
            }
            
            */
            
            }, failure: { error in
                print(error.localizedDescription)
        })
        
    
        
    }


    
/*    func getDogowner(oauthswift: OAuth2Swift) {
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
 
 */
    
    
    // URL: https://app.fitbark.com/api/v2/picture/dog/{dog_slug} 

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
        

        oauthswift.client.get(self.picture, parameters: [:], success: {
                                data, response in
                                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                let image = jsonDict["image"] as? NSDictionary?
                                let encodedImageData = image!!["data"] as? String
                                let decodedData = NSData(base64EncodedString: encodedImageData!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                                let decodedImage = UIImage(data: decodedData!)
                            ///    self.dogpic.clipsToBounds = true
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
    
    @IBAction func cancelfromCloudContoller(segue:UIStoryboardSegue) {
        print ("go back from cloud")
        
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
        //
       // print ("Passed token: \(passedtoken!)")
        self.Authenticate()
        
        self.fromdate = NSDate()
        self.todate = NSDate ()
        
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
    /*
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
    
    */
    

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
            print ("Prepare to segue to doggy world")
            let destination = segue.destinationViewController as! DoggyDetailsViewController
       //     let selectedRow = tableView.indexPathForSelectedRow()!.row
           // destination.passedName = self.dognameToPass
            destination.thepasseddog = self.mydogtopass
        }
 
        if segue.identifier == "cloudloader" {
            let destination = segue.destinationViewController as! CloudViewController
            //destination.thepasseddog = self.mydogtopass
            print("What I am passing over to cloudview is \(self.userslug)")
           // print ("Prepare to segue to cloudy world")
            destination.userslug = self.userslug
        }
 
    }
    
    


}
