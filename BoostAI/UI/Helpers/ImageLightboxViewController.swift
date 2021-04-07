//
//  ImageLightboxViewController.swift
//  BoostAI
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import UIKit

open class ImageLightboxViewController: UIViewController {

    public var image: UIImage
    public weak var imageViewSizeConstraint: NSLayoutConstraint?
    public var minimumZoomScale: CGFloat = 1
    public var maximumZoomScale: CGFloat = 4
    
    private lazy var doubleTapGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        gestureRecognizer.numberOfTapsRequired = 2
        
        return gestureRecognizer
    }()
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        let constraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate(constraints)
        
        return scrollView
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let imageAspectRatio = image.size.width / image.size.height
        
        let constraints = [
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        
        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate(constraints)
        
        return imageView
    }()
    
    public init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.imageViewSizeConstraint?.isActive = false
        
        let imageAspectRatio = image.size.width / image.size.height
        let screenAspectRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        
        let imageViewSizeConstraint: NSLayoutConstraint
        if imageAspectRatio >= screenAspectRatio {
            imageViewSizeConstraint = imageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        } else {
            imageViewSizeConstraint = imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        }
        
        imageViewSizeConstraint.isActive = true
        
        self.imageViewSizeConstraint = imageViewSizeConstraint
    }
    
    @objc func handleDoubleTap(sender: UIGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
       } else {
            scrollView.setZoomScale(1, animated: true)
       }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}

extension ImageLightboxViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.zoomScale == 1 && (scrollView.contentOffset.y < -20 || scrollView.contentOffset.y > 20) {
            dismiss(animated: true, completion: nil)
        }
    }
}
