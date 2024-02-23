//
//  TrackerPageViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 19.02.2024.
//

import UIKit

final class TrackerPageViewController: UIPageViewController {

    private lazy var pages: [UIViewController] = {
        let onboardingVC1 = OnboardingViewController()
        onboardingVC1.set(image: .trOnboarding1, title: "Отслеживайте только то, что хотите")
        
        let onboardingVC2 = OnboardingViewController()
        onboardingVC2.set(image: .trOnboarding2, title: "Даже если это \nне литры воды и йога")
        
        return [onboardingVC1, onboardingVC2]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .trBlack
        pageControl.pageIndicatorTintColor = .trBlack.withAlphaComponent(0.3)
        return pageControl
    }()
    
    private let exitButton: UIButton = {
        let exitButton = UIButton()
        exitButton.layer.cornerRadius = 20
        exitButton.backgroundColor = .trBlack
        exitButton.setTitle("Вот это технологии!", for: .normal)
        exitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return exitButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func configure(){
    
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        exitButton.addTarget(parent, action: #selector(TabBarController.removeChildVC), for: .touchUpInside)
        view.addSubviews(pageControl, exitButton)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: exitButton.topAnchor, constant: -24),
            
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            exitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension TrackerPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages[pages.count - 1]
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages[0]
        }
        
        return pages[nextIndex]
    }
}

extension TrackerPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
