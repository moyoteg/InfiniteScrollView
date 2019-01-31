//
//  ViewController2ViewController.swift
//  cricut-interview
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 M. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InfiniteScrollViewDataSource, InfiniteScrollViewProtocol, UIScrollViewDelegate {

	var infiniteScrollView: InfiniteScrollView!
	@IBOutlet var currentIndexLabel: UILabel!
	@IBOutlet var currentContentOffsetLabel: UILabel!

	/// images to be displayed
	let images: [UIImage] = [#imageLiteral(resourceName: "0"), #imageLiteral(resourceName: "1"), #imageLiteral(resourceName: "2")]

    override func viewDidLoad() {
        super.viewDidLoad()

		infiniteScrollView = InfiniteScrollView(frame: self.view.frame)
		self.view.insertSubview(infiniteScrollView, at: 0)

        // Do any additional setup after loading the view.
		infiniteScrollView.delegate = self
		infiniteScrollView.infiniteScrollDataSource = self
		infiniteScrollView.infiniteScrollDelegate = self
    }

	// MARK: UIScrollViewDelegate

	func scrollViewDidScroll(_ infiniteScrollView: UIScrollView) {
		currentContentOffsetLabel.text = "x offset: \(String(format: "%.2f", infiniteScrollView.contentOffset.x))"
	}

	// MARK: InfiniteScrollViewProtocol

	func didScroll(to index: Int) {
		currentIndexLabel.text = "\(index)"
		currentIndexLabel.pulseFast()
	}

	// MARK: InfiniteScrollViewDataSource

	func numberOfImages() -> Int {
		return images.count
	}

	func image(for index: Int) -> UIImage {
		return images[index]
	}

	func imageContentMode(for index: Int) -> UIView.ContentMode {
		return .scaleAspectFit
	}
}
