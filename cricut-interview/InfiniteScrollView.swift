//
//  InfiniteScrollView.swift
//  StreetScroller
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

protocol InfiniteScrollViewProtocol: class {
	func didScroll(to index: Int)
}

protocol InfiniteScrollViewDataSource: class {
	func numberOfImages() -> Int
	func image(for index: Int) -> UIImage
	func imageContentMode(for index: Int) -> UIView.ContentMode
}

class InfiniteScrollView: UIScrollView {

	// MARK: properties

	private var imageViewContainerView: UIView!

	// MARK: Delegates

	weak var infiniteScrollDelegate: InfiniteScrollViewProtocol?
	weak var infiniteScrollDataSource: InfiniteScrollViewDataSource?

	var defaultImageMode: UIView.ContentMode = .scaleAspectFit

	private var visibleImageViews: [UIImageView] = [UIImageView]() {
		didSet {
			print("visible image views count: \(visibleImageViews.count)")
			var indices: String = ""
			visibleImageViews.forEach { (imageView) in
				indices.append("[\(imageView.tag)] ")
			}
			print(indices)
		}
	}

	// MARK: parameter properties

	let numberOfRecyclingViews = 3

	/// keeps track of the true index without wrapping
	var currentRelativeCenterIndex: Int = 0 {
		didSet {
			infiniteScrollDelegate?.didScroll(to: currentCenterIndex)
		}
	}

	var currentCenterIndex: Int {
		guard let numberOfImages = self.infiniteScrollDataSource?.numberOfImages() else {
			return currentRelativeCenterIndex
		}
		return self.currentRelativeCenterIndex.mod(numberOfImages)
	}

	// MARK: init methods

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	func setupView() {
		imageViewContainerView = UIView()
		imageViewContainerView.frame = frame
		imageViewContainerView.isUserInteractionEnabled = false
		let width = imageViewContainerView.frame.width * CGFloat(numberOfRecyclingViews)
		contentSize = CGSize(width: width, height: frame.size.height)
		addSubview(imageViewContainerView)
		// hide horizontal scroll indicator so our recentering trick is not revealed
		showsHorizontalScrollIndicator = false
	}

	/// recenter content periodically to achieve impression of infinite scrolling
	func recenterIfNecessary() {
		let currentOffset: CGPoint = contentOffset
		let contentWidth: CGFloat = contentSize.width
		let centerOffsetX: CGFloat = (contentWidth - bounds.size.width) / 2.0
		let distanceFromCenter = CGFloat(abs(Float(currentOffset.x - centerOffsetX)))
		/*
		This value determines when recentering happens affecting
		inertia conservation.Lower means recentering happens sooner
		therefore more inertia conservation.
		*/
		let inertiaConservationRate: CGFloat = 0.1
		if distanceFromCenter > (contentWidth / CGFloat(numberOfRecyclingViews) * inertiaConservationRate) {
			contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
			// move content by the same amount so it appears to stay still
			for imageView: UIImageView in visibleImageViews {
				var center = imageViewContainerView.convert(imageView.center, to: self)
				center.x += centerOffsetX - currentOffset.x
				imageView.center = convert(center, to: imageViewContainerView)
			}
		}
	}

	/// layoutSubviews
	override func layoutSubviews() {
		super.layoutSubviews()
		recenterIfNecessary()
		// tile content in visible bounds
		let visibleBounds: CGRect = convert(bounds, to: imageViewContainerView)
		let minimumVisibleX = visibleBounds.minX
		let maximumVisibleX = visibleBounds.maxX
		tileImageViews(fromMinX: minimumVisibleX, toMaxX: maximumVisibleX)
	}

	// MARK: View Insertion Logic

	/// Insert new view to image view container view
	///
	/// - Returns: uimage view that was added
	func insertImageView() -> UIImageView {
		let imageView = UIImageView(frame: self.frame)
		imageView.clipsToBounds = true
		imageView.backgroundColor = .random()
		imageViewContainerView.addSubview(imageView)
		return imageView
	}

