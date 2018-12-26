//
//  Settings.swift
//  VideoGraph
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

public enum RepeatMode: Int {
    case Bounce = 0
    case Repeat = 1
}

public enum ToneCurveMode: Int {
    case RGB = 0
    case R = 1
    case G = 2
    case B = 3
}

struct Project {
    let editSettings: EditSettings
    let bChangedToneCurve: Bool
    let bChangedTemperature: Bool
    let bChangedTint: Bool
    
    let cropSettings: CropSettings
    let priorCropSettings: CropSettings
    
    let fontObjects: [FontObject]
    let selectedObjectIdx: Int
    
    let leftTrimOffset: CGFloat
    let rightTrimOffset: CGFloat
    
    let stillImage: UIImage?
    let stillImageSize: CGSize
    
    let originalMaskImage: UIImage?
    let currentMaskImage: UIImage?
    var finalVideoName: String = ""
    
    init(_ originalMaskImage: UIImage?, _ currentMaskImage: UIImage?, _ finalVideoName: String = "") {
        self.editSettings = TheVideoEditor.editSettings
        self.bChangedToneCurve = TheVideoEditor.bChangedToneCurve
        self.bChangedTemperature = TheVideoEditor.bChangedTemperature
        self.bChangedTint = TheVideoEditor.bChangedTint
        
        self.cropSettings = TheVideoEditor.cropSettings
        self.priorCropSettings = TheVideoEditor.priorCropSettings
        
        self.fontObjects = TheVideoEditor.fontObjects.map { $0.copy() } as! [FontObject]
        self.selectedObjectIdx = TheVideoEditor.selectedFontObjectIdx
        
        self.leftTrimOffset = TheVideoEditor.fTrimLeftOffset
        self.rightTrimOffset = TheVideoEditor.fTrimRightOffset
        
        self.stillImage = TheVideoEditor.stillImage
        self.stillImageSize = TheVideoEditor.initialStillImageSize
        
        self.originalMaskImage = originalMaskImage
        self.currentMaskImage = currentMaskImage
        
        self.finalVideoName = finalVideoName
    }
    
    init(_ nProjectIdx: Int) {
        let name = "project_\(nProjectIdx)_settings"
        
        self.editSettings = EditSettings.init(nProjectIdx)
        
        self.bChangedToneCurve = UserDefaults.standard.bool(forKey: "\(name)_bChangedToneCurve")
        self.bChangedTemperature = UserDefaults.standard.bool(forKey: "\(name)_bChangedTemperature")
        self.bChangedTint = UserDefaults.standard.bool(forKey: "\(name)_bChangedTint")
        
        self.cropSettings = CropSettings.init(nProjectIdx, true)
        self.priorCropSettings = CropSettings.init(nProjectIdx, false)
        
        if let data = UserDefaults.standard.data(forKey: "\(name)_fontobjects"), let objects = NSKeyedUnarchiver.unarchiveObject(with: data) as? [FontObject] {
            self.fontObjects = objects
        } else {
            self.fontObjects = []
        }

        self.selectedObjectIdx = UserDefaults.standard.integer(forKey: "\(name)_selectedObjectIdx")
        
        self.leftTrimOffset = CGFloat(UserDefaults.standard.double(forKey: "\(name)_leftTrimOffset"))
        self.rightTrimOffset = CGFloat(UserDefaults.standard.double(forKey: "\(name)_rightTrimOffset"))

        let stillImagePath = UserDefaults.standard.value(forKey: "\(name)_stillImage") as! String
        if (stillImagePath.length == 0) {
            self.stillImage = UIImage()
        } else {
            self.stillImage = TheGlobalPoolManager.loadImage(stillImagePath)
        }
        
        self.stillImageSize = CGSizeFromString(UserDefaults.standard.value(forKey: "\(name)_stillImageSize") as! String)
        
        let originalMaskImagePath = UserDefaults.standard.value(forKey: "\(name)_originalMaskImage") as! String
        if (originalMaskImagePath.length == 0) {
            self.originalMaskImage = UIImage()
        } else {
            self.originalMaskImage = TheGlobalPoolManager.loadImage(originalMaskImagePath)
        }

        let currentMaskImagePath = UserDefaults.standard.value(forKey: "\(name)_currentMaskImage") as! String
        if (currentMaskImagePath.length == 0) {
            self.currentMaskImage = UIImage()
        } else {
            self.currentMaskImage = TheGlobalPoolManager.loadImage(currentMaskImagePath)
        }
        
        if let finalVideoName = UserDefaults.standard.value(forKey: "final_video") as? String {
            self.finalVideoName = finalVideoName
        } else {
            self.finalVideoName = ""
        }
    }
    
