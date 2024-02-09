//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Глеб Капустин on 28.01.2024.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let daysOfWeek = value as? [DaysOfWeek] else { return nil }
        do {
            let data = try JSONEncoder().encode(daysOfWeek)
            return data as NSData
        } catch {
            print("Error encoding daysOfWeek: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            print("Nil data value in \(#function)")
            return nil
        }
        
        do {
            let daysOfWeek = try JSONDecoder().decode([DaysOfWeek].self, from: data)
            return daysOfWeek
        } catch {
            print("Error decoding daysOfWeek: \(error)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(String(describing: DaysValueTransformer.self)))
    }
}
