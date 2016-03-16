//
//  MainViewController.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    @IBOutlet weak var cameraButton:UIButton!
    @IBOutlet weak var photoLibButton: UIButton!
    @IBOutlet weak var paletteButton: UIButton!
    @IBOutlet weak var noAvailableCameraLabel:UILabel!
    
    let captureSession = AVCaptureSession()
    var backFacingCamera:AVCaptureDevice?
    var frontFacingCamera:AVCaptureDevice?
    var currentDevice:AVCaptureDevice?
    
    var stillImageOutput:AVCaptureStillImageOutput?
    var stillImage:UIImage?
    
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // camera setup
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.noAvailableCameraLabel.removeFromSuperview()
            setupCaptureSession()
        }else{
            self.noAvailableCameraLabel.text = "Camera Device is not Available in Simulator so please Pick an Image From PhotoLiberary"
        }
        print("\(__FUNCTION__)")
    }
    
    /*override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // walkthrough Setup
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthrough")
        
        if hasViewedWalkthrough == false {
            /*if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController {
            
            self.presentViewController(pageViewController, animated: true, completion: nil)
            }*/
            
            showWalkthrough()
        }
        
    }*/
    
    /*func showWalkthrough(){
        
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("WalkContainer") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("WalkPage1")
        let page_two = stb.instantiateViewControllerWithIdentifier("WalkPage2")
        let page_three = stb.instantiateViewControllerWithIdentifier("WalkPage3")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)
    }*/
    
    
    func setupCaptureSession(){
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        // Get the front and back-facing camera for taking photos
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevicePosition.Front {
                frontFacingCamera = device
            }
        }
        currentDevice = backFacingCamera
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
            
            // Configure the session with the output for capturing still images
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            // Configure the session with the input and the output devices
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput)
            
        } catch {
            print(error)
            return
        }
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // Bring the camera & photoLib button to front
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(photoLibButton)
        view.bringSubviewToFront(paletteButton)
        captureSession.startRunning()
        
        // Toggle Camera recognizer
        toggleCameraGestureRecognizer.direction = .Down
        toggleCameraGestureRecognizer.addTarget(self, action: "toggleCamera")
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .Right
        zoomInGestureRecognizer.addTarget(self, action: "zoomIn")
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .Left
        zoomOutGestureRecognizer.addTarget(self, action: "zoomOut")
        view.addGestureRecognizer(zoomOutGestureRecognizer)
    }

    
    @IBAction func didCaptureImage(){
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                self.stillImage = UIImage(data: imageData)
                self.performSegueWithIdentifier("ShowPhotoEditor", sender: self.stillImage?.fixOrientation() )
                
            })
        }
    }
    
    func toggleCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.Back) ? frontFacingCamera : backFacingCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    @IBAction func didPickImage(){
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .PhotoLibrary
            
            presentViewController(picker, animated: true, completion: nil)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            captureSession.stopRunning()
        }
        
        if segue.identifier == "ShowPhotoEditor" {
            let editorVC = segue.destinationViewController as! EditorViewController
            editorVC.delegate = self
            editorVC.originalImage = sender as? UIImage
        }else{
            let NVC = segue.destinationViewController as! UINavigationController
            let palettesVC = NVC.topViewController as! PalettesTableViewController
            palettesVC.delegate = self
        }
    }
    
    @IBAction func onShowPalettes(sender: AnyObject) {
        performSegueWithIdentifier("ShowPalettes", sender: sender)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension MainViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            performSegueWithIdentifier("ShowPhotoEditor", sender: image)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension MainViewController : UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.barTintColor = UIColor.hex("#76C2AF")
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
}

extension MainViewController : ReSetupCaptureSessionDelegate {
    func reSetupCaptureSession() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            captureSession.startRunning()
        }
    }
}

extension MainViewController : BWWalkthroughViewControllerDelegate {
    
    func walkthroughCloseButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func walkthroughPageDidChange(pageNumber: Int) {
        print(pageNumber)
    }
    
    func walkthroughNextButtonPressed() {
     print("next")
    }
    
    func walkthroughPrevButtonPressed() {
     print("previous")
    }
}