    func deleteData(_ nProjectIdx: Int) {
        let name = "project_\(nProjectIdx)_settings"

        let stillImagePath = UserDefaults.standard.value(forKey: "\(name)_stillImage") as! String
        if (stillImagePath.length > 0) {
            TheGlobalPoolManager.deleteImage(stillImagePath)
        }
        
        let originalMaskImagePath = UserDefaults.standard.value(forKey: "\(name)_originalMaskImage") as! String
        if (originalMaskImagePath.length > 0) {
            TheGlobalPoolManager.deleteImage(originalMaskImagePath)
        }
        
        let currentMaskImagePath = UserDefaults.standard.value(forKey: "\(name)_currentMaskImage") as! String
        if (currentMaskImagePath.length > 0) {
            TheGlobalPoolManager.deleteImage(currentMaskImagePath)
        }
        
        if (self.finalVideoName != "") {
            TheGlobalPoolManager.eraseFile(self.finalVideoName)
        }
    }
    
    mutating func saveProject(_ nProjectIdx: Int, _ finalVideoName: String) {
        let name = "project_\(nProjectIdx)_settings"
        
        self.editSettings.save(nProjectIdx)
        
        UserDefaults.standard.set(self.bChangedToneCurve, forKey: "\(name)_bChangedToneCurve")
        UserDefaults.standard.set(self.bChangedTemperature, forKey: "\(name)_bChangedTemperature")
        UserDefaults.standard.set(self.bChangedTint, forKey: "\(name)_bChangedTint")

        self.cropSettings.save(nProjectIdx, true)
        self.priorCropSettings.save(nProjectIdx, false)
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.fontObjects)
        UserDefaults.standard.set(encodedData, forKey: "\(name)_fontobjects")
        
        UserDefaults.standard.set(self.selectedObjectIdx, forKey: "\(name)_selectedObjectIdx")
        
        UserDefaults.standard.set(Double(self.leftTrimOffset), forKey: "\(name)_leftTrimOffset")
        UserDefaults.standard.set(Double(self.rightTrimOffset), forKey: "\(name)_rightTrimOffset")
        
        if (self.stillImage == nil) {
            UserDefaults.standard.set("", forKey: "\(name)_stillImage")
        } else {
            if TheGlobalPoolManager.saveImage(self.stillImage!, "\(name)_stillImage") {
                UserDefaults.standard.set("\(name)_stillImage", forKey: "\(name)_stillImage")
            } else {
                UserDefaults.standard.set("", forKey: "\(name)_stillImage")
            }
        }
        
        //let updatedStillImageSize = self.stillImage!.size
        //UserDefaults.standard.set(NSStringFromCGSize(updatedStillImageSize), forKey: "\(name)_stillImageSize")
        UserDefaults.standard.set(NSStringFromCGSize(self.stillImageSize), forKey: "\(name)_stillImageSize")

