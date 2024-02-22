//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Глеб Капустин on 21.02.2024.
//

import Foundation

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(update: TrackerCategoryStoreUpdate)
}

final class CategoriesViewModel {
    private let trackerCategoryStore: TrackerCategoryStore
    
    private(set) var categories: [String] = []
    
    var categoriesBinding: Binding<TrackerCategoryStoreUpdate>?
    
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.headers
    }
}

extension CategoriesViewModel: CategoriesSupplementaryVCDelegate {
    func dismissVC(mode: CategoriesSupplementaryVCMode, categoryString: String) {
        trackerCategoryStore.addNewTrackerCategory(TrackerCategory(header: categoryString, trackers: []))
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.headers
        categoriesBinding?(update)
    }
    
}
