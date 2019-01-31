//
//  Int.swift
//  cricut-interview
//
//  Created by Jaime Moises Gutierrez on 1/30/19.
//  Copyright © 2019 M. All rights reserved.
//

import Foundation

extension Int {
	func mod(_ integer: Int) -> Int {
		precondition(integer > 0, "modulus must be positive")
		let remainder = self % integer
		return remainder >= 0 ? remainder : remainder + integer
	}
}
