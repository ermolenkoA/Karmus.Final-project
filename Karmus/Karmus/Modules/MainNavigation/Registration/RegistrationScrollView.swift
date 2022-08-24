//
//  RegistrationScrollView.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import UIKit

class RegistrationScrollView: UIScrollView {
    var disablePanOnViews: [UIView]?
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let disablePanOnViews = disablePanOnViews else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    let touchPoint = gestureRecognizer.location(in: self)
    let isTouchingAnyDisablingView = disablePanOnViews.first { $0.frame.contains(touchPoint) } != nil

    if gestureRecognizer === panGestureRecognizer && isTouchingAnyDisablingView {
      return false
    }
    return true
  }

}
