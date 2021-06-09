//
//  EditCourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 27/05/2021.
//

import UIKit

class EditCourseViewController: UIViewController, MustSizeToKeyboard {
    
    @IBOutlet weak var courseTitle: UITextField!
    @IBOutlet weak var hours: UITextField!
    @IBOutlet weak var minutes: UITextField!
    @IBOutlet weak var saveEditCourse: UIBarButtonItem!
    @IBOutlet weak var allScrollView: UIScrollView!
    
    var requiredFields:[UITextField] = []
    var viewMustSizeToKeyboard: UIScrollView?
    var delegate: ModalDelegate?
    var course: Course?
    
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
        checkSaveEnabledConditions()
        
        viewMustSizeToKeyboard = allScrollView
        registerMustSizeToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        courseTitle.becomeFirstResponder()
    }
    
    @IBAction func cancelEditCourse(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveEditCourse(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            let totalSecondsDuration = (Int32(minutes.text!)! + Int32(hours.text!)! * 60) * 60
            course?.title = courseTitle.text
            course?.duration = totalSecondsDuration
            do {
                try PersistentContainer.sharedInstance.context.save()
                delegate.modalReturnsEditCourse!(true)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error saving context saveEditCourse \(error)")
            }
        }
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
        
        var formErrors = false
        if let h = Int(hours.text!), let m = Int(minutes.text!) {
            if h == 0 && m == 0 {
                formErrors = true
            }
        }
        if saveEditCourse.isEnabled {
            saveEditCourse.isEnabled = formErrors == false
        }
    }
    
}

extension EditCourseViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkSaveEnabledConditions()
    }
}
