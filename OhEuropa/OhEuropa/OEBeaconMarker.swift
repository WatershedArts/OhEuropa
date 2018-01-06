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
	
	///------------------------------------------------------------------------------------------
	/// Initilize Beacon
	///
	/// - Parameter beaconName:
	///------------------------------------------------------------------------------------------
	init(beaconName:String) {
		col = Color.rgb(r: Int(arc4random_uniform(255)), g:Int(arc4random_uniform(255)), b: Int(arc4random_uniform(255)))
		let shape = Shape(form: Circle(cx: 150,cy:150,r:10), fill: col, stroke: Stroke(fill: col, width: 3))
		super.init(contents: [shape])
		
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
		let radius = 120.0
		
		let rx = originX + (radius * sin(heading))
		let ry = originY - (radius * cos(heading))
		self.place = Transform.move(dx: rx, dy: ry)
	}
	
	func returnColor() -> Color {
		return col
	}
}