	/// Insert an ImageView to the right of the carousel
	///
	/// - Parameter rightEdge: max x value of visible bounds of container
	/// - Returns: Returns the largest value of the x-coordinate for the rectangle.
	func placeNewImageView(onRight rightEdge: CGFloat) -> CGFloat {
		let imageView: UIImageView = insertImageView()
		if visibleImageViews.count == 0 {
			imageView.image = imageFor(index: currentCenterIndex)
			imageView.tag = currentCenterIndex
		} else {
			if let lastTag = visibleImageViews.last?.tag {
				imageView.tag = (lastTag + 1).mod(numberOfImages())
				imageView.image = imageFor(index: imageView.tag)
			}
		}
		imageView.contentMode = contentMode(for: imageView.tag)
		visibleImageViews.append(imageView) // add rightmost imageView at the end of the array
		var frame: CGRect = imageView.frame
		frame.origin.x = rightEdge
		frame.origin.y = imageViewContainerView.bounds.size.height - (frame.size.height)
		imageView.frame = frame
		return frame.maxX
	}

	/// Insert an ImageView to the left of the carousel
	///
	/// - Parameter leftEdge: max x value of visible bounds of container
	/// - Returns: smallest value for the x
	func placeNewImageView(onLeft leftEdge: CGFloat) -> CGFloat {
		let imageView: UIImageView = insertImageView()
		if let firstTag = visibleImageViews.first?.tag {
			imageView.tag = (firstTag - 1).mod(numberOfImages())
			imageView.image = imageFor(index: imageView.tag)
		}
		imageView.contentMode = contentMode(for: imageView.tag)
		visibleImageViews.insert(imageView, at: 0) // add leftmost imageView at the beginning of the array
		var frame: CGRect = imageView.frame
		frame.origin.x = leftEdge - frame.size.width
		frame.origin.y = imageViewContainerView.bounds.size.height - frame.size.height
		imageView.frame = frame
		return frame.minX
	}

	/// Using the imageViewContainerView we delimit the min and max x values
	///
	/// - Parameters:
	///   - minimumVisibleX: minimum allowed x value that is visible
	///   - maximumVisibleX: max allowed x value that is visible
	func tileImageViews(fromMinX minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat) {
		// the upcoming tiling logic depends on there already being at least one imageView in the visibleImageViews array, so
		// to kick off the tiling we need to make sure there's at least one imageView
		if visibleImageViews.count == 0 {
			_ = placeNewImageView(onRight: minimumVisibleX)
		}

		// add imageViews that are missing on right side
		guard var currentLastImageView = visibleImageViews.last else {
			return
		}
		var rightEdge = currentLastImageView.frame.maxX
		while rightEdge < maximumVisibleX {
			rightEdge = placeNewImageView(onRight: rightEdge)
		}

		// add imageViews that are missing on left side
		guard var currentFirstImageView: UIImageView = visibleImageViews.first else {
			return
		}
		var leftEdge = currentFirstImageView.frame.minX
		while leftEdge > minimumVisibleX {
			leftEdge = placeNewImageView(onLeft: leftEdge)
		}

		// remove imageViews that have fallen off right edge
		while currentLastImageView.frame.origin.x > maximumVisibleX {
			currentLastImageView.removeFromSuperview()
			visibleImageViews.removeLast()
			guard let lastImageView = visibleImageViews.last else {
				break
			}
			currentLastImageView = lastImageView
			// scrolled left
			currentRelativeCenterIndex -= 1
		}

		// remove imageViews that have fallen off left edge
		currentFirstImageView = visibleImageViews[0]
		while currentFirstImageView.frame.maxX < minimumVisibleX {
			currentFirstImageView.removeFromSuperview()
			visibleImageViews.remove(at: 0)
			guard let firstImageView = visibleImageViews.first else {
				break
			}
			currentFirstImageView = firstImageView
			// scrolled right
			currentRelativeCenterIndex += 1
		}
	}

	// MARK: Helper Methods

	/// get image for index
	///
	/// - Parameter index: current index
	/// - Returns: image for index
	func imageFor(index: Int) -> UIImage? {
		return self.infiniteScrollDataSource?.image(for: index.mod(numberOfImages()))
	}

	/// gets the number of images from the delegate
	///
	/// - Returns: if no delegate is available it returns 0
	func numberOfImages() -> Int {
		guard let numberOfImages = self.infiniteScrollDataSource?.numberOfImages() else {
			return 0
		}
		return numberOfImages
	}

	/// gets the content mode from the delegate
	///
	/// - Parameter index: index for image view
	/// - Returns: returns content mode or defaults
	func contentMode(for index: Int) -> UIView.ContentMode {
		guard let mode = infiniteScrollDataSource?.imageContentMode(for: index) else {
			return defaultImageMode
		}
		return mode
	}
}
