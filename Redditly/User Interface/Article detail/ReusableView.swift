//
//  ReusableView.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-05.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, identifier: String? = nil) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: identifier ?? T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }

        return cell
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }
