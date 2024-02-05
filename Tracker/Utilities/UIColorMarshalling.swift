//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Глеб Капустин on 04.02.2024.
//

import UIKit

final class UIColorMarshalling {
    func hexToUIColor(hex: String) -> UIColor {
        let alpha: CGFloat = 1
        
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func UIColorToHex(color: UIColor, alpha: Bool = false) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red = Int(r * 255.0)
        let green = Int(g * 255.0)
        let blue = Int(b * 255.0)
        
        if alpha {
            let alpha = Int(a * 255.0)
            return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
        } else {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}

