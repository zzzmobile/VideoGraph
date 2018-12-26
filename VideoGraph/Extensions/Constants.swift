//
//  Constants.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit

public enum Camera: Int {
    case Back = 0
    case Front = 1
}

public enum Flash: Int {
    case Off = 0
    case On = 1
}

public enum CameraMenu: Int {
    case Ratio = 0
    case FPS = 1
    case Timer = 2
    case AWB = 3
}

public enum EditMenu: Int {
    case Video = 0
    case Brush = 1
    case Tune = 2
    case Filter = 3
    case Text = 4
}

public enum TextAlignment: Int {
    case Left = 0
    case Right = 1
    case Center = 2
    case Justify = 3
}

public let colors: [UIColor] = [.purple, .yellow, .red, .green, .blue, .brown, .orange, .black, .darkGray, .lightGray, .cyan, .magenta]

public struct Constants {
    static let AppName = "VideoGraph"
    static let iTunesID = "1038319355"
    
    static let SomethingWentWrong = "Something went wrong. Please try again!"
    
    static let DefaultText = "Double tap to edit \nthe text"
    static let ShareText = "I have made this result with VideoGraph App"
    
    struct Contact {
        static let Title: String = "Feedback For VideoGraph"
        static let Email: String = "contact@spaceinfo.com"
    }
    
    struct Colors {
        static let GrayBG = UIColor(netHex: 0xEAEAEA)
        static let MenuBG = UIColor(netHex: 0x3C3D40)
        static let MenuSelectBG = UIColor(netHex: 0x4D4F54)
        static let Main = UIColor(netHex: 0x00BAFF)
        static let RedMode = UIColor(netHex: 0xF03E0D)

        static let TempLow = UIColor(netHex: 0x0101F4)
        static let TempHigh = UIColor(netHex: 0xFFFE54)

        static let TintLow = UIColor(netHex: 0x72F64A)
        static let TintHigh = UIColor(netHex: 0xE532F2)
    }
    
    struct NotificationName {
        static let FinishedAnimation = "FinishedAnimation"
        static let UpdatedEditVideoSettings = "UpdatedEditVideoSettings"
        static let ResetStillImage = "ResetStillImage"
        static let UpdatedStillImage = "UpdatedStillImage"
        static let UpdatedStillImageInSubView = "UpdatedStillImageInSubView"

        static let TappedActionInStillImage = "TappedActionInStillImage"

        static let AppliedVideoFilter = "AppliedVideoFilter"
        static let PrepareCroppedVideo = "PrepareCroppedVideo"
        static let CroppedVideo = "CroppedVideo"

        static let UpdatedMaskView = "UpdatedMaskView"
        static let UpdatedBrushParam = "UpdatedBrushParam"
        
        static let UpdatedMaskVisible = "UpdatedMaskVisible"
        static let UpdatedMaskColor = "UpdatedMaskColor"
        static let UpdatedMaskOpacity = "UpdatedMaskOpacity"
        static let UpdatedMaskFeature = "UpdatedMaskFeature"
        
        static let ShowHideTopBarsInEditViewAsAlways = "ShowHideTopBarsInEditViewAsAlways"
        static let ShowTopBarsInEditViewJustOnce = "ShowTopBarsInEditViewJustOnce"
        static let HideTopBarsInEditViewJustOnce = "HideTopBarsInEditViewJustOnce"
        
        static let SelectedFontObject = "SelectedFontObject"
        static let UpdatedTextSeting = "UpdatedTextSeting"
        static let RotateZoomText = "RotateZoomText"
        
        //noitifications for undo
        static let AddedActionForUndo = "AddedActionForUndo"
        static let didUndoProcess = "didUndoProcess"
        
        static let ChangedSomething = "ChangedSomething"
        
        static let UpdateRotateValueInStickView = "UpdateRotateValueInStickView"
        static let FinishUpdateRotateValueInStickView = "FinishUpdateRotateValueInStickView"
        
        static let UpdateZoomValueInStickView = "UpdateZoomValueInStickView"
        static let FinishUpdateZoomValueInStickView = "FinishUpdateZoomValueInStickView"
    }

    struct IAP {
        static let UnlockBackground = "com.backeraser.unlock.background"
        static let UnlockAll = "com.backeraser.unlock.all"
    }
    
    struct ViewIDs {
        static let ViewController = "ViewController"
        static let InitialViewController = "InitialViewController"
        
        static let NewEditViewController = "NewEditViewController"
        static let NewStillViewController = "NewStillViewController"
        
        
        static let CameraViewController = "CameraViewController"
        static let NewCameraViewController = "NewCameraViewController"
        static let CropViewController = "CropViewController"
        static let CropSubViewController = "CropSubViewController"
        static let EditViewController = "EditViewController"
        static let ExportViewController = "NewExportViewController"
        static let TextViewController = "TextViewController"
        
        static let TemplateMenuViewController = "TemplateMenuViewController"
        static let TextMenuViewController = "TextMenuViewController"
        
        static let VideoSliderViewController = "VideoSliderViewController"
        static let VideoStillImageViewController = "VideoStillImageViewController"
        
        static let BrushOverlayViewController = "BrushOverlayViewController"
        static let BrushSliderViewController = "BrushSliderViewController"
        
