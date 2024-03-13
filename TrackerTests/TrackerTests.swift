//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Глеб Капустин on 13.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersVC() throws {
        let vc = TrackersViewController(viewModel: TrackersViewModel())
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))  
    }

}
