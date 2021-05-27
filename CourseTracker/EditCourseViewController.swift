//
//  EditCourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 27/05/2021.
//

import UIKit

class EditCourseViewController: UIViewController {

    var delegate: ModalDelegate?
    var course: Course?
    
    @IBOutlet weak var courseTitle: UITextField!
    @IBOutlet weak var hours: UITextField!
    @IBOutlet weak var minutes: UITextField!
    @IBOutlet weak var saveEditCourse: UIBarButtonItem!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var requiredFields:[UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseTitle.text = course?.title

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour]
        formatter.unitsStyle = .positional
        let h = formatter.string(from: TimeInterval(Float(course!.duration)))!
        hours.text = h
        formatter.allowedUnits = [.minute]
        minutes.text = formatter.string(from: TimeInterval(Float(course!.duration) - (Float(h)! * 60 * 60)))
        
        requiredFields = [courseTitle, hours, minutes]
        courseTitle.delegate = self
        hours.delegate = self
        minutes.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(keyboardShowNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(keyboardDidHideNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        checkSaveEnabledConditions()
        // Do any additional setup after loading the view.
    }

    @objc private func keyboardShown(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
            scrollViewBottom.constant = -keyboardHeight
        }
    }

    @objc private func keyboardHidden(keyboardDidHideNotification notification: Notification) {
        scrollViewBottom.constant = 0
    }
    
    @IBAction func cancelEditCourse(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveEditCourse(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
                totalSecondsDuration = (Int32(minutes.text!)! + Int32(hours.text!)! * 60) * 60
            course?.title = courseTitle.text
            course?.duration = totalSecondsDuration
            do {
                try context.save()
                delegate.modalReturnsEditCourse!(true)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error saving context \(error)")
            }
        }
        // self.dismiss(animated: true, completion: nil)
    }
    
    func checkSaveEnabledConditions() {
        var formComplete = true
        for field in requiredFields {
            if let empty = field.text?.isEmpty {
                if empty {
                    formComplete = false
                }
            }
        }
        saveEditCourse.isEnabled = formComplete
    }
    
}

extension EditCourseViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkSaveEnabledConditions()
    }
}
