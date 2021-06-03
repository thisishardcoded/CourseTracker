//
//  AllCoursesViewController.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData

class AllCoursesViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var allCourses: UITableView!
    
    var coursesArray:[Course] = []
    var selectedCourseIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        allCourses.dataSource = self
        allCourses.delegate = self
        allCourses.register(UINib(nibName: "CourseCell", bundle: nil), forCellReuseIdentifier: "CourseCell")
        allCourses.register(UINib(nibName: "AddCourseCell", bundle: nil), forCellReuseIdentifier: "AddCourseCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let rect:CGRect = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 156, height: 35))
        let titleView:UIView = UIView.init(frame: rect)
        let image:UIImage = UIImage.init(named: "onCourse")!
        let image_view:UIImageView = UIImageView.init(image: image)
        image_view.frame = CGRect.init(x: 0, y: 0, width: 156, height: 35)
        image_view.center = CGPoint.init(x: titleView.center.x, y: titleView.center.y)
        titleView.addSubview(image_view)
        navigationItem.titleView = titleView
        loadCourses()
    }
    
    func loadCourses(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request:NSFetchRequest<Course> = Course.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        do {
            coursesArray = try context.fetch(request)
        } catch {
            print("Error loading context \(error)")
        }
        allCourses.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCourseView" {
            let vc = segue.destination as! AddCourseViewController
            vc.delegate = self
        }
        if segue.identifier == "courseView" {
            let vc = segue.destination as! CourseViewController
            vc.course = coursesArray[selectedCourseIndex!]
        }
    }
    
}

extension AllCoursesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < coursesArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCell
            cell.courseTitle.text = coursesArray[indexPath.row].title
            cell.courseSubTitle.text = coursesArray[indexPath.row].website
            cell.courseLogo.image = UIImage(imageLiteralResourceName: coursesArray[indexPath.row].iconReference!)
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "AddCourseCell", for: indexPath) as! AddCourseCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < coursesArray.count {
            selectedCourseIndex = indexPath.row
            performSegue(withIdentifier: "courseView", sender: nil)
        } else {
            performSegue(withIdentifier: "addCourseView", sender: nil)
        }
    }
      
}

extension AllCoursesViewController: ModalDelegate {
    func modalReturnsAddCourse(_ success: Bool) {
        if success {
            loadCourses()
        }
    }
}
