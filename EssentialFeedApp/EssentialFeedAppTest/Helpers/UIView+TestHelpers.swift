//
//  UIView+TestHelpers.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 12/11/24.
//

import UIKit

extension UIView {
  func enforceLayoutCycle() {
    layoutIfNeeded()
    RunLoop.current.run(until: Date())
  }
}
