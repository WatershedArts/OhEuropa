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
	
	var theta = 0.0
	var amplitude = 75.0
	var period = 500.0
	var dx = 0.0
	var yValues = [Double]()
	var xspacing = 10.0
	var w = 0.0
	
	///------------------------------------------------------------------------------------------
	/// Setup
	///
	///------------------------------------------------------------------------------------------
	func setup() {
		background(UIColor.white)
		frameRate(60);
		centerX = self.frame.width / 2
		centerY = self.frame.height / 2
		compassRadius = Double(centerX) - 40.0
		w = Double(self.frame.width)
		dx = (Double(TWO_PI) / Double(period)) * xspacing
		let t = Int(w / xspacing)
		for i in 0...t {
			yValues.append(0.0)
		}
	}
	
	func calcWave() {
		theta += 0.002
		var x = theta
		for i in 0...yValues.count-1 {
			yValues[i] = cos(Double(x)) * amplitude
			x+=dx
		}
	}
	
	func drawWave() {
		noStroke()
		fill(UIColor.black)
		
		for i in 0...yValues.count-1 {
			ellipse(CGFloat(i) * CGFloat(xspacing), CGFloat(centerY) + CGFloat(yValues[i]), 4, 4)
		}
	}

	///------------------------------------------------------------------------------------------
	/// Draw the Context View
	///------------------------------------------------------------------------------------------
	func draw() {
		background(UIColor.white)

//		for (index,zone) in zoneData.enumerated() {
//			if zone.0 {
//				fill(zone.2)
//				ellipse(centerX, centerY, CGFloat(zone.1),CGFloat(zone.1))
//			}
//		}
	
	
		noStroke()
		strokeWeight(3.0)
		pushMatrix()
		translate(x: centerX, y: centerY)
		rotate(angle: CGFloat(currentAngle))
		pushMatrix()
		translate(x: -centerX, y: -centerY)
		
		fill(DEFAULT_COLOR_OPPOSED)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)+20), CGFloat((compassRadius*2)+20))
		
		fill(DEFAULT_COLOR)
		ellipse(centerX, centerY, CGFloat((compassRadius*2)), CGFloat((compassRadius*2)))
		
		
		strokeWeight(1.5)
		
		for i in stride(from: 0, to: 360, by: 10) {
			let rx = CGFloat(Double(centerX) + ((compassRadius + 7.0) * sin(Double(i).toRadians())))
			let ry = CGFloat(Double(centerY) - ((compassRadius + 7.0) * cos(Double(i).toRadians())))
			let drx = CGFloat(Double(centerX) + ((compassRadius) * sin(Double(i).toRadians())))
			let dry = CGFloat(Double(centerY) - ((compassRadius) * cos(Double(i).toRadians())))

			fill(UIColor.white)
			stroke(UIColor.white)
			if i == 0 {
				textFont(UIFont.systemFont(ofSize: 15.0))
				
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
		calcWave()
		drawWave()
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	func drawArrow() {
		let tmpRadius = CGFloat(compassRadius + 80)
		let tmpX = CGFloat(centerX - 3)
		
		
		
		noFill()
		stroke(UIColor.black)
		strokeWeight(4)
//		fill(UIColor.black)
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
		noFill()
		stroke(UIColor.black)
		strokeWeight(2)
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
	func deactivateIndicator(zonetype: String) {
		if zonetype == "O" {
			zoneData[0].0 = false
		}
		else if zonetype == "I" {
			zoneData[1].0 = false
		}
		else if zonetype == "C" {
			zoneData[2].0 = false
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter zonetype: <#zonetype description#>
	///------------------------------------------------------------------------------------------
	public func enteredBeaconZone(zonetype:String) {
		if zonetype == "O" {
			zoneData[0].0 = true
			let move = InterpolationAction(from: fromSize, to: toSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[0].1 = $0 }
			scheduler.run(action: move)
		}
		else if zonetype == "I" {
			zoneData[1].0 = true
			let move = InterpolationAction(from: fromSize, to: toSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[1].1 = $0 }
			scheduler.run(action: move)
		}
		else if zonetype == "C" {
			zoneData[2].0 = true
			let move = InterpolationAction(from: fromSize, to: toSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[2].1 = $0 }
			scheduler.run(action: move)
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter zonetype: <#zonetype description#>
	///------------------------------------------------------------------------------------------
	public func exittedBeaconZone(zonetype:String) {
		if zonetype == "O" {
			let move = InterpolationAction(from: toSize, to: fromSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[0].1 = $0 }
			move.onBecomeInactive = { self.deactivateIndicator(zonetype: "O") }
			scheduler.run(action: move)
		}
		else if zonetype == "I" {
			let move = InterpolationAction(from: toSize, to: fromSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[1].1 = $0 }
			move.onBecomeInactive = { self.deactivateIndicator(zonetype: "I") }
			scheduler.run(action: move)
		}
		else if zonetype == "C" {
			let move = InterpolationAction(from: toSize, to: fromSize, duration: 1.5, easing: .exponentialIn) { [unowned self] in self.zoneData[2].1 = $0 }
			move.onBecomeInactive = { self.deactivateIndicator(zonetype: "C") }
			scheduler.run(action: move)
		}
	}
}
