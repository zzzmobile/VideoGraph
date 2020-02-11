//
//  NewEditViewController.swift
//  VideoGraph
//
//  Created by Techsviewer on 11/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class NewEditViewController: UIViewController, TemplateMenuViewControllerDelegate, TextMenuViewControllerDelegate, UIGestureRecognizerDelegate {
    func tappedTextMenu() {
        
    }
    
    func tappedTemplateMenu() {
        
    }
    
    @IBOutlet weak var btn_left_home: UIButton!
    @IBOutlet weak var btn_left_rotate: UIButton!
    @IBOutlet weak var btn_left_brush: UIButton!
    @IBOutlet weak var btn_left_stillImage: UIButton!
    @IBOutlet weak var btn_left_share: UIButton!
    
    @IBOutlet weak var btn_right_repeat: UIButton!
    @IBOutlet weak var btn_right_color: UIButton!
    @IBOutlet weak var btn_right_filter: UIButton!
    @IBOutlet weak var btn_right_text: UIButton!
    
    @IBOutlet weak var view_setting_brush: SettingBrushView!
    
    @IBOutlet weak var view_right_settingView: RightSettingView!
    
    @IBOutlet weak var view_actionContainer: UIView!
    @IBOutlet weak var const_actionContainer_left: NSLayoutConstraint!
    @IBOutlet weak var const_actionContainer_right: NSLayoutConstraint!
    
    
    @IBOutlet weak var m_btnAddText: UIButton!
    
    let TRIM_INDICATOR_WIDTH: CGFloat = 16.0
    
    var bLoadedView: Bool = false
    
    var bAlwaysStatusBar: Bool = false
    var bShowStatusBar: Bool = true
    
    @IBOutlet weak var m_workingCanvasView: UIView!
    @IBOutlet weak var m_videoFadePlayerView: VideoFadePlayerView!
    @IBOutlet weak var m_videoPlayerView: VideoPlayerView!
    @IBOutlet weak var m_videoDrawingView: VideoDrawingView!
    @IBOutlet weak var m_imgViewVideoWithoutActions: UIImageView!
    
    @IBOutlet weak var m_constraintVideoPlayerWidth: NSLayoutConstraint!
    @IBOutlet weak var m_constraintVideoPlayerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var m_viewVideoThumbnail: UIView!
    @IBOutlet weak var m_viewBottomIndicatorInThumbnails: UIView!
    @IBOutlet weak var m_imgScrubber: UIImageView!
    @IBOutlet weak var m_constraintScrubberLeading: NSLayoutConstraint!
    
    //variables for trim feature
    @IBOutlet weak var m_viewTrimOverlay: UIView!
    @IBOutlet weak var m_constraintLeftTrimWidth: NSLayoutConstraint!
    @IBOutlet weak var m_constraintRightTrimWidth: NSLayoutConstraint!
    
    @IBOutlet weak var m_viewTrimLeftIndicator: UIView!
    @IBOutlet weak var m_constraintTrimLeftIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var m_viewTrimRightIndicator: UIView!
    @IBOutlet weak var m_constraintTrimRightIndicatorLeading: NSLayoutConstraint!
    
    var videoScrubberPanGesture: UIPanGestureRecognizer? = nil
    var leftTrimPanGesture: UIPanGestureRecognizer? = nil
    var rightTrimPanGesture: UIPanGestureRecognizer? = nil
    
    //video player size when views original video
    var currentVideoPlayerWidth: CGFloat = 0.0
    var currentVideoPlayerHeight: CGFloat = 0.0
    
    //video thumbnails
    var videoThumbSize: CGSize = .zero
    var m_videoThumbView: VideoThumbnailsView? = nil
    
    var bGoExportViewCon: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = true
        self.view_setting_brush.alpha = 1
        self.view_right_settingView.alpha = 1
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tappedActionInStillImage), name: NSNotification.Name(rawValue: Constants.NotificationName.TappedActionInStillImage), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatedStillImageFromSubView), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImageInSubView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetStillImage), name: NSNotification.Name(rawValue: Constants.NotificationName.ResetStillImage), object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(doShowHideTopBarsAlways), name: NSNotification.Name(rawValue: Constants.NotificationName.ShowHideTopBarsInEditViewAsAlways), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(doShowTopBarsJustOnce), name: NSNotification.Name(rawValue: Constants.NotificationName.ShowTopBarsInEditViewJustOnce), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(doHideTopbarsJustOnce), name: NSNotification.Name(rawValue: Constants.NotificationName.HideTopBarsInEditViewJustOnce), object: nil)
//
        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskFesture), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(croppedVideo), name: NSNotification.Name(rawValue: Constants.NotificationName.CroppedVideo), object: nil)
