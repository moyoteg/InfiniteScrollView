//
//  ViewController2ViewController.swift
//  cricut-interview
//
//  Created by Jaime Moises Gutierrez on 1/28/19.
//  Copyright © 2019 M. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, InfiniteScrollViewDataSource, InfiniteScrollViewProtocol, UIScrollViewDelegate {

	@IBOutlet var infiniteScrollView: InfiniteScrollView!
	@IBOutlet var currentIndexLabel: UILabel!
	@IBOutlet var currentContentOffsetLabel: UILabel!
	
	let images:[UIImage] = [#imageLiteral(resourceName: "0"),#imageLiteral(resourceName: "1"),#imageLiteral(resourceName: "2"), #imageLiteral(resourceName: "Moi")]
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		infiniteScrollView.delegate = self
		infiniteScrollView.infiniteScrollDataSource = self
		infiniteScrollView.infiniteScrollDelegate = self
    }
	
	//Mark : InfiniteScrollViewProtocol
	
	func didScroll(to index: Int) {
		currentIndexLabel.text = "\(index)"
	}
	
	//Mark: UIScrollViewDelegate
	
	func infiniteScrollViewDidScroll(_ infiniteScrollView: UIScrollView) {
		currentContentOffsetLabel.text = "x: \(String(format: "%.2f", infiniteScrollView.contentOffset.x))"
	}
	
	//Mark: UIScrollViewDataSource
	
	func numberOfImages() -> Int {
		return images.count
	}

	func image(for index: Int) -> UIImage {
		return images[index]
	}
}
