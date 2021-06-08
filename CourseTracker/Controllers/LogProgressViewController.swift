//
//  LogProgressViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData

class LogProgressViewController: UIViewController {

    @IBOutlet weak var hoursTaken: UITextField!
    @IBOutlet weak var minutesCompleted: UITextField!
    @IBOutlet weak var hoursCompleted: UITextField!
    @IBOutlet weak var minutesTaken: UITextField!
    @IBOutlet weak var saveLogProgress: UIBarButtonItem!
    @IBOutlet weak var allForms: UIStackView!
    @IBOutlet weak var allScrollView: UIScrollView!
    
    private var allFields:[UITextField] = []
    
    var delegate: ModalDelegate?
    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hoursTaken.delegate = self
        minutesCompleted.delegate = self
        hoursCompleted.delegate = self
        minutesTaken.delegate = self
        allFields = [hoursTaken, minutesCompleted, hoursCompleted, minutesTaken]
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(keyboardShowNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(keyboardDidHideNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardShown(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            allScrollView.contentInset = contentInset
            allScrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc private func keyboardHidden(keyboardDidHideNotification notification: Notification) {
        allScrollView.contentInset = UIEdgeInsets.zero
        allScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hoursTaken.becomeFirstResponder()
    }
    
    @IBAction func saveLogProgress(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
                totalSecondsCompleted = (Int32(minutesCompleted.text!)! + (Int32(hoursCompleted.text!)! * 60)) * 60,
                totalSecondsTaken = (Int32(minutesTaken.text!)! + (Int32(hoursTaken.text!)! * 60)) * 60,
                logItem = LogItem(context: context)
            logItem.completed = totalSecondsCompleted
            logItem.taken = totalSecondsTaken
            logItem.date = Date()
            logItem.parentCourse = course
            
            do {
                try context.save()
                delegate.modalReturnsLogProgress!(true)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error saving context \(error)")
            }
        }
        // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelLogProgresss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LogProgressViewController:UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        var formComplete = true
        for field in allFields {
            if let empty = field.text?.isEmpty {
                if empty {
                    formComplete = false
                }
            }
        }
        saveLogProgress.isEnabled = formComplete
        
        var formErrors = false
        if let ht = Int(hoursTaken.text!), let mt = Int(minutesTaken.text!) {
            if ht == 0 && mt == 0 {
                formErrors = true
            }
        }
        if let hc = Int(hoursCompleted.text!), let mc = Int(minutesCompleted.text!) {
            if hc == 0 && mc == 0 {
                formErrors = true
            }
        }
        if saveLogProgress.isEnabled {
            saveLogProgress.isEnabled = formErrors == false
        }
    }
    
}
