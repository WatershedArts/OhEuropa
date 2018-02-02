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
	
	func maskWithColor(color: UIColor) -> UIImage? {
		let maskImage = cgImage!
		
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		context.clip(to: bounds, mask: maskImage)
		context.setFillColor(color.cgColor)
		context.fill(bounds)
		
		if let cgImage = context.makeImage() {
			let coloredImage = UIImage(cgImage: cgImage)
			return coloredImage
		} else {
			return nil
		}
	}
	
}
