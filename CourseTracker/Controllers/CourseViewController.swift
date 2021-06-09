//
//  CourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData
import Charts

class CourseViewController: UIViewController, ChartViewDelegate {

    // heading
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var websiteSubtitle: UILabel!
    var studyFactorText:String = ""
    
    // secondary stats
    @IBOutlet weak var courseLength: UILabel!
    @IBOutlet weak var timeSpent: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    
    // graph
    @IBOutlet weak var percentageCompleted: UILabel!
    
    // primary stats
    @IBOutlet weak var averageRatio: UILabel!
    @IBOutlet weak var estimatedTimeRemaining: UILabel!
    
    @IBOutlet weak var undoLogsButton: UIBarButtonItem!
    
    @IBOutlet weak var graph: UIImageView!
    
    @IBOutlet weak var logProgressButton: UIBarButtonItem!
    var course:Course?
    
    lazy var chart: PieChartView = {
        let chart = PieChartView()
        return chart
    }()
    let chartColours = [UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.00), UIColor(red: 0.22, green: 0.66, blue: 0.80, alpha: 1.00)]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialise chart
        graph.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.centerXAnchor.constraint(equalTo: graph.centerXAnchor).isActive = true
        chart.centerYAnchor.constraint(equalTo: graph.centerYAnchor).isActive = true
        chart.heightAnchor.constraint(equalTo: graph.heightAnchor, multiplier: 1.0).isActive = true
        let widthConstraint = NSLayoutConstraint(item: chart, attribute: .height, relatedBy: .equal, toItem: chart, attribute: .width, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([widthConstraint])
        chart.drawEntryLabelsEnabled = false
        chart.holeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        chart.legend.enabled = false
        chart.drawSlicesUnderHoleEnabled = false
        chart.transparentCircleRadiusPercent = 0
        
        // initialise
        updateAll()
        
    }
    
    @IBAction func tapURL(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: (course?.website)!) {
            UIApplication.shared.open(url)
        }
    }
    
    func updateAll(){
        
        courseTitle.text = course?.title
        websiteSubtitle.text = course?.website
      
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute]
        timeFormatter.unitsStyle = .abbreviated
        timeFormatter.zeroFormattingBehavior = .dropAll
           
        courseLength.text = timeFormatter.string(from: TimeInterval(course!.duration))!

        let logs = course!.logs as! Set<LogItem>
        var totalTimeCompleted:Int32 = 0,
            totalTimeTaken:Int32 = 0
        for log in logs {
            totalTimeCompleted += log.completed
            totalTimeTaken += log.taken
        }
        
        timeSpent.text = timeFormatter.string(from: TimeInterval(totalTimeTaken))!
        let average = totalTimeTaken > 0 ? Float(totalTimeCompleted) / Float(totalTimeTaken) : 0
        
        let numFormatter = NumberFormatter()
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 2
        
        averageRatio.text = numFormatter.string(from: NSNumber(value: average))
        let trueEstimate = Float((course!.duration - totalTimeCompleted)) / average
        let estimate = trueEstimate < 0 ? 0 : trueEstimate
       
        estimatedTimeRemaining.text = totalTimeTaken > 0 ? timeFormatter.string(from: TimeInterval( estimate ))! : courseLength.text
        
        timeCompleted.text = timeFormatter.string(from: TimeInterval(totalTimeCompleted))!
        var p = (Float(totalTimeCompleted) / Float(course!.duration)) * 100
        logProgressButton.isEnabled = p < 100
        percentageCompleted.text = "\(String(format: "%.0f", p))%"
        
        undoLogsButton.isEnabled = (course!.logs!.count > 0)
        
        if p > 100 {
            p = 100
        }
        let dataEntries: [ChartDataEntry] = [
            PieChartDataEntry(value: Double(100 - p), label: "", data: ""),
            PieChartDataEntry(value: Double(p), label: "", data: "")
        ]
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = chartColours
        
        pieChartDataSet.drawValuesEnabled = false
        pieChartDataSet.selectionShift = 0
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chart.data = pieChartData
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logProgressView" {
            let vc = segue.destination as! LogProgressViewController
            vc.delegate = self
            vc.course = course
        }
        if segue.identifier == "editCourseView" {
            let vc = segue.destination as! EditCourseViewController
            vc.delegate = self
            vc.course = course
        }
    }
    
    @IBAction func undoLastLogPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear most recent log", style: .default, handler: clearLastLog))
        alert.addAction(UIAlertAction(title: "Clear all logs", style: .destructive, handler: clearAllLogs))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = UIColor(named: "AppGreen")
        
        // known bug fix
        if let constraints = alert.view?.subviews.first?.constraints { for constraint in constraints { if constraint.constant < 0 { constraint.priority = UILayoutPriority(rawValue: constraint.priority.rawValue - 1) } } }
        
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    func clearLastLog(action: UIAlertAction) {
        let sortedItems = (course!.logs as! Set<LogItem>).sorted(by: { $0.date! < $1.date! })
        PersistentContainer.sharedInstance.context.delete(sortedItems[sortedItems.count - 1])
        do {
            try PersistentContainer.sharedInstance.context.save()
            updateAll()
        } catch {
            print("Error saving context clearLastLog \(error)")
        }
    }
    
    func clearAllLogs(action: UIAlertAction) {
        let sortedItems = (course!.logs as! Set<LogItem>).sorted(by: { $0.date! < $1.date! })
        for i in 0...sortedItems.count - 1 {
            PersistentContainer.sharedInstance.context.delete(sortedItems[i])
        }
        do {
            try PersistentContainer.sharedInstance.context.save()
            updateAll()
        } catch {
            print("Error saving context clearAllLogs \(error)")
        }
    }
    
    @IBAction func deleteCoursePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "This cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete course", style: .destructive, handler: deleteEntireCourse))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = UIColor(named: "AppGreen")
        
        // known bug fix
        if let constraints = alert.view?.subviews.first?.constraints { for constraint in constraints { if constraint.constant < 0 { constraint.priority = UILayoutPriority(rawValue: constraint.priority.rawValue - 1) } } }
        
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    func deleteEntireCourse(action: UIAlertAction) {

        PersistentContainer.sharedInstance.context.delete(course!)
        do {
            try PersistentContainer.sharedInstance.context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error saving context deleteEntireCourse \(error)")
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
   
}

extension CourseViewController: ModalDelegate {
    
    func modalReturnsLogProgress(_ success: Bool) {
        updateAll()
    }
    
    func modalReturnsEditCourse(_ success: Bool) {
        updateAll()
    }
    
}