        if (self.originalMaskImage == nil) {
            UserDefaults.standard.set("", forKey: "\(name)_originalMaskImage")
        } else {
            if TheGlobalPoolManager.saveImage(self.originalMaskImage!, "\(name)_originalMaskImage") {
                UserDefaults.standard.set("\(name)_originalMaskImage", forKey: "\(name)_originalMaskImage")
            } else {
                UserDefaults.standard.set("", forKey: "\(name)_originalMaskImage")
            }
        }

        if (self.currentMaskImage == nil) {
            UserDefaults.standard.set("", forKey: "\(name)_currentMaskImage")
        } else {
            if TheGlobalPoolManager.saveImage(self.currentMaskImage!, "\(name)_currentMaskImage") {
                UserDefaults.standard.set("\(name)_currentMaskImage", forKey: "\(name)_currentMaskImage")
            } else {
                UserDefaults.standard.set("", forKey: "\(name)_currentMaskImage")
            }
        }
        
        if (self.finalVideoName != "") {
            TheGlobalPoolManager.eraseFile(self.finalVideoName)
        }

        UserDefaults.standard.set(finalVideoName, forKey: "final_video")
        self.finalVideoName = finalVideoName
        
        UserDefaults.standard.synchronize()
    }
}

struct CropSettings {
    var entireTransform: CGAffineTransform = .identity
    var cropSize: CGSize = .zero
    var imageViewSize: CGSize = .zero
    var fliped: Bool = false
    var angle: CGFloat = 0.0
    var rotateCnt: Int = 0
    var contentViewFrame: CGRect = .zero
    var scrollViewFrame: CGRect = .zero
    var scrollViewContentOffset: CGPoint = .zero
    var bUpdated: Bool = false
    
    init() {
        self.entireTransform = .identity
        self.cropSize = .zero
        self.imageViewSize = .zero
        self.fliped = false
        self.angle = 0.0
        self.rotateCnt = 0
        self.contentViewFrame = .zero
        self.scrollViewFrame = .zero
        self.scrollViewContentOffset = .zero
        self.bUpdated = false
    }
    
    init(_ entireTransform: CGAffineTransform, _ cropSize: CGSize, _ imageViewSize: CGSize, _ fliped: Bool, _ angle: CGFloat, _ rotateCnt: Int, _ contentViewFrame: CGRect, _ scrollViewFrame: CGRect, _ scrollViewContentOffset: CGPoint) {
        self.entireTransform = entireTransform
        self.cropSize = cropSize
        self.imageViewSize = imageViewSize
        self.fliped = fliped
        self.angle = angle
        self.rotateCnt = rotateCnt
        self.contentViewFrame = contentViewFrame
        self.scrollViewFrame = scrollViewFrame
        self.scrollViewContentOffset = scrollViewContentOffset
        self.bUpdated = true
    }
    
    mutating func update(_ entireTransform: CGAffineTransform, _ cropSize: CGSize, _ imageViewSize: CGSize, _ fliped: Bool, _ angle: CGFloat, _ rotateCnt: Int, _ contentViewFrame: CGRect, _ scrollViewFrame: CGRect, _ scrollViewContentOffset: CGPoint) {
        self.entireTransform = entireTransform
        self.cropSize = cropSize
        self.imageViewSize = imageViewSize
        self.fliped = fliped
        self.angle = angle
        self.rotateCnt = rotateCnt
        self.contentViewFrame = contentViewFrame
        self.scrollViewFrame = scrollViewFrame
        self.scrollViewContentOffset = scrollViewContentOffset
        self.bUpdated = true
    }
    
