//
//  OEIntroViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 30/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

class OEIntroViewController: UIViewController {
	
	var index = 0
	var introText = ["finding nearby beacons","loading compass"]
	var timer: Timer!
	
	
	@IBOutlet weak var activityIcon: NVActivityIndicatorView!
	@IBOutlet weak var InfoLabel: UILabel!
		
	///-----------------------------------------------------------------------------
	/// View Will Appear
	///
	/// - Parameter animated: <#animated description#>
	///-----------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if activityIcon != nil {
			activityIcon.type = .lineScalePulseOut
			activityIcon.startAnimating()
		}
		
		self.view.createGradientBackground()
		
		var center = CGPoint(x: (self.view.frame.size.width / 2.0),y: (self.view.frame.size.height / 2.0))
		
		self.view.createCircle(center: CGPoint(x:6,y:center.y-10), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:self.view.frame.size.width-16,y:center.y+50), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:center.x-100,y:center.y-100), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:center.x-50,y:center.y+50), radius: 10, color: ACTIVE_COMPASS_COLOR)
		self.view.createCircle(center: CGPoint(x:center.x+50,y:center.y-50), radius: 10, color: ACTIVE_COMPASS_COLOR)
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
		
//		activityIcon.type = NVActivityIndicatorType.lineScalePulseOut
//		activityIcon.startAnimating()
		
		self.InfoLabel.text = introText[index]
		timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(nextInformation), userInfo: nil, repeats: false)
    }

	///-----------------------------------------------------------------------------
    /// Memory
	///-----------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
