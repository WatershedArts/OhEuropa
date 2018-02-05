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
	var centerImage: UIImageView!
	
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
		
		// Offset Radius for the Image and add to the Main controller
		let tmpRadius = compassRadius - 5
		centerImage = UIImageView(frame: CGRect(x: centerX-tmpRadius, y: centerY-tmpRadius, width: CGFloat(tmpRadius*2), height: CGFloat(tmpRadius*2)))
		centerImage.backgroundColor = UIColor.clear
		centerImage.image = UIImage(named:"InfoPageWaves")!.maskWithColor(color: INACTIVE_COMPASS_COLOR)
		centerImage.layer.cornerRadius = centerImage.frame.width/2
		centerImage.layer.masksToBounds = true
		self.addSubview(centerImage)
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
		
		let tmpRadius = CGFloat(compassRadius+40)
		let tmpX = CGFloat(centerX)
		
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(beaconAngle))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		noFill()
		stroke(centerBeaconAnimationColors[0].1)
		strokeWeight(2)
		beginShape()
		vertex(centerX, CGFloat(compassRadius + 40 - 20))
		vertex(tmpX + 10.0, tmpRadius)
		vertex(tmpX - 10.0, tmpRadius)
		endShape(EndShapeMode.close)
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
