//
//  UIColor.swift
//  StreetScroller
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable all

extension UIColor {
	static func random() -> UIColor {
		return UIColor(red:.random(),
					   green:.random(),
					   blue:.random(),
					   alpha: 1.0)
	}
}