//
        NotificationCenter.default.addObserver(self, selector: #selector(updatedTextSetting), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRotateZoomText), name: NSNotification.Name(rawValue: Constants.NotificationName.RotateZoomText), object: nil)
//
        NotificationCenter.default.addObserver(self, selector: #selector(addActionForUndo), name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUndoProcess), name: NSNotification.Name(rawValue: Constants.NotificationName.didUndoProcess), object: nil)
//
        NotificationCenter.default.addObserver(self, selector: #selector(updatedRotateInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateRotateValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishUpdateRotateInStickerView), name: NSNotification.Name(rawValue: Constants.NotificationName.FinishUpdateRotateValueInStickView), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatedZoomInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateZoomValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishUpdateZoomInStickerView), name: NSNotification.Name(rawValue: Constants.NotificationName.FinishUpdateZoomValueInStickView), object: nil)
        
        //init process of ImageProcesser
        TheImageProcesser.bEraserMode = false
        
    }
    @objc func updateMaskFesture() {
        if (TheVideoEditor.editSettings.bMaskAll) {
            TheImageProcesser.bEraserMode = false
        } else {
            TheImageProcesser.bEraserMode = true
        }
        
        self.showEraserMode()
    }
    @objc func croppedVideo() {
        //adjust width and height of video player and drawing view
        let newVideoThumbSize = TheImageProcesser.getCorrectStillImage().size
        self.updateVideoPlayerSize(newVideoThumbSize)
        
        self.addActionForUndo()
    }
    @objc func updatedTextSetting() {
        print("updated text setting")
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].doProcess()
    }
    
    @objc func didRotateZoomText() {
        print("rotate & zoom text setting")
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].doZoomRotateProcess()
    }
    @objc func updatedRotateInStickerView(_ notiInfo: Notification) {
        if let rotateValue = notiInfo.userInfo?["value"] as? CGFloat {
            if (TheVideoEditor.selectedFontObjectIdx == -1) {
                return
            }
            
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation = rotateValue
        }
    }
    
    @objc func finishUpdateRotateInStickerView() {
        self.addActionForUndo()
    }
    
    @objc func updatedZoomInStickerView(_ notiInfo: Notification) {
        if let zoomValue = notiInfo.userInfo?["value"] as? CGFloat {
            if (TheVideoEditor.selectedFontObjectIdx == -1) {
                return
            }
            
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom = zoomValue
        }
    }
    
    @objc func finishUpdateZoomInStickerView() {
        self.addActionForUndo()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        videoThumbSize = TheThumbnailManager.initManager(TheVideoEditor.editSettings.originalVideoURL)
        
        makeUserInterface()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.bGoExportViewCon) {
            self.bGoExportViewCon = false
            self.m_videoPlayerView.playVideo(self.m_videoThumbView, self.m_videoFadePlayerView)
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func makeUserInterface() {
        self.m_videoDrawingView.workingCanvasView = self.m_workingCanvasView
        
        TheInterfaceManager.nSelectedMenu = .Video
        TheInterfaceManager.nSelectedSubMenu = 0
        
        showEraserMode()
        
        //add video thumbnails
        InterfaceManager.makeRadiusControl(self.m_viewTrimOverlay!, cornerRadius: 0.0, withColor: UIColor.black.withAlphaComponent(0.4), borderSize: 2.0)
        
        var videoThumbViewFrame = self.m_viewTrimOverlay.frame
        videoThumbViewFrame.size.width = self.view_actionContainer.frame.size.width - 48
        self.m_videoThumbView = VideoThumbnailsView(videoThumbViewFrame)
        self.m_viewVideoThumbnail.insertSubview(self.m_videoThumbView!, belowSubview: self.m_viewTrimOverlay)
        InterfaceManager.makeRadiusControl(self.m_videoThumbView!, cornerRadius: 0.0, withColor: UIColor.black.withAlphaComponent(0.4), borderSize: 2.0)
        
        self.m_constraintScrubberLeading.constant = self.m_videoThumbView!.frame.origin.x - self.m_imgScrubber.frame.width / 2.0
        self.view.layoutIfNeeded()
        
        //setup trim view
        self.setupTrimView()
        
        //adjust width & height of video player view
        self.updateVideoPlayerSize(videoThumbSize)
        
        //play video
        self.m_videoPlayerView.playVideo(self.m_videoThumbView, self.m_videoFadePlayerView)
        
        //show overlay thumbnail
        self.m_videoDrawingView.showOverlayThumbnail(self.videoThumbSize)
        if (TheProjectManger.curArrayIdx == -1) {
            TheUndoManager.bChanged = true
            self.loadSelectedVideoThumbail(0.0)
        } else {
            self.addActionForUndoFromProject(TheProjectManger.getSelectedProject().finalVideoName)
            TheUndoManager.bChanged = false
            
            let newVideoThumbSize = TheImageProcesser.getCorrectStillImage().size
            self.updateVideoPlayerSize(newVideoThumbSize)
            
            self.m_videoDrawingView.showStillMaskImageForProject()
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImage), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
            
            //add font objects
            deselectAllStickerViews()
            for fontObject in TheVideoEditor.fontObjects {
                fontObject.doProcessAfterUndo(self)
            }
            selectStickerView()
        }
        self.m_btnAddText.isHidden = true
        //add pan gesture for indicating specfic thumbnail, trim indicators
        self.videoScrubberPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureProc(_:)))
        self.videoScrubberPanGesture!.delegate = self
        self.m_imgScrubber.isUserInteractionEnabled = true
        self.m_imgScrubber.addGestureRecognizer(self.videoScrubberPanGesture!)
        
        self.leftTrimPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureProc(_:)))
        self.leftTrimPanGesture!.delegate = self
        self.m_viewTrimLeftIndicator.isUserInteractionEnabled = true
        self.m_viewTrimLeftIndicator.addGestureRecognizer(self.leftTrimPanGesture!)
        
        self.rightTrimPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureProc(_:)))
        self.rightTrimPanGesture!.delegate = self
        self.m_viewTrimRightIndicator.isUserInteractionEnabled = true
        self.m_viewTrimRightIndicator.addGestureRecognizer(self.rightTrimPanGesture!)
        
        //add long press gesture
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressProc(_:)))
        longGesture.minimumPressDuration = 0.0
        self.m_imgViewVideoWithoutActions.isUserInteractionEnabled = true
        self.m_imgViewVideoWithoutActions.addGestureRecognizer(longGesture)
        
        self.view_right_settingView.initializeNotifications()
    }
    func showEraserMode() {
        /*if (TheImageProcesser.bEraserMode) {
            self.m_btnOption1.backgroundColor = UIColor.black
            self.m_btnOption1.setImage(UIImage(named: Constants.MaskOptionIcons.HighlightSelected), for: .normal)
            
            self.m_btnOption2.backgroundColor = UIColor.white
            self.m_btnOption2.setImage(UIImage(named: Constants.MaskOptionIcons.Eraser), for: .normal)
        } else {
            self.m_btnOption1.backgroundColor = UIColor.white
            self.m_btnOption1.setImage(UIImage(named: Constants.MaskOptionIcons.Highlight), for: .normal)
            
            self.m_btnOption2.backgroundColor = UIColor.black
            self.m_btnOption2.setImage(UIImage(named: Constants.MaskOptionIcons.EraserSelected), for: .normal)
        }*/
    }
    func setupTrimView() {
        self.m_constraintTrimLeftIndicatorLeading.constant = TheVideoEditor.fTrimLeftOffset + 8.0
        self.m_constraintTrimRightIndicatorLeading.constant = TheVideoEditor.fTrimRightOffset + 24.0
        
        self.m_constraintLeftTrimWidth.constant = TheVideoEditor.fTrimLeftOffset
        self.m_constraintRightTrimWidth.constant = self.view_actionContainer.frame.width - 48 - TheVideoEditor.fTrimRightOffset
        
        self.view.layoutIfNeeded()
    }
    func updateVideoPlayerSize(_ thumbSize: CGSize) {
        let widthRatio = thumbSize.width / self.m_workingCanvasView.frame.width
        let heightRatio = thumbSize.height / self.m_workingCanvasView.frame.width
        
        var videoPlayerSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.m_workingCanvasView.frame.width) {
            videoPlayerSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            videoPlayerSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        self.m_constraintVideoPlayerWidth.constant = videoPlayerSize.width
        self.m_constraintVideoPlayerHeight.constant = videoPlayerSize.height
        self.view.layoutIfNeeded()
    }
    func loadSelectedVideoThumbail(_ offset: CGFloat, _ bFirstTime: Bool = true) {
        let time = TheThumbnailManager.getTime(offset, self.m_videoThumbView!.frame.width)
        TheThumbnailManager.generateThumbnailImage(time!) { (image) in
            TheVideoEditor.stillImage = image
            if (bFirstTime) {
                TheVideoEditor.initialStillImageSize = image!.size
                
                self.addActionForUndo()
            }
            
            self.m_videoDrawingView.showStillImage()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImage), object: nil, userInfo: nil)
        }
    }
    @objc func didUndoProcess() {
        self.setupTrimView()
        
        let newVideoThumbSize = TheImageProcesser.getCorrectStillImage().size
        self.updateVideoPlayerSize(newVideoThumbSize)
        
        m_videoPlayerView.restartPlayVideo()
        
        //update font objects in the video
        deselectAllStickerViews()
        for fontObject in TheVideoEditor.fontObjects {
            fontObject.doProcessAfterUndo(self)
        }
        selectStickerView()
    }
    @objc func addActionForUndo() {
        let project = Project.init(self.m_videoDrawingView.maskImage, self.m_videoDrawingView.maskImageView?.image)
        TheUndoManager.addAction(project)
        
        self.btn_left_rotate.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    func addActionForUndoFromProject(_ finalVideoName: String) {
        let project = Project.init(self.m_videoDrawingView.maskImage, self.m_videoDrawingView.maskImageView?.image, finalVideoName)
        TheUndoManager.addAction(project)
        
        self.btn_left_rotate.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    @objc func panGestureProc(_ sender: UIPanGestureRecognizer) {
        if (sender.view == self.m_imgScrubber) {
            let translation = sender.translation(in: self.m_viewVideoThumbnail)
            
            switch sender.state {
            case .began:
                break
            case .changed:
                let prevLeading = self.m_constraintScrubberLeading.constant
                var newLeading = prevLeading + translation.x
                
                if (newLeading <= self.m_videoThumbView!.frame.origin.x - self.m_imgScrubber.frame.width / 2.0) {
                    newLeading = self.m_videoThumbView!.frame.origin.x - self.m_imgScrubber.frame.width / 2.0
                } else if (newLeading >= self.m_videoThumbView!.frame.origin.x + self.m_videoThumbView!.frame.width - self.m_imgScrubber.frame.width / 2.0) {
                    newLeading = self.m_videoThumbView!.frame.origin.x + self.m_videoThumbView!.frame.width - self.m_imgScrubber.frame.width / 2.0
                }
                
                self.m_constraintScrubberLeading.constant = newLeading
                self.view.layoutIfNeeded()
                
                sender.setTranslation(CGPoint.zero, in: self.m_viewVideoThumbnail)
                
                break
            case .ended, .cancelled:
                self.loadSelectedVideoThumbail(self.m_constraintScrubberLeading.constant + self.m_imgScrubber.frame.width / 2.0 - self.m_videoThumbView!.frame.origin.x)
                break
            default:
                break
            }
        } else if (sender.view == self.m_viewTrimLeftIndicator) {
            print("left trim - pan")
            let translation = sender.translation(in: self.m_viewVideoThumbnail)
            
            switch sender.state {
            case .began:
                break
            case .changed:
                let prevLeading = self.m_constraintTrimLeftIndicatorLeading.constant
                var newLeading = prevLeading + translation.x
                
                if (newLeading <= self.m_videoThumbView!.frame.minX - TRIM_INDICATOR_WIDTH) {
                    newLeading = self.m_videoThumbView!.frame.minX - TRIM_INDICATOR_WIDTH
                } else if (newLeading >= self.m_constraintTrimRightIndicatorLeading.constant - 60.0) {
                    newLeading = self.m_constraintTrimRightIndicatorLeading.constant - 60.0
                }
                
                self.m_constraintTrimLeftIndicatorLeading.constant = newLeading
                self.m_constraintLeftTrimWidth.constant = newLeading - self.m_videoThumbView!.frame.minX
                
                self.view.layoutIfNeeded()
                
                sender.setTranslation(CGPoint.zero, in: self.m_viewVideoThumbnail)
                
                break
            case .ended, .cancelled:
                print("left trim indicator is finished")
                self.updatedTrimIndicator()
                break
            default:
                break
            }
        } else if (sender.view == self.m_viewTrimRightIndicator) {
            print("right trim - pan")
            let translation = sender.translation(in: self.m_viewVideoThumbnail)
            
            switch sender.state {
            case .began:
                break
            case .changed:
                let prevLeading = self.m_constraintTrimRightIndicatorLeading.constant
                var newLeading = prevLeading + translation.x
                
                if (newLeading >= self.m_videoThumbView!.frame.maxX) {
                    newLeading = self.m_videoThumbView!.frame.maxX
                } else if (newLeading <= self.m_constraintTrimLeftIndicatorLeading.constant + 60.0) {
                    newLeading = self.m_constraintTrimLeftIndicatorLeading.constant + 60.0
                }
                
                self.m_constraintTrimRightIndicatorLeading.constant = newLeading
                self.m_constraintRightTrimWidth.constant = self.m_videoThumbView!.frame.maxX - newLeading
                
                self.view.layoutIfNeeded()
                
                sender.setTranslation(CGPoint.zero, in: self.m_viewVideoThumbnail)
                
                break
            case .ended, .cancelled:
                print("right trim indicator is finished")
                self.updatedTrimIndicator()
                break
            default:
                break
            }
        }
    }
    @objc func longPressProc(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            self.currentVideoPlayerWidth = self.m_constraintVideoPlayerWidth.constant
            self.currentVideoPlayerHeight = self.m_constraintVideoPlayerHeight.constant
            
            self.updateVideoPlayerSize(self.videoThumbSize)
            
//            doHideTopbarsJustOnce()
            
            TheVideoEditor.bViewOriginalVideo = true
            self.m_videoDrawingView.isHidden = true
            //self.m_videoDrawingView.hideAllSubViewsForOriginalVideo(true)
            for fontObject in TheVideoEditor.fontObjects {
                fontObject.iconView?.isHidden = true
            }
        } else if (sender.state == .ended || sender.state == .cancelled) {
//            doShowTopBarsJustOnce()
            
            self.updateVideoPlayerSize(CGSize(width: self.currentVideoPlayerWidth, height: self.currentVideoPlayerHeight))
            
            TheVideoEditor.bViewOriginalVideo = false
            self.m_videoDrawingView.isHidden = false
            //self.m_videoDrawingView.hideAllSubViewsForOriginalVideo(false)
            for fontObject in TheVideoEditor.fontObjects {
                fontObject.iconView?.isHidden = false
            }
        }
    }
    func updatedTrimIndicator() {
        let fLeftOffset = (self.m_constraintTrimLeftIndicatorLeading.constant + TRIM_INDICATOR_WIDTH) - self.m_videoThumbView!.frame.minX
        let fRightOffset = self.m_constraintTrimRightIndicatorLeading.constant - 24.0
        
        TheVideoEditor.fTrimRightOffset = fRightOffset
        TheVideoEditor.fTrimLeftOffset = fLeftOffset
        
        self.m_videoPlayerView.restartPlayVideo()
        
        self.addActionForUndo()
    }
    
    @objc func tappedActionInStillImage() {
        self.bGoExportViewCon = true
        self.m_videoPlayerView.stopVideo()
    }
    @objc func resetStillImage() {
        self.loadSelectedVideoThumbail(0.0)
    }
    
    @objc func updatedStillImageFromSubView() {
        self.m_videoDrawingView.showStillImage()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //// left setting UI Action
    @IBAction func actionDone(_ sender: Any) {
        //make screenshot of drawing view
        self.goToExportViewCon()
    }
    @IBAction func actionUndo(_ sender: Any) {
        self.btn_left_home.isSelected = false
        self.btn_left_rotate.isSelected = true
        self.btn_left_brush.isSelected = false
        self.btn_left_stillImage.isSelected = false
        self.btn_left_share.isSelected = false
        
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = true
        self.actionContainerGotoCenter()
        TheUndoManager.doUndo()
        self.m_btnAddText.isHidden = true
        self.btn_left_rotate.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    @IBAction func onGotoHome(_ sender: Any) {
        self.btn_left_home.isSelected = true
        self.btn_left_rotate.isSelected = false
        self.btn_left_brush.isSelected = false
        self.btn_left_stillImage.isSelected = false
        self.btn_left_share.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = true
        self.actionContainerGotoCenter()
        
        let actionSheet = UIAlertController(title: "Are you sure you want to leave this screen?", message: "It will save your project under My Project", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            self.goToExportViewCon()
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(actionSheet, animated: true, completion: nil)
        })
    }
    @IBAction func onLeftBrush(_ sender: Any) {
        if(self.btn_left_brush.isSelected){
            self.btn_left_brush.isSelected = false
            self.view_setting_brush.isHidden = true
            self.view_right_settingView.isHidden = true
            return
        }
        self.btn_left_home.isSelected = false
        self.btn_left_rotate.isSelected = false
        self.btn_left_brush.isSelected = true
        self.btn_left_stillImage.isSelected = false
        self.btn_left_share.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = false
        self.view_right_settingView.isHidden = true
        self.actionContainerGotoRight()
        self.view.bringSubviewToFront(self.view_setting_brush)
    }
    @IBAction func onLeftStillImage(_ sender: Any) {
        self.btn_left_home.isSelected = false
        self.btn_left_rotate.isSelected = false
        self.btn_left_brush.isSelected = false
        self.btn_left_stillImage.isSelected = true
        self.btn_left_share.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = true
        self.actionContainerGotoCenter()
        
        self.bGoExportViewCon = true
        self.m_videoPlayerView.stopVideo()
        
        self.loadSelectedVideoThumbail(0.0)
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.NewStillViewController) as? NewStillViewController
        self.navigationController?.present(viewCon ?? UIViewController(), animated: true, completion: nil)
        
    }
    @IBAction func onLeftShare(_ sender: Any) {
        self.btn_left_home.isSelected = false
        self.btn_left_rotate.isSelected = false
        self.btn_left_brush.isSelected = false
        self.btn_left_stillImage.isSelected = false
        self.btn_left_share.isSelected = true
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = true
        self.actionContainerGotoCenter()
        
        self.goToExportViewCon()
    }
    //// right setting UI Action
    @IBAction func onRightRepeat(_ sender: Any) {
        if(self.btn_right_repeat.isSelected){
            self.btn_right_repeat.isSelected = false
            self.view_setting_brush.isHidden = true
            self.view_right_settingView.isHidden = true
            return
        }
        self.btn_right_repeat.isSelected = true
        self.btn_right_color.isSelected = false
        self.btn_right_filter.isSelected = false
        self.btn_right_text.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = false
        self.view_right_settingView.showRightRepeatSetting()
        self.actionContainerGotoLeft()
        self.view.bringSubviewToFront(self.view_right_settingView)
    }
    @IBAction func onRightColor(_ sender: Any) {
        if(self.btn_right_color.isSelected){
            self.btn_right_color.isSelected = false
            self.view_setting_brush.isHidden = true
            self.view_right_settingView.isHidden = true
            return
        }
        self.btn_right_repeat.isSelected = false
        self.btn_right_color.isSelected = true
        self.btn_right_filter.isSelected = false
        self.btn_right_text.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = false
        self.view_right_settingView.showRightColorSetting()
        self.actionContainerGotoLeft()
        self.view.bringSubviewToFront(self.view_right_settingView)
    }
    @IBAction func onRightFilter(_ sender: Any) {
        if(self.btn_right_filter.isSelected){
            self.btn_right_filter.isSelected = false
            self.view_setting_brush.isHidden = true
            self.view_right_settingView.isHidden = true
            return
        }
        self.btn_right_repeat.isSelected = false
        self.btn_right_color.isSelected = false
        self.btn_right_filter.isSelected = true
        self.btn_right_text.isSelected = false
        self.m_btnAddText.isHidden = true
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = false
        self.view_right_settingView.showRightFilterSetting()
        self.actionContainerGotoLeft()
        self.view.bringSubviewToFront(self.view_right_settingView)
    }
    @IBAction func onRightText(_ sender: Any) {
        if(self.btn_right_text.isSelected){
            self.btn_right_text.isSelected = false
            self.m_btnAddText.isHidden = true
            self.view_setting_brush.isHidden = true
            self.view_right_settingView.isHidden = true
            return
        }
        self.btn_right_repeat.isSelected = false
        self.btn_right_color.isSelected = false
        self.btn_right_filter.isSelected = false
        self.btn_right_text.isSelected = true
        self.m_btnAddText.isHidden = false
        self.view_setting_brush.isHidden = true
        self.view_right_settingView.isHidden = false
        self.view_right_settingView.showRightTextSetting()
        self.actionContainerGotoLeft()
        self.view.bringSubviewToFront(self.view_right_settingView)
        
        
    }
    @IBAction func onAddText(_ sender: Any) {
        deselectAllStickerViews()
        
        let fontObject = FontObject.init(self)
        TheVideoEditor.fontObjects.append(fontObject)
        TheVideoEditor.selectedFontObjectIdx = TheVideoEditor.fontObjects.count - 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
        
        self.addActionForUndo()
    }
    func actionContainerGotoLeft(){
        UIView.animate(withDuration: 0.5, animations: {
//            self.const_actionContainer_left.constant = 0
//            self.const_actionContainer_right.constant = 230
//            self.view.setNeedsLayout()
        })
    }
    func actionContainerGotoRight(){
        UIView.animate(withDuration: 0.5, animations: {
//            self.const_actionContainer_left.constant = 200
//            self.const_actionContainer_right.constant = 0
//            self.view.setNeedsLayout()
        })
    }
    func actionContainerGotoCenter(){
        UIView.animate(withDuration: 0.5, animations: {
            self.const_actionContainer_left.constant = 0
            self.const_actionContainer_right.constant = 0
            self.view.setNeedsLayout()
        })
    }
    func goToExportViewCon() {
        self.m_workingCanvasView.backgroundColor = UIColor.clear
        deselectAllStickerViews()
        self.m_videoDrawingView.showHideDrawingViewForExport(false)
        self.m_videoPlayerView.isHidden = true
        self.m_videoFadePlayerView.isHidden = true
        
        let newSize = CGSize(width: self.m_videoPlayerView.bounds.size.width * UIScreen.main.scale, height: self.m_videoPlayerView.bounds.size.height * UIScreen.main.scale)
        let fakeMaskImage = self.m_workingCanvasView.takeScreenshotForExport().cropImageWithRectAndScale(newSize)
        
        let stillImageSize = TheImageProcesser.getCorrectStillImage().size
        let finalMaskImage = fakeMaskImage.resizeImage(targetSize: stillImageSize)
        
        self.m_workingCanvasView.backgroundColor = Constants.Colors.GrayBG
        selectStickerView()
        self.m_videoDrawingView.showHideDrawingViewForExport(true)
        self.m_videoPlayerView.isHidden = false
        self.m_videoFadePlayerView.isHidden = false
        
        if (TheUndoManager.bChanged) {
            InterfaceManager.showLoadingView()
            DispatchQueue.global(qos: .background).async {
                TheVideoEditor.makePreviewVideo(TheVideoEditor.editSettings.originalVideoURL, finalMaskImage.size, finalMaskImage, TheVideoEditor.editSettings.delay) { (videoURL, bSuccess) in
                    DispatchQueue.main.async {
                        InterfaceManager.hideLoadingView()
                        
                        if (bSuccess) {
                            self.bGoExportViewCon = true
                            self.m_videoPlayerView.deinitVideo()
                            
                            let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.ExportViewController) as? NewExportViewController
                            viewCon?.finalMaskImage = finalMaskImage
                            viewCon?.fakeMaskImage = fakeMaskImage
                            viewCon?.videoURL = videoURL
                            self.navigationController?.pushViewController(viewCon!, animated: true)
                        } else {
                            InterfaceManager.showMessage(false, title: "Failed to proceed the video. Please try again!", bBottomPos: true)
                        }
                    }
                }
            }
        } else {
            let curProject = TheUndoManager.getLastProject()
            
            self.bGoExportViewCon = true
            self.m_videoPlayerView.stopVideo()
            
            let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.ExportViewController) as? NewExportViewController
            viewCon?.finalMaskImage = finalMaskImage
            viewCon?.fakeMaskImage = fakeMaskImage
            viewCon?.videoURL = TheGlobalPoolManager.getVideoURL(curProject.finalVideoName)
            self.navigationController?.pushViewController(viewCon!, animated: true)
        }
        
    }
}
// MARK: - TextViewController Delegate
extension NewEditViewController: TextViewControllerDelegate {
    func dismissTextViewCon(_ viewCon: TextViewController, _ text: String) {
        viewCon.dismiss(animated: true) {
            if (text.length > 0) {
                TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text = text
                TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].bTextChanged = true
                TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].doProcess()
                
                self.addActionForUndo()
            }
        }
    }
}
extension NewEditViewController: ZDStickerViewDelegate {
    func deselectAllStickerViews() {
        for fontObject in TheVideoEditor.fontObjects {
            fontObject.deSelectObject()
        }
    }
    
