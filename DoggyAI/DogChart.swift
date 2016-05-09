//
//  DogChart.swift
//  DoggyAI
//
//  Created by ryan on 2016-05-03.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit
import Charts




class DogChart: UIViewController {

    @IBOutlet var barChartView: BarChartView!
    var userslug:String! // the username we got back
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print ("Dog chart userslug is \(self.userslug)")
        ChartDailyActivity()
        
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
    
    @IBAction func savechart(sender: UIButton) {
        barChartView.saveToCameraRoll()
    }
    
    func ChartDailyActivity() {
        print ("Display the daily activity for my dog")
        var months: [String]!
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setChart(months, values: unitsSold)
        
    }
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        barChartView.noDataTextDescription = "GIVE REASON"
        var dataEntries: [BarChartDataEntry] = []
        var colorArray: [UIColor] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
            if values[i] > 10 {
                print("Value: \(values[i])")
                 colorArray.append(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1))
            }
            else {
                
               colorArray.append(UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1))
            }
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.descriptionText = ""
        //chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.colors = colorArray
        //chartDataSet.colors = ChartColorTemplates.joyful()
        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        let ll = ChartLimitLine(limit: 10.0, label: "Target Goal")
        barChartView.rightAxis.addLimitLine(ll)
        barChartView.xAxis.labelPosition = .Bottom
    }
    
    

}
