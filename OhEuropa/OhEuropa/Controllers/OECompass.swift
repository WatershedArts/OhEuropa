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

class OECompass : ProcessingView {

	var markers = [OEBeaconMarker]()
	var currentAngle: Double = 0.0

	var centerX: CGFloat!
	var centerY: CGFloat!
	var compassRadius: Double!
	var i = 0.0
	var time = Timer()
	var beaconMarker: Double = 0.0
	
	var circleSize = 0.0
	let fromSize = 0.0
	let toSize = 1000.0
	var value = 0.0
	let scheduler = ActionScheduler()
	
	
	func setup() {
		background(UIColor.white)
		frameRate(60);
		centerX = self.frame.width / 2
		centerY = self.frame.height / 2
		compassRadius = Double(centerX) - 40.0
		var move = InterpolationAction(from: fromSize, to: toSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.value = $0 }
		
		scheduler.run(action: move.yoyo().repeatedForever())
	}
	
	func draw() {
		background(UIColor.white)

		ellipse(centerX, centerY, CGFloat(value),CGFloat(value))
		
		strokeWeight(3.0)
		noFill()
		stroke(DEFAULT_COLOR)
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(currentAngle))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		ellipse(centerX, centerY, CGFloat(compassRadius*2), CGFloat(compassRadius*2))
		fill(DEFAULT_COLOR)
		ellipse(centerX, centerY, 10, 10)
		drawMarker()
		strokeWeight(1.2)
		
		for i in stride(from: 0, to: 360, by: 10) {
			let rx = CGFloat(Double(centerX) + ((compassRadius - 20.0) * sin(Double(i).toRadians())))
			let ry = CGFloat(Double(centerY) - ((compassRadius - 20.0) * cos(Double(i).toRadians())))
			let drx = CGFloat(Double(centerX) + ((compassRadius) * sin(Double(i).toRadians())))
			let dry = CGFloat(Double(centerY) - ((compassRadius) * cos(Double(i).toRadians())))

			if i == 0 {
				textFont(UIFont.systemFont(ofSize: 15.0))
				fill(UIColor.black)
				stroke(UIColor.black)
				textAlign(.center)
				text("N", rx, ry+10)
			}
			else {
				line(rx, ry, drx, dry);
			}
		}
		popMatrix()
		popMatrix()

		
		
		if i > 500 {
			i = 0.0
		}
		i += 3.0
	}
	
	func drawArrow() {
		let tmpRadius = CGFloat(compassRadius + 80)
		let tmpX = CGFloat(centerX - 3)
		
		stroke(DEFAULT_COLOR_OPPOSED)
		fill(DEFAULT_COLOR)
		beginShape()
		vertex(centerX, CGFloat(compassRadius + 70))
		vertex(centerX + 8.0, tmpRadius)
		vertex(tmpX + 6.0, tmpRadius)
		vertex(tmpX + 6.0, centerY)
		vertex(tmpX, centerY)
		vertex(tmpX, tmpRadius)
		vertex(centerX - 8, tmpRadius)
		endShape(EndShapeMode.close)
	}
	
	func setAngle(newAngle: Double) {
		currentAngle = newAngle
	}

	func drawNearestMarker() {
		
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
		
		let tmpRadius = CGFloat(compassRadius+30)
		let tmpX = CGFloat(centerX)
		
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(beaconMarker)) //CGFloat(Double(180.0 + 180.0 * sin(Double(millis()/100))).toRadians()))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		stroke(DEFAULT_COLOR_OPPOSED)
		fill(DEFAULT_COLOR)
		beginShape()
		vertex(centerX, CGFloat(compassRadius+30 - 20))
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
	/// <#Description#>
	///
	/// - Parameter zonetype: <#zonetype description#>
	///------------------------------------------------------------------------------------------
	public func insideBeaconZone(zonetype:String) {
		
	}
}
