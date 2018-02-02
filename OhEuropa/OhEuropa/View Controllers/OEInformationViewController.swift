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

	var gradientLayer: CAGradientLayer!
	
	///-----------------------------------------------------------------------------
	/// Create the Gradient for the Background
	///-----------------------------------------------------------------------------
	func createGradientForBackground() {
		gradientLayer = CAGradientLayer()
		gradientLayer.colors = [GRADIENT_COLOR_TOP.cgColor,GRADIENT_COLOR_BOTTOM.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		gradientLayer.frame = self.view.frame
		self.view.layer.insertSublayer(gradientLayer,at: 0)
	}
	
	///-----------------------------------------------------------------------------
    /// View Did Load
	///-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		createGradientForBackground()
		
		var center = CGPoint(x: (self.view.frame.size.width / 2.0),y: (self.view.frame.size.height / 2.0))
		
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
