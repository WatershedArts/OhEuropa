//
//  OEAudioBars.swift
//  OhEuropa
//
//  Created by David Haylock on 07/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import Macaw

class OEAudioBars: MacawView {

	var centerX: Double!
	var centerY: Double!
	///------------------------------------------------------------------------------------------
	/// Init
	///------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		// Call the View with blank content
		super.init(node: Group(), coder: aDecoder)
		centerX = Double(self.center.x)
		centerY = Double(self.center.y)
	
	}
}
