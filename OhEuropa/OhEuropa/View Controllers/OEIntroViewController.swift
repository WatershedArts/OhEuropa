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
	
	var index = 0
	var introText = ["Welcome","Finding Nearby Beacons","Loading Compass"]
	var timer: Timer!
	
	@IBOutlet weak var InfoLabel: UILabel!
	
	///-----------------------------------------------------------------------------
	/// Create Gradient
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
	/// View Will Appear
	///
	/// - Parameter animated: <#animated description#>
	///-----------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		createGradientForBackground()
	}

	///-----------------------------------------------------------------------------
	/// Next Information into the Label
	///-----------------------------------------------------------------------------
	@objc func nextInformation() {
		
		if index < introText.count-1 {
			index = index + 1
			timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(nextInformation), userInfo: nil, repeats: false)
		}
		else if index == introText.count-1 {
			timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(moveToCompass), userInfo: nil, repeats: false)
		}
		
		self.InfoLabel.text = introText[index]
	}
	
	///-----------------------------------------------------------------------------
	/// Move to the Compass View
	///-----------------------------------------------------------------------------
	@objc func moveToCompass() {
		self.performSegue(withIdentifier: "toMainView", sender: self)
	}
	
	///-----------------------------------------------------------------------------
    /// View Did Load
	///-----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.InfoLabel.text = introText[index]
		
		timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(nextInformation), userInfo: nil, repeats: false)
		
		
//		let currentRoute = AVAudioSession.sharedInstance().currentRoute
//		if currentRoute.outputs != nil {
//			for description in currentRoute.outputs {
//				if description.portType == AVAudioSessionPortHeadphones {
//					print("Headphones Plugged In")
//				} else {
//					print("Headphones Not Plugged In")
//				}
//			}
//		} else {
//			print("Requires connection to device")
//		}
    }

	///-----------------------------------------------------------------------------
    /// Memory
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
