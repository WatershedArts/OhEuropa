//
//  extensions.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import Foundation

extension Double {
	func toRadians() -> Double {
		return self * .pi / 180.0
	}
	
	func toDegrees() -> Double {
		return self * 180.0 / .pi
	}
	
	func roundToDecimal(_ fractionDigits: Int) -> Double {
		let multiplier = pow(10,Double(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
}

extension NSNotification.Name {
	static let EnteredBeacon = NSNotification.Name("EnteredBeacon")
	static let ExitedBeacon = NSNotification.Name("ExitedBeacon")
}
