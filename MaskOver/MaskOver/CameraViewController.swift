//
//  CameraViewController.swift
//  MaskOver
//
//  Created by Mansur Can on 20/05/2019.
//  Copyright © 2019 Mansur Can. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreData

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

        var session: AVCaptureSession?   //captureSession
        let shapeLayer = CAShapeLayer()
        let imageLayer4 = CALayer()      //previewLayer
        
        
        let faceDetection = VNDetectFaceRectanglesRequest()
        let faceLandmarks = VNDetectFaceLandmarksRequest()
        let faceLandmarksDetectionRequest = VNSequenceRequestHandler()
        let faceDetectionRequest = VNSequenceRequestHandler()
        var sequenceHandler = VNSequenceRequestHandler()
        var imageNose = UIImage(named: "nose01")
        var imageEyes = UIImage(named: "eyes01")
        let noseOptions = ["nose01", "nose02", "nose03", "nose04"]
        let eyeOptions = ["eyes01","eyes02","eyes03","eyes04"]
        var index = 1
        var boun: CGSize?
        var ciimage : CIImage?
        
        var noseImageView : UIImageView?
        var lEyeImageView : UIImageView?
        var rEyeImageView : UIImageView?
        // var stillImageOutput: AVCapturePhotoOutput?
        //captureDevice
        //    var captureDevice = AVCaptureDevice?.self
        var takePhoto = false
        
        var frontCamera: AVCaptureDevice? = {
            return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionPrepare()
        session?.startRunning()
    }
    
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            ciimage = CIImage(cvPixelBuffer: imageBuffer)
            
            // 2
            let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
            
            // 3
            do {
                try sequenceHandler.perform(
                    [detectFaceRequest],
                    on: imageBuffer,
                    orientation: .right)
            } catch {
                print(error.localizedDescription)
            }
            
            
            
        }
        
        
        
        func detectedFace(request: VNRequest, error: Error?) {
            // var point:[(x:CGFloat,y:CGFloat)]
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    // print("Found \(results.count) faces")
                    for faceObservation in results {
                        
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        DispatchQueue.main.async {
                            let boundingRect = faceObservation.boundingBox
                            
                            let faceBoundingBox = boundingRect.scaled(to: self.view.bounds.size)
                            
                            if let leftEye = landmarks.leftEye {
                                self.convertPointsForFace(leftEye,faceBoundingBox,self.imageEyes!, "LEye")
                                
                            }
                            if let rightEye = landmarks.rightEye {
                                self.convertPointsForFace(rightEye,faceBoundingBox,self.imageEyes!, "REye")
                                
                                
                            }
                            
                            if let nose = landmarks.nose{
                                self.convertPointsForFace(nose,faceBoundingBox,self.imageNose!,  "Nose")
                                
                                
                            }
                        }
                        
                    }
                }
                self.shapeLayer.sublayers?.removeAll()
                
                
            } else {
                print(error!.localizedDescription)
            }
            
        }
        
        func convertPointsForFace(_ landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect, _ img : UIImage, _ land: String){
            if let points = landmark?.normalizedPoints {
                let faceLandmarkPoints = points.map { (point: CGPoint) -> (x: CGFloat, y: CGFloat) in
                    let pointX = point.x * boundingBox.width + boundingBox.origin.x
                    let pointY = point.y * boundingBox.height + boundingBox.origin.y
                    return (x: pointX, y: pointY)
                }
                
                DispatchQueue.main.async {
                    self.draw(points: faceLandmarkPoints, img : img, land: land)
                }
            }
            
        }
        
        func draw(points: [(x: CGFloat, y: CGFloat)], img : UIImage, land : String) {
            let newLayer = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: points[0].x - 30, y: points[0].y - 30))
            let p = points.count - 1
            for i in 0..<p {
                let point: CGPoint
                if i == p - 1 {
                    point = CGPoint(x: points[i].x + 30, y: points[i].y + 30)
                    
                }else{
                    point = CGPoint(x: points[i].x , y: points[i].y)
                }
                path.addLine(to: point)
                path.move(to: point)
            }
            
            newLayer.path = path.cgPath
            
            if land == "Nose" {
                newLayer.frame.origin.y = newLayer.frame.origin.y + 20
                newLayer.frame.origin.x = newLayer.frame.origin.x - 10
            }
            
            if land == "LEye" {
                newLayer.frame.origin.y = newLayer.frame.origin.y  + 20
                newLayer.frame.origin.x = newLayer.frame.origin.x  - 10
            }
            
            if land == "REye" {
                newLayer.frame.origin.y = newLayer.frame.origin.y  + 20
                newLayer.frame.origin.x = newLayer.frame.origin.x  - 10
            }
            
            var imageView : UIImageView
            imageView = UIImageView(frame:(newLayer.path?.boundingBox)!)
            imageView.image = img
            
            if land == "Nose" {
                noseImageView = imageView
            }
            
            if land == "LEye" {
                lEyeImageView = imageView
            }
            
            if land == "REye" {
                rEyeImageView = imageView
            }
            
            self.shapeLayer.addSublayer(imageView.layer)
        }
        
        lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
            guard let session = self.session else { return nil }
            
            var previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            
            return previewLayer
        }()
    
    
    
        // MARK: View Controller Life Cycle
        override func viewWillAppear(_ animated: Bool) {
           
            super.viewWillAppear(animated)
            previewLayer?.frame = view.frame
            shapeLayer.frame = view.frame
        }
    
    
    
    
        override func viewWillDisappear(_ animated: Bool) {
            
            super.viewWillDisappear(animated)
        }
    
    
    
    
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard let previewLayer = previewLayer else { return }
            
            view.layer.addSublayer(previewLayer)
            boun = view.bounds.size
            
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2.0
            
            //needs to filp coordinate system for Vision
            shapeLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
            
            view.layer.addSublayer(shapeLayer)
            //   shapeLayer.addSublayer(imageLayer4)
            let bX = (boun!.width / 2)  - 20
            let bY = boun!.height - 120
            let button = UIButton(frame: CGRect(x: bX, y: bY, width: 100, height: 100))
            // button.backgroundColor = .green
            button.setTitle("", for: .normal)
            button.setImage(UIImage(named: "captureIcon"), for: .normal)
            button.addTarget(self, action: #selector(captureBTN), for: .touchUpInside)
            view.addSubview(button)
        }
    
    
    //Capture an image with the button
    
        @objc func captureBTN(sender: UIButton!) {
            
            let uimage = convert(cmage: ciimage!)
            //        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
            //        view.layer.render(in: UIGraphicsGetCurrentContext()!)
            //        let image = UIGraphicsGetImageFromCurrentImageContext()
            //        UIGraphicsEndImageContext()
            
            let newImage = self.composite(image:uimage)
            UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil)
            
            //  UIImageWriteToSavedPhotosAlbum(uimage, nil, nil, nil)
        }
