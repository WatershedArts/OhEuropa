//
//  OECustomTabBar.swift
//  OhEuropa
//
//  Created by David Haylock on 01/02/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit

protocol OECustomTabBarDataSource {
	func tabBarItemsInCustomTabBar(tabBarView:OECustomTabBar) -> [UITabBarItem]
}

protocol OECustomTabBarDelegate {
	func didSelectViewController(tabBarView: OECustomTabBar, atIndex index: Int)
}

class OECustomTabBar: UIView {

	var tabBarItems: [UITabBarItem]!
	var tabBarButtons: [UIButton]!
	var customTabBarItems: [OECustomTabBarItem]!
	var datasource: OECustomTabBarDataSource!
	var delegate: OECustomTabBarDelegate!
	var initialTabBarItemIndex: Int!
	var selectedTabBarItemIndex: Int!
	var tabBarItemWidth: CGFloat!
	
	var colorMask: UIView!

	///-----------------------------------------------------------------------------
	/// Setup the Bar Items
	///-----------------------------------------------------------------------------
	func setup() {
		
		initialTabBarItemIndex = 0
		tabBarItems = datasource.tabBarItemsInCustomTabBar(tabBarView: self)
		
		customTabBarItems = []
		tabBarButtons = []
		
		selectedTabBarItemIndex = initialTabBarItemIndex
		
		tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
		
		let containers = createTabBarItemContainers()
		colorMask = UIView(frame: containers[0])
		colorMask.backgroundColor = ICON_BAR_SELECTED_COLOR
		self.addSubview(colorMask)

		createTabBarItems(containers: containers)
	}
	
	///-----------------------------------------------------------------------------
	/// Create the tab bar items
	///
	/// - Parameter containers: sizes of Items
	///-----------------------------------------------------------------------------
	func createTabBarItems(containers: [CGRect]) {
		
		var index = 0
		for item in tabBarItems {
			
			let container = containers[index]
			
			let customTabBarItem = OECustomTabBarItem(frame: container)
			customTabBarItem.setup(item: item)
			
			self.addSubview(customTabBarItem)
			customTabBarItems.append(customTabBarItem)
			
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
			button.addTarget(self, action: #selector(barItemTapped), for: UIControlEvents.touchUpInside)
			
			customTabBarItem.addSubview(button)
			tabBarButtons.append(button)
			
			index = index + 1
		}
	}
	
	///-----------------------------------------------------------------------------
	/// Create The Tab Bar Containers
	///
	/// - Returns: containers
	///-----------------------------------------------------------------------------
	func createTabBarItemContainers() -> [CGRect] {
		var containerArray = [CGRect]()
		
		for index in 0..<tabBarItems.count {
			let tabBarContainer = createTabBarContainer(index: index)
			containerArray.append(tabBarContainer)
		}
		return containerArray
	}
	
	///-----------------------------------------------------------------------------
	/// Create Tab Bar Container
	///
	/// - Parameter index: at what index do you want to draw
	/// - Returns: container rectangle
	///-----------------------------------------------------------------------------
	func createTabBarContainer(index:Int) -> CGRect {
		let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
		let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
		return tabBarContainerRect
	}
	
	///-----------------------------------------------------------------------------
	/// Animate to Item
	///
	/// - Parameters:
	///   - from: from which item
	///   - to: to which item
	///-----------------------------------------------------------------------------
	func animateTabBarSelection(_ from: Int, to: Int) {

		let tb = CGFloat(to - from)
		let t = tabBarItemWidth * tb
		UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
			self.colorMask.frame.origin.x += t
		}, completion: nil)
	}
	
	///-----------------------------------------------------------------------------
	/// Bar Tapped
	///
	/// - Parameter sender: UIButton ID
	///-----------------------------------------------------------------------------
	@objc func barItemTapped(sender: UIButton) {
		let index = tabBarButtons.index(of: sender)!
		
		animateTabBarSelection(selectedTabBarItemIndex, to: index)
		selectedTabBarItemIndex = index
		delegate.didSelectViewController(tabBarView: self, atIndex: index)
	}
	
	///-----------------------------------------------------------------------------
	/// Initialize Frame
	///
	/// - Parameter frame: size of frame
	///-----------------------------------------------------------------------------
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = ICON_BAR_DEFAULT_COLOR
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Init has not been implemented")
	}
}
