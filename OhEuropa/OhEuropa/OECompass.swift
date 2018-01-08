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
	var compassGroup: Group!
	var arrowIndicator: Group!
	
	var wave: Polyline!
	var currentAngle: Double = 0.0

	var northIcon: Text!
	var southIcon: Text!
	var eastIcon: Text!
	var westIcon: Text!

	var centerX: Double!
	var centerY: Double!
	var compassRadius: Double!
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Returns: <#return value description#>
	///------------------------------------------------------------------------------------------
	func createCompass() -> Group {
		let compassCenter = Shape(form:
							Circle(
								cx: centerX,
								cy: centerY,
								r: 5),
							fill: Color.navy,
							stroke: Stroke(fill: Color.navy, width: 3.0))
		
		let compassRing = Shape(form:
						Circle(
							cx: centerX,
							cy: centerY,
							r: compassRadius),
						fill: Color.clear,
						stroke: Stroke(fill: Color.navy, width: 3.0))
		
		var lineArray = [Shape!]()
		
		for i in stride(from: 0, to: 360, by: 10) {
			let rx = centerX + ((compassRadius - 20.0) * sin(Double(i).toRadians()))
			let ry = centerY - ((compassRadius - 20.0) * cos(Double(i).toRadians()))
			let drx = centerX + ((compassRadius) * sin(Double(i).toRadians()))
			let dry = centerY - ((compassRadius) * cos(Double(i).toRadians()))
			
			if i == 0 { northIcon = Text(text: "N", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 90 { eastIcon = Text(text: "E", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 180 { southIcon = Text(text: "S", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 270 { westIcon = Text(text: "W", align: .mid, baseline:.mid, place: .move(dx: rx, dy: ry)) }
			else if i == 360 { }
			else {
				lineArray.append(Shape(form: Line(x1: rx, y1: ry, x2: drx, y2: dry)))
			}
		}
		let compassLines = Group(contents: lineArray)
		let compassPoints = Group(contents:[northIcon,southIcon,westIcon,eastIcon])
		
		// Make a Crap Array of Markers for now
		for i in 1...10 {
			markers.append(OEBeaconMarker(beaconName:"\(i)",x:centerX,y:centerY,radius:compassRadius+25))
		}
		let markerGroup = Group(contents:markers)
		
		return Group(contents:[compassRing,compassLines,compassPoints,markerGroup,compassCenter])
	}
	
	///------------------------------------------------------------------------------------------
	/// Init
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		// Call the View with blank content
		super.init(node: Group(), coder: aDecoder)
	
		centerX = Double(self.center.x)
		centerY = Double(self.center.y)
		compassRadius = Double(self.frame.width / 2 - 25)
		
		let tmpRadius = Double(compassRadius+60)
		let tmpX = centerX-3
		let arrow = Shape(form: Polygon(points:
			[
				centerX,compassRadius+40,
				centerX+8,tmpRadius,
				tmpX+6,tmpRadius,
				tmpX+6,centerY,
				tmpX,centerY,
				tmpX,tmpRadius,
				centerX-8,tmpRadius
			]
			),
			fill: Color.navy
		)
		
		arrowIndicator = Group(contents: [arrow])
		
		compassGroup = createCompass()
		let allGroups = Group(contents: [compassGroup,arrowIndicator])
		
		self.node = allGroups
	}
	
	///------------------------------------------------------------------------------------------
	/// Set the Compass Heading
	///
	/// - Parameter heading: Compass Heading
	///------------------------------------------------------------------------------------------
	public func setCompassHeading(heading:Double) {
		
		// Convert Angle and Switch to Radians
		let tmpAngle = (360 - heading).toRadians()
		
		if compassGroup != nil{
			// Animate the group from previous rotation to new
			compassGroup.placeVar.animate(
				from: Transform.rotate(angle: currentAngle,x:centerX,y:centerY),
				to: Transform.rotate(angle: tmpAngle,x:centerX,y:centerY),
				during: 0.1,
				delay: 0.0)
			
			// Keep a reference to the current angle
			currentAngle = tmpAngle
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameters:
	///   - index: <#index description#>
	///   - angle: <#angle description#>
	///------------------------------------------------------------------------------------------
	public func setBeaconRotation(index: Int, angle:Double) {
		markers[index].setBeaconHeading(heading: angle)
	}
	
	///------------------------------------------------------------------------------------------
	/// <#Description#>
	///
	/// - Parameter zonetype: <#zonetype description#>
	///------------------------------------------------------------------------------------------
	public func insideBeaconZone(zonetype:String) {
		
//		indicator.contentsVar.animation({ t in
//			let color = Color.rgba(r: 255, g: 0, b: 0, a: 1 - t)
//			return [Circle(cx:150,cy:150,r: t * 60).stroke(fill: color, width: 5)]
//		}, during: 1.5, delay: 0.1).easing(.easeInOut).cycle().play()
	}
}
