//
//  OECompass.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import ProcessingKit
import TweenKit
import GameKit

class OECompass : ProcessingView {

	// Animation Easing Type and Timing
	let easingType = Easing.exponentialInOut
	let easingTime = 2.0
	
	// What angle the compass is currently rotated to
	var currentAngle: Double = 0.0

	// Center of the View Controller for drawing
	var centerX: CGFloat!
	var centerY: CGFloat!
	
	// How Big the compass should be
	var compassRadius: CGFloat!
	
	// What angle the beacon marker should be at
	var beaconAngle: Double = 0.0
	
	// Animation Handler
	let scheduler = ActionScheduler()
	
	// An image that appears when the user enters the center zone of the beacon
	var centerImage: UIImage!
	
	// The Y offset of the marker
	var offsetY = CGFloat(40.0)
	
	// Rather than writing it out three times
	// The colors are accordingly (DefaultState : CurrentState : ActiveState)
	var centerBeaconAnimationColors = [
		(UIColor.white,UIColor.white,UIColor.clear), // 1: is the marker triangle, outer lines and the North symbol
		(ACTIVE_COMPASS_COLOR,ACTIVE_COMPASS_COLOR,INACTIVE_COMPASS_COLOR), // 2: is the outershell
		(INACTIVE_COMPASS_COLOR,INACTIVE_COMPASS_COLOR,ACTIVE_COMPASS_COLOR), // 3: is the center
		(UIColor.clear,UIColor.clear,INACTIVE_COMPASS_COLOR) // 4: is the centerimage
	]
	
	///-----------------------------------------------------------------------------
	/// Setup
	///-----------------------------------------------------------------------------
	func setup() {
		
		// Set Background to clear so we can see the gradient
		background(UIColor.clear)
		
		frameRate(60);
		
		// Calculate the Center Point
		centerX = self.frame.width / 2
		centerY = self.frame.height / 2
		
		// Define the Radius
		compassRadius = centerX - 50.0
		
		// Check the Phone Version if its the X
		// then you need to do another calculation to account for the
		// screen size.
		if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
			offsetY = (145 / 2.0) + 15
		}
		
