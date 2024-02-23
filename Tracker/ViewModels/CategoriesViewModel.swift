//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Глеб Капустин on 21.02.2024.
//

import Foundation

protocol CategoriesViewModelProtocol: CategoriesSupplementaryVCDelegate {
    var categories: [String] { get }
    
    var insertOrEditCategoryBinding: Binding<TrackerCategoryStoreUpdate>? {get set}
    var deleteCategoryBinding: Binding<TrackerCategoryStoreUpdate>? { get set }
    func deleteTrackerCategory(headerTrackerCategory: String)
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(update: TrackerCategoryStoreUpdate, type: TrackerUpdateType)
}

protocol CategoriesSupplementaryVCDelegate: AnyObject {
    func dismissVC(mode: CategoriesSupplementaryVCMode, oldHeaderCategory: String, newHeaderCategory: String)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    private let trackerCategoryStore: TrackerCategoryStore
    
    private(set) var categories: [String] = []
    
    var insertOrEditCategoryBinding: Binding<TrackerCategoryStoreUpdate>?    
    var deleteCategoryBinding: Binding<TrackerCategoryStoreUpdate>?
    
    
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore.shared) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.headers
    }
    
    func deleteTrackerCategory(headerTrackerCategory: String){
        trackerCategoryStore.deleteCategory(headerCategory: headerTrackerCategory)
    }
}

extension CategoriesViewModel: CategoriesSupplementaryVCDelegate {
    
    func dismissVC(mode: CategoriesSupplementaryVCMode, oldHeaderCategory: String, newHeaderCategory: String) {
        if mode == .create {
            trackerCategoryStore.addHeader(headerCategory: newHeaderCategory)
        } else {
            trackerCategoryStore.updateHeader(oldValue: oldHeaderCategory, newValue: newHeaderCategory)
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(update: TrackerCategoryStoreUpdate, type: TrackerUpdateType ) {
        categories = trackerCategoryStore.headers
        print(type)
        switch type {
        case .insert, .edit, .update:
            insertOrEditCategoryBinding?(update)
        case .delete:
            deleteCategoryBinding?(update)
        }
    }
    
}
