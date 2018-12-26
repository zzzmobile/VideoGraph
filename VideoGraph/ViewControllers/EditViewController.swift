//
//  EditViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

let TRIM_INDICATOR_WIDTH: CGFloat = 16.0

class EditViewController: UIViewController, TemplateMenuViewControllerDelegate, TextMenuViewControllerDelegate, UIGestureRecognizerDelegate {
    var bLoadedView: Bool = false
    
    var bAlwaysStatusBar: Bool = false
    var bShowStatusBar: Bool = true
    
    @IBOutlet weak var m_viewTopArea: UIView!
    @IBOutlet weak var m_viewNaviBar: UIView!
    
    @IBOutlet weak var m_constraintTop1: NSLayoutConstraint! //-84
    @IBOutlet weak var m_constraintTop2: NSLayoutConstraint! // -84

    @IBOutlet weak var m_viewTopOptions: UIView!
    @IBOutlet weak var m_btnOption1: UIButton!
    @IBOutlet weak var m_btnOption2: UIButton!

    @IBOutlet weak var m_btnUndo: UIButton!
    
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_contentView: UIView!
    
    @IBOutlet weak var m_workingCanvasView: UIView!
    
    @IBOutlet weak var m_videoFadePlayerView: VideoFadePlayerView!
    @IBOutlet weak var m_videoPlayerView: VideoPlayerView!
    @IBOutlet weak var m_constraintVideoPlayerWidth: NSLayoutConstraint!
    @IBOutlet weak var m_constraintVideoPlayerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var m_videoDrawingView: VideoDrawingView!
    
    @IBOutlet weak var m_imgViewVideoWithoutActions: UIImageView!
    @IBOutlet weak var m_btnAddText: UIButton!
    
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

    @IBOutlet weak var m_btnMenuVideo: UIButton!
    @IBOutlet weak var m_btnMenuBrush: UIButton!
    @IBOutlet weak var m_btnMenuTune: UIButton!
    @IBOutlet weak var m_btnMenuFilter: UIButton!
    @IBOutlet weak var m_btnMenuText: UIButton!

    @IBOutlet weak var m_viewSubMenu: UIView!
    @IBOutlet weak var m_constraintSubMenuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var m_viewSubMenuContent: UIView!
    @IBOutlet weak var m_constraintSubMenuContentHeight: NSLayoutConstraint!
    
    var currentSubMenuViewCon: UIViewController? = nil
    var currentSubMenuContentViewCon: UIViewController? = nil
    
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
        self.edgesForExtendedLayout = UIRectEdge()

