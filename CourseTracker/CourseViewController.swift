//
//  CourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit

class CourseViewController: UIViewController {

    // heading
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var websiteSubtitle: UILabel!
    
    // secondary stats
    @IBOutlet weak var courseLength: UILabel!
    @IBOutlet weak var timeSpent: UILabel!
    
    // graph
    @IBOutlet weak var percentageCompleted: UILabel!
    
    // primary stats
    @IBOutlet weak var averageRatio: UILabel!
    @IBOutlet weak var estimatedTimeRemaining: UILabel!
    
    var course:Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
          
        courseTitle.text = course?.title
        websiteSubtitle.text = course?.website
        
        updateStats()
        
    }
    
    func updateStats(){
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
           
        courseLength.text = formatter.string(from: TimeInterval(course!.duration))!

        let logs = course!.logs as! Set<LogItem>
        var totalTimeCompleted:Int32 = 0,
            totalTimeTaken:Int32 = 0
        for log in logs {
            totalTimeCompleted += log.completed
            totalTimeTaken += log.taken
        }
        
        timeSpent.text = formatter.string(from: TimeInterval(totalTimeTaken))!
        let average = totalTimeTaken > 0 ? Float(totalTimeCompleted) / Float(totalTimeTaken) : 0
        averageRatio.text = String(format: "%.3f", average)
        estimatedTimeRemaining.text = totalTimeTaken > 0 ? formatter.string(from: TimeInterval( Float((course!.duration - totalTimeCompleted)) / average ))! : courseLength.text
        print(formatter.string(from: TimeInterval(totalTimeCompleted))!)
        let p = (Float(totalTimeCompleted) / Float(course!.duration)) * 100
        percentageCompleted.text = "\(String(format: "%.0f", p))%"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logProgressView" {
            let vc = segue.destination as! LogProgressViewController
            vc.delegate = self
            vc.course = course!
        }
    }
    
}

extension CourseViewController: ModalDelegate {
    
    func modalReturnsLogProgress(_ success: Bool) {
        updateStats()
    }
    
}


