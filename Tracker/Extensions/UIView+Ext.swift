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
    
    func addGradientBorder(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = nil
        gradientLayer.mask = shapeLayer
    }
}
