//
//  OEBeaconMarker.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import Macaw

class OEBeaconMarker: Group {
	var currentAngle: Double = 0.0
	var col:Color!
	var radius:Double!
	var x:Double!
	var y:Double!
	
	///------------------------------------------------------------------------------------------
	/// Initilize Beacon
	///
	/// - Parameter beaconName:
	///------------------------------------------------------------------------------------------
	init(beaconName:String,x:Double,y:Double,radius:Double) {
		col = Color.rgb(r: Int(arc4random_uniform(255)), g:Int(arc4random_uniform(255)), b: Int(arc4random_uniform(255)))
		
		self.x = x
		self.y = y
		
//		let shape = Shape(form: Circle(cx:x,cy:y,r:10), fill: col, stroke: Stroke(fill: col, width: 3))
		let shape = Shape(form:
						  Polygon(points: [
							x,y-7.5,
							x+7.5,y+7.5,
							x-7.5,y+7.5
						  ]),
						  fill: col,
						  stroke: Stroke(fill: col, width: 1))
		
		self.radius = radius
		super.init(contents: [shape])
		
//		self.placeVar.animate(from: Transform.rotate(angle: 0.0.toRadians(),x:x,y:y), to: Transform.rotate(angle: 90.0.toRadians(),x:x,y:y), during: 0.5, delay: 0.0)
		
		//		self.contentsVar.animation({ t in
		//			let color = Color.rgba(r: 0, g: 0, b: 255, a: 1 - t)
		//			return [Circle(r: t * 20).stroke(fill: color, width: 3)]
		//		}, during: 1.0, delay: 0).easing(.easeInOut).cycle().play()
	}
	
	///------------------------------------------------------------------------------------------
	/// Set where beacon marker heading
	///
	/// - Parameter heading: Heading in relation to current location
	///------------------------------------------------------------------------------------------
	func setBeaconHeading(heading:Double) {
		let originX = 0.0
		let originY = 0.0

		let rx = originX + (radius * sin(heading))
		let ry = originY - (radius * cos(heading))
		
		var tmpAngle = (360 - heading).toRadians()
		
//		self.placeVar.animate(from: Transform.rotate(angle: currentAngle,x:x,y:y), to: Transform.rotate(angle: tmpAngle,x:x,y:y), during: 0.5, delay: 0.0)
		self.place = Transform.move(dx: rx, dy: ry)
		
		currentAngle = tmpAngle
		
	}
	
	func returnColor() -> Color {
		return col
	}
}