    func save(_ nProjectIdx: Int, _ isCurrent: Bool) {
        let subName = (isCurrent ? "current" : "prior")
        let name = "project_\(nProjectIdx)_cropsettings_\(subName)"
        
        UserDefaults.standard.set(NSStringFromCGAffineTransform(self.entireTransform), forKey: "\(name)_entireTransform")
        UserDefaults.standard.set(NSStringFromCGSize(self.cropSize), forKey: "\(name)_cropSize")
        UserDefaults.standard.set(NSStringFromCGSize(self.imageViewSize), forKey: "\(name)_imageViewSize")
        
        UserDefaults.standard.set(self.fliped, forKey: "\(name)_fliped")
        UserDefaults.standard.set(self.angle, forKey: "\(name)_angle")
        UserDefaults.standard.set(self.rotateCnt, forKey: "\(name)_rotateCnt")

        UserDefaults.standard.set(NSStringFromCGRect(self.contentViewFrame), forKey: "\(name)_contentViewFrame")
        UserDefaults.standard.set(NSStringFromCGRect(self.scrollViewFrame), forKey: "\(name)_scrollViewFrame")
        UserDefaults.standard.set(NSStringFromCGPoint(self.scrollViewContentOffset), forKey: "\(name)_scrollViewContentOffset")

        UserDefaults.standard.set(self.bUpdated, forKey: "\(name)_bUpdated")

        UserDefaults.standard.synchronize()
    }
    
    init(_ nProjectIdx: Int, _ isCurrent: Bool) {
        let subName = (isCurrent ? "current" : "prior")
        let name = "project_\(nProjectIdx)_cropsettings_\(subName)"

        self.entireTransform = CGAffineTransformFromString(UserDefaults.standard.value(forKey: "\(name)_entireTransform") as! String)
        self.cropSize = CGSizeFromString(UserDefaults.standard.value(forKey: "\(name)_cropSize") as! String)
        self.imageViewSize = CGSizeFromString(UserDefaults.standard.value(forKey: "\(name)_imageViewSize") as! String)
        
        self.fliped = UserDefaults.standard.bool(forKey: "\(name)_fliped")
        self.angle = UserDefaults.standard.value(forKey: "\(name)_angle") as! CGFloat
        self.rotateCnt = UserDefaults.standard.integer(forKey: "\(name)_rotateCnt")

        self.contentViewFrame = CGRectFromString(UserDefaults.standard.value(forKey: "\(name)_contentViewFrame") as! String)
        self.scrollViewFrame = CGRectFromString(UserDefaults.standard.value(forKey: "\(name)_scrollViewFrame") as! String)
        self.scrollViewContentOffset = CGPointFromString(UserDefaults.standard.value(forKey: "\(name)_scrollViewContentOffset") as! String)

        self.bUpdated = UserDefaults.standard.bool(forKey: "\(name)_bUpdated")
    }
}

struct CameraSettings {
    var RatioIdx: Int = -1
    var FPSIdx: Int = -1
    var TimerIdx: Int = -1
    var AWBIdx: Int = -1
    
    init() {
        self.RatioIdx = 0
        self.FPSIdx = 0
        self.TimerIdx = 0
        self.AWBIdx = 2
    }
}

class TextSettings: NSObject, NSCoding, NSCopying {
    var text: String = Constants.DefaultText
    var colorIdx: Int = 0
    var opacity: CGFloat = 1.0
    var bg_colorIdx: Int = -1
    var bg_opacity: CGFloat = 0.5
    var fontIdx: Int = 0
    var text_size: CGFloat = 20.0
    var character_spacing: CGFloat = 0.0
    var line_spacing: CGFloat = 1.15
    var text_prospective: CGFloat = 0.0
    var text_rotation: CGFloat = 0.0
    var text_in_zoom: CGFloat = 4.0
    var text_aligment: TextAlignment = .Center
    
    override init() {
        self.text = Constants.DefaultText
        self.colorIdx = 0
        self.opacity = 1.0
        self.bg_colorIdx = -1
        self.bg_opacity = 0.5
        self.fontIdx = 0
        self.text_size = 20.0
        self.character_spacing = 0.0
        self.line_spacing = 1.15
        self.text_prospective = 0.0
        self.text_rotation = 0.0
        self.text_in_zoom = 4.0
        self.text_aligment = .Center
    }
    
