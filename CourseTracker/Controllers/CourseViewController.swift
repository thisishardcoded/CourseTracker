//
//  CourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData

class CourseViewController: UIViewController {

    // heading
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var websiteSubtitle: UILabel!
    
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
    
    var course:Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        timeCompleted.text = formatter.string(from: TimeInterval(totalTimeCompleted))!
        let p = (Float(totalTimeCompleted) / Float(course!.duration)) * 100
        percentageCompleted.text = "\(String(format: "%.0f", p))%"
        
        undoLogsButton.isEnabled = (course!.logs!.count > 0)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logProgressView" {
            let vc = segue.destination as! LogProgressViewController
            vc.delegate = self
            vc.course = course!
        }
        if segue.identifier == "editCourseView" {
            let vc = segue.destination as! EditCourseViewController
            vc.delegate = self
            vc.course = course!
        }
    }
    
    @IBAction func undoLastLogPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear Most Recent", style: .default, handler: clearLastLog))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: clearAllLogs))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // known bug fix
        if let constraints = alert.view?.subviews.first?.constraints { for constraint in constraints { if constraint.constant < 0 { constraint.priority = UILayoutPriority(rawValue: constraint.priority.rawValue - 1) } } }
        
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    func clearLastLog(action: UIAlertAction) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
            sortedItems = (course!.logs as! Set<LogItem>).sorted(by: { $0.date! < $1.date! })
        context.delete(sortedItems[sortedItems.count - 1])
        do {
            try context.save()
            updateAll()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func clearAllLogs(action: UIAlertAction) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
            sortedItems = (course!.logs as! Set<LogItem>).sorted(by: { $0.date! < $1.date! })
        // BETTER ???
        for i in 0...sortedItems.count - 1 {
            context.delete(sortedItems[i])
        }
        do {
            try context.save()
            updateAll()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    @IBAction func deleteCoursePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete course", style: .destructive, handler: deleteEntireCourse))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // known bug fix
        if let constraints = alert.view?.subviews.first?.constraints { for constraint in constraints { if constraint.constant < 0 { constraint.priority = UILayoutPriority(rawValue: constraint.priority.rawValue - 1) } } }
        
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    func deleteEntireCourse(action: UIAlertAction) {
        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogItem")
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.executeAndMergeChanges(using: batchDeleteRequest)
//            navigationController?.popViewController(animated: true)
//        } catch {
//            print("Error saving context \(error)")
//        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext/*,
            sortedItems = (course!.logs as! Set<LogItem>).sorted(by: { $0.date! < $1.date! })*/
        
//        if sortedItems.count > 0 {
//            for i in 0...sortedItems.count - 1 {
//                context.delete(sortedItems[i])
//            }
//        }
        context.delete(course!)
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error saving context \(error)")
        }
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

extension NSManagedObjectContext {
    
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
