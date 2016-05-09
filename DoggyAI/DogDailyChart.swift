
//
//  DogDailyChart.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-06.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit
import Charts


class DogDailyChart: UIViewController, ChartViewDelegate {

   
    
    @IBAction func ChartButton(sender: UIButton) {
        print ("Chart")
       
        let hours = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
        
        var line4 = [Double]()  //list of fitbark points moved from INT to double
        var line1 = [Double]()  //list of min active  moved from INT to double
        var line2 = [Double]()  //list of minutes of rest
        var line3 = [Double]()  //list of minutes of play
        
        for item in self.minute_active_list {
            line1.append(Double(item))
        }
        for item in self.minute_rest_list {
            line2.append(Double(item))
        }
        
        for item in self.minute_play_list {
            line3.append(Double(item))
        }
        
    
        
        

       // let line2 = [0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
       // let line3 = [0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
       // let line4 = [0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        self.lineChartView.delegate = self
        self.lineChartView.descriptionText = "Tap node for details"
        self.lineChartView.descriptionTextColor = UIColor.whiteColor()
        self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
        self.lineChartView.noDataText = "No data provided"
       
        
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < hours.count; i++ {
            yVals1.append(ChartDataEntry(value: line1[i], xIndex: i))
        }
        
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Active Dog")
        set1.axisDependency = .Left // Line will correlate with left axis values
        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        set1.setCircleColor(UIColor.redColor())
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.redColor()
        set1.highlightColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        
        var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < hours.count; i++ {
            yVals2.append(ChartDataEntry(value: line2[i], xIndex: i))
        }
        
        let set2: LineChartDataSet = LineChartDataSet(yVals: yVals2, label: "Rest Set")
        set2.axisDependency = .Left // Line will correlate with left axis values
        set2.setColor(UIColor.greenColor().colorWithAlphaComponent(0.5))
        set2.setCircleColor(UIColor.greenColor())
        set2.lineWidth = 2.0
        set2.circleRadius = 6.0
        set2.fillAlpha = 65 / 255.0
        set2.fillColor = UIColor.greenColor()
        set2.highlightColor = UIColor.whiteColor()
        set2.drawCircleHoleEnabled = true
        
        var yVals3 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < hours.count; i++ {
            yVals3.append(ChartDataEntry(value: line3[i], xIndex: i))
        }
        
        let set3: LineChartDataSet = LineChartDataSet(yVals: yVals3, label: "Play Set")
        set3.axisDependency = .Left // Line will correlate with left axis values
        set3.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        set3.setCircleColor(UIColor.blueColor())
        set3.lineWidth = 2.0
        set3.circleRadius = 6.0
        set3.fillAlpha = 65 / 255.0
        set3.fillColor = UIColor.blueColor()
        set3.highlightColor = UIColor.whiteColor()
        set3.drawCircleHoleEnabled = true
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        
        //4 - pass our months in for our x-axis label value along with our dataSets
        let data: LineChartData = LineChartData(xVals: hours, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        
        //5 - finally set our data
        self.lineChartView.data = data
    }
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet var playvalue: UILabel!
    @IBOutlet var activevalue: UILabel!
    @IBOutlet var restvalue: UILabel!
    @IBOutlet var ptsleftvalue: UILabel!
    @IBOutlet var targetvaluelabel: UILabel!   //done
    @IBOutlet var ptsvaluelabel: UILabel!      //done
    @IBOutlet var percentagelabel: UILabel!    //done
    var targetvalue = 0
    var percentcomplete:Double!
    var ptsvalue = 0
    var minresttotal = 0
    var minacttotal = 0
    var minplaytotal = 0
    var dogslug:String! // the string for the user that was passed over from previous controller
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var startdate:NSDate!  //start date for daily activity
    var enddate:NSDate! //end date for daily activity that was passed
    var fitbptlist:[Int] = []   // the fitbark points we received for each hour
    var minute_active_list:[Int] = []  //the number of minutes active each hour
    var minute_play_list:[Int] = []  //the number of minutes playing each hour
    var minute_rest_list:[Int] = []  //the number of minutes resting each hour
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self,
                                               selector: #selector(DogDailyChart.updateData), userInfo: nil, repeats: true)
        

       // print("The user's dogs slug is: \(dogslug) ")
        GetDailyActivity(dogslug, startdate:startdate, enddate:enddate )
        getDailyGoals ()
        drawCircle()
        
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
    
    
    func drawCircle() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 100,y: 100), radius: CGFloat(30), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        shapeLayer.fillColor = UIColor.redColor().CGColor
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(shapeLayer)
    }
    
    
    func GetDailyActivity(dogslug:String, startdate:NSDate, enddate:NSDate) {
        
        //double check before we save the record for the dog that we didn't already do it
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
      //  let mydate = dateFormatter.dateFromString(startdate)
        //print("Savelist of activities - dog date is: \(thedate) and \(mydate)")
        //let adogslug = "AAAA"
        var fitbarkpts:Int = 0
       
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, startdate)
        let query = CKQuery(recordType: "ActivityRecord", predicate: predicate)
      //  print ("Query: \(query)")
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                  //  let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                    //print ("we have a record \(records)")
                    for activity in records! {
                        self.fitbptlist = activity.objectForKey("fitbarkpts") as! [Int]
                        self.minute_active_list = activity.objectForKey("minute_active_list") as! [Int]
                        self.minute_rest_list = activity.objectForKey("minute_rest_list") as! [Int]
                        self.minute_play_list = activity.objectForKey("minute_play_list") as! [Int]

                        //  print("Dog Owner  token date: \(activity["fitbarkpts"])")
                     //   fitbptlist = Intactivity["fitbarkpts"]
                    }
                    print("List of points: \(self.fitbptlist)")
                   // print("MInutes of active: \(self.minute_active_list)")
                    for counter in self.fitbptlist {
                      fitbarkpts = fitbarkpts + counter
                    }

                    for hours in self.minute_active_list {
                        self.minacttotal = self.minacttotal + hours
                    }
                    
                    for hours in self.minute_rest_list {
                        self.minresttotal = self.minresttotal + hours
                    }
                    
                    for hours in self.minute_play_list {
                        self.minplaytotal = self.minplaytotal + hours
                    }
                    
                   // print ("Counter: \(fitbarkpts)")
                        self.ptsvalue = fitbarkpts
                  

                    
                }
                else {
                    //we have no records                    
                }
                
            }
        })
        
        //if we already have saved it, we may want to see if it changed and modify it
        
        
        
    }

    
    
    
    func getDailyGoals () // need to use an input of dogslug {
    {
        print ("Get dog's current daily and future goals")
        var daily_goals = [DailyGoal] () // an array that will contain all our daily goals
        let predicate = NSPredicate(format: "slug BEGINSWITH %@", dogslug)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        print ("Query: \(query)")
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    //print ("we have a record \(records)")
                    for goals in records! {
                        // fitbptlist = activity.objectForKey:"fitbarkptsfitbptlist")
                        var goallist = goals.objectForKey("daily_goals") as! [String]
                       // print("Dog Goals: \(goallist[0])")
                     
                        self.targetvalue = Int(goallist[0])!
                    }
                    

                }
                else {
                    //we have no records
                }
                
            }
        })  }


    
    
    func updateData () {
        //all this does is update a lable
           self.targetvaluelabel.text = String(self.targetvalue)
           self.ptsvaluelabel.text = String(ptsvalue)
        
               
        if self.targetvalue > 0 {
           
            percentcomplete = Double((Double(self.ptsvalue) / Double(self.targetvalue)) * 100)
            self.percentagelabel.text = String(self.percentcomplete)
            self.playvalue.text = String(self.minplaytotal)
            self.activevalue.text = String(self.minacttotal)
            self.restvalue.text = String(self.minresttotal)
            view.bringSubviewToFront(self.percentagelabel)
            // print ("\(percentcomplete) \(self.ptsvalue) \(self.targetvalue)")
        }
        
    }
}