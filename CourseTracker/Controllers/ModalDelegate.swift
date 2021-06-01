//
//  ModalDelegate.swift
//  CourseTracker
//
//  Created by Jim on 18/05/2021.
//

import Foundation

@objc protocol ModalDelegate {
    @objc optional func modalReturnsAddCourse(_ success: Bool)
    @objc optional func modalReturnsLogProgress(_ success: Bool)
    @objc optional func modalReturnsEditCourse(_ success: Bool)
}
