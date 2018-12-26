//
//  FontObject.swift
//  BackEraser
//
//  Created by Admin on 25/07/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class FontObject: NSObject, NSCoding, NSCopying {
    var settings: TextSettings = TextSettings.init()
    
    var iconView: ZDStickerView? = nil
    var bSelected: Bool = false
    var editViewCon: NewEditViewController? = nil
    
    var originalCenter: CGPoint = .zero
    var bTextChanged: Bool = false
    
    init(_ delegate: NewEditViewController) {
        super.init()

        self.editViewCon = delegate
        
        let textViewInfo = self.makeTextView()
        
        let icon_width: CGFloat = textViewInfo.1.width + 100
        let icon_height: CGFloat = textViewInfo.1.height + 54

        let icon_x: CGFloat = (delegate.m_videoDrawingView.bounds.size.width - icon_width) / 2.0
        let icon_y: CGFloat = (delegate.m_videoDrawingView.bounds.size.height - icon_height) / 2.0
        
        let iconFrame = CGRect(x: icon_x, y: icon_y, width: icon_width, height: icon_height)
        originalCenter = CGPoint(x: iconFrame.midX, y: iconFrame.midY)
        
        let iconView = ZDStickerView(frame: iconFrame)
        let bgColor = (self.settings.bg_colorIdx == -1 ? UIColor.white : colors[self.settings.bg_colorIdx])
        iconView.iconTintColor = bgColor.withAlphaComponent(self.settings.bg_opacity)
        iconView.contentView = textViewInfo.0
        iconView.preventsPositionOutsideSuperview = false
        iconView.translucencySticker = true
        iconView.bShowBorderCorners = true
        iconView.stickerViewDelegate = delegate
        iconView.bLocked = false
        iconView.showEditingHandles()
        iconView.showBorderCorners()
        
        delegate.m_videoDrawingView.addSubview(iconView)
        
        self.bSelected = true
        iconView.setSelectedStatus(true)
        
        self.iconView = iconView
    }
    
    func selectObject() {
        self.bSelected = true
        iconView?.setSelectedStatus(true)
        
        iconView?.showBorderCorners()
        iconView?.showEditingHandles()
    }
    
    func deSelectObject() {
        self.bSelected = false
        iconView?.setSelectedStatus(false)
        
        iconView?.hideBorderCorners()
        iconView?.hideEditingHandles()
    }
    
    required init(_ object: FontObject) {
        self.settings = object.settings.copy() as! TextSettings
        self.iconView = object.iconView
        self.bSelected = object.bSelected
        self.editViewCon = object.editViewCon
        self.originalCenter = object.iconView!.center
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of:self).init(self)
    }

    required init?(coder decoder: NSCoder) {
        self.settings = decoder.decodeObject(forKey: "settings") as! TextSettings
        self.iconView = decoder.decodeObject(forKey: "icon_view") as? ZDStickerView
        self.bSelected = decoder.decodeBool(forKey: "selected")
        self.originalCenter = decoder.decodeCGPoint(forKey: "original_center")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.settings, forKey: "settings")
        coder.encode(self.iconView, forKey: "icon_view")
        coder.encode(self.bSelected, forKey: "selected")
        coder.encode(self.originalCenter, forKey: "original_center")
    }

    func calculateSizeFromTextView(size: CGSize) {
    
    
    }
    
    func doProcessForUndo() {
        self.iconView?.removeFromSuperview()
    }
    
    func doProcessAfterUndo(_ delegate: NewEditViewController) {
        self.editViewCon = delegate
        
        let textViewInfo = self.makeTextView()
        
        let icon_width: CGFloat = textViewInfo.1.width + 100
        let icon_height: CGFloat = textViewInfo.1.height + 54
        
        let icon_x: CGFloat = (self.editViewCon!.m_videoDrawingView.bounds.size.width - icon_width) / 2.0
        let icon_y: CGFloat = (self.editViewCon!.m_videoDrawingView.bounds.size.height - icon_height) / 2.0
        
        let iconFrame = CGRect(x: icon_x, y: icon_y, width: icon_width, height: icon_height)

        delegate.m_videoDrawingView.addSubview(self.iconView!)
        
        //set new image into icon view
        let bgColor = (self.settings.bg_colorIdx == -1 ? UIColor.white : colors[self.settings.bg_colorIdx])
        iconView?.iconTintColor = bgColor.withAlphaComponent(self.settings.bg_opacity)
        iconView?.contentView = textViewInfo.0
        iconView?.stickerViewDelegate = delegate
        
        iconView?.resetRotateZoom(forTextChange: self.settings.text_rotation / 180.0 * CGFloat(Double.pi), withZoom: self.settings.text_in_zoom)

        iconView?.frame = iconFrame
        iconView?.center = self.originalCenter

        iconView?.zoom(self.settings.text_in_zoom)
        iconView?.rotateView(self.settings.text_rotation / 180.0 * CGFloat(Double.pi))
    }

    func doDeleteForUndo() {
        self.iconView?.removeFromSuperview()
    }

    func doDelete() {
        self.editViewCon = nil
        
        self.iconView?.removeFromSuperview()
        self.iconView = nil
    }

    func doReset() {
        settings.reset()
        iconView?.resetRotateZoom()
        
        let _ = self.doProcess(true)
    }
    
    func doProcess(_ bReset: Bool = false) {
        let original_center = self.iconView?.center
        
        let textViewInfo = self.makeTextView()
        
        let icon_width: CGFloat = textViewInfo.1.width + 100
        let icon_height: CGFloat = textViewInfo.1.height + 54
        
        let icon_x: CGFloat = (self.editViewCon!.m_videoDrawingView.bounds.size.width - icon_width) / 2.0
        let icon_y: CGFloat = (self.editViewCon!.m_videoDrawingView.bounds.size.height - icon_height) / 2.0
        
        let iconFrame = CGRect(x: icon_x, y: icon_y, width: icon_width, height: icon_height)
        originalCenter = CGPoint(x: iconFrame.midX, y: iconFrame.midY)

        //set new image into icon view
        let bgColor = (self.settings.bg_colorIdx == -1 ? UIColor.white : colors[self.settings.bg_colorIdx])
        iconView?.iconTintColor = bgColor.withAlphaComponent(self.settings.bg_opacity)
        iconView?.contentView = textViewInfo.0

        iconView?.resetRotateZoom(forTextChange: self.settings.text_rotation / 180.0 * CGFloat(Double.pi), withZoom: self.settings.text_in_zoom)

        iconView?.frame = iconFrame
        iconView?.center = original_center!
        
        iconView?.zoom(self.settings.text_in_zoom)
        iconView?.rotateView(self.settings.text_rotation / 180.0 * CGFloat(Double.pi))

        if (bReset) {
            iconView?.frame = iconFrame
            iconView?.center = self.originalCenter
        }
        
        self.bTextChanged = false
    }
    
    func doZoomRotateProcess() {
        iconView?.zoom(self.settings.text_in_zoom)
        iconView?.rotateView(self.settings.text_rotation / 180.0 * CGFloat(Double.pi))
    }
    
    func makeTransparentImage() -> UIImage? {
        let font = UIFont.init(name: TheGlobalPoolManager.allFonts[settings.fontIdx], size: settings.text_size)
        let text_width = InterfaceManager.evaluateStringSize(font: font!, textToEvaluate: settings.text).width
        
        let size = CGSize(width: text_width * 2.0 + 2000.0, height: text_width * 2.0 + 2000.0)
        
        var final_image: UIImage? = nil
        
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            let context = UIGraphicsGetCurrentContext()!

            context.translateBy (x: size.width / 2, y: size.height / 2)
            context.scaleBy (x: 1, y: -1)
            
            self.makeRealImage(context, font!)
 
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            final_image = image!.trimmingTransparentPixels()
            image = nil
        }
        
        return final_image!
    }
    
    func makeImageWithBackgroundColor() -> UIImage? {
        let font = UIFont.init(name: TheGlobalPoolManager.allFonts[settings.fontIdx], size: settings.text_size)
        let text_width = InterfaceManager.evaluateStringSize(font: font!, textToEvaluate: settings.text).width
        
        let size = CGSize(width: text_width * 2.0 + 2000.0, height: text_width * 2.0 + 2000.0)
        
        var final_image: UIImage? = nil
        
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            let context = UIGraphicsGetCurrentContext()!
            
            context.translateBy (x: size.width / 2, y: size.height / 2)
            context.scaleBy (x: 1, y: -1)
            
            self.makeRealImage(context, font!)
            
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let text_image = image!.trimmingTransparentPixels()
            image = nil
            
            let textImageSize = text_image!.size
            UIGraphicsBeginImageContextWithOptions(textImageSize, false, 1.0)
            
            colors[settings.bg_colorIdx].withAlphaComponent(settings.bg_opacity).setFill()
            UIRectFill(CGRect(origin: .zero, size: textImageSize))

            text_image!.draw(in: CGRect(origin: .zero, size: textImageSize))
            
            final_image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        return final_image!
    }
    
    func makeTextView() -> (UIView, CGSize) {
        let font = UIFont.init(name: TheGlobalPoolManager.allFonts[settings.fontIdx], size: settings.text_size)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = getCorrectTextAlignment()
        paragraphStyle.lineSpacing = settings.line_spacing
        paragraphStyle.lineBreakMode = .byClipping
        
        let attributes = [NSAttributedStringKey.foregroundColor: colors[settings.colorIdx].withAlphaComponent(settings.opacity),
                          NSAttributedStringKey.font: font,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.kern: settings.character_spacing] as [NSAttributedStringKey : Any]
        
        let updatedText = NSAttributedString(string: self.settings.text, attributes: attributes)
        let sizeOfText: CGSize = self.settings.text.size(withAttributes: attributes)

        let textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: sizeOfText.width, height: sizeOfText.height))
        textView.attributedText = updatedText
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        
        let canvasView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: sizeOfText.width, height: sizeOfText.height))
        canvasView.backgroundColor = UIColor.clear
        canvasView.addSubview(textView)
        
        return (canvasView, sizeOfText)
    }
    
    func makeRealImage(_ context: CGContext, _ font: UIFont) {
        // Set the text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = getCorrectTextAlignment()
        paragraphStyle.lineSpacing = settings.line_spacing
        paragraphStyle.lineBreakMode = .byClipping
        
        let attributes = [NSAttributedStringKey.foregroundColor: colors[settings.colorIdx].withAlphaComponent(settings.opacity),
                          NSAttributedStringKey.font: font,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.kern: settings.character_spacing] as [NSAttributedStringKey : Any]
        
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: 0.0, y: 0.0)
        // Rotate the coordinate system
        context.rotate(by: 0.0)
        // Calculate the width of the text
        let offset = settings.text.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        
        settings.text.draw(in: CGRect(x: -1000, y: -1000, width: 2000, height: 2000), withAttributes: attributes)

        // Restore the context
        context.restoreGState()
    }
    
    func getCorrectTextAlignment() -> NSTextAlignment {
        switch settings.text_aligment {
        case .Center:
            return .center
        case .Justify:
            return .justified
        case .Left:
            return .left
        case .Right:
            return .right
        }
    }
}
