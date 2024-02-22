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

protocol CategoriesSupplementaryVCDelegate: AnyObject {
    func dismissVC(mode: CategoriesSupplementaryVCMode, oldHeaderCategory: String, newHeaderCategory: String)
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
    
    func dismissVC(mode: CategoriesSupplementaryVCMode, oldHeaderCategory: String, newHeaderCategory: String) {
        if mode == .create {
            trackerCategoryStore.addNewTrackerCategory(TrackerCategory(header: newHeaderCategory, trackers: []))
        } else {
            trackerCategoryStore.updateHeader(oldValue: oldHeaderCategory, newValue: newHeaderCategory)
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.headers
        categoriesBinding?(update)
    }
    
}