		// Load the Image
		centerImage = UIImage(named: "CompassInnerWaves")!.maskWithColor(color: INACTIVE_COMPASS_COLOR)
	}
	
	///-----------------------------------------------------------------------------
	/// Draw the Context View
	///-----------------------------------------------------------------------------
	func draw() {
		background(UIColor.clear)
	
		noStroke()
		strokeWeight(3.0)
		
		// Move the context
		pushMatrix()
		translate(x: centerX, y: centerY)
		
		// Rotate the context
		rotate(angle: CGFloat(currentAngle))
		
		// Move the context back
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		
		// Draw the Compass outer ring
		fill(centerBeaconAnimationColors[1].1)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)+10), CGFloat((compassRadius*2)+10))
		
		// Draw the Compass inner ring
		fill(centerBeaconAnimationColors[2].1)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)-10), CGFloat((compassRadius*2)-10))
		
		// Draw the image here now instead
		fill(centerBeaconAnimationColors[3].1)
		image(centerImage!, centerX-(compassRadius - 5), centerY-(compassRadius - 5), CGFloat((compassRadius - 5)*2), CGFloat((compassRadius - 5)*2))
		
		// Draw the outer ring white marks
		strokeWeight(2.5)
		for i in stride(from: 0, to: 360, by: 10) {
			
			// Calculate the Inner Start Point
			let rx = centerX + (compassRadius - 5.0) * CGFloat(sin(Double(i).toRadians()))
			let ry = centerY - (compassRadius - 5.0) * CGFloat(cos(Double(i).toRadians()))
			
			// Calculate the Outer End Point
			let drx = centerX + (compassRadius + 2.5) * CGFloat(sin(Double(i).toRadians()))
			let dry = centerY - (compassRadius + 2.5) * CGFloat(cos(Double(i).toRadians()))

			// Draw the North Marker
			fill(centerBeaconAnimationColors[0].1)
			stroke(centerBeaconAnimationColors[0].1)
			if i == 0 {
				textFont(UIFont.boldSystemFont(ofSize: 20))
				textAlign(.center)
				text("N", rx, ry+40)
				line(rx, ry, drx, dry);
			}
			else {
				line(rx, ry, drx, dry);
			}
		}
		
		drawMarker()
		popMatrix()
		popMatrix()
	}
	
	///-----------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///-----------------------------------------------------------------------------
	public func setCompassHeading(heading:Double) {
		
		// Convert Angle and Switch to Radians
		currentAngle = (360 - heading).toRadians()
	}
	
	///-----------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///-----------------------------------------------------------------------------
	public func drawMarker() {
		
		// Bare with me here
		let markerSize = CGFloat(10.0)
		
		// Move the Context to the center and offset Upwards
		// This moves the triangle to the top of the compass
		pushMatrix()
		translate(x: centerX, y: compassRadius + offsetY)
		
		// Move the context the difference between the original move and the center of the frame
		// which essentially is the center of the frame.
		// This will be our rotation matrix position
		pushMatrix()
		translate(x: 0.0, y: (centerY - (compassRadius + offsetY)))
		rotate(angle: CGFloat(beaconAngle))
		
		// Shift the context back to the original position.
		pushMatrix()
		translate(x: 0.0, y: -(centerY - (compassRadius + offsetY)))
		
		noFill()
		stroke(centerBeaconAnimationColors[0].1)
		strokeWeight(2)
		
		// Draw Shape
		beginShape()
		vertex(0.0, CGFloat(markerSize - 20))
		vertex(0.0 + markerSize, markerSize)
		vertex(0.0 - markerSize, markerSize)
		endShape(EndShapeMode.close)
		
		// Return the context
		popMatrix()
		popMatrix()
		popMatrix()
	}
	
	///-----------------------------------------------------------------------------
	/// Set what angle the beacon should be at
	///
	/// - Parameters:
	///   - beaconAngle: angle of the beacon
	///-----------------------------------------------------------------------------
	public func setBeaconRotation(beaconAngle:Double) {
		self.beaconAngle = beaconAngle
	}
	
	///-----------------------------------------------------------------------------
	/// If the User Enters the Beacon Zone
	///
	/// - Parameter zonetype: zone id
	///-----------------------------------------------------------------------------
	public func enteredBeaconZone(zonetype:String) {
		
		// If we enter the C zone start the animations active
		if zonetype == "C" {
			let set1 = InterpolationAction(from: centerBeaconAnimationColors[0].0,
										   to: centerBeaconAnimationColors[0].2,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[0].1 = $0 }
			
			let set2 = InterpolationAction(from: centerBeaconAnimationColors[1].0,
										   to: centerBeaconAnimationColors[1].2,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[1].1 = $0 }
			
			let set3 = InterpolationAction(from: centerBeaconAnimationColors[2].0,
										   to: centerBeaconAnimationColors[2].2,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[2].1 = $0 }
			
			let set4 = InterpolationAction(from: centerBeaconAnimationColors[3].0,
										   to: centerBeaconAnimationColors[3].2,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[3].1 = $0 }
			
			let actions = ActionGroup(actions: set1,set2,set3,set4)
			scheduler.run(action: actions)
		}
	}
	
	///-----------------------------------------------------------------------------
	/// If user Exits the Beacon Zone
	///
	/// - Parameter zonetype: Zone id
	///-----------------------------------------------------------------------------
	public func exittedBeaconZone(zonetype:String) {
		if zonetype == "C" {
			let set1 = InterpolationAction(from: centerBeaconAnimationColors[0].2,
										   to: centerBeaconAnimationColors[0].0,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[0].1 = $0 }
			
			let set2 = InterpolationAction(from: centerBeaconAnimationColors[1].2,
										   to: centerBeaconAnimationColors[1].0,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[1].1 = $0 }
			
			let set3 = InterpolationAction(from: centerBeaconAnimationColors[2].2,
										   to: centerBeaconAnimationColors[2].0,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[2].1 = $0 }
			
			let set4 = InterpolationAction(from: centerBeaconAnimationColors[3].2,
										   to: centerBeaconAnimationColors[3].0,
										   duration: easingTime,
										   easing: easingType) { [unowned self] in self.centerBeaconAnimationColors[3].1 = $0 }
			
			let actions = ActionGroup(actions: set1,set2,set3,set4)
			scheduler.run(action: actions)
		}
	}
}
