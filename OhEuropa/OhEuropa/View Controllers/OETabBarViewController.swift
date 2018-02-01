//
//  OETabBarViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 31/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import FontAwesome_swift

class OETabBarViewController: UITabBarController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		self.tabBar.backgroundColor = UIColor.black
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
//		self.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
