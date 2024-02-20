//
//  TRTabBarController.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

final class TabBarController: UITabBarController {

    private var childViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        
        if UserDefaults.isFirstLaunch() {
            let childViewController = TrackerPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            addChild(childViewController)
            view.addSubview(childViewController.view)
            childViewController.view.frame = view.frame
            childViewController.didMove(toParent: self)
            self.childViewController = childViewController
        }
    }
    
    @objc func removeChildVC(){
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.childViewController?.view.layer.opacity = 0
        } completion: {[weak self] _ in
            guard let self else { return }
            childViewController?.willMove(toParent: nil)
            childViewController?.view.removeFromSuperview()
            childViewController?.removeFromParent()
        }

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