        static let TuneColorViewController = "TuneColorViewController"
        static let TuneLightViewController = "TuneLightViewController"
        static let TuneToneCurveViewController = "TuneToneCurveViewController"
        static let TuneVignetteViewController = "TuneVignetteViewController"
        
        static let FilterViewController = "FilterViewController"
        
        static let TextFontColorViewController = "TextFontColorViewController"
        static let TextSettingsViewController = "TextSettingsViewController"
    }
    
    struct CollectionViewID {
        static let ExportOptionCell = "ExportOptionCell"
        static let FilterCell = "FilterCell"
        static let ProjectCell = "ProjectCell"
        static let FontCell = "FontCell"
    }

    struct CameraOptions {
        static let Ratio: [String] = ["1:1", "4:3", "16:9"]
        static let RatioActiveIcons: [String] = ["icon_11_select", "icon_43_select", "icon_169_select"]
        static let RatioUnactiveIcons: [String] = ["icon_11", "icon_43", "icon_169"]
        
        static let FPS: [String] = ["24", "30", "60", "120", "240"]
        static let FPSForFront: [String] = ["24", "30", "60"]

        static let Timer: [String] = ["0", "3", "10"]
        
        static let AWBActiveIcons: [String] = ["AWB1_selected", "AWB2_selected", "AWB3_selected", "AWB4_selected", "AWB5_selected"]
        static let AWBUnactiveIcons: [String] = ["AWB1", "AWB2", "AWB3", "AWB4", "AWB5"]
    }
    
    struct VideoMenu {
        static let MenuHeight: CGFloat = 50.0
        static let MenuViewID: String = "TemplateMenuViewController"
        static let Titles: [String] = ["Timeline", "Speed", "Delay", "Still Image"]
        static let Heights: [CGFloat] = [120.0, 120.0, 120.0, 30.0 + UIScreen.main.bounds.width]
        static let ViewIDs: [String] = ["VideoSliderViewController",
                                        "VideoSliderViewController",
                                        "VideoSliderViewController",
                                        "VideoStillImageViewController"]
    }
    
    struct BrushMenu {
        static let MenuHeight: CGFloat = 50.0
        static let MenuViewID: String = "TemplateMenuViewController"
        static let Titles: [String] = ["Size", "Hardness", "Opacity", "Show Overlay"]
        static let Heights: [CGFloat] = [80.0, 80.0, 80.0, 280.0]
        static let ViewIDs: [String] = ["BrushSliderViewController",
                                        "BrushSliderViewController",
                                        "BrushSliderViewController",
                                        "BrushOverlayViewController"]
    }

    struct TuneMenu {
        static let MenuHeight: CGFloat = 50.0
        static let MenuViewID: String = "TemplateMenuViewController"
        static let Titles: [String] = ["Color", "Light", "Tone Curve", "Vignette"]
        static let Heights: [CGFloat] = [220.0, 220.0, 300.0, 200.0]
        static let ViewIDs: [String] = ["TuneColorViewController",
                                        "TuneLightViewController",
                                        "TuneToneCurveViewController",
                                        "TuneVignetteViewController"]
    }

    struct TextMenu {
        static let MenuHeight: CGFloat = 50.0
        static let MenuViewID: String = "TextMenuViewController"
        static let Titles: [String] = ["Text", "Angle"]
        static let Heights: [CGFloat] = [410.0, 300.0]
        static let ViewIDs: [String] = ["TextFontColorViewController",
                                        "TextSettingsViewController"]
    }

    struct SliderImage {
        static let Unactive = "icon_slider_unactive"
        static let Active = "icon_slider"
        static let Active_Temp = "icon_slider_temp"
        static let Active_Tint = "icon_slider_tint"
        static let Active_Red = "icon_slider_red"
        static let Active_Green = "icon_slider_green"
        static let Active_Blue = "icon_slider_blue"

    }
    
    struct MenuIcons {
        static let Video = "menu_video"
        static let VideoSelected = "menu_video_selected"
        
        static let Brush = "menu_brush"
        static let BrushSelected = "menu_brush_selected"
        
        static let Tune = "menu_tune"
        static let TuneSelected = "menu_tune_selected"
        
        static let Filter = "menu_filter"
        static let FilterSelected = "menu_filter_selected"
        
        static let Text = "menu_text"
        static let TextSelected = "menu_text_selected"
    }
    
    struct AWBIcons {
        static let Normal = ["AWB1", "AWB2", "AWB3", "AWB4", "AWB5"]
        static let Selected = ["AWB1_selected", "AWB2_selected", "AWB3_selected", "AWB4_selected", "AWB5_selected"]
    }
    
    struct MaskOptionIcons {
        static let HighlightSelected = "icon_white_highlight"
        static let Highlight = "icon_highlight"
        
        static let EraserSelected = "icon_white_eraser"
        static let Eraser = "icon_eraser"
    }
    
    struct LockOptionIcons {
        static let LockSelected = "icon_white_lock"
        static let Lock = "icon_lock"
        
        static let UnlockSelected = "icon_white_lock_open"
        static let Unlock = "icon_lock_open"
    }
    
    struct DeviceInfo {
        static let DefaultDeviceToken = ""
        static let DeviceType = "iOS"
    }

}
