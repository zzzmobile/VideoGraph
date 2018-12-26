//
//  SettingBrushView.swift
//  VideoGraph
//
//  Created by Techsviewer on 11/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import VerticalSteppedSlider

class SettingBrushView: UIView {
    @IBOutlet weak var btn_write: UIButton!
    @IBOutlet weak var btn_eraser: UIButton!
    
    @IBOutlet weak var btn_draw: UIButton!
    @IBOutlet weak var btn_mask: UIButton!
    
    @IBOutlet weak var view_draw_setting: UIView!
    @IBOutlet weak var view_mask_setting: UIView!
    
    @IBOutlet weak var chk_always: UIButton!
    @IBOutlet weak var chk_whenMask: UIButton!
    
    @IBOutlet weak var view_musk_sub: UIView!
    @IBOutlet weak var chk_maskall: UIButton!
    @IBOutlet weak var chk_unmaskall: UIButton!
    
    
    @IBOutlet weak var slider_maskSetting_opacity: VSSlider!
    @IBOutlet weak var lbl_slider_maskSetting_opacity: UILabel!
    @IBOutlet weak var slider_maskSetting_color: VSSlider!
    @IBOutlet weak var lbl_slider_maskSetting_color: UILabel!
    
    @IBOutlet weak var slider_brushSetting_size: VSSlider!
    @IBOutlet weak var lbl_slider_brushSetting_size: UILabel!
    @IBOutlet weak var slider_brushSetting_hardness: VSSlider!
    @IBOutlet weak var lbl_slider_brushSetting_hardness: UILabel!
    @IBOutlet weak var slider_brushSetting_opacity: VSSlider!
    @IBOutlet weak var lbl_slider_brushSetting_opacity: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func slider_maskSetting_opacity_valueChanged(_ sender: VSSlider) {
        let value = self.slider_maskSetting_opacity.value
        self.lbl_slider_maskSetting_opacity.text = value.description
        TheVideoEditor.editSettings.maskOpacity = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskColor), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_maskSetting_color_valueChanged(_ sender: VSSlider) {
        let value = self.slider_maskSetting_color.value
        TheVideoEditor.editSettings.maskColorIdx = Int(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskColor), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_brushSetting_size_valueChanged(_ sender: VSSlider) {
        let value = self.slider_brushSetting_size.value
        self.lbl_slider_brushSetting_size.text = value.description
        TheVideoEditor.editSettings.brushSize = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedBrushParam), object: nil, userInfo: nil)
    }
    @IBAction func slider_brushSetting_hardness_valueChanged(_ sender: VSSlider) {
        let value = self.slider_brushSetting_hardness.value
        self.lbl_slider_brushSetting_hardness.text = value.description
        TheVideoEditor.editSettings.brushHardness = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedBrushParam), object: nil, userInfo: nil)
    }
    @IBAction func slider_brushSetting_opacity_valueChanged(_ sender: VSSlider) {
        let value = self.slider_brushSetting_opacity.value
        self.lbl_slider_brushSetting_opacity.text = value.description
        TheVideoEditor.editSettings.brushOpacity = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedBrushParam), object: nil, userInfo: nil)
    }
    @IBAction func onWriteMode(_ sender: Any) {
        self.btn_write.isSelected = true
        self.btn_eraser.isSelected = false
        TheImageProcesser.bEraserMode = false
    }
    @IBAction func onEraseMode(_ sender: Any) {
        self.btn_write.isSelected = false
        self.btn_eraser.isSelected = true
        TheImageProcesser.bEraserMode = true
    }
    @IBAction func onDraw(_ sender: Any) {
        self.btn_draw.isSelected = true
        self.btn_mask.isSelected = false
        self.view_draw_setting.isHidden = false
        self.view_mask_setting.isHidden = true
    }
    @IBAction func onMask(_ sender: Any) {
        self.btn_draw.isSelected = false
        self.btn_mask.isSelected = true
        self.view_draw_setting.isHidden = true
        self.view_mask_setting.isHidden = false
    }
    
    @IBAction func onSelectAlways(_ sender: Any) {
        self.view_musk_sub.isHidden = true
        self.chk_always.isSelected = true
        self.chk_whenMask.isSelected = false
        
        TheVideoEditor.editSettings.bShowMaskAlways = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskVisible), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func onSelectWhenMask(_ sender: Any) {
        self.view_musk_sub.isHidden = false
        self.chk_always.isSelected = false
        self.chk_whenMask.isSelected = true
        
        TheVideoEditor.editSettings.bShowMaskAlways = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskVisible), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func onSelectMaskAll(_ sender: Any) {
        self.chk_maskall.isSelected = true
        self.chk_unmaskall.isSelected = false
        
        TheVideoEditor.editSettings.bMaskAll = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func onSelectUnMaskAll(_ sender: Any) {
        self.chk_maskall.isSelected = false
        self.chk_unmaskall.isSelected = true
        TheVideoEditor.editSettings.bMaskAll = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
}
