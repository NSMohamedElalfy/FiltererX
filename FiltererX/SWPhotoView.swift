//
//  SWPhotoView.swift
//  VIPhotoViewDemo
//
//  Created by Mohamed El-Alfy on 3/4/16.
//  Copyright © 2016 vito. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    func sizeThatFits(size: CGSize) -> CGSize? {
        
        var imageSize = CGSizeMake(self.size.width / self.scale, self.size.height / self.scale)
        
        let widthRatio = imageSize.width / size.width
        let heightRatio = imageSize.height / size.height
        
        if widthRatio > heightRatio {
            imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio)
        }else{
            imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio)
        }
        
        return imageSize
    }
}

extension UIImageView {
    func contentSize()-> CGSize? {
        return self.image?.sizeThatFits(self.bounds.size)
    }
}

class SWPhotoView: UIScrollView {
    
    var containerView:UIView!
    var imageView:UIImageView!
    
    var rotating = false
    var minSize:CGSize!
    
    init(frame: CGRect , image:UIImage) {
        super.init(frame: frame)
        self.delegate = self
        self.bouncesZoom = true
        
        self.containerView = UIView(frame: self.bounds)
        self.containerView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.containerView)
        
        self.imageView = UIImageView(image: image)
        self.imageView.frame = self.containerView.bounds
        self.imageView.contentMode = .ScaleAspectFit
        self.containerView.addSubview(self.imageView)
        
        let imageSize = imageView.contentSize()
        self.containerView.frame = CGRectMake(0, 0, imageSize!.width, imageSize!.height)
        imageView.bounds = CGRectMake(0, 0, imageSize!.width, imageSize!.height)
        imageView.center = CGPointMake(imageSize!.width / 2, imageSize!.height / 2)
        
        self.contentSize = imageSize!
        self.minSize = imageSize

        self.setMaxMinZoomScale()
        self.centerContent()
        self.setupGestureRecognizer()
        self.setupRotationNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func orientationChanged(notification : NSNotification) {
        self.rotating = true
    }
    
    func setMaxMinZoomScale(){
        let imageSize = self.imageView.image?.size
        let imagePresentationSize = self.imageView.contentSize()
        let maxScale = max((imageSize?.height)! / imagePresentationSize!.height , (imageSize?.width)! / imagePresentationSize!.width)
        self.maximumZoomScale = max(1,maxScale)
        self.minimumZoomScale = 1.0
    }
    
    func centerContent(){
        let frame = self.containerView.frame
        var top:CGFloat = 0 , left:CGFloat = 0
        if (self.contentSize.width < self.bounds.size.width) {
            left = (self.bounds.size.width - self.contentSize.width) * 0.5
        }
        if (self.contentSize.height < self.bounds.size.height) {
            top = (self.bounds.size.height - self.contentSize.height) * 0.5
        }
        
        top -= frame.origin.y;
        left -= frame.origin.x;
        
        self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    }
    
    func setupGestureRecognizer(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapHandler:")
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func tapHandler(recognizer:UITapGestureRecognizer){
        if self.zoomScale > self.minimumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else if self.zoomScale < self.maximumZoomScale {
            let location = recognizer.locationInView(recognizer.view)
            var zoomToRect = CGRectMake(0, 0, 50, 50)
            zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2)
            self.zoomToRect(zoomToRect, animated: true)
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupRotationNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.rotating {
            self.rotating = false
            let containerSize = self.containerView.frame.size
            let containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds))
            let imageSize = self.imageView.image?.sizeThatFits(self.bounds.size)
            let minZoomScale = (imageSize?.width)! / self.minSize.width
            self.minimumZoomScale = minZoomScale
            if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) {
                self.zoomScale = minZoomScale;
            }
            self.centerContent()
        }
    }
    
    
}

extension SWPhotoView : UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerContent()
    }
    
}



