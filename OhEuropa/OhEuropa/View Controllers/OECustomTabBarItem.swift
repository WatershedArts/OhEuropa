//
//  OECustomTabBarItem.swift
//  OhEuropa
//
//  Created by David Haylock on 01/02/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit

class OECustomTabBarItem: UIView {
		
	var iconView: UIImageView!
	
	///-----------------------------------------------------------------------------
	/// Init
	///
	/// - Parameter frame: frame size
	///-----------------------------------------------------------------------------
	override init (frame : CGRect) {
		super.init(frame : frame)
	}
	
	///-----------------------------------------------------------------------------
	/// Init
	///-----------------------------------------------------------------------------
	convenience init () {
		self.init(frame:CGRect.zero)
	}
	
	///-----------------------------------------------------------------------------
	/// Init
	///-----------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	///-----------------------------------------------------------------------------
	/// Setup
	///
	/// - Parameter item: Tab Bar Item
	///-----------------------------------------------------------------------------
	func setup(item: UITabBarItem) {
		
		guard let image = item.image else {
			fatalError("Add images to tabbar items")
		}
		
		iconView = UIImageView(frame: CGRect(x: (self.frame.width-image.size.width)/2, y: (self.frame.height-image.size
			.height)/2, width: self.frame.width, height: self.frame.height))
		
		iconView.image = image
		iconView.sizeToFit()
		
		self.addSubview(iconView)
	}
}
