//
//  AddCourseViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData

class AddCourseViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var courseTitle: UITextField!
    @IBOutlet weak var courseHours: UITextField!
    @IBOutlet weak var courseMinutes: UITextField!
    @IBOutlet weak var saveAddCourse: UIBarButtonItem!
    @IBOutlet weak var websiteList: UITableView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private var requiredFields:[UITextField] = []
    private var tabFields:[UITextField] = []
    private var tabFieldsIndex = 0
    private var noConstraints = true
    
    private var selectedCell:UITableViewCell?
    private var selectedSite:Site?
    
    private struct Site {
        var uiLabel:String
        var siteName:String
        var url:String
        var icon:String
        init(_ uiLabel:String, _ siteName:String, _ url:String, _ icon:String){
            self.uiLabel = uiLabel
            self.siteName = siteName
            self.url = url
            self.icon = icon
        }
    }
    
    private var sites:[Site] = [
        Site("Udemy", "Udemy", "http://www.udemy.com", "UdemyLogo"),
        Site("Masterclass", "Masterclass", "http://www.masterclass.com", "MasterclassLogo"),
        Site("Lynda", "Lynda", "http://www.lynda.com", "LyndaLogo"),
        Site("Other", "", "", "OtherLogo")
    ]
    
    var delegate: ModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseTitle.delegate = self
        courseHours.delegate = self
        courseMinutes.delegate = self
        tabFields = [courseTitle]
        requiredFields = [courseTitle, courseHours, courseMinutes]
        websiteList.delegate = self
        websiteList.dataSource = self
        websiteList.register(UINib(nibName: "NamedSiteCell", bundle: nil), forCellReuseIdentifier: "NamedSiteCell")
        websiteList.register(UINib(nibName: "OtherSiteCell", bundle: nil), forCellReuseIdentifier: "OtherSiteCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(keyboardShowNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(keyboardDidHideNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardShown(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
            scrollViewBottomConstraint.constant = -keyboardHeight
        }
    }
    
    @objc private func keyboardHidden(keyboardDidHideNotification notification: Notification) {
        scrollViewBottomConstraint.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        courseTitle.becomeFirstResponder()
    }
    
    @IBAction func cancelAddCourse(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAddCourse(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
                totalSecondsDuration = (Int32(courseMinutes.text!)! + Int32(courseHours.text!)! * 60) * 60,
                course = Course(context: context)
            course.duration = totalSecondsDuration
            course.title = courseTitle.text
            course.iconReference = selectedSite?.icon
            course.website = selectedSite?.url
            course.date = Date()
            do {
                try context.save()
                delegate.modalReturnsAddCourse!(true)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error saving context \(error)")
            }
       }
    }
    
}

extension AddCourseViewController:UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableHeight?.constant = self.websiteList.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == sites.count - 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "OtherSiteCell", for: indexPath)
            let downcast = cell as! OtherSiteCell
            downcast.siteLogo.image = UIImage(imageLiteralResourceName: sites[indexPath.row].icon)
            if downcast.siteName.delegate == nil {
                downcast.siteName.delegate = self
                tabFields.append(downcast.siteName)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NamedSiteCell", for: indexPath)
            let downcast = cell as! NamedSiteCell
            downcast.nameLabel.text = sites[indexPath.row].uiLabel
            downcast.siteLogo.image = UIImage(imageLiteralResourceName: sites[indexPath.row].icon)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousCell = selectedCell {
            previousCell.accessoryType = UITableViewCell.AccessoryType.none
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == selectedCell {
                cell.accessoryType = UITableViewCell.AccessoryType.none
                selectedCell = nil
                selectedSite = nil
                if indexPath.row == sites.count - 1 {
                    let downcast = tableView.cellForRow(at: indexPath) as! OtherSiteCell
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        downcast.siteName.resignFirstResponder()
                   }
                }
            } else {
                selectedCell = cell
                selectedSite = sites[indexPath.row]
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                if indexPath.row == sites.count - 1 {
                    let downcast = tableView.cellForRow(at: indexPath) as! OtherSiteCell
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        downcast.siteName.becomeFirstResponder()
                   }
                }
            }
        }
        tableView.reloadData()
        checkSaveEnabledConditions()
    }
    
}

extension AddCourseViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tabFieldsIndex += 1
        if tabFieldsIndex > tabFields.count - 1 {
            tabFieldsIndex = 0
        }
        tabFields[tabFieldsIndex].becomeFirstResponder()
        checkSaveEnabledConditions()
        return true
    }
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let index = tabFields.firstIndex(of: textField) {
            tabFieldsIndex = index
        }
        if textField is OtherSiteTextField {
            if let previousCell = selectedCell {
                previousCell.accessoryType = UITableViewCell.AccessoryType.none
            }
            if let cell = websiteList.cellForRow(at: IndexPath.init(row: sites.count - 1, section: 0)) {
                selectedCell = cell
                selectedSite = sites[sites.count - 1]
                selectedSite?.siteName = textField.text!
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            checkSaveEnabledConditions()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField is OtherSiteTextField && textField.text!.isEmpty && selectedCell is OtherSiteCell {
            selectedCell!.accessoryType = UITableViewCell.AccessoryType.none
            selectedCell = nil
        }
    }
  
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkSaveEnabledConditions()
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
        if selectedCell == nil {
            formComplete = false
        }
        if selectedCell is OtherSiteCell {
            if let downcastCell = selectedCell as? OtherSiteCell {
                if downcastCell.siteName.text!.isEmpty {
                    formComplete = false
                }
            }
        }
        saveAddCourse.isEnabled = formComplete
    }
}
