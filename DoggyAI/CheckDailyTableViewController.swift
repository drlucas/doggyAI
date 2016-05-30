//
//  CheckDailyTableViewController.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-29.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import Charts
import CloudKit

class CheckDailyTableViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    
    var fitbptlist:[Int] = []   // the fitbark points we received for each hour

    //these next 5 come from table
    var dogslug = ""
    var chartdate:NSDate!
    var pass_play_list: [Int] =  []  //the number of minutes playing each hour
    var pass_rest_list: [Int] =  []  //the number of minutes resting each hour
    var pass_active_list: [Int] =  [] //the number of minutes active each hour
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("Dog: \(dogslug)")
        print ("Date: \(chartdate)")
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        ChartIt()
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
    
    
    func ChartIt() {
        print ("Chart out the results")
        
        let hours = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
        
        var line4 = [Double]()  //list of fitbark points moved from INT to double
        var line1 = [Double]()  //list of min active  moved from INT to double
        var line2 = [Double]()  //list of minutes of rest
        var line3 = [Double]()  //list of minutes of play
        
      //  for item in self.minute_active_list {
        for item in self.pass_active_list {
            print (item)
            line1.append(Double(item))
        }
        for item in self.pass_rest_list {
            line2.append(Double(item))
        }
        
        for item in self.pass_play_list {
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


}
