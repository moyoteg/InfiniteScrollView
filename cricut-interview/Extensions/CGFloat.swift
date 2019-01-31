//
//  CGFloat.swift
//  StreetScroller
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}
