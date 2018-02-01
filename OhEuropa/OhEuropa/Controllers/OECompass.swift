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

	let easingType = Easing.exponentialInOut
	let easingTime = 2.0
	
	var markers = [OEBeaconMarker]()
	var currentAngle: Double = 0.0

	var centerX: CGFloat!
	var centerY: CGFloat!
	var compassRadius: Double!
	var time = Timer()
	var beaconMarker: Double = 0.0
	
	var circleSize = 0.0
	let fromSize = 0.0
	let toSize = 1000.0
	var value = 0.0
	let scheduler = ActionScheduler()
	
	var zoneData = [(false,0.0,UIColor.red),(false,0.0,UIColor.yellow),(false,0.0,UIColor.green)]
	
	// Rather than writing it out three times
	
	
	// The colors are accordingly (DefaultState : CurrentState : ActiveState)
	var centerBeaconAnimationColors = [
		(UIColor.white,UIColor.white,UIColor.clear), // 1: is the marker triangle, outer lines and the North symbol
		(DEFAULT_COLOR_OPPOSED,DEFAULT_COLOR_OPPOSED,DEFAULT_COLOR), // 2: is the outershell
		(DEFAULT_COLOR,DEFAULT_COLOR,DEFAULT_COLOR_OPPOSED), // 3: is the center
		(UIColor.clear,UIColor.clear,DEFAULT_COLOR_OPPOSED) // 4: is the centerimage
	]
	
	///------------------------------------------------------------------------------------------
	/// Setup
	///
	///------------------------------------------------------------------------------------------
	func setup() {
		background(UIColor.clear)
		frameRate(60);
		centerX = self.frame.width / 2
		centerY = self.frame.height / 2
		compassRadius = Double(centerX) - 40.0
	}
	

	///------------------------------------------------------------------------------------------
	/// Draw the Context View
	///------------------------------------------------------------------------------------------
	func draw() {
		background(UIColor.clear)
	
		noStroke()
		strokeWeight(3.0)
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(currentAngle))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		
		fill(centerBeaconAnimationColors[1].1)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)+20), CGFloat((compassRadius*2)+20))
		
		fill(centerBeaconAnimationColors[2].1)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)), CGFloat((compassRadius*2)))
		
		strokeWeight(1.5)
		
		for i in stride(from: 0, to: 360, by: 10) {
			let rx = CGFloat(Double(centerX) + ((compassRadius + 7.0) * sin(Double(i).toRadians())))
			let ry = CGFloat(Double(centerY) - ((compassRadius + 7.0) * cos(Double(i).toRadians())))
			let drx = CGFloat(Double(centerX) + ((compassRadius) * sin(Double(i).toRadians())))
			let dry = CGFloat(Double(centerY) - ((compassRadius) * cos(Double(i).toRadians())))

			fill(centerBeaconAnimationColors[0].1)
			stroke(centerBeaconAnimationColors[0].1)
			if i == 0 {
				textFont(UIFont(name: "Nimbus Sans L", size: 20)!)
				textAlign(.center)
				text("N", rx, ry+40)
			}
			else {
				line(rx, ry, drx, dry);
			}
		}
		
		drawMarker()
		popMatrix()
		popMatrix()
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	func setAngle(newAngle: Double) {
		currentAngle = newAngle
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	public func setCompassHeading(heading:Double) {
		
		// Convert Angle and Switch to Radians
		currentAngle = (360 - heading).toRadians()
		print(currentAngle)
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	public func drawMarker() {
		
		let tmpRadius = CGFloat(compassRadius + 30)
		let tmpX = CGFloat(centerX)
		
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(beaconMarker)) //CGFloat(Double(180.0 + 180.0 * sin(Double(millis()/100))).toRadians()))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		noFill()
		stroke(centerBeaconAnimationColors[0].1)
		strokeWeight(2)
		beginShape()
		vertex(centerX, CGFloat(compassRadius + 30 - 20))
		vertex(tmpX + 10.0, tmpRadius)
		vertex(tmpX - 10.0, tmpRadius)
		endShape(EndShapeMode.close)
		popMatrix()
		popMatrix()
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - index: <#index description#>
	///   - angle: <#angle description#>
	///------------------------------------------------------------------------------------------
	public func setBeaconRotation(beaconAngle:Double) {
		beaconMarker = beaconAngle
	}
	
	///------------------------------------------------------------------------------------------
	/// If the User Enters the Beacon Zone
	///
	/// - Parameter zonetype: zone id
	///------------------------------------------------------------------------------------------
	public func enteredBeaconZone(zonetype:String) {
		
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
		else {
			
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// If user Exits the Beacon Zone
	///
	/// - Parameter zonetype: Zone id
	///------------------------------------------------------------------------------------------
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
		else {
			
		}
	}
}