//
//    @objc func logOutBTN(sender: UIButton!){
//
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "viewcontroller") as! ViewController
//        self.present(nextViewController, animated:true, completion:nil)
//
//
//    }
    
        func convert(cmage:CIImage) -> UIImage
        {
            let context:CIContext = CIContext.init(options: nil)
            let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
            let image:UIImage = UIImage.init(cgImage: cgImage)
            let nimage = image.rotate(radians: .pi/2)!
            return nimage
        }
    
    
    
    //Nose, left&right eye location adjusting for photo capturing
    
        func composite(image:UIImage)->UIImage?{
            UIGraphicsBeginImageContext(image.size)
            var overlay : UIImage?
            var rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: rect)
            
            //////////////// NOSE
            
            let wratio = image.size.width / view.frame.size.width + CGFloat(0.8)
            let yratio = image.size.width / view.frame.size.width + CGFloat(0.2)
            
            
            ////////////// LEYE
            
            overlay = lEyeImageView!.image
            var Px = (lEyeImageView?.frame.origin.x)! * wratio
            var Py = (lEyeImageView?.frame.origin.y)! * yratio + CGFloat(0.2)
            
            rect = CGRect(x: Px, y: Py, width: overlay!.size.width, height: overlay!.size.height)
            overlay!.draw(in: rect)
            
            ////////////// REYE
            
            overlay = rEyeImageView!.image
            Px = (rEyeImageView?.frame.origin.x)! * wratio
            Py = (rEyeImageView?.frame.origin.y)! * yratio + CGFloat(0.2)
            
            rect = CGRect(x: Px, y: Py, width: overlay!.size.width, height: overlay!.size.height)
            overlay!.draw(in: rect)
            
            ////nose
            overlay = noseImageView!.image
            overlay = overlay?.rotate(radians: .pi)
            
            Px = (noseImageView?.frame.origin.x)! * wratio
            Py = (noseImageView?.frame.origin.y)! * yratio + CGFloat(0.1)
            
            let r = image.size.width / view.frame.size.width
            
            rect = CGRect(x: Px, y: Py, width: overlay!.size.width / r, height: overlay!.size.height / r)
            
            overlay!.draw(in: rect)
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        
        
        
        
        func sessionPrepare() {
            
            //suitable for high resolution
            //session?.sessionPreset = AVCaptureSession.Preset.photo
            
            session = AVCaptureSession()
            guard let session = session, let captureDevice = frontCamera else { return }
            
            do {
                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                session.beginConfiguration()
                // stillImageOutput = AVCapturePhotoOutput()
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }else{
                    print("kCFErrorLocalizedDescriptionKey" )
                }
                
                
            
                let output = AVCaptureVideoDataOutput()
                output.videoSettings = [
                    String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                ]
                
                output.alwaysDiscardsLateVideoFrames = true
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                session.commitConfiguration()
                let queue = DispatchQueue(label: "output.queue")
                output.setSampleBufferDelegate(self, queue: queue)
                print("setup delegate")
            } catch {
                print("can't setup session")
            }
        }
        
        
    //Tap to change the emoji
        @IBAction func tapGestureFunc(_ sender: Any) {
            imageNose = UIImage(named: noseOptions[index])
            imageEyes = UIImage(named: eyeOptions[index])
            index = index + 1
            if index >= 4 {
                index = 0
            }
            
        }
    

        
        
    }
    
    extension CGRect {
        func scaled(to size: CGSize) -> CGRect {
            return CGRect(
                x: self.origin.x * size.width,
                y: self.origin.y * size.height,
                width: self.size.width * size.width,
                height: self.size.height * size.height
            )
        }
    }



    extension UIImage {
        
        func rotate(radians: Float) -> UIImage? {
            var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size

            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
            let context = UIGraphicsGetCurrentContext()!
            
            // Move origin to middle
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            // Rotate around middle
            context.rotate(by: CGFloat(radians))
            // Draw the image at its center
            self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }

   


