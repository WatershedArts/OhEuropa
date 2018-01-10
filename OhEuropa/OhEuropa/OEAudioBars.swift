//
//  OEAudioBars.swift
//  OhEuropa
//
//  Created by David Haylock on 07/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import Macaw

class Bar : Group {
	var currentHeight: Double = 0.0
	
	init(x:Double,y: Double, width: Double, height:Double) {
		
		//		let shape = Shape(form: Circle(cx:x,cy:y,r:10), fill: col, stroke: Stroke(fill: col, width: 3))
		let shape = Shape(form: Rect(x: x, y: y, w: width, h: height),fill:Color.black)
		
		currentHeight = height
		super.init(contents: [shape])
	}
	
	func setNewHeight(height:Double) {
//		compassGroup.placeVar.animate(
//			from: Transform.rotate(angle: currentAngle,x:centerX,y:centerY),
//			to: Transform.rotate(angle: tmpAngle,x:centerX,y:centerY),
//			during: 0.1,
//			delay: 0.0)
//		self.place = Transform.move(dx: 0, dy: height)
		self.placeVar.animate(from: Transform.move(dx: 1, dy: currentHeight), to: Transform.move(dx: 1, dy: height), during: 0.075, delay: 0.0 )//		self.place =
//			Transform.scale(sx: 1, sy: currentHeight), to: Transform.scale(sx: 1, sy: height), during: 0.1, delay: 0.0 )//		self.place = Transform.scale(sx: 1, sy: height)
		currentHeight = height
	}
}

class OEAudioBars: MacawView {

	var centerX: Double!
	var centerY: Double!
	
	
	var randomness = 1.0
	var animation: Animation?
	var bars = [Bar]()
	
	var timer:Timer!
	
	
	@objc func timerFunc() {
		for (index,bar) in bars.enumerated() {
			var newHeight = 0.5 + 25 * tan(Double(Date().timeIntervalSince1970 * 1000.0))
//			print(" Index \(index) \(newHeight)")
			bar.setNewHeight(height: newHeight)
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// Init
	///------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		
		// Call the View with blank content
		super.init(node: Group(), coder: aDecoder)
		self.backgroundColor = UIColor.clear
		centerX = Double(self.center.x)
		centerY = Double(self.center.y)
		
		
		
		let barwidth = 10.0
		let spacing = 3.0
		var numberofbars = Double(self.bounds.width) / (barwidth + spacing)
		
		for i in 0...Int(numberofbars) {
			bars.append(Bar(x: Double(i) * (barwidth + spacing), y: self.centerY, width: barwidth, height: 2))
		}
		
		self.node = Group(contents: bars)

		
//		Timer.scheduledTimer(timeInterval: 0.076, target: self, selector: #selector(timerFunc), userInfo: nil, repeats: true)
		
//		group.contentsVar.animation({ t in
//			let color = Color.rgba(r: 0, g: 0, b: 255, a: 1 - t)
//			
//			
//			
//			return [
////				for i in 0...Int(numberofbars) {
////					Rect(x: 100, y: 100, w: 10, h: t * 100).fill(with: Color.black),
////				}
//			]
//		}, during:0.5, delay:0.1).easing(.easeInOut).cycle().autoreversed().play()
		
//		let barwidth = 10.0
//		let spacing = 3.0
//		let height = 10.0
//		let numberofbars = Double(self.bounds.width) / (barwidth + spacing)
//
//		for i in 0...Int(numberofbars) {
//			let tmpShape = Rect(x: (Double(i) * (barwidth + spacing)), y: Double(self.frame.height / 2) - Double(height / 2), w: barwidth, h: height)
//			bars.append(Shape(form: tmpShape, fill: Color.black))
//		}
//
//		self.node = Group(contents: bars)
	}
}
