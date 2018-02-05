//
//  OETabBarViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 31/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//
// http://blog.adambardon.com/how-to-create-custom-tab-bar-in-swift-part-1/


import UIKit
import FontAwesome_swift

class OETabBarViewController: UITabBarController, OECustomTabBarDataSource, OECustomTabBarDelegate {
	
	///-----------------------------------------------------------------------------
    /// View Did Load
	///-----------------------------------------------------------------------------
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

	///-----------------------------------------------------------------------------
	/// Get the Tab bar items in the View Controller
	///
	/// - Parameter tabBarView: which view controller
	/// - Returns: tabbar items array
	///-----------------------------------------------------------------------------
	func tabBarItemsInCustomTabBar(tabBarView: OECustomTabBar) -> [UITabBarItem] {
		return tabBar.items!
	}
	
	///-----------------------------------------------------------------------------
	/// Select Which Tab bar item
	///
	/// - Parameters:
	///   - tabBarView: which view controller
	///   - index: which index
	///-----------------------------------------------------------------------------
	func didSelectViewController(tabBarView: OECustomTabBar, atIndex index: Int) {
		self.selectedIndex = index
	}
	
	///-----------------------------------------------------------------------------
    /// Memories
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
