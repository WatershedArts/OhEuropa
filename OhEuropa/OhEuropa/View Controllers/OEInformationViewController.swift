//
//  InformationViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 08/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import AVFoundation
import FontAwesome_swift

class OEInformationViewController: UIViewController {
	
	///-----------------------------------------------------------------------------
    /// View Did Load
	///-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.createGradientBackground()
		
		let center = CGPoint(x: (self.view.frame.size.width / 2.0),y: (self.view.frame.size.height / 2.0))
		self.view.createCircle(center: CGPoint(x:center.x+50,y:self.view.frame.height-35), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:self.view.frame.size.width-20,y:self.view.frame.height-75), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:40,y:self.view.frame.height-25), radius: 10, color: ACTIVE_COMPASS_COLOR)
    }
	
	///-----------------------------------------------------------------------------
	/// Memory
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
