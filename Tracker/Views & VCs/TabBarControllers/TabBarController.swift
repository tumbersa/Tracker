//
//  TRTabBarController.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func configure(){
        tabBar.tintColor = .trBlue
        tabBar.unselectedItemTintColor = .gray
        
        let trackerVC = TrackersViewController()
        trackerVC.title = "Трекеры"
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .trTabbarItemTracker), tag: 0)
        
        let statsVC = StatisticsViewController()
        statsVC.tabBarItem =  UITabBarItem(title: "Статистика", image: UIImage(resource: .trTabbarItemStats), tag: 1)
        viewControllers = [UINavigationController(rootViewController: trackerVC), statsVC]
    }
}