        NotificationCenter.default.addObserver(self, selector: #selector(tappedActionInStillImage), name: NSNotification.Name(rawValue: Constants.NotificationName.TappedActionInStillImage), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatedStillImageFromSubView), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImageInSubView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetStillImage), name: NSNotification.Name(rawValue: Constants.NotificationName.ResetStillImage), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(doShowHideTopBarsAlways), name: NSNotification.Name(rawValue: Constants.NotificationName.ShowHideTopBarsInEditViewAsAlways), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doShowTopBarsJustOnce), name: NSNotification.Name(rawValue: Constants.NotificationName.ShowTopBarsInEditViewJustOnce), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doHideTopbarsJustOnce), name: NSNotification.Name(rawValue: Constants.NotificationName.HideTopBarsInEditViewJustOnce), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskFesture), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(croppedVideo), name: NSNotification.Name(rawValue: Constants.NotificationName.CroppedVideo), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatedTextSetting), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRotateZoomText), name: NSNotification.Name(rawValue: Constants.NotificationName.RotateZoomText), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(addActionForUndo), name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUndoProcess), name: NSNotification.Name(rawValue: Constants.NotificationName.didUndoProcess), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatedRotateInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateRotateValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishUpdateRotateInStickerView), name: NSNotification.Name(rawValue: Constants.NotificationName.FinishUpdateRotateValueInStickView), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatedZoomInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateZoomValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishUpdateZoomInStickerView), name: NSNotification.Name(rawValue: Constants.NotificationName.FinishUpdateZoomValueInStickView), object: nil)

        //init process of ImageProcesser
        TheImageProcesser.bEraserMode = true
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
    
    override var prefersStatusBarHidden: Bool {
        return !bShowStatusBar
    }
    
    @objc func doShowHideTopBarsAlways() {
        bAlwaysStatusBar = !bAlwaysStatusBar
        
        if (bAlwaysStatusBar) {
            hideTopBars()
        } else {
            showTopBars()
        }
    }
    
    @objc func doShowTopBarsJustOnce() {
        if (bAlwaysStatusBar) {
            return
        }
        
        showTopBars()
    }
    
    @objc func doHideTopbarsJustOnce() {
        if (bAlwaysStatusBar) {
            return
        }
        
        hideTopBars()
    }
    
    func showTopBars() {
        bShowStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
        
        UIView.animate(withDuration: 0.3) {
            self.m_constraintTop1.constant = 0.0
            self.m_constraintTop2.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func hideTopBars() {
        bShowStatusBar = false
        setNeedsStatusBarAppearanceUpdate()

        let fOffset = self.m_viewTopArea.frame.height + self.m_viewNaviBar.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.m_constraintTop1.constant = -1 * fOffset
            self.m_constraintTop2.constant = -1 * fOffset
            self.view.layoutIfNeeded()
        }
    }

    @objc func updateMaskFesture() {
        if (TheVideoEditor.editSettings.bMaskAll) {
            TheImageProcesser.bEraserMode = false
        } else {
            TheImageProcesser.bEraserMode = true
        }
        
        self.showEraserMode()
    }
    
    @objc func tappedActionInStillImage() {
        self.bGoExportViewCon = true
        self.m_videoPlayerView.stopVideo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        InterfaceManager.makeRadiusControl(self.m_viewTopOptions, cornerRadius: 0.0, withColor: UIColor.black, borderSize: 2.0)
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func makeUserInterface() {
        self.m_videoDrawingView.workingCanvasView = self.m_workingCanvasView
        
        self.m_btnUndo.isEnabled = false
        
        TheInterfaceManager.nSelectedMenu = .Video
        TheInterfaceManager.nSelectedSubMenu = 0
        
        self.m_btnAddText.isHidden = true
        
        showEraserMode()
        
        showMenu()
        setupSubMenu()
        setupSubMenuContentView()
        
        //add video thumbnails
        InterfaceManager.makeRadiusControl(self.m_viewTrimOverlay!, cornerRadius: 0.0, withColor: UIColor.black.withAlphaComponent(0.4), borderSize: 2.0)

        let videoThumbViewFrame = self.m_viewTrimOverlay.frame
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
//                fontObject.doProcessAfterUndo(self)
            }
            selectStickerView()
        }
        
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
    }
    
    func setupTrimView() {
        self.m_constraintTrimLeftIndicatorLeading.constant = TheVideoEditor.fTrimLeftOffset + 8.0
        self.m_constraintTrimRightIndicatorLeading.constant = TheVideoEditor.fTrimRightOffset + 24.0

        self.m_constraintLeftTrimWidth.constant = TheVideoEditor.fTrimLeftOffset
        self.m_constraintRightTrimWidth.constant = self.m_viewTrimOverlay.frame.width - TheVideoEditor.fTrimRightOffset
        
        self.view.layoutIfNeeded()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("detected gesture")
        
        if (gestureRecognizer == self.videoScrubberPanGesture) {
            return false
        }
        
        return true
    }
    
    @objc func longPressProc(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            self.currentVideoPlayerWidth = self.m_constraintVideoPlayerWidth.constant
            self.currentVideoPlayerHeight = self.m_constraintVideoPlayerHeight.constant
            
            self.updateVideoPlayerSize(self.videoThumbSize)
            
            doHideTopbarsJustOnce()
            
            TheVideoEditor.bViewOriginalVideo = true
            self.m_videoDrawingView.isHidden = true
            //self.m_videoDrawingView.hideAllSubViewsForOriginalVideo(true)
            for fontObject in TheVideoEditor.fontObjects {
                fontObject.iconView?.isHidden = true
            }
        } else if (sender.state == .ended || sender.state == .cancelled) {
            doShowTopBarsJustOnce()
            
            self.updateVideoPlayerSize(CGSize(width: self.currentVideoPlayerWidth, height: self.currentVideoPlayerHeight))
            
            TheVideoEditor.bViewOriginalVideo = false
            self.m_videoDrawingView.isHidden = false
            //self.m_videoDrawingView.hideAllSubViewsForOriginalVideo(false)
            for fontObject in TheVideoEditor.fontObjects {
                fontObject.iconView?.isHidden = false
            }
        }
    }
    
