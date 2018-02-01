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
	
	///------------------------------------------------------------------------------------------
	/// Create the Gradient for the Background
	///------------------------------------------------------------------------------------------
	func createGradientForBackground() {
		gradientLayer = CAGradientLayer()
		gradientLayer.colors = [DEFAULT_COLOR_OPPOSED.cgColor,DEFAULT_COLOR.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		gradientLayer.frame = self.view.frame
		self.view.layer.insertSublayer(gradientLayer,at: 0)
	}
	
	///------------------------------------------------------------------------------------------
    /// View Did Load
	///------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		createGradientForBackground()
    }
	
	///------------------------------------------------------------------------------------------
	/// Memory
	///------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
