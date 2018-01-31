//
//  InformationViewController.swift
//  OhEuropa
//
//  Created by David Haylock on 08/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import UIKit
import AVFoundation

class OEInformationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewDidLayoutSubviews() {
		print(self.view.bounds)
		let backButton = UIButton(frame: CGRect(x: self.view.bounds.width-(14+40), y: self.view.bounds.height-(14+40), width: 40, height: 40))
		backButton.setImage(UIImage.fontAwesomeIcon(name: .compass, textColor: DEFAULT_COLOR_OPPOSED, size: CGSize(width: 25, height: 25), backgroundColor: UIColor.clear), for: UIControlState.normal)
		
		backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
		backButton.layer.cornerRadius = 0.5 * backButton.bounds.size.width
		backButton.backgroundColor = DEFAULT_COLOR
		self.view.addSubview(backButton)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	///------------------------------------------------------------------------------------------
	/// Dismiss the View Controller
	///------------------------------------------------------------------------------------------
	@objc func dismissViewController() {
		print("Dismissing Popover")
		self.dismiss(animated: true, completion: nil)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
