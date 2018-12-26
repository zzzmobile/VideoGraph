//
//  NewExportViewController.swift
//  VideoGraph
//
//  Created by Techsviewer on 12/2/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVKit
import Regift
import Photos
import AssetsLibrary
import VerticalSteppedSlider

class NewExportViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    var bLoadedView: Bool = false
    
    var bShowStatusBar: Bool = true
    var finalMaskImage: UIImage? = nil
    var fakeMaskImage: UIImage? = nil
    
    @IBOutlet weak var slider_repititions: VSSlider!
    @IBOutlet weak var lbl_repetitionResult: UILabel!
    @IBOutlet weak var m_viewTopArea: UIView!
    @IBOutlet weak var m_viewNaviBar: UIView!
    
    @IBOutlet weak var m_constraintTop1: NSLayoutConstraint! //-84
    @IBOutlet weak var m_constraintTop2: NSLayoutConstraint! // -84
    
    @IBOutlet weak var m_workingCanvasView: UIView!
    
    @IBOutlet weak var m_videoFadePlayerView: VideoFadePlayerView!
    @IBOutlet weak var m_videoPlayerView: VideoPlayerView!
    @IBOutlet weak var m_constraintVideoPlayerWidth: NSLayoutConstraint!
    @IBOutlet weak var m_constraintVideoPlayerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var m_imgDrawing: UIImageView!
    
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_contentView: UIView!
    
    @IBOutlet weak var m_imgThumbnail: UIImageView!
    
    @IBOutlet weak var m_segmentExportOptions: UISegmentedControl!
    @IBOutlet weak var m_lblVideoDuration: UILabel!
    
    @IBOutlet weak var m_collectionRepetitions: UICollectionView!
    @IBOutlet weak var m_collectionResolutions: UICollectionView!
    
    @IBOutlet weak var m_viewGifRepetitions: UIView!
    @IBOutlet weak var m_lblNone: UILabel!
    @IBOutlet weak var m_lblLoop: UILabel!
    @IBOutlet weak var m_viewBorderNone: UIView!
    @IBOutlet weak var m_viewBorderLoop: UIView!
    
    let repetitions = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let resolutions = [480, 540, 720, 1080]
    
    var bVideoExport: Bool = true
    
    var nSelectedRepeatIdx: Int = 0
    var nSelectedResolutionIdx: Int = 0
    var bGIFLoop: Bool = false
    
    var asset: AVAsset? = nil
    var videoURL: URL? = nil
    
    @IBOutlet weak var btn_480p: UIButton!
    @IBOutlet weak var btn_540p: UIButton!
    @IBOutlet weak var btn_720p: UIButton!
    @IBOutlet weak var btn_1080p: UIButton!
    @IBOutlet weak var btn_more_video: UIButton!
    @IBOutlet weak var btn_more_gif: UIButton!
    private let documentInteractionController = UIDocumentInteractionController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        makeUserInterface()
        
        self.m_imgDrawing.image = self.finalMaskImage
        self.updateVideoPlayerSize(self.finalMaskImage!.size)
        self.m_videoPlayerView.playVideo(nil, self.m_videoFadePlayerView)
        
        self.asset = AVAsset(url: self.videoURL!)
        showDuration()
    }
    func makeUserInterface() {
//        self.m_viewGifRepetitions.isHidden = true
//        self.showSelectedGifRepeat()
//
//        //repetitions collectionview
//        self.m_collectionRepetitions.backgroundColor = UIColor.white
//
//        let edgeInsets = UIEdgeInsets.zero
//        let layoutRepetitions: UICollectionViewFlowLayout = self.m_collectionRepetitions.collectionViewLayout as! UICollectionViewFlowLayout;
//        layoutRepetitions.sectionInset = edgeInsets
//        layoutRepetitions.minimumInteritemSpacing = (self.view.frame.width - 32.0 - 270.0) / 8.0
//        layoutRepetitions.minimumLineSpacing = (self.view.frame.width - 32.0 - 270.0) / 8.0
//
//        self.m_collectionRepetitions.delegate = self
//        self.m_collectionRepetitions.dataSource = self
//
//        self.m_collectionRepetitions.isScrollEnabled = false
//
//        //resolutions collectionview
//        self.m_collectionResolutions.backgroundColor = UIColor.white
//
//        let layoutResolutions: UICollectionViewFlowLayout = self.m_collectionResolutions.collectionViewLayout as! UICollectionViewFlowLayout;
//        layoutResolutions.sectionInset = edgeInsets
//        layoutResolutions.minimumInteritemSpacing = 30.0
//        layoutResolutions.minimumLineSpacing = 30.0
        
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
    
    func showDuration() {
//        let duration = self.asset!.duration
//        let durationTime = CMTimeGetSeconds(duration) / Double(TheVideoEditor.editSettings.speed)
//
//        self.m_lblVideoDuration.text = String(format: "%.02f", durationTime)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeFinalResult(_ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        let nRepeatCnt = repetitions[self.nSelectedRepeatIdx]
        let videoDimension = resolutions[self.nSelectedResolutionIdx]
        
        TheVideoEditor.resizeVideo(self.videoURL!, CGFloat(videoDimension)) { (resizedVideoURL, bSuccess) in
            if (bSuccess) {
                if (self.bVideoExport) {
                    TheVideoEditor.makeLoopVideo(nRepeatCnt, resizedVideoURL!) { (url, bSuccess) in
                        DispatchQueue.main.async {
                            completion(url, bSuccess)
                        }
                    }
                } else {
                    Regift.createGIFFromSource(resizedVideoURL!, frameCount: 16, delayTime: 0.0, loopCount: (self.bGIFLoop ? 0 : 1), size: self.finalMaskImage!.size) { (url) in
                        DispatchQueue.main.async {
                            completion(url, (url == nil ? false : true))
                        }
                    }
                }
            } else {
                completion(nil, false)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func actionGoHome(_ sender: Any) {
        self.saveProject {
            self.goHomeScreen()
        }
    }
    
    func goHomeScreen() {
        self.m_videoPlayerView.deinitVideo()
        TheVideoEditor.removeAllTempVideos()
        self.navigationController?.popToViewController(TheGlobalPoolManager.rootViewCon!, animated: true)
    }
    func saveProject(_ completion: @escaping () -> Void) {
        let projectThumbnail = self.m_workingCanvasView.takeScreenshotForExport().cropImageWithRectAndScale(self.fakeMaskImage!.size)
        
        if (TheProjectManger.curArrayIdx == -1) {
            InterfaceManager.showLoadingView()
            TheProjectManger.addProject(projectThumbnail, TheUndoManager.getLastProject(), self.videoURL!.lastPathComponent) {
                InterfaceManager.hideLoadingView()
                completion()
            }
        } else {
            if (TheUndoManager.bChanged) {
                InterfaceManager.showLoadingView()
                TheProjectManger.updateProject(projectThumbnail, TheUndoManager.getLastProject(), self.videoURL!.lastPathComponent) {
                    InterfaceManager.hideLoadingView()
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    @IBAction func onSelectVideo(_ sender: Any) {
        self.btn_more_video.isSelected = true
        self.btn_more_gif.isSelected = false
        self.bVideoExport = true
    }
    @IBAction func onSelectGif(_ sender: Any) {
        self.btn_more_video.isSelected = false
        self.btn_more_gif.isSelected = true
        self.bVideoExport = false
    }
    
    @IBAction func onSelecRepetitions(_ sender: Any) {
        self.lbl_repetitionResult.text = Int(slider_repititions.value).description
        nSelectedRepeatIdx = Int(slider_repititions.value) - 1
    }
    @IBAction func onSelect480p(_ sender: Any) {
        self.btn_480p.isSelected = true
        self.btn_540p.isSelected = false
        self.btn_720p.isSelected = false
        self.btn_1080p.isSelected = false
        nSelectedResolutionIdx = 0
    }
    @IBAction func onSelect540p(_ sender: Any) {
        self.btn_480p.isSelected = false
        self.btn_540p.isSelected = true
        self.btn_720p.isSelected = false
        self.btn_1080p.isSelected = false
        nSelectedResolutionIdx = 1
    }
    @IBAction func onSelect720p(_ sender: Any) {
        self.btn_480p.isSelected = false
        self.btn_540p.isSelected = false
        self.btn_720p.isSelected = true
        self.btn_1080p.isSelected = false
        nSelectedResolutionIdx = 2
    }
    @IBAction func onSelect1080p(_ sender: Any) {
        self.btn_480p.isSelected = false
        self.btn_540p.isSelected = false
        self.btn_720p.isSelected = false
        self.btn_1080p.isSelected = true
        nSelectedResolutionIdx = 3
    }
    
    @IBAction func actionShare(_ sender: Any) {
        InterfaceManager.showLoadingView()
        self.makeFinalResult { (finalURL, bSuccess) in
            DispatchQueue.main.async {
                if (bSuccess) {
                    InterfaceManager.hideLoadingView()
                    
                    let textToShare = Constants.ShareText
                    
                    let objectsToShare = [textToShare, finalURL!] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.completionWithItemsHandler = { activity, success, items, error in
                        if (!success) {
                            DispatchQueue.main.async {
                                InterfaceManager.showMessage(false, title: "Failed to share your result. Please try again!", bBottomPos: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                if (self.bVideoExport) {
                                    InterfaceManager.showMessage(true, title: "You have shared the video successfully!", bBottomPos: true)
                                } else {
                                    InterfaceManager.showMessage(true, title: "You have shared the gif successfully!", bBottomPos: true)
                                }
                                
                                self.saveProject {
                                    self.goHomeScreen()
                                }
                            }
                        }
                    }
                    
                    self.present(activityVC, animated: true, completion: nil)
                } else {
                    InterfaceManager.hideLoadingView()
                    InterfaceManager.showMessage(false, title: "Failed to generate video. Please try again!", bBottomPos: true)
                }
            }
        }
    }
    @IBAction func actionShareWithIG(_ sender: Any) {
        var videoAssetPlaceholder:PHObjectPlaceholder!
        
        InterfaceManager.showLoadingView()
        self.makeFinalResult { (finalURL, bSuccess) in
            DispatchQueue.main.async {
                if (bSuccess) {
                    PHPhotoLibrary.requestAuthorization { (status) in
                        if (status == .authorized) {
                            PHPhotoLibrary.shared().performChanges({
                                if (self.bVideoExport) {
                                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalURL!)
                                    videoAssetPlaceholder = request!.placeholderForCreatedAsset
                                } else {
                                    let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: finalURL!)
                                    videoAssetPlaceholder = request!.placeholderForCreatedAsset
                                }
                            }) { saved, error in
                                DispatchQueue.main.async {
                                    InterfaceManager.hideLoadingView()
                                    if saved {
                                        let localID = videoAssetPlaceholder.localIdentifier
                                        let assetID = localID.replacingOccurrences(of: "/.*", with: "")
                                        let ext = self.bVideoExport ? "mp4" : "gif"
                                        let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)".encodeURLString()
                                        
                                        let instagramURL = URL(string: "instagram://library?AssetPath=\(assetURLStr)&InstagramCaption=\(Constants.ShareText.encodeURLString())")
                                        UIApplication.shared.openURL(instagramURL!)
                                    } else {
                                        if (self.bVideoExport) {
                                            InterfaceManager.showMessage(false, title: "Failed to save video into your library!", bBottomPos: true)
                                        } else {
                                            InterfaceManager.showMessage(false, title: "Failed to save gif into your library!", bBottomPos: true)
                                        }
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                InterfaceManager.hideLoadingView()
                                InterfaceManager.showMessage(false, title: "Please allow our app to access your photo library!", bBottomPos: true)
                            }
                        }
                    }
                } else {
                    InterfaceManager.hideLoadingView()
                    InterfaceManager.showMessage(false, title: "Failed to generate video. Please try again!", bBottomPos: true)
                }
            }
        }
    }
    @IBAction func actionSave(_ sender: Any) {
        InterfaceManager.showLoadingView()
        self.makeFinalResult { (finalURL, bSuccess) in
            DispatchQueue.main.async {
                if (bSuccess) {
                    PHPhotoLibrary.requestAuthorization { (status) in
                        if (status == .authorized) {
                            PHPhotoLibrary.shared().performChanges({
                                if (self.bVideoExport) {
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalURL!)
                                } else {
                                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: finalURL!)
                                }
                            }) { saved, error in
                                DispatchQueue.main.async {
                                    InterfaceManager.hideLoadingView()
                                    if saved {
                                        if (self.bVideoExport) {
                                            InterfaceManager.showMessage(true, title: "Saved video into your gallery successfully!", bBottomPos: true)
                                        } else {
                                            InterfaceManager.showMessage(true, title: "Saved gif into your gallery successfully!", bBottomPos: true)
                                        }
                                        
                                        self.saveProject {
                                            self.goHomeScreen()
                                        }
                                    } else {
                                        if (self.bVideoExport) {
                                            InterfaceManager.showMessage(false, title: "Failed to save video into your library!", bBottomPos: true)
                                        } else {
                                            InterfaceManager.showMessage(false, title: "Failed to save gif into your library!", bBottomPos: true)
                                        }
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                InterfaceManager.hideLoadingView()
                                InterfaceManager.showMessage(false, title: "Please allow our app to access your photo library!", bBottomPos: true)
                            }
                        }
                    }
                } else {
                    InterfaceManager.hideLoadingView()
                    InterfaceManager.showMessage(false, title: "Failed to generate video. Please try again!", bBottomPos: true)
                }
            }
        }
    }
    
}
