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
        guard let data = value as? [DaysOfWeek] else { return nil }
        return try? JSONEncoder().encode(data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([DaysOfWeek].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(String(describing: DaysValueTransformer.self)))
    }
}
