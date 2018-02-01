//
//  extensions.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import Foundation
import UIKit

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
	
	static let EnteredBeaconInnerPerimeter = NSNotification.Name("EnteredBeaconInnerPerimeter")
	static let ExitedBeaconInnerPerimeter = NSNotification.Name("ExitedBeaconInnerPerimeter")
	
	static let EnteredBeaconOuterPerimeter = NSNotification.Name("EnteredBeaconOuterPerimeter")
	static let ExitedBeaconOuterPerimeter = NSNotification.Name("ExitedBeaconOuterPerimeter")
}


extension UIImage {
	
	/// Returns a image that fills in newSize
	func resizedImage(newSize: CGSize) -> UIImage {
		// Guard newSize is different
		guard self.size != newSize else { return self }
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		self.draw(in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
	/// Returns a resized image that fits in rectSize, keeping it's aspect ratio
	/// Note that the new image size is not rectSize, but within it.
	func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
		let widthFactor = size.width / rectSize.width
		let heightFactor = size.height / rectSize.height
		
		var resizeFactor = widthFactor
		if size.height > size.width {
			resizeFactor = heightFactor
		}
		
		let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
		let resized = resizedImage(newSize: newSize)
		return resized
	}
	
}