    required init(_ object: TextSettings) {
        self.text = object.text
        
        self.fontIdx = object.fontIdx
        self.colorIdx = object.colorIdx
        self.opacity = object.opacity
        self.bg_colorIdx = object.bg_colorIdx
        self.bg_opacity = object.bg_opacity

        self.text_aligment = object.text_aligment

        self.text_size = object.text_size
        self.character_spacing = object.character_spacing
        self.line_spacing = object.line_spacing
        self.text_prospective = object.text_prospective
        self.text_rotation = object.text_rotation
        self.text_in_zoom = object.text_in_zoom
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of:self).init(self)
    }
    
    required init?(coder decoder: NSCoder) {
        self.text = decoder.decodeObject(forKey: "text") as! String
        
        self.fontIdx = decoder.decodeInteger(forKey: "fontIdx")
        self.colorIdx = decoder.decodeInteger(forKey: "colorIdx")
        self.opacity = CGFloat(decoder.decodeDouble(forKey: "opacity"))
        self.bg_colorIdx = decoder.decodeInteger(forKey: "bg_colorIdx")
        self.bg_opacity = CGFloat(decoder.decodeDouble(forKey: "bg_opacity"))

        self.text_aligment = TextAlignment(rawValue: decoder.decodeInteger(forKey: "text_aligment"))!
        
        self.text_size = CGFloat(decoder.decodeDouble(forKey: "text_size"))
        self.character_spacing = CGFloat(decoder.decodeDouble(forKey: "character_spacing"))
        self.line_spacing = CGFloat(decoder.decodeDouble(forKey: "line_spacing"))
        self.text_prospective = CGFloat(decoder.decodeDouble(forKey: "text_prospective"))
        self.text_rotation = CGFloat(decoder.decodeDouble(forKey: "text_rotation"))
        self.text_in_zoom = CGFloat(decoder.decodeDouble(forKey: "text_in_zoom"))
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.text, forKey: "text")
        
        coder.encode(self.fontIdx, forKey: "fontIdx")
        coder.encode(self.colorIdx, forKey: "colorIdx")
        coder.encode(Double(self.opacity), forKey: "opacity")
        coder.encode(self.bg_colorIdx, forKey: "bg_colorIdx")
        coder.encode(Double(self.bg_opacity), forKey: "bg_opacity")
        
        coder.encode(self.text_aligment.rawValue, forKey: "text_aligment")

        coder.encode(Double(self.text_size), forKey: "text_size")
        coder.encode(Double(self.character_spacing), forKey: "character_spacing")
        coder.encode(Double(self.line_spacing), forKey: "line_spacing")
        coder.encode(Double(self.text_prospective), forKey: "text_prospective")
        coder.encode(Double(self.text_rotation), forKey: "text_rotation")
        coder.encode(Double(self.text_in_zoom), forKey: "text_in_zoom")
    }
    
    func reset() {
        //self.text = Constants.DefaultText
        self.colorIdx = 0
        self.opacity = 1.0
        self.bg_colorIdx = -1
        self.bg_opacity = 0.5
        self.fontIdx = 0
        self.text_size = 20.0
        self.character_spacing = 0.0
        self.line_spacing = 1.15
        self.text_prospective = 0.0
        self.text_rotation = 0.0
        self.text_in_zoom = 4.0
        self.text_aligment = .Center
    }
}

struct EditSettings {
    var originalVideoURL: URL {
        get {
            return TheGlobalPoolManager.getVideoURL(self.originalVideoName)
        }
    }

    var originalVideoName: String = ""
    
    //video
    var repeatMode: RepeatMode = .Repeat
    var crossFade: CGFloat = 0.1
    var speed: CGFloat = 1.0
    var delay: CGFloat = 0.0
    
