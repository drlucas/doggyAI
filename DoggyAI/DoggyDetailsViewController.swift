//
//  DoggyDetailsViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-01.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit


class DoggyDetailsViewController: UIViewController, EPCalendarPickerDelegate  {
 
    
    @IBOutlet weak var enddate: UILabel!
    @IBOutlet weak var startdate: UILabel!
    @IBOutlet var dognamelabel: UILabel!
    var thepasseddog:Dog!
    var passedName:String!
    var passedSlug:String!
    var date1:NSDate!
    var date2:NSDate!
    var userslug:String! // the string for the user that was passed over from previous controller
    
    @IBOutlet var thedogpic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        date1 = NSDate()
        date2 = NSDate()
        
        print("Im in the dog table view now")
        print("Passed dog: \(thepasseddog.slug)")
        
        dognamelabel.text = thepasseddog.name
        let decodedData = NSData(base64EncodedString:  thepasseddog.image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        self.thedogpic.image = decodedImage
        
        
    

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
