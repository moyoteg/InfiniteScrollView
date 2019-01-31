//
//  InfiniteScrollView.swift
//  StreetScroller
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class InfiniteScrollView: UIScrollView, UIScrollViewDelegate {
	
	private var visibleImageViews: [UIImageView] = [UIImageView]()
	
	private var imageViewContainerView: UIView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		contentSize = CGSize(width: 5000, height: frame.size.height)
		
		imageViewContainerView = UIView()
		imageViewContainerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height / 2)
		addSubview(imageViewContainerView)
		
		imageViewContainerView?.isUserInteractionEnabled = false
		
		// hide horizontal scroll indicator so our recentering trick is not revealed
		showsHorizontalScrollIndicator = false
	}
	
	// recenter content periodically to achieve impression of infinite scrolling
	func recenterIfNecessary() {
		
		let currentOffset: CGPoint = contentOffset
		let contentWidth: CGFloat = contentSize.width
		let centerOffsetX: CGFloat = (contentWidth - bounds.size.width) / 2.0
		let distanceFromCenter = CGFloat(abs(Float(currentOffset.x - centerOffsetX)))
		
		if distanceFromCenter > (contentWidth / 4.0) {
			contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
			
			// move content by the same amount so it appears to stay still
			for imageView: UIImageView in visibleImageViews {
				var center = imageViewContainerView.convert(imageView.center, to: self)
				center.x += centerOffsetX - currentOffset.x
				imageView.center = convert(center, to: imageViewContainerView)
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		recenterIfNecessary()
		
		// tile content in visible bounds
		let visibleBounds: CGRect = convert(bounds, to: imageViewContainerView)
		let minimumVisibleX = visibleBounds.minX
		let maximumVisibleX = visibleBounds.maxX
		
		tileImageViews(fromMinX: minimumVisibleX, toMaxX: maximumVisibleX)
	}
	
	func insertImageView() -> UIImageView {
		let imageView = UIImageView(frame: self.frame)
		imageView.backgroundColor = .random()
		imageViewContainerView.addSubview(imageView)
		
		return imageView
	}

	func placeNewImageView(onRight rightEdge: CGFloat) -> CGFloat {
		let imageView: UIImageView = insertImageView()
		visibleImageViews.append(imageView) // add rightmost imageView at the end of the array
		
		var frame: CGRect = imageView.frame
		frame.origin.x = rightEdge
		frame.origin.y = imageViewContainerView.bounds.size.height - (frame.size.height)
		imageView.frame = frame
		
		return frame.maxX
	}
	
	func placeNewImageView(onLeft leftEdge: CGFloat) -> CGFloat {
		let imageView: UIImageView = insertImageView()
		visibleImageViews.insert(imageView, at: 0) // add leftmost imageView at the beginning of the array
		
		var frame: CGRect = imageView.frame
		frame.origin.x = leftEdge - (frame.size.width)
		frame.origin.y = imageViewContainerView.bounds.size.height - (frame.size.height)
		imageView.frame = frame
		
		return frame.minX
	}

	func tileImageViews(fromMinX minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat) {
		// the upcoming tiling logic depends on there already being at least one imageView in the visibleImageViews array, so
		// to kick off the tiling we need to make sure there's at least one imageView
		if visibleImageViews.count == 0 {
			_ = placeNewImageView(onRight: minimumVisibleX)
		}
		
		// add imageViews that are missing on right side
		var lastImageView = visibleImageViews.last!
		
		var rightEdge = lastImageView.frame.maxX
		while rightEdge < maximumVisibleX {
			rightEdge = placeNewImageView(onRight: rightEdge)
		}
		
		// add imageViews that are missing on left side
		guard var firstImageView: UIImageView = visibleImageViews.first else {
			return
		}
		var leftEdge = firstImageView.frame.minX
		while leftEdge > minimumVisibleX {
			leftEdge = placeNewImageView(onLeft: leftEdge)
		}
		
		// remove imageViews that have fallen off right edge
		while lastImageView.frame.origin.x > maximumVisibleX {
			lastImageView.removeFromSuperview()
			visibleImageViews.removeLast()
			lastImageView = visibleImageViews.last!
		}
		
		// remove imageViews that have fallen off left edge
		firstImageView = visibleImageViews[0]
		while firstImageView.frame.maxX < minimumVisibleX {
			firstImageView.removeFromSuperview()
			visibleImageViews.remove(at: 0)
			firstImageView = visibleImageViews[0]
		}
	}
}
