//
//  NewCameraViewController.swift
//  VideoGraph
//
//  Created by Techsviewer on 11/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreData
import MobileCoreServices
import AVFoundation
import FCAlertView
import AVKit


class NewCameraViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, RecordingButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var m_cameraContainer: UIView!
    @IBOutlet weak var m_viewCamera: UIView!
    @IBOutlet weak var m_imgCamera: UIImageView!
    @IBOutlet weak var m_blurView: UIVisualEffectView!
    

    @IBOutlet weak var m_viewCounter: UIView!
    @IBOutlet weak var m_lblCounter: UILabel!
    
    @IBOutlet weak var m_btnCancel: UIButton!
    @IBOutlet weak var m_btnFlash: UIButton!
    @IBOutlet weak var m_btnShowGrid: UIButton!
    @IBOutlet weak var m_btnFlipCamera: UIButton!
    
    @IBOutlet weak var m_btnAlbum: UIButton!
    @IBOutlet weak var m_btnCapture: RecordingButton!
    @IBOutlet weak var m_viewCameraSensor: CameraSensorView!
    
    @IBOutlet weak var m_constraintCameraViewWidth: NSLayoutConstraint!
    
    
    var menuScrollView: CenterFocusView? = nil
    
    @IBOutlet weak var tbl_left_setting: UITableView!
    @IBOutlet weak var constant_frame_top: NSLayoutConstraint!
    @IBOutlet weak var constant_time_top: NSLayoutConstraint!
    @IBOutlet weak var constant_awb_top: NSLayoutConstraint!
    @IBOutlet weak var constant_leftTbl_top: NSLayoutConstraint!
    @IBOutlet weak var constant_leftTbl_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var btn_left_frame: UIButton!
    var array_setting_frame = NSArray.init(objects: "24", "30", "60", "120", "240")
    @IBOutlet weak var btn_left_time: UIButton!
    var array_setting_timer = NSArray.init(objects: "0sec", "3sec", "10sec")
    @IBOutlet weak var btn_left_awb: UIButton!
    var array_setting_awb = NSArray.init(objects: "1-gray", "2-gray", "3-gray", "4-gray", "5-gray")
    
    var nLeftSettingActiveMode: Int = 0
    var nLeftSettingActiveIndex: Int = 0
    
    var nSelectedMenu: CameraMenu = .Ratio
    
    var bLoadedView: Bool = false
    var bStartingCapture: Bool = false
    
    var imagePicker: UIImagePickerController?
    var selectedVideoURL: URL? = nil
    
    var bFlashOn: Bool = false
    var bShowGrid: Bool = false
    
    var nTimerCounter: Int = 0
    
    var startedRecordTime: Double = 0.0
    
    //camera settings
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var back_device: AVCaptureDevice?
    var front_device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var defaultVideoFormat: AVCaptureDevice.Format?
    var defaultVideoMaxFrameDuration: CMTime? = nil
    var defaultVideoMinFrameDuration: CMTime? = nil
    var focusView: UIView?
    var cameraMode: Camera = .Back
    var flashView: UIView? = nil
    var orientation: AVCaptureVideoOrientation = .portrait
    let context = CIContext()
    
    var bShowedCameraPermissionDialog: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.UIActionLeftFrame()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        imagePicker = UIImagePickerController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishedCounterAnimation), name: NSNotification.Name(rawValue: Constants.NotificationName.FinishedAnimation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDroppedBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appReactivatedForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (bSuccess) in
            DispatchQueue.main.async {
                if (bSuccess) {
                    self.doCameraSettings()
                } else {
                    self.showCameraPermissionWaring()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TheMotionManager.startMonitoring(self.m_viewCameraSensor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TheMotionManager.stopMonitoring()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        InterfaceManager.makeRadiusControl(self.m_viewCameraSensor, cornerRadius: self.m_viewCameraSensor.bounds.height / 2.0, withColor: UIColor.white, borderSize: 2.0)
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        makeUserInterface()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func makeUserInterface() {
        self.m_btnCapture.delegate = self
        self.m_btnFlash.tintColor = self.bFlashOn ? UIColor.black : UIColor.lightGray.withAlphaComponent(0.6)
        
        hideGrid()
        self.m_btnShowGrid.tintColor = self.bShowGrid ? UIColor.black : UIColor.lightGray.withAlphaComponent(0.6)
        
        adjustCameraCanvasHeight()
        showMenuContentView()
        
        if (TheGlobalPoolManager.cameraSettings.RatioIdx == 0) {
            TheGlobalPoolManager.tempCameraViewOffset = (self.m_imgCamera.frame.minY)
        }
    }
    func selectedOneOption(nIdx: Int) {
        switch self.nSelectedMenu {
        case .FPS:
            TheGlobalPoolManager.cameraSettings.FPSIdx = nIdx
            showBlurView(true)
            DispatchQueue.global(qos: .background).async {
                self.setupCorrectFrameRate()
                
                DispatchQueue.main.async {
                    self.showBlurView(false)
                }
            }
            break
        case .Ratio:
            TheGlobalPoolManager.cameraSettings.RatioIdx = nIdx
            self.adjustCameraCanvasHeight(true)
            break
        case .Timer:
            TheGlobalPoolManager.cameraSettings.TimerIdx = nIdx
        default:
            break
        }
    }
    @objc func finishedCounterAnimation() {
        if (self.nTimerCounter == 0) {
            enabledAllTheActions()
            
            self.m_viewCounter.isHidden = true
            self.enabledAllTheActions(false, false)
            self.m_btnCapture.startAnimation(duration: MAX_VIDEO_DURATION)
            
            self.bStartingCapture = true
            
            startedRecordTime = Date().timeIntervalSince1970
        } else {
            self.startCounterAnimation()
        }
    }
    @objc func appDroppedBackground() {
        print("app goes to background")
        self.stopCamera()
        self.m_imgCamera.image = nil
    }
    @objc func appReactivatedForeground() {
        print("app goes to foreground")
        self.showCameraPermissionWaring()
        
        self.showBlurView(true)
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.startCamera()
        })
    }
    func startCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == AVAuthorizationStatus.authorized {
            session?.startRunning()
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            session?.stopRunning()
        }
        
        DispatchQueue.main.async {
            self.showBlurView(false)
        }
    }
    func stopCamera() {
        self.session?.stopRunning()
    }
    
    
    func doCameraSettings() {
        orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        
        // AVCapture
        session = AVCaptureSession()
        self.addVideoOutput()
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        self.back_device = devices.filter({ $0.position == .back }).first
        self.front_device = devices.filter({ $0.position == .front }).first
        
        self.cameraMode = .Back
        self.device = self.back_device
        
        self.defaultVideoFormat = self.device!.activeFormat
        self.defaultVideoMaxFrameDuration = self.device!.activeVideoMaxFrameDuration
        self.defaultVideoMinFrameDuration = self.device!.activeVideoMinFrameDuration
        
        do {
            if let session = self.session {
                session.beginConfiguration()
                
                session.automaticallyConfiguresApplicationAudioSession = false
                session.sessionPreset = AVCaptureSession.Preset.hd1280x720
                
                self.videoInput = try AVCaptureDeviceInput(device: self.device!)
                session.addInput(self.videoInput!)
                
                self.flashConfiguration()
                
                session.commitConfiguration()
            }
            
            DispatchQueue.main.async {
                // Focus View
                self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
                let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(self.focus(_:)))
                tapRecognizer.numberOfTapsRequired = 1
                tapRecognizer.delegate = self
                self.m_imgCamera.isUserInteractionEnabled = true
                self.m_imgCamera.addGestureRecognizer(tapRecognizer)
                
                self.startCamera()
            }
        } catch {
            DispatchQueue.main.async {
                print("Failed to init camera")
            }
        }
    }
    func addVideoOutput() {
        guard let session = session else {
            return
        }
        
        for output in session.outputs {
            if output is AVCaptureVideoDataOutput {
                (output as! AVCaptureVideoDataOutput).setSampleBufferDelegate(nil, queue: nil)
                session.removeOutput(output)
            }
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.videograph.queue", qos: .background))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
    }
    func forceFlashConfiguration() {
        do {
            if let device = device {
                guard device.hasTorch else { return }
                
                try device.lockForConfiguration()
                
                if (device.hasTorch) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                }
                
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }
    func flashConfiguration() {
        do {
            if let device = device {
                guard device.hasTorch else { return }
                
                try device.lockForConfiguration()
                
                if (self.bFlashOn) {
                    if (device.hasTorch) {
                        device.torchMode = AVCaptureDevice.TorchMode.on
                    }
                } else {
                    if (device.hasTorch) {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                    }
                }
                
                
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.m_viewCamera)
        let viewsize = self.m_viewCamera.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        guard let device = device else {
            return
        }
        
        do {
            try device.lockForConfiguration()
        } catch _ {
            return
        }
        
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {
            
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device.focusPointOfInterest = newPoint
        }
        
        if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = UIColor.init(hex: 0xFFFFFF, alpha: 1.0).cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.m_imgCamera.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.focusView!.removeFromSuperview()
        })
    }
    func setupCorrectFrameRate() {
        guard let device = self.device else {
            return
        }
        
        var bFoundBestRate: Bool = false
        var bestFrameRate: AVFrameRateRange? = nil
        var bestFormat: AVCaptureDevice.Format? = nil
        
        for vFormat in device.formats {
            let videoDimension = CMVideoFormatDescriptionGetDimensions(vFormat.formatDescription)
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            print(frameRates.maxFrameRate)
            print(videoDimension)
            
            if frameRates.maxFrameRate == Float64(Constants.CameraOptions.FPS[TheGlobalPoolManager.cameraSettings.FPSIdx])! && videoDimension.width >= 1280 {
                bFoundBestRate = true
                bestFormat = vFormat
                bestFrameRate = frameRates
                
                break
            }
        }
        
        do {
            try device.lockForConfiguration()
            //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
            if (bFoundBestRate) {
                print("found best frame rate - \(bestFormat!)")
                device.activeFormat = bestFormat!
                device.activeVideoMinFrameDuration = bestFrameRate!.minFrameDuration
                device.activeVideoMaxFrameDuration = bestFrameRate!.maxFrameDuration
            } else {
                print("++++ not found best frame rate, so set as default")
                device.activeFormat = self.defaultVideoFormat!
                device.activeVideoMinFrameDuration = self.defaultVideoMinFrameDuration!
                device.activeVideoMaxFrameDuration = self.defaultVideoMaxFrameDuration!
            }
            
            device.unlockForConfiguration()
            
            print("setup active format")
        }
        catch {
            print("Could not set active format")
            print(error)
        }
    }
    func showBlurView(_ bShow: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.m_blurView.alpha = (bShow ? 1.0 : 0.0)
        }
    }
    func showCameraPermissionWaring() {
        if (self.bShowedCameraPermissionDialog) {
            return
        }
        
        let cameraAuthrization = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (cameraAuthrization == .denied || cameraAuthrization == .restricted) {
            self.bShowedCameraPermissionDialog = true
            let alertView = FCAlertView.init()
            alertView.makeAlertTypeWarning()
            alertView.bounceAnimations = true
            alertView.titleFont = UIFont.systemFont(ofSize: 18.0)
            alertView.subtitleFont = UIFont.systemFont(ofSize: 14.0)
            alertView.showAlert(withTitle: nil, withSubtitle: "'VideoGraph' requires access to camera so that you can record video. Go to Settings and allow permission to access camera now.", withCustomImage: nil, withDoneButtonTitle: "Settings", andButtons: nil)
            alertView.doneActionBlock({
                self.bShowedCameraPermissionDialog = false
                
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        }
    }
    
    func showGrid() {
        for nIdx in 0..<4 {
            if let seperatorView = self.m_cameraContainer.viewWithTag(40 + nIdx) {
                seperatorView.isHidden = false
                InterfaceManager.addShadowToView(seperatorView, UIColor.black, .zero, 3.0, 0.0)
            }
        }
    }
    
    func hideGrid() {
        for nIdx in 0..<4 {
            if let seperatorView = self.m_cameraContainer.viewWithTag(40 + nIdx) {
                seperatorView.isHidden = true
                InterfaceManager.addShadowToView(seperatorView, UIColor.clear, .zero, 5.0, 0.0)
            }
        }
    }
    func finishedRecordingAnimation() {
        var delay: Double = 0.0
        let recordedDuration = Date().timeIntervalSince1970 - startedRecordTime
        if (recordedDuration < 1.0) {
            delay = 1.0 - recordedDuration
        }
        
        let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.enabledAllTheActions()
            
            self.bStartingCapture = false
            self.processVideo()
        })
    }
    func enabledAllTheActions(_ isEnabled: Bool = true, _ includesCaptureButton: Bool = true) {
        self.m_btnCancel.isEnabled = isEnabled
        self.m_btnFlash.isEnabled = isEnabled
        self.m_btnFlipCamera.isEnabled = isEnabled
        self.m_btnShowGrid.isEnabled = isEnabled
        self.m_btnAlbum.isEnabled = isEnabled
        
        if (includesCaptureButton) {
            self.m_btnCapture.isEnabled = isEnabled
        }
        
//        self.m_btnRatio.isEnabled = isEnabled
//        self.m_btnFPS.isEnabled = isEnabled
//        self.m_btnTimer.isEnabled = isEnabled
//        self.m_btnAWB.isEnabled = isEnabled
//
        for nIdx in 0..<5 {
            if let btnAWBOption = self.view.viewWithTag(100 + nIdx) as? UIButton {
                btnAWBOption.isEnabled = isEnabled
            }
        }
        
        if (self.menuScrollView != nil) {
            self.menuScrollView!.isUserInteractionEnabled = isEnabled
        }
    }
    func processVideo() {
        //self.showVideo(outputURL!)
        
        TheVideoWriter.stopAssetWriter { (bSuccess, outputURL) in
            if (bSuccess) {
                let nFPS = Int32(Constants.CameraOptions.FPS[TheGlobalPoolManager.cameraSettings.FPSIdx])!
                let strRatio = Constants.CameraOptions.Ratio[TheGlobalPoolManager.cameraSettings.RatioIdx]
                
                InterfaceManager.showLoadingView()
                
                DispatchQueue.global(qos: .background).async {
                    TheVideoEditor.crop(outputURL!, nFPS, strRatio, { (originalVideoURL) in
                        DispatchQueue.main.async {
                            if (originalVideoURL != nil) {
                                InterfaceManager.hideLoadingView()
                                
                                if (originalVideoURL != nil) {
                                    self.forceFlashConfiguration()
                                    self.goToEditView(originalVideoURL!)
                                } else {
                                    InterfaceManager.showMessage(false, title: "Failed to process video. Please try again!", bBottomPos: true)
                                }
                            } else {
                                InterfaceManager.hideLoadingView()
                                InterfaceManager.showMessage(false, title: "Failed to process video. Please try again!", bBottomPos: true)
                            }
                        }
                    })
                }
            } else {
                InterfaceManager.showMessage(false, title: "Failed to record video. Please try again!", bBottomPos: true)
            }
        }
    }
    func adjustCameraCanvasHeight(_ bAnimations: Bool = false) {
        var fWidth: CGFloat = self.m_viewCamera.bounds.height
        switch TheGlobalPoolManager.cameraSettings.RatioIdx {
        case 0:
//            self.m_viewTopMenu.backgroundColor = UIColor.white
//            self.m_viewBottomMenu.backgroundColor = UIColor.white
//            self.m_viewTopArea.backgroundColor = UIColor.white
//            self.m_viewBottomArea.backgroundColor = UIColor.white
//            self.m_constraintCameraCenterY.constant = -58.0
            self.view.layoutIfNeeded()
            
            fWidth = self.m_viewCamera.bounds.height
            break
        case 1:
//            self.m_viewTopMenu.backgroundColor = UIColor.white
//            self.m_viewBottomMenu.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_viewTopArea.backgroundColor = UIColor.white
//            self.m_viewBottomArea.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_constraintCameraCenterY.constant = -58.0 - TheGlobalPoolManager.tempCameraViewOffset
            self.view.layoutIfNeeded()
            
            fWidth = self.m_viewCamera.bounds.height / 3.0 * 4.0
            //fHeight = self.view.bounds.width / 4.0 * 3.0
            break
        case 2:
//            self.m_viewTopMenu.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_viewBottomMenu.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_viewTopArea.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_viewBottomArea.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//            self.m_constraintCameraCenterY.constant = 0.0
            self.view.layoutIfNeeded()
            
//            fWidth = self.m_viewCamera.bounds.height + (TheInterfaceManager.checkiPhoneX() ? 100.0 : 20.0) //self.view.bounds.width / 9.0 * 16.0
            fWidth = self.view.bounds.height / 9.0 * 16.0
            break
        default:
            break
        }
        
        UIView.animate(withDuration: bAnimations ? 0.3 : 0.0, animations: {
//            self.m_constraintCameraViewHeight.constant = fHeight
//            self.m_constraintSeperatorTop1.constant = fHeight / 3.0
//            self.m_constraintSeperatorTop2.constant = fHeight / 3.0 * 2.0
            self.m_constraintCameraViewWidth.constant = fWidth
            
            self.view.layoutIfNeeded()
            
            if (self.bShowGrid) {
                self.showGrid()
            }
        }) { (bCompleted) in
            if (bCompleted) {
                print("finished animation")
            }
        }
    }
    func goToEditView(_ videoURL: URL) {
        TheVideoEditor.initEditor()
        TheVideoEditor.setupOriginalVideosInSettings(videoURL.lastPathComponent)
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.NewEditViewController)
        self.navigationController?.pushViewController(viewCon!, animated: true)
    }
    func showMenuContentView() {
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = orientation
        if (self.cameraMode == .Back) {
            if (connection.isVideoMirroringSupported) {
                connection.isVideoMirrored = false
            }
        } else {
            if (connection.isVideoMirroringSupported) {
                connection.isVideoMirrored = true
            }
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        var cgImage: CGImage? = nil
        var effect: CIFilter? = nil
        
        switch TheGlobalPoolManager.cameraSettings.AWBIdx {
        case 0:
            /*
             effect = CIFilter(name: "CIVignette")
             effect!.setValue(cameraImage, forKey: kCIInputImageKey)
             effect!.setValue(0.4, forKey: kCIInputIntensityKey)
             effect!.setValue(4.0, forKey: kCIInputRadiusKey)
             cgImage = self.context.createCGImage(effect!.outputImage!, from: cameraImage.extent)!
             */
            effect = CIFilter(name: "CISepiaTone")
            effect!.setValue(cameraImage, forKey: kCIInputImageKey)
            effect!.setValue(0.4, forKey: kCIInputIntensityKey)
            cgImage = self.context.createCGImage(effect!.outputImage!, from: cameraImage.extent)!
            
            break
        case 1:
            effect = CIFilter(name: "CISepiaTone")
            effect!.setValue(cameraImage, forKey: kCIInputImageKey)
            effect!.setValue(0.8, forKey: kCIInputIntensityKey)
            cgImage = self.context.createCGImage(effect!.outputImage!, from: cameraImage.extent)!
            break
            
        case 2: //normal
            cgImage = self.context.createCGImage(cameraImage, from: cameraImage.extent)
            
            break
        case 3:
            effect = CIFilter(name: "CIWhitePointAdjust")
            effect!.setValue(cameraImage, forKey: kCIInputImageKey)
            effect!.setValue(CIColor(cgColor: UIColor(hex: 0x90E0F4).cgColor), forKey: kCIInputColorKey)
            cgImage = self.context.createCGImage(effect!.outputImage!, from: cameraImage.extent)!
            
            break
        case 4:
            effect = CIFilter(name: "CIWhitePointAdjust")
            effect!.setValue(cameraImage, forKey: kCIInputImageKey)
            effect!.setValue(CIColor(cgColor: UIColor(hex: 0xB0F4D0).cgColor), forKey: kCIInputColorKey)
            cgImage = self.context.createCGImage(effect!.outputImage!, from: cameraImage.extent)!
            break
        default:
            break
        }
        
        if (cgImage != nil) {
            DispatchQueue.main.async {
                let filteredImage = UIImage(cgImage: cgImage!)
                self.m_imgCamera.image = filteredImage
                
                if (self.bStartingCapture) {
                    TheVideoWriter.writeVideoFromData(cgImage!, CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                }
            }
        }
    }
    
    
    
    func UIActionLeftFrame(){
        UIView.animate(withDuration: 0.5, animations:{
            self.constant_time_top.constant = self.view.frame.size.height - 96
            self.constant_awb_top.constant = self.view.frame.size.height - 58
            self.constant_leftTbl_top.constant = 50
            self.constant_leftTbl_bottom.constant = 114
            self.view.setNeedsLayout()
        })
        self.nLeftSettingActiveMode = 0
        self.UIActionReloadLeftSettingTBL()
        self.btn_left_frame.isSelected = true
        self.btn_left_time.isSelected = false
        self.btn_left_awb.isSelected = false
    }
    func UIActionLeftTime(){
        UIView.animate(withDuration: 0.5, animations:{
            self.constant_time_top.constant = 50
            self.constant_awb_top.constant = self.view.frame.size.height - 58
            self.constant_leftTbl_top.constant = 88
            self.constant_leftTbl_bottom.constant = 74
            self.view.setNeedsLayout()
        })
        self.nLeftSettingActiveMode = 1
        self.UIActionReloadLeftSettingTBL()
        self.btn_left_frame.isSelected = false
        self.btn_left_time.isSelected = true
        self.btn_left_awb.isSelected = false
    }
    func UIActionLeftAWB(){
        UIView.animate(withDuration: 0.5, animations:{
            self.constant_time_top.constant = 50
            self.constant_awb_top.constant = 88
            self.constant_leftTbl_top.constant = 126
            self.constant_leftTbl_bottom.constant = 30
            self.view.setNeedsLayout()
        })
        self.nLeftSettingActiveMode = 2
        self.UIActionReloadLeftSettingTBL()
        self.btn_left_frame.isSelected = false
        self.btn_left_time.isSelected = false
        self.btn_left_awb.isSelected = true
    }
    func UIActionReloadLeftSettingTBL(){
        nLeftSettingActiveIndex = 0
        self.tbl_left_setting.delegate = self
        self.tbl_left_setting.dataSource = self
        self.tbl_left_setting.reloadData()
    }
    @IBAction func onActionleftSettingFrame(_ sender: Any) {
        self.UIActionLeftFrame()
    }
    @IBAction func onActionLeftSettingTime(_ sender: Any) {
        self.UIActionLeftTime()
    }
    @IBAction func onActionLeftSettingAwb(_ sender: Any) {
        self.UIActionLeftAWB()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        nLeftSettingActiveIndex = indexPath.row
        self.tbl_left_setting.delegate = self
        self.tbl_left_setting.dataSource = self
        self.tbl_left_setting.reloadData()
        
        if(nLeftSettingActiveMode == 0){
            self.nSelectedMenu = .FPS
        }else if(nLeftSettingActiveMode == 1){
            self.nSelectedMenu = .Timer
        }else if(nLeftSettingActiveMode == 2){
            self.nSelectedMenu = .AWB
            TheGlobalPoolManager.cameraSettings.AWBIdx = indexPath.row
        }
        self.selectedOneOption(nIdx: nLeftSettingActiveIndex)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.nLeftSettingActiveMode == 0){return array_setting_frame.count}
        if(self.nLeftSettingActiveMode == 1){return array_setting_timer.count}
        return array_setting_awb.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath as IndexPath)
        var actionButton : UIButton!
        for subView: UIView in cell.contentView.subviews{
            if(subView.isKind(of: UIButton.classForCoder())){
                actionButton = subView as? UIButton
            }
        }
        if(self.nLeftSettingActiveMode == 0){
            actionButton.setTitle(array_setting_frame.object(at: indexPath.row) as? String, for: UIControl.State.normal)
            actionButton.setImage(nil, for: UIControl.State.normal)
        }else if(self.nLeftSettingActiveMode == 1){
            actionButton.setTitle(array_setting_timer.object(at: indexPath.row) as? String, for: UIControl.State.normal)
            actionButton.setImage(nil, for: UIControl.State.normal)
        }else if(self.nLeftSettingActiveMode == 2){
            actionButton.setImage(UIImage.init(named: array_setting_awb.object(at: indexPath.row) as? String ?? ""), for: UIControl.State.normal)
            actionButton.setTitle("", for: UIControl.State.normal)
        }
        actionButton.setBackgroundImage(UIImage.init(named: "hr-bg"), for: UIControl.State.selected)
        actionButton.setBackgroundImage(nil, for: UIControl.State.normal)
        if(nLeftSettingActiveIndex == indexPath.row){
            actionButton.isSelected = true
        }else{
            actionButton.isSelected = false
        }
        return cell
    }
    
    ////// action
    @IBAction func actionClose(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionFlash(_ sender: Any) {
        do {
            if let device = device, device.hasTorch {
                try device.lockForConfiguration()
                
                if self.bFlashOn {
                    self.bFlashOn = false
                    
                    if (device.hasTorch) {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                    }
                } else {
                    self.bFlashOn = true
                    
                    if (device.hasTorch) {
                        device.torchMode = AVCaptureDevice.TorchMode.on
                    }
                }
                
                device.unlockForConfiguration()
                
                self.m_btnFlash.tintColor = self.bFlashOn ? UIColor.black : UIColor.lightGray.withAlphaComponent(0.6)
            }
            
        } catch _ {
            return
        }
    }
    @IBAction func actionShowGrid(_ sender: Any) {
        self.bShowGrid = !self.bShowGrid
        self.m_btnShowGrid.tintColor = self.bShowGrid ? UIColor.black : UIColor.lightGray.withAlphaComponent(0.6)
        
        if (self.bShowGrid) {
            showGrid()
        } else {
            hideGrid()
        }
    }
    func startCounterAnimation() {
        self.m_lblCounter.text = "\(nTimerCounter)"
        InterfaceManager.doCounterAnimation(self.m_lblCounter) {
            self.nTimerCounter -= 1
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationName.FinishedAnimation), object: nil)
        }
    }
    @IBAction func onShutUp(_ sender: Any) {
        if (!bStartingCapture) {
            //start capture
            let nTimer = Int(Constants.CameraOptions.Timer[TheGlobalPoolManager.cameraSettings.TimerIdx])!
            if (nTimer == 0) {
                self.enabledAllTheActions(false, false)
                self.m_btnCapture.startAnimation(duration: MAX_VIDEO_DURATION)
                
                self.bStartingCapture = true
                
                startedRecordTime = Date().timeIntervalSince1970
            } else {
                //show counter animation
                enabledAllTheActions(false)
                
                self.m_viewCounter.isHidden = false
                self.nTimerCounter = nTimer
                self.startCounterAnimation()
            }
        } else {
            self.m_btnCapture.stopAnimation()
        }
    }
    @IBAction func actionFlipCamera(_ sender: Any) {
        session?.stopRunning()
        
        self.showBlurView(true)
        TheGlobalPoolManager.cameraSettings.FPSIdx = 0
        self.showMenuContentView()
        
        DispatchQueue.global(qos: .background).async {
            do {
                self.session?.beginConfiguration()
                
                if let session = self.session {
                    for input : AVCaptureDeviceInput in (self.session?.inputs as! [AVCaptureDeviceInput]){
                        session.removeInput(input)
                    }
                    
                    if (self.cameraMode == .Back) {
                        self.cameraMode = .Front
                        self.device = self.front_device
                    } else {
                        self.cameraMode = .Back
                        self.device = self.back_device
                    }
                    
                    if let device = self.device {
                        self.defaultVideoFormat = device.activeFormat
                        self.defaultVideoMaxFrameDuration = device.activeVideoMaxFrameDuration
                        self.defaultVideoMinFrameDuration = device.activeVideoMinFrameDuration
                        
                        self.videoInput = try AVCaptureDeviceInput(device: device)
                        session.addInput(self.videoInput!)
                        
                        //self.addVideoOutput()
                    }
                }
                
                self.session?.commitConfiguration()
                
                DispatchQueue.main.async {
                    self.session?.startRunning()
                    
                    if (self.cameraMode == .Front) {
                        self.bFlashOn = false
                        self.m_btnFlash.tintColor = self.bFlashOn ? UIColor.black : UIColor.lightGray.withAlphaComponent(0.6)
                    }
                    
                    let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                        self.showBlurView(false)
                        self.flashConfiguration()
                    })
                }
            } catch {
                DispatchQueue.main.async {
                    print("failed")
                }
            }
        }
    }
    @IBAction func actionAlbum(_ sender: Any) {
        imagePicker!.delegate = self
        imagePicker?.allowsEditing = true
        imagePicker!.mediaTypes = [kUTTypeMovie as String]
        imagePicker!.sourceType = .photoLibrary
        imagePicker!.videoMaximumDuration = MAX_VIDEO_DURATION
        present(imagePicker!, animated: true, completion: nil)
    }
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType.rawValue]
        
        var bFoundVideo: Bool = false
        if mediaType is String {
            let stringType = mediaType as! String
            if stringType == kUTTypeMovie as String {
                if let urlOfVideo = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
                    self.selectedVideoURL = urlOfVideo
                    bFoundVideo = true
                }
            }
        }
        
        picker.dismiss(animated: true) {
            if (bFoundVideo) {
                self.gotVideoFromGallery()
            } else {
                InterfaceManager.showMessage(false, title: "Failed to import video. Please try again!", bBottomPos: true)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func gotVideoFromGallery() {
        InterfaceManager.showLoadingView()
        
        DispatchQueue.global(qos: .background).async {
            TheVideoEditor.removeAudioAndFixOrientation(self.selectedVideoURL!) { (originalVideoURL) in
                DispatchQueue.main.async {
                    if (originalVideoURL != nil) {
                        InterfaceManager.hideLoadingView()
                        
                        if (originalVideoURL != nil) {
                            self.forceFlashConfiguration()
                            self.goToEditView(originalVideoURL!)
                        } else {
                            InterfaceManager.showMessage(false, title: "Failed to process video. Please try again!", bBottomPos: true)
                        }
                    } else {
                        InterfaceManager.hideLoadingView()
                        InterfaceManager.showMessage(false, title: "Failed to process video. Please try again!", bBottomPos: true)
                    }
                }
            }
        }
    }
}