    //brush
    var brushSize: CGFloat = 34.0
    var brushHardness: CGFloat = 0.0
    var brushOpacity: CGFloat = 100
    var maskColorIdx: Int = 0
    var maskOpacity: CGFloat = 80.0
    var bShowMaskAlways: Bool = false // true - shows always, false - shows when masking
    var bMaskAll: Bool = false // true - mask all, false - unmask all (default action)
    
    //filter
    var filterIdx: Int = 0
    
    //tune
    var temperature: CGFloat = 0.0
    var tint: CGFloat = 0.0
    var saturation: CGFloat = 1.0
    
    var exposure: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var contrast: CGFloat = 1.0

    var toneCurveMode: ToneCurveMode = .RGB
    
    var blacks: CGFloat = 0.0
    var shadows: CGFloat = 0.0
    var highlights: CGFloat = 0.0
    var whites: CGFloat = 0.0

    var blacks_r: CGFloat = 0.0
    var shadows_r: CGFloat = 0.0
    var highlights_r: CGFloat = 0.0
    var whites_r: CGFloat = 0.0

    var blacks_g: CGFloat = 0.0
    var shadows_g: CGFloat = 0.0
    var highlights_g: CGFloat = 0.0
    var whites_g: CGFloat = 0.0

    var blacks_b: CGFloat = 0.0
    var shadows_b: CGFloat = 0.0
    var highlights_b: CGFloat = 0.0
    var whites_b: CGFloat = 0.0

    var intensity: CGFloat = 0.0
    var radius: CGFloat = 1.0
    
    init() {
        self.originalVideoName = ""
        
        //video editing settings
        self.repeatMode = .Repeat
        self.crossFade = 0.1
        self.speed = 1.0
        self.delay = 0.0
        
        //brush
        self.brushSize = 34.0
        self.brushHardness = 6.0
        self.brushOpacity = 100
        self.maskColorIdx = 0
        self.maskOpacity = 80
        self.bShowMaskAlways = false
        self.bMaskAll = true
        
        //filter
        self.filterIdx = 0
        
        //tone curve
        self.temperature = 0.0
        self.tint = 0.0
        self.saturation = 1.0

        self.exposure = 0.0
        self.brightness = 0.0
        self.contrast = 1.0

        self.toneCurveMode = .RGB

        self.blacks = 0.0
        self.shadows = 0.0
        self.highlights = 0.0
        self.whites = 0.0

        self.blacks_r = 0.0
        self.shadows_r = 0.0
        self.highlights_r = 0.0
        self.whites_r = 0.0

        self.blacks_g = 0.0
        self.shadows_g = 0.0
        self.highlights_g = 0.0
        self.whites_g = 0.0

        self.blacks_b = 0.0
        self.shadows_b = 0.0
        self.highlights_b = 0.0
        self.whites_b = 0.0

        self.intensity = 0.0
        self.radius = 1.0
    }
    
    mutating func resetAdjustment() {
        self.filterIdx = 0

        self.temperature = 0.0
        self.tint = 0.0
        self.saturation = 1.0
        
        self.exposure = 0.0
        self.brightness = 0.0
        self.contrast = 1.0
        
        self.toneCurveMode = .RGB
        
        self.blacks = 0.0
        self.shadows = 0.0
        self.highlights = 0.0
        self.whites = 0.0
        
        self.blacks_r = 0.0
        self.shadows_r = 0.0
        self.highlights_r = 0.0
        self.whites_r = 0.0
        
        self.blacks_g = 0.0
        self.shadows_g = 0.0
        self.highlights_g = 0.0
        self.whites_g = 0.0
        
        self.blacks_b = 0.0
        self.shadows_b = 0.0
        self.highlights_b = 0.0
        self.whites_b = 0.0
        
        self.intensity = 0.0
        self.radius = 1.0
    }
    
