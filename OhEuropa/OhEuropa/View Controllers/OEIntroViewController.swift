//
//  OEIntroViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 30/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import AVFoundation

class OEIntroViewController: UIViewController {
	var gradientLayer: CAGradientLayer!
	
	func createGradientForBackground() {
		gradientLayer = CAGradientLayer()
		gradientLayer.colors = [DEFAULT_COLOR_OPPOSED.cgColor,DEFAULT_COLOR.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		gradientLayer.frame = self.view.frame
		self.view.layer.insertSublayer(gradientLayer,at: 0)
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		createGradientForBackground()
		let currentRoute = AVAudioSession.sharedInstance().currentRoute
		if currentRoute.outputs != nil {
			for description in currentRoute.outputs {
				if description.portType == AVAudioSessionPortHeadphones {
					print("Headphones Plugged In")
				} else {
					print("Headphones Not Plugged In")
				}
			}
		} else {
			print("Requires connection to device")
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
