//
//  File.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView..., isTamic: Bool = false){
        for view in views {
            self.addSubview(view)
            if !isTamic { view.translatesAutoresizingMaskIntoConstraints = false }
        }
    }
}
