//
//  extensions.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import Foundation
import UIKit

///-----------------------------------------------------------------------------
extension Double {
	
	///-----------------------------------------------------------------------------
	/// Convert Degrees to Radians
	///
	/// - Returns: Converted Value
	///-----------------------------------------------------------------------------
	func toRadians() -> Double {
		return self * .pi / 180.0
	}
	
	///-----------------------------------------------------------------------------
	/// Convert Radians to Degrees
	///
	/// - Returns: Converted Value
	///-----------------------------------------------------------------------------
	func toDegrees() -> Double {
		return self * 180.0 / .pi
	}
	
	///-----------------------------------------------------------------------------
	/// Round a Double to a number of Decimal Places
	///
	/// - Parameter fractionDigits: how many digits
	/// - Returns: rounded number
	///-----------------------------------------------------------------------------
	func roundToDecimal(_ fractionDigits: Int) -> Double {
		let multiplier = pow(10,Double(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
}

///-----------------------------------------------------------------------------
extension NSNotification.Name {
	static let EnteredBeacon = NSNotification.Name("EnteredBeacon")
	static let ExitedBeacon = NSNotification.Name("ExitedBeacon")
	
	static let EnteredBeaconInnerPerimeter = NSNotification.Name("EnteredBeaconInnerPerimeter")
	static let ExitedBeaconInnerPerimeter = NSNotification.Name("ExitedBeaconInnerPerimeter")
	
	static let EnteredBeaconOuterPerimeter = NSNotification.Name("EnteredBeaconOuterPerimeter")
	static let ExitedBeaconOuterPerimeter = NSNotification.Name("ExitedBeaconOuterPerimeter")
}

///-----------------------------------------------------------------------------
extension UIView {
	
	///-----------------------------------------------------------------------------
	/// Create a Circle in the View
	///
	/// - Parameters:
	///   - center: center of the Circle
	///   - radius: how big is the Circle
	///   - color: what color
	///-----------------------------------------------------------------------------
	func createCircle(center: CGPoint, radius:CGFloat, color: UIColor) {
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor! = color.cgColor
		
		let path = UIBezierPath(ovalIn: CGRect(x: center.x-radius/2, y: center.y-radius/2, width: radius, height: radius))
		shapeLayer.path = path.cgPath
	
		self.layer.addSublayer(shapeLayer)
	}
	
	///-----------------------------------------------------------------------------
	/// Make A Gradient Background
	///-----------------------------------------------------------------------------
	func createGradientBackground() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [GRADIENT_COLOR_TOP.cgColor,GRADIENT_COLOR_BOTTOM.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		gradientLayer.frame = self.frame
		self.layer.insertSublayer(gradientLayer,at: 0)
	}
}

///-----------------------------------------------------------------------------
extension UIImage {
	
	///-----------------------------------------------------------------------------
	/// Mask Image with Color
	///
	/// - Parameter color: what color
	/// - Returns: UIImage
	///-----------------------------------------------------------------------------
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
