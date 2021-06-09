//
//  PersistentContainer.swift
//  CourseTracker
//
//  Created by Jim on 09/06/2021.
//

import UIKit

class PersistentContainer {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let sharedInstance = PersistentContainer()
}
