//
//  TRTabBarController.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

final class TRTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func configure(){
        tabBar.tintColor = .trBlue
        tabBar.unselectedItemTintColor = .gray
        
        let trackerVC = TrackersVC()
        trackerVC.title = "Трекеры"
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .trTabbarItemTracker), tag: 0)
        
        let statsVC = StatsVC()
        statsVC.tabBarItem =  UITabBarItem(title: "Статистика", image: UIImage(resource: .trTabbarItemStats), tag: 1)
        viewControllers = [UINavigationController(rootViewController: trackerVC), statsVC]
    }
}