    func updateVideoPlayerSize(_ thumbSize: CGSize) {
        let widthRatio = thumbSize.width / self.view.frame.width
        let heightRatio = thumbSize.height / self.view.frame.width
        
        var videoPlayerSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.view.frame.width) {
            videoPlayerSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            videoPlayerSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        
        self.m_constraintVideoPlayerWidth.constant = videoPlayerSize.width
        self.m_constraintVideoPlayerHeight.constant = videoPlayerSize.height
        self.view.layoutIfNeeded()
    }
    
    @objc func croppedVideo() {
        //adjust width and height of video player and drawing view
        let newVideoThumbSize = TheImageProcesser.getCorrectStillImage().size
        self.updateVideoPlayerSize(newVideoThumbSize)
        
        self.addActionForUndo()
    }
    
    @objc func resetStillImage() {
        self.loadSelectedVideoThumbail(0.0)
    }
    
    @objc func updatedStillImageFromSubView() {
        self.m_videoDrawingView.showStillImage()
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
    
    func updatedTrimIndicator() {
        let fLeftOffset = (self.m_constraintTrimLeftIndicatorLeading.constant + TRIM_INDICATOR_WIDTH) - self.m_videoThumbView!.frame.minX
        let fRightOffset = self.m_constraintTrimRightIndicatorLeading.constant - 24.0
        
        TheVideoEditor.fTrimRightOffset = fRightOffset
        TheVideoEditor.fTrimLeftOffset = fLeftOffset
        
        self.m_videoPlayerView.restartPlayVideo()
        
        self.addActionForUndo()
    }
    
    func showEraserMode() {
        if (TheImageProcesser.bEraserMode) {
            self.m_btnOption1.backgroundColor = UIColor.black
            self.m_btnOption1.setImage(UIImage(named: Constants.MaskOptionIcons.HighlightSelected), for: .normal)
            
            self.m_btnOption2.backgroundColor = UIColor.white
            self.m_btnOption2.setImage(UIImage(named: Constants.MaskOptionIcons.Eraser), for: .normal)
        } else {
            self.m_btnOption1.backgroundColor = UIColor.white
            self.m_btnOption1.setImage(UIImage(named: Constants.MaskOptionIcons.Highlight), for: .normal)
            
            self.m_btnOption2.backgroundColor = UIColor.black
            self.m_btnOption2.setImage(UIImage(named: Constants.MaskOptionIcons.EraserSelected), for: .normal)
        }
    }
    
    func showMenu() {
        self.m_btnAddText.isHidden = true
        
        self.m_btnMenuVideo.setImage(UIImage(named: Constants.MenuIcons.Video), for: .normal)
        self.m_btnMenuBrush.setImage(UIImage(named: Constants.MenuIcons.Brush), for: .normal)
        self.m_btnMenuTune.setImage(UIImage(named: Constants.MenuIcons.Tune), for: .normal)
        self.m_btnMenuFilter.setImage(UIImage(named: Constants.MenuIcons.Filter), for: .normal)
        self.m_btnMenuText.setImage(UIImage(named: Constants.MenuIcons.Text), for: .normal)
        
        switch TheInterfaceManager.nSelectedMenu {
        case .Video:
            self.m_btnMenuVideo.setImage(UIImage(named: Constants.MenuIcons.VideoSelected), for: .normal)
            break
        case .Brush:
            self.m_btnMenuBrush.setImage(UIImage(named: Constants.MenuIcons.BrushSelected), for: .normal)
            break
        case .Tune:
            self.m_btnMenuTune.setImage(UIImage(named: Constants.MenuIcons.TuneSelected), for: .normal)
            break
        case .Filter:
            self.m_btnMenuFilter.setImage(UIImage(named: Constants.MenuIcons.FilterSelected), for: .normal)
            break
        case .Text:
            self.m_btnAddText.isHidden = false
            self.m_btnMenuText.setImage(UIImage(named: Constants.MenuIcons.TextSelected), for: .normal)
            break
        }
    }
    
    func removeCurrentMenuViewCon() {
        if (currentSubMenuViewCon != nil) {
            currentSubMenuViewCon!.willMove(toParentViewController: nil)
            currentSubMenuViewCon!.view.removeFromSuperview()
            currentSubMenuViewCon!.removeFromParentViewController()
        }
        
        currentSubMenuViewCon = nil
    }
    
    func removeCurrentMenuContentViewCon() {
        if (currentSubMenuContentViewCon != nil) {
            currentSubMenuContentViewCon!.willMove(toParentViewController: nil)
            currentSubMenuContentViewCon!.view.removeFromSuperview()
            currentSubMenuContentViewCon!.removeFromParentViewController()
        }
        
        currentSubMenuContentViewCon = nil
    }
    
    func addTemplateMenu(_ menuHeight: CGFloat, viewID: String, _ titles: [String]) {    
        self.m_constraintSubMenuHeight.constant = menuHeight
        self.view.layoutIfNeeded()
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: viewID) as? TemplateMenuViewController
        viewCon?.titles = titles
        viewCon?.delegate = self
        
        self.addChildViewController(viewCon!)
        self.m_viewSubMenu.addSubview(viewCon!.view)
        viewCon?.didMove(toParentViewController: self)
        viewCon!.view.frame = self.m_viewSubMenu.bounds
        
        self.currentSubMenuViewCon = viewCon
    }