    func save(_ nProjectIdx: Int) {
        let name = "project_\(nProjectIdx)_editsettings"
        
        UserDefaults.standard.set(self.originalVideoName, forKey: "\(name)_originalVideoName")
        
        UserDefaults.standard.set(self.repeatMode.rawValue, forKey: "\(name)_repeatMode")
        UserDefaults.standard.set(self.crossFade, forKey: "\(name)_crossFade")
        UserDefaults.standard.set(self.speed, forKey: "\(name)_speed")
        UserDefaults.standard.set(self.delay, forKey: "\(name)_delay")
        
        UserDefaults.standard.set(self.brushSize, forKey: "\(name)_brushSize")
        UserDefaults.standard.set(self.brushHardness, forKey: "\(name)_brushHardness")
        UserDefaults.standard.set(self.brushOpacity, forKey: "\(name)_brushOpacity")
        UserDefaults.standard.set(self.maskColorIdx, forKey: "\(name)_maskColorIdx")
        UserDefaults.standard.set(self.maskOpacity, forKey: "\(name)_maskOpacity")
        UserDefaults.standard.set(self.bShowMaskAlways, forKey: "\(name)_bShowMaskAlways")
        UserDefaults.standard.set(self.bMaskAll, forKey: "\(name)_bMaskAll")

        UserDefaults.standard.set(self.filterIdx, forKey: "\(name)_filterIdx")

        UserDefaults.standard.set(self.temperature, forKey: "\(name)_temperature")
        UserDefaults.standard.set(self.tint, forKey: "\(name)_tint")
        UserDefaults.standard.set(self.saturation, forKey: "\(name)_saturation")

        UserDefaults.standard.set(self.exposure, forKey: "\(name)_exposure")
        UserDefaults.standard.set(self.brightness, forKey: "\(name)_brightness")
        UserDefaults.standard.set(self.contrast, forKey: "\(name)_contrast")

        UserDefaults.standard.set(self.toneCurveMode.rawValue, forKey: "\(name)_toneCurveMode")

        UserDefaults.standard.set(self.blacks, forKey: "\(name)_blacks")
        UserDefaults.standard.set(self.shadows, forKey: "\(name)_shadows")
        UserDefaults.standard.set(self.highlights, forKey: "\(name)_highlights")
        UserDefaults.standard.set(self.whites, forKey: "\(name)_whites")

        UserDefaults.standard.set(self.blacks_r, forKey: "\(name)_blacks_r")
        UserDefaults.standard.set(self.shadows_r, forKey: "\(name)_shadows_r")
        UserDefaults.standard.set(self.highlights_r, forKey: "\(name)_highlights_r")
        UserDefaults.standard.set(self.whites_r, forKey: "\(name)_whites_r")

        UserDefaults.standard.set(self.blacks_g, forKey: "\(name)_blacks_g")
        UserDefaults.standard.set(self.shadows_g, forKey: "\(name)_shadows_g")
        UserDefaults.standard.set(self.highlights_g, forKey: "\(name)_highlights_g")
        UserDefaults.standard.set(self.whites_g, forKey: "\(name)_whites_g")

        UserDefaults.standard.set(self.blacks_b, forKey: "\(name)_blacks_b")
        UserDefaults.standard.set(self.shadows_b, forKey: "\(name)_shadows_b")
        UserDefaults.standard.set(self.highlights_b, forKey: "\(name)_highlights_b")
        UserDefaults.standard.set(self.whites_b, forKey: "\(name)_whites_b")

        UserDefaults.standard.set(self.intensity, forKey: "\(name)_intensity")
        UserDefaults.standard.set(self.radius, forKey: "\(name)_radius")

        UserDefaults.standard.synchronize()
    }
    
