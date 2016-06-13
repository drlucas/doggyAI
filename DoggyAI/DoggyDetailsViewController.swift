//
//  DoggyDetailsViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-01.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit 

class DoggyDetailsViewController: UIViewController, EPCalendarPickerDelegate, MKMapViewDelegate, CLLocationManagerDelegate   {
 
    
    @IBOutlet var lastlocationmap: MKMapView!
    
    @IBOutlet weak var enddate: UILabel!
    @IBOutlet weak var startdate: UILabel!
    @IBOutlet var dognamelabel: UILabel!
    var thepasseddog:Dog!
    var passedName:String!
    var passedSlug:String!
    var date1:NSDate!
    var date2:NSDate!
    var userslug:String! // the string for the user that was passed over from previous controller
    
    @IBOutlet var DaystoBday: UILabel!
    
    let dogRecord = CKRecord(recordType: "Dogs")
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var userrecord:CKRecordID!
    var locationManager = CLLocationManager()
    
    
    @IBOutlet var thedogpic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        print("Im in the dog table view now")
        print("Passed dog: \(thepasseddog.slug)")
        print("Dog's birth day is: \(thepasseddog.birth)")
        
        dognamelabel.text = thepasseddog.name
        let decodedData = NSData(base64EncodedString:  thepasseddog.image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        self.thedogpic.image = decodedImage
        

        //Configure and start the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
     
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day, .Hour, .Minute, .Second], fromDate: thepasseddog.birth, toDate:NSDate(), options: [])
            
            var dayText = String(components.day) + "d "
            var hourText = String(components.hour) + "h "
            
            // Hide day and hour if they are zero
            if components.day <= 0 {
                dayText = ""
                if components.hour <= 0 {
                    hourText = ""
                }
            }
            
            DaystoBday.text = dayText + hourText + String(components.minute) + "m " + String(components.second) + "s"
        // DaystoBday.text = String(components.day) + "d"
        //dayText + hourText + String(components.minute) + "m " + String(components.second) + "s"
    
    }

    func timeBetween(startDate: NSDate, endDate: NSDate) -> [Int]
    {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day, .Month, .Year], fromDate: startDate, toDate: endDate, options: [])
    return [components.day, components.hour, components.minute]
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager.stopUpdatingLocation()
        
        let latestLocation = locations.last
        
        let latitude = String(format: "%.4f", latestLocation!.coordinate.latitude)
        let longitude = String(format: "%.4f", latestLocation!.coordinate.longitude)
        let userLocation: CLLocation = locations[0]
      
        let center = CLLocationCoordinate2D(latitude: latestLocation!.coordinate.latitude, longitude: latestLocation!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.lastlocationmap.setRegion(region, animated: true)
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
        SaveDogLocation(thepasseddog, location: latestLocation!)
    }
   
   

func SaveDogLocation(dog2save: Dog, location:CLLocation ) {
        
        /*
         Matching Records where Record's location is within 100 meters of the given location:
         var location = new CLLocation(37.783,-122.404);
         var predicate = NSPredicate.FromFormat(string.Format("distanceToLocation:fromLocation(Location,{0}) < 100", location));
         */

        //get the recordID for the dogslug (which is thepasseddog.slug)
        //then replace the Dog lastlocation record field with the new loaction
        
        let predicate = NSPredicate(format: "slug BEGINSWITH %@", dog2save.slug)
        print("Dog bday: \(dog2save.birth)")
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record.setObject(location, forKey: "lastlocation")
                    
                    // Save this record again
                    self.publicDB.saveRecord(record, completionHandler: { (savedRecord, saveError)in
                        if saveError != nil {
                            print("Error saving record: \(saveError!.localizedDescription)")
                        } else {
                            print("Successfully updated record with new location!")
                        }
                    })
                }
            }
        })
        
    }
    
    
        
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        lastlocationmap.showsUserLocation = (status == .AuthorizedAlways)
    }
    


    @IBAction func showcalendar(sender: UIButton) {
        print ("show calendar")
        let calendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
        calendarPicker.calendarDelegate = self
       // calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = true
        calendarPicker.tintColor = UIColor.orangeColor()
        //        calendarPicker.barTintColor = UIColor.greenColor()
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        calendarPicker.title = "Activity Selection"
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
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        if (dates.count != 2) {
            print ("ERROR more than 2 dates")
        }
        else
        {
           
            self.date1 = dates[0]
            self.date2 = dates[1]
            
            if (dates[0] > dates[1]) {
                startdate.text = String(dates[1])
                enddate.text = String(dates[0])
                self.date1 = dates[1]
                self.date2 = dates[0]
            }
            else {
                startdate.text = String(dates[0])
                enddate.text = String(dates[1])
                
            }
        print ( "User selected dates: \(startdate.text) and \(enddate.text)")        }
        
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

    
    
@IBAction func cancelfromCharts(segue:UIStoryboardSegue) {
        print ("go back from chart")
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dogdailychart" {
            print ("Prepare to segue to dog daily chart screen \(thepasseddog.slug)")
            let destination = segue.destinationViewController as! DogDailyChart
            destination.dogslug = thepasseddog.slug//self.userslug
            destination.startdate = date1
            destination.enddate = date2
        }
    }
    
}
