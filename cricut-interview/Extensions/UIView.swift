//
//  UIView.swift
//  cricut-interview
//
//  Created by Jaime Moises Gutierrez on 1/30/19.
//  Copyright © 2019 M. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

	func pulseToSize(_ scale: CGFloat, duration: TimeInterval, shouldRepeat: Bool) {
		let pulseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		pulseAnimation.duration = duration
		pulseAnimation.fromValue = 1.0
		pulseAnimation.toValue = scale
		pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		pulseAnimation.autoreverses = true
		pulseAnimation.repeatCount = shouldRepeat ? Float.infinity : 0
		self.layer.add(pulseAnimation, forKey: "pulse")
	}

	func pulseFast() {
		self.pulseToSize(1.5, duration: 0.1, shouldRepeat: false)
	}
}