    func selectStickerView() {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].selectObject()
    }
    
    func stickerViewDidClose(_ sticker: ZDStickerView!) {
        TheVideoEditor.fontObjects.remove(at: TheVideoEditor.selectedFontObjectIdx)
        
        deselectAllStickerViews()
        
        if (TheVideoEditor.fontObjects.count == 0) {
            TheVideoEditor.selectedFontObjectIdx = -1
        } else {
            TheVideoEditor.selectedFontObjectIdx = TheVideoEditor.fontObjects.count - 1
        }
        
        selectStickerView()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
        
        self.addActionForUndo()
    }
    
    func stickerViewDidReset(_ sticker: ZDStickerView!) {
        print("updated text setting")
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].doReset()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
        
        self.addActionForUndo()
    }
    
    func stickerViewDidTapped(_ sticker: ZDStickerView!) {
        deselectAllStickerViews()
        
        for nIdx in 0..<TheVideoEditor.fontObjects.count {
            let fontObject = TheVideoEditor.fontObjects[nIdx]
            
            if (fontObject.iconView == sticker) {
                TheVideoEditor.selectedFontObjectIdx = nIdx
                break
            }
        }
        
        selectStickerView()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
    }
    
    func stickerViewDidDoubleTapped(_ sticker: ZDStickerView!) {
        deselectAllStickerViews()
        
        for nIdx in 0..<TheVideoEditor.fontObjects.count {
            let fontObject = TheVideoEditor.fontObjects[nIdx]
            
            if (fontObject.iconView == sticker) {
                TheVideoEditor.selectedFontObjectIdx = nIdx
                break
            }
        }
        
        selectStickerView()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.TextViewController) as? TextViewController
        viewCon?.delegate = self
        self.present(viewCon!, animated: true, completion: nil)
    }
    
    func stickerViewDidEndEditing(_ sticker: ZDStickerView!) {
        self.addActionForUndo()
    }
}
