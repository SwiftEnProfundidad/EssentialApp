//
//  UITableView + HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 11/11/24.
//

import UIKit

extension UITableView {
  func sizeHeaderToFit() {
    guard let headerView = tableHeaderView else { return }
    let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    let needsFrameUpdate = headerView.frame.size.height != size.height
    if needsFrameUpdate {
      headerView.frame.size.height = size.height
      tableHeaderView = headerView
    }
  }
}
