//
//  OECompass.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import Macaw

class OECompass: MacawView {
	
	var markers = [OEBeaconMarker]()
	var group:Group!
	var currentAngle:Double = 0.0
	
	var inid:Shape!
	var indicator:Group!
	var northIcon: Text!
	var southIcon: Text!
	var eastIcon: Text!
	var westIcon: Text!
	
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		print(frame)
//	}
	
	///------------------------------------------------------------------------------------------
	/// Init
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		let compassRing = Shape(form: Circle(cx: Double(300) / 2.0, cy: Double(300) / 2.0, r: 100.0),
								fill: Color.clear,
								stroke: Stroke(fill: Color.navy, width: 3.0))
		
		let originX = 150.0
		let originY = 150.0
		var lineArray = [Shape!]()
		
		for i in stride(from: 0, to: 360, by: 10) {
			let rx = originX + (80 * sin(Double(i).toRadians()))
			let ry = originY - (80 * cos(Double(i).toRadians()))
			let drx = originX + (100 * sin(Double(i).toRadians()))
			let dry = originY - (100 * cos(Double(i).toRadians()))
			
			if i == 0 { northIcon = Text(text: "N", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 90 { eastIcon = Text(text: "E", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 180 { southIcon = Text(text: "S", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 270 { westIcon = Text(text: "W", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 360 { }
			else {
				lineArray.append(Shape(form: Line(x1: rx, y1: ry, x2: drx, y2: dry)))
			}
		}
		
		let compassPoints = Group(contents:[northIcon,southIcon,westIcon,eastIcon])
		let lines = Group(contents: lineArray)
		
		// Make a Crap Array of Markers for now
		for i in 1...10 {
			markers.append(OEBeaconMarker(beaconName:""))
		}
		
		inid = Shape(form: Circle(cx: 150, cy: 150, r: 0),
					 fill: Color.rgb(r: 255, g: 0, b: 0),
					 stroke: Stroke(fill: Color.rgb(r: 200, g: 0, b: 0), width: 3))
		indicator = Group(contents: [inid])
		
		let markerGroup = Group(contents:markers)
		group = Group(contents: [indicator,compassRing,compassPoints,markerGroup,lines])
		super.init(node: group, coder: aDecoder)
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	public func setCompassHeading(heading:Double) {
		
		// Convert Angle and Switch to Radians
		let tmpAngle = (360 - heading).toRadians()
		
		// Animate the group from previous rotation to new
		group.placeVar.animate(from: Transform.rotate(angle: currentAngle,x:150,y:150),
							   to: Transform.rotate(angle: tmpAngle,x:150,y:150),
							   during: 0.1,
							   delay: 0.0)
		
		// Keep a reference to the current angle
		currentAngle = tmpAngle
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - index: <#index description#>
	///   - angle: <#angle description#>
	public func setBeaconRotation(index: Int, angle:Double) {
		markers[index].setBeaconHeading(heading: angle)
	}
	
	public func insideBeaconZone(zonetype:String) {
		
		indicator.contentsVar.animation({ t in
			let color = Color.rgba(r: 255, g: 0, b: 0, a: 1 - t)
			return [Circle(cx:150,cy:150,r: t * 60).stroke(fill: color, width: 5)]
		}, during: 1.5, delay: 0.1).easing(.easeInOut).cycle().play()
	}
}
