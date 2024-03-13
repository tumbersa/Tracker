//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.03.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        if let configuration = AppMetricaConfiguration(apiKey: "ef501a87-a428-4f8d-ac72-db8384f6d28c") {
            configuration.areLogsEnabled = true
            AppMetrica.activate(with: configuration)
        }
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("DID FAIL REPORT EVENT: %@", event)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

