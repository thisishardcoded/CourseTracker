//
//  MustSizeToKeyboard.swift
//  CourseTracker
//
//  Created by Jim on 09/06/2021.
//

import UIKit

protocol MustSizeToKeyboard {
    var viewMustSizeToKeyboard: UIScrollView? { get set }
    func keyboardShown(keyboardShowNotification notification: Notification)
    func keyboardHidden(keyboardDidHideNotification notification: Notification)
    func registerMustSizeToKeyboard()
}

extension MustSizeToKeyboard {
    func registerMustSizeToKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil, using: keyboardShown)
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil, using: keyboardHidden)
    }
    func keyboardShown(keyboardShowNotification notification: Notification){
        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            viewMustSizeToKeyboard?.contentInset = contentInset
            viewMustSizeToKeyboard?.scrollIndicatorInsets = contentInset
        }
    }
    func keyboardHidden(keyboardDidHideNotification notification: Notification) {
        viewMustSizeToKeyboard?.contentInset = UIEdgeInsets.zero
        viewMustSizeToKeyboard?.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