    init(_ nProjectIdx: Int) {
        let name = "project_\(nProjectIdx)_editsettings"

        self.originalVideoName = UserDefaults.standard.object(forKey: "\(name)_originalVideoName") as! String
        
        self.repeatMode = RepeatMode(rawValue: UserDefaults.standard.integer(forKey: "\(name)_repeatMode"))!
        self.crossFade = UserDefaults.standard.value(forKey: "\(name)_crossFade") as! CGFloat
        self.speed = UserDefaults.standard.value(forKey: "\(name)_speed") as! CGFloat
        self.delay = UserDefaults.standard.value(forKey: "\(name)_delay") as! CGFloat

        self.brushSize = UserDefaults.standard.value(forKey: "\(name)_brushSize") as! CGFloat
        self.brushHardness = UserDefaults.standard.value(forKey: "\(name)_brushHardness") as! CGFloat
        self.brushOpacity = UserDefaults.standard.value(forKey: "\(name)_brushOpacity") as! CGFloat
        self.maskColorIdx = UserDefaults.standard.integer(forKey: "\(name)_maskColorIdx")
        self.maskOpacity = UserDefaults.standard.value(forKey: "\(name)_maskOpacity") as! CGFloat
        self.bShowMaskAlways = UserDefaults.standard.bool(forKey: "\(name)_bShowMaskAlways")
        self.bMaskAll = UserDefaults.standard.bool(forKey: "\(name)_bMaskAll")

        self.filterIdx = UserDefaults.standard.integer(forKey: "\(name)_filterIdx")

        self.temperature = UserDefaults.standard.value(forKey: "\(name)_temperature") as! CGFloat
        self.tint = UserDefaults.standard.value(forKey: "\(name)_tint") as! CGFloat
        self.saturation = UserDefaults.standard.value(forKey: "\(name)_saturation") as! CGFloat

        self.exposure = UserDefaults.standard.value(forKey: "\(name)_exposure") as! CGFloat
        self.brightness = UserDefaults.standard.value(forKey: "\(name)_brightness") as! CGFloat
        self.contrast = UserDefaults.standard.value(forKey: "\(name)_contrast") as! CGFloat

        self.toneCurveMode = ToneCurveMode(rawValue: UserDefaults.standard.integer(forKey: "\(name)_toneCurveMode"))!
        
        self.blacks = UserDefaults.standard.value(forKey: "\(name)_blacks") as! CGFloat
        self.shadows = UserDefaults.standard.value(forKey: "\(name)_shadows") as! CGFloat
        self.highlights = UserDefaults.standard.value(forKey: "\(name)_highlights") as! CGFloat
        self.whites = UserDefaults.standard.value(forKey: "\(name)_whites") as! CGFloat

        self.blacks_r = UserDefaults.standard.value(forKey: "\(name)_blacks_r") as! CGFloat
        self.shadows_r = UserDefaults.standard.value(forKey: "\(name)_shadows_r") as! CGFloat
        self.highlights_r = UserDefaults.standard.value(forKey: "\(name)_highlights_r") as! CGFloat
        self.whites_r = UserDefaults.standard.value(forKey: "\(name)_whites_r") as! CGFloat

        self.blacks_g = UserDefaults.standard.value(forKey: "\(name)_blacks_g") as! CGFloat
        self.shadows_g = UserDefaults.standard.value(forKey: "\(name)_shadows_g") as! CGFloat
        self.highlights_g = UserDefaults.standard.value(forKey: "\(name)_highlights_g") as! CGFloat
        self.whites_g = UserDefaults.standard.value(forKey: "\(name)_whites_g") as! CGFloat

        self.blacks_b = UserDefaults.standard.value(forKey: "\(name)_blacks_b") as! CGFloat
        self.shadows_b = UserDefaults.standard.value(forKey: "\(name)_shadows_b") as! CGFloat
        self.highlights_b = UserDefaults.standard.value(forKey: "\(name)_highlights_b") as! CGFloat
        self.whites_b = UserDefaults.standard.value(forKey: "\(name)_whites_b") as! CGFloat

        self.intensity = UserDefaults.standard.value(forKey: "\(name)_intensity") as! CGFloat
        self.radius = UserDefaults.standard.value(forKey: "\(name)_radius") as! CGFloat

    }
    
}
