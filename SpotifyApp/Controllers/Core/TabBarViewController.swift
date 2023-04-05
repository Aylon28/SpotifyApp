//
//  TabBarViewController.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstVC = HomeViewController()
        let secondVC = SearchViewController()
        let thirdVC = LibraryViewController()
        
        firstVC.title = "Browse"
        secondVC.title = "Search"
        thirdVC.title = "Library"
        
        firstVC.navigationItem.largeTitleDisplayMode = .always
        secondVC.navigationItem.largeTitleDisplayMode = .always
        thirdVC.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: firstVC)
        let nav2 = UINavigationController(rootViewController: secondVC)
        let nav3 = UINavigationController(rootViewController: thirdVC)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2, nav3], animated: false)
        
        tabBar.backgroundColor = .systemGray6
    }


}
