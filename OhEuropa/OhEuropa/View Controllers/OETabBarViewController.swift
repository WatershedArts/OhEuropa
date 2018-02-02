//
//  OETabBarViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 31/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//
//http://blog.adambardon.com/how-to-create-custom-tab-bar-in-swift-part-1/


import UIKit
import FontAwesome_swift

class OETabBarViewController: UITabBarController, OECustomTabBarDataSource, OECustomTabBarDelegate {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tabBar.isHidden = true
		self.selectedIndex = 0
		
		let customTabBar = OECustomTabBar(frame: self.tabBar.frame)
		customTabBar.datasource = self
		customTabBar.delegate = self
		customTabBar.setup()
		
		
		self.view.addSubview(customTabBar)
    }

	func tabBarItemsInCustomTabBar(tabBarView: OECustomTabBar) -> [UITabBarItem] {
		return tabBar.items!
	}
	
	func didSelectViewController(tabBarView: OECustomTabBar, atIndex index: Int) {
		self.selectedIndex = index
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
