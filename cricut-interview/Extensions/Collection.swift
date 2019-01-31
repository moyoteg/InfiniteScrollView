//
//  Collection.swift
//  cricut-interview
//
//  Created by Jaime Moises Gutierrez on 1/30/19.
//  Copyright © 2019 M. All rights reserved.
//

import Foundation

extension Collection {
	subscript(safe index: Index) -> Iterator.Element? {
		guard indices.contains(index) else { return nil }
		return self[index]
	}
}