    func addTextMenu(_ menuHeight: CGFloat, viewID: String, _ titles: [String]) {
        self.m_constraintSubMenuHeight.constant = menuHeight
        self.view.layoutIfNeeded()
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: viewID) as? TextMenuViewController
        viewCon?.titles = titles
        viewCon?.delegate = self

        self.addChildViewController(viewCon!)
        self.m_viewSubMenu.addSubview(viewCon!.view)
        viewCon?.didMove(toParentViewController: self)
        viewCon!.view.frame = self.m_viewSubMenu.bounds
        
        self.currentSubMenuViewCon = viewCon
    }

    func addFilterView() {
        removeCurrentMenuContentViewCon()

        self.m_constraintSubMenuHeight.constant = 0.0
        let cellHeight = (self.view.bounds.width - 32.0 - 12.0) / 4.0 * 1.4
        let nRows = (TheVideoFilterManager.filterNames.count % 4 == 0 ? TheVideoFilterManager.filterNames.count / 4 : TheVideoFilterManager.filterNames.count / 4 + 1)
        self.m_constraintSubMenuContentHeight.constant = cellHeight * CGFloat(nRows) + 32.0 + 4.0 * CGFloat(nRows - 1) //32.0 - top and bottom margin, cell spacing - 4.0
        
        self.view.layoutIfNeeded()

        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.FilterViewController) as? FilterViewController
        
        self.addChildViewController(viewCon!)
        self.m_viewSubMenuContent.addSubview(viewCon!.view)
        viewCon?.didMove(toParentViewController: self)
        viewCon!.view.frame = self.m_viewSubMenuContent.bounds
        
        self.currentSubMenuViewCon = nil
        self.currentSubMenuContentViewCon = viewCon
    }
    
    func setupSubMenu() {
        removeCurrentMenuViewCon()
        
        switch TheInterfaceManager.nSelectedMenu {
        case .Video:
            addTemplateMenu(Constants.VideoMenu.MenuHeight, viewID: Constants.VideoMenu.MenuViewID, Constants.VideoMenu.Titles)
            break
        case .Brush:
            addTemplateMenu(Constants.BrushMenu.MenuHeight, viewID: Constants.BrushMenu.MenuViewID, Constants.BrushMenu.Titles)
            break
        case .Tune:
            addTemplateMenu(Constants.TuneMenu.MenuHeight, viewID: Constants.TuneMenu.MenuViewID, Constants.TuneMenu.Titles)
            break
        case .Filter:
            addFilterView()
            break
        case .Text:
            addTextMenu(Constants.TextMenu.MenuHeight, viewID: Constants.TextMenu.MenuViewID, Constants.TextMenu.Titles)
            break
        }
    }
    
    func setupSubMenuContentView() {
        removeCurrentMenuContentViewCon()
        
        if (TheInterfaceManager.nSelectedMenu == .Filter) {
            return
        }
        
        var viewID: String = ""
        var viewHeight: CGFloat = 0.0
        
        switch TheInterfaceManager.nSelectedMenu {
        case .Video:
            viewID = Constants.VideoMenu.ViewIDs[TheInterfaceManager.nSelectedSubMenu]
            viewHeight = Constants.VideoMenu.Heights[TheInterfaceManager.nSelectedSubMenu]
            break
        case .Tune:
            viewID = Constants.TuneMenu.ViewIDs[TheInterfaceManager.nSelectedSubMenu]
            viewHeight = Constants.TuneMenu.Heights[TheInterfaceManager.nSelectedSubMenu]
            break
        case .Brush:
            viewID = Constants.BrushMenu.ViewIDs[TheInterfaceManager.nSelectedSubMenu]
            viewHeight = Constants.BrushMenu.Heights[TheInterfaceManager.nSelectedSubMenu]
            break
        case .Text:
            viewID = Constants.TextMenu.ViewIDs[TheInterfaceManager.nSelectedSubMenu]
            viewHeight = Constants.TextMenu.Heights[TheInterfaceManager.nSelectedSubMenu]
            break
        default:
            break
        }
        
        self.m_constraintSubMenuContentHeight.constant = viewHeight
        self.view.layoutIfNeeded()
        
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: viewID)
        
        self.addChildViewController(viewCon!)
        self.m_viewSubMenuContent.addSubview(viewCon!.view)
        viewCon?.didMove(toParentViewController: self)
        viewCon!.view.frame = self.m_viewSubMenuContent.bounds
        
        self.currentSubMenuContentViewCon = viewCon
    }
    
    func tappedTemplateMenu() {
        setupSubMenuContentView()
    }
    
    func tappedTextMenu() {
        setupSubMenuContentView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionBack(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Are you sure you want to leave this screen?", message: "It will save your project under My Project", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            self.goToExportViewCon()

            /*
            self.m_videoPlayerView.stopVideo()
            
            deselectAllStickerViews()
            
            let newSize = CGSize(width: self.m_videoPlayerView.frame.size.width * UIScreen.main.scale, height: self.m_videoPlayerView.frame.size.height * UIScreen.main.scale)
            let projectThumbnail = self.m_workingCanvasView.takeScreenshotForExport().cropImageWithRectAndScale(newSize)
            
            if (TheProjectManger.curArrayIdx == -1) {
                InterfaceManager.showLoadingView()
                TheProjectManger.addProject(projectThumbnail, TheUndoManager.getLastProject()) {
                    InterfaceManager.hideLoadingView()
                    
                    NotificationCenter.default.removeObserver(self)
                    self.navigationController?.popToViewController(TheGlobalPoolManager.rootViewCon!, animated: true)
                    //self.navigationController?.popViewController(animated: true)
                }
            } else {
                InterfaceManager.showLoadingView()
                TheProjectManger.updateProject(projectThumbnail, TheUndoManager.getLastProject()) {
                    InterfaceManager.hideLoadingView()
                    
                    NotificationCenter.default.removeObserver(self)
                    self.navigationController?.popToViewController(TheGlobalPoolManager.rootViewCon!, animated: true)
                    //self.navigationController?.popViewController(animated: true)
                }
            }
            */
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(actionSheet, animated: true, completion: nil)
        })
    }
    
    @IBAction func actionCrop(_ sender: Any) {
        DispatchQueue.main.async {
            let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.CropViewController) as? CropViewController
            viewCon?.originalImage = TheVideoEditor.stillImage
            self.present(viewCon!, animated: true, completion: nil)
        }

        /*
        //get current thumbnail from the video
        let offset = self.m_constraintScrubberLeading.constant + self.m_imgScrubber.frame.width / 2.0 - self.m_videoThumbView!.frame.origin.x
        let time = TheThumbnailManager.getTime(offset, self.m_videoThumbView!.frame.width)
        TheThumbnailManager.generateThumbnailImage(time!) { (image) in
            DispatchQueue.main.async {
                let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.CropViewController) as? CropViewController
                viewCon?.originalImage = image
                self.present(viewCon!, animated: true, completion: nil)
            }
        }
        */
    }
    
    @objc func didUndoProcess() {
        self.setupTrimView()
        
        let newVideoThumbSize = TheImageProcesser.getCorrectStillImage().size
        self.updateVideoPlayerSize(newVideoThumbSize)
        
        m_videoPlayerView.restartPlayVideo()
        
        //update subviews
        if (TheInterfaceManager.nSelectedMenu == .Filter) {
            setupSubMenu()
        } else {
            setupSubMenuContentView()
        }
        
        //update font objects in the video
        deselectAllStickerViews()
        for fontObject in TheVideoEditor.fontObjects {
//            fontObject.doProcessAfterUndo(self)
        }
        selectStickerView()
    }
    
    func addActionForUndoFromProject(_ finalVideoName: String) {
        let project = Project.init(self.m_videoDrawingView.maskImage, self.m_videoDrawingView.maskImageView?.image, finalVideoName)
        TheUndoManager.addAction(project)
        
        self.m_btnUndo.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    
    @objc func addActionForUndo() {
        let project = Project.init(self.m_videoDrawingView.maskImage, self.m_videoDrawingView.maskImageView?.image)
        TheUndoManager.addAction(project)
        
        self.m_btnUndo.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    
    @IBAction func actionUndo(_ sender: Any) {
        TheUndoManager.doUndo()
        
        self.m_btnUndo.isEnabled = TheUndoManager.checkUndoAvailable()
    }
    
    @IBAction func actionDone(_ sender: Any) {
        //make screenshot of drawing view
        self.goToExportViewCon()
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
                            
                            let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.ExportViewController) as? ExportViewController
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
            
            let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.ExportViewController) as? ExportViewController
            viewCon?.finalMaskImage = finalMaskImage
            viewCon?.fakeMaskImage = fakeMaskImage
            viewCon?.videoURL = TheGlobalPoolManager.getVideoURL(curProject.finalVideoName)
            self.navigationController?.pushViewController(viewCon!, animated: true)
        }
        
    }
    
    @IBAction func actionChooseTopOption1(_ sender: Any) {
        TheImageProcesser.bEraserMode = true
        showEraserMode()
    }

    @IBAction func actionChooseTopOption2(_ sender: Any) {
        TheImageProcesser.bEraserMode = false
        showEraserMode()
    }

    @IBAction func actionAddText(_ sender: Any) {
        deselectAllStickerViews()

//        let fontObject = FontObject.init(self)
//        
//        TheVideoEditor.fontObjects.append(fontObject)
        TheVideoEditor.selectedFontObjectIdx = TheVideoEditor.fontObjects.count - 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil, userInfo: nil)
        
        self.addActionForUndo()
    }
    
    @IBAction func actionChooseMenuVideo(_ sender: Any) {
        if (TheInterfaceManager.nSelectedMenu == .Video) {
            return
        }
        
        TheInterfaceManager.nSelectedMenu = .Video
        TheInterfaceManager.nSelectedSubMenu = 0
        
        showMenu()
        setupSubMenu()
        setupSubMenuContentView()
    }

    @IBAction func actionChooseMenuBrush(_ sender: Any) {
        if (TheInterfaceManager.nSelectedMenu == .Brush) {
            return
        }
        
        TheInterfaceManager.nSelectedMenu = .Brush
        TheInterfaceManager.nSelectedSubMenu = 0

        showMenu()
        setupSubMenu()
        setupSubMenuContentView()
    }

    @IBAction func actionChooseMenuTune(_ sender: Any) {
        if (TheInterfaceManager.nSelectedMenu == .Tune) {
            return
        }

        TheInterfaceManager.nSelectedMenu = .Tune
        TheInterfaceManager.nSelectedSubMenu = 0
        
        showMenu()
        setupSubMenu()
        setupSubMenuContentView()
    }

    @IBAction func actionChooseMenuFilter(_ sender: Any) {
        if (TheInterfaceManager.nSelectedMenu == .Filter) {
            return
        }

        TheInterfaceManager.nSelectedMenu = .Filter
        TheInterfaceManager.nSelectedSubMenu = -1

        showMenu()
        setupSubMenu()
    }

    @IBAction func actionChooseMenuText(_ sender: Any) {
        if (TheInterfaceManager.nSelectedMenu == .Text) {
            return
        }

        TheInterfaceManager.nSelectedMenu = .Text
        TheInterfaceManager.nSelectedSubMenu = 0
        
        showMenu()
        setupSubMenu()
        setupSubMenuContentView()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
}

// MARK: - TextViewController Delegate
extension EditViewController: TextViewControllerDelegate {
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

// MARK: - Sticker View Delegate
extension EditViewController: ZDStickerViewDelegate {
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
