//
//  RightSettingView.swift
//  VideoGraph
//
//  Created by Techsviewer on 11/29/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import VerticalSteppedSlider

class RightSettingView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var view_repeat_setting: UIView!
    @IBOutlet weak var lbl_repeat_title: UILabel!
    @IBOutlet weak var btn_repeat_repeat: UIButton!
    @IBOutlet weak var btn_repeat_bounce: UIButton!
    @IBOutlet weak var subview_repeat_repeat: UIView!
    @IBOutlet weak var subview_repeat_bounce: UIView!
  
    
    @IBOutlet weak var view_color_setting: UIView!
    @IBOutlet weak var lbl_color_title: UILabel!
    @IBOutlet weak var btn_color_color: UIButton!
    @IBOutlet weak var btn_color_light: UIButton!
    @IBOutlet weak var btn_color_tone: UIButton!
    @IBOutlet weak var btn_color_vignette: UIButton!
    @IBOutlet weak var subview_color_color: UIView!
    @IBOutlet weak var subview_color_light: UIView!
    @IBOutlet weak var subview_color_tone: UIView!
    @IBOutlet weak var subview_color_vignette: UIView!
    
    @IBOutlet weak var view_filter_setting: UIView!
    @IBOutlet weak var col_filter_type: UICollectionView!
    
    @IBOutlet weak var view_text_setting: UIView!
    @IBOutlet weak var lbl_text_title: UILabel!
    @IBOutlet weak var btn_text_align_left: UIButton!
    @IBOutlet weak var btn_text_align_right: UIButton!
    @IBOutlet weak var btn_text_align_center: UIButton!
    @IBOutlet weak var btn_text_align_justify: UIButton!
    @IBOutlet weak var btn_text_textSetting: UIButton!
    @IBOutlet weak var btn_text_background: UIButton!
    @IBOutlet weak var btn_text_font: UIButton!
    @IBOutlet weak var btn_text_angle: UIButton!
    @IBOutlet weak var subview_text_textSetting: UIView!
    @IBOutlet weak var subview_text_background: UIView!
    @IBOutlet weak var subview_text_font: UIView!
    @IBOutlet weak var col_font_type: UICollectionView!
    @IBOutlet weak var subview_text_angle: UIView!
    
    @IBOutlet weak var slider_textSetting_textColor: VSSlider!
    @IBOutlet weak var slider_textSetting_textOpacity: VSSlider!
    @IBOutlet weak var lbl_slider_text_opacity_title: UILabel!
    @IBOutlet weak var slider_textSetting_backgroundColor: VSSlider!
    @IBOutlet weak var slider_textSetting_bgOpacity: VSSlider!
    @IBOutlet weak var lbl_slider_text_bgOpacity_title: UILabel!
    var nSelectedBGColorIdx: Int = -1
    var nSelectedTextColorIdx: Int = 0
    var nSelectedFontIdx: Int = 0
    @IBOutlet weak var slider_textSetting_textProspective: VSSlider!
    @IBOutlet weak var lbl_slider_textSetting_textProspective: UILabel!
    @IBOutlet weak var slider_textSetting_textRotate: VSSlider!
    @IBOutlet weak var lbl_slider_textSetting_textRotate: UILabel!
    @IBOutlet weak var slider_textSetting_textZoom: VSSlider!
    @IBOutlet weak var lbl_slider_textSetting_textZoom: UILabel!
    
    @IBOutlet weak var slider_colorSetting_temperature: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_temperature: UILabel!
    @IBOutlet weak var slider_colorSetting_tine: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_tine: UILabel!
    @IBOutlet weak var slider_colorSetting_saturation: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_saturation: UILabel!
    
    @IBOutlet weak var slider_colorSetting_exposure: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_exposure: UILabel!
    @IBOutlet weak var slider_colorSetting_brightness: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_brightness: UILabel!
    @IBOutlet weak var slider_colorSetting_constrast: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_constrast: UILabel!
    
    @IBOutlet weak var slider_colorSetting_black: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_black: UILabel!
    @IBOutlet weak var slider_colorSetting_shadow: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_shadow: UILabel!
    @IBOutlet weak var slider_colorSetting_highlight: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_highlight: UILabel!
    
    @IBOutlet weak var slider_colorSetting_intensity: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_intensity: UILabel!
    @IBOutlet weak var slider_colorSetting_radius: VSSlider!
    @IBOutlet weak var lbl_slider_colorSetting_radius: UILabel!
    
    @IBOutlet weak var slider_repeatSetting_crossFade: VSSlider!
    @IBOutlet weak var lbl_slider_repeatSetting_crossFade: UILabel!
    @IBOutlet weak var slider_repeatSetting_delay: VSSlider!
    @IBOutlet weak var lbl_slider_repeatSetting_delay: UILabel!
    @IBOutlet weak var slider_repeatSetting_speed: VSSlider!
    @IBOutlet weak var lbl_slider_repeatSetting_speed: UILabel!
    @IBOutlet weak var slider_boundsSetting_delay: VSSlider!
    @IBOutlet weak var lbl_slider_boundsSetting_delay: UILabel!
    @IBOutlet weak var slider_boundsSetting_speed: VSSlider!
    @IBOutlet weak var lbl_slider_boundsSetting_speed: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var bShowSettings: Bool = true
    
    func initializeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(selectedFontObject), name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedRotateInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateRotateValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedZoomInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateZoomValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSelectedObject), name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFilters), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImage), object: nil)
    }
    
    @objc func selectedFontObject() {
    }
    @objc func showSelectedObject() {
    }
    @objc func refreshFilters() {
        self.reloadFilterSetting()
    }
    
    @objc func updatedRotateInStickerView(_ notiInfo: Notification) {
        if let rotateValue = notiInfo.userInfo?["value"] as? CGFloat {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation = rotateValue
            
//            if let slider = self.m_viewSlider2.viewWithTag(21) as? RulerSliderView {
//                slider.setCurrentValue(rotateValue)
//            }
        }
    }
    @objc func updatedZoomInStickerView(_ notiInfo: Notification) {
        if let zoomValue = notiInfo.userInfo?["value"] as? CGFloat {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom = zoomValue
            
//            if let slider = self.m_viewSlider3.viewWithTag(22) as? RulerSliderView {
//                slider.setCurrentValue(zoomValue)
//            }
        }
    }
    
    
    
    
    @IBAction func slider_textSetting_textColor_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        nSelectedTextColorIdx = Int(self.slider_textSetting_textColor.value)
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.colorIdx = nSelectedTextColorIdx
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_textOpacity_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        let value = self.slider_textSetting_textOpacity.value
        self.lbl_slider_text_opacity_title.text = value.description
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.opacity = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_backgroundColor_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        nSelectedBGColorIdx = Int(self.slider_textSetting_backgroundColor.value)
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_colorIdx = nSelectedBGColorIdx
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_bgOpacity_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        let value = self.slider_textSetting_bgOpacity.value
        self.lbl_slider_text_bgOpacity_title.text = value.description
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_opacity = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_angelProspect_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        let value = self.slider_textSetting_textProspective.value
        self.lbl_slider_textSetting_textProspective.text = value.description
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_prospective = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_angelRotate_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        let value = self.slider_textSetting_textRotate.value
        self.lbl_slider_textSetting_textRotate.text = value.description
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_textSetting_angelZoom_valueChanged(_ sender: VSSlider) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        let value = self.slider_textSetting_textZoom.value
        self.lbl_slider_textSetting_textZoom.text = value.description
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    
    @IBAction func slider_colorSetting_colorTemperature_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_temperature.value
        self.lbl_slider_colorSetting_temperature.text = value.description
        TheVideoEditor.editSettings.temperature = CGFloat(value)
        if (TheVideoEditor.editSettings.temperature == 0.0) {
            TheVideoEditor.bChangedTemperature = false
        } else {
            TheVideoEditor.bChangedTemperature = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_colorTine_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_tine.value
        self.lbl_slider_colorSetting_tine.text = value.description
        TheVideoEditor.editSettings.tint = CGFloat(value)
        if (TheVideoEditor.editSettings.tint == 0.0) {
            TheVideoEditor.bChangedTint = false
        } else {
            TheVideoEditor.bChangedTint = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_colorSaturation_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_saturation.value
        self.lbl_slider_colorSetting_saturation.text = value.description
        TheVideoEditor.editSettings.saturation = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_lightExposure_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_exposure.value
        self.lbl_slider_colorSetting_exposure.text = value.description
        TheVideoEditor.editSettings.exposure = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_lightBrightness_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_brightness.value
        self.lbl_slider_colorSetting_brightness.text = value.description
        TheVideoEditor.editSettings.brightness = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_lightContrast_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_constrast.value
        self.lbl_slider_colorSetting_constrast.text = value.description
        TheVideoEditor.editSettings.contrast = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_CuveBlack_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_black.value
        self.lbl_slider_colorSetting_black.text = value.description
        TheVideoEditor.editSettings.blacks = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_CuveShadow_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_shadow.value
        self.lbl_slider_colorSetting_shadow.text = value.description
        TheVideoEditor.editSettings.shadows = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_CuveHighlight_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_highlight.value
        self.lbl_slider_colorSetting_highlight.text = value.description
        TheVideoEditor.editSettings.highlights = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_colorSetting_VignetteIntensity_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_intensity.value
        self.lbl_slider_colorSetting_intensity.text = value.description
        TheVideoEditor.editSettings.intensity = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    
    @IBAction func slider_colorSetting_VignetteRadius_valueChanged(_ sender: VSSlider) {
        let value = self.slider_colorSetting_radius.value
        self.lbl_slider_colorSetting_radius.text = value.description
        TheVideoEditor.editSettings.radius = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_repeatSetting_crossfade_valueChanged(_ sender: VSSlider) {
        let value = self.slider_repeatSetting_crossFade.value
        self.lbl_slider_repeatSetting_crossFade.text = value.description
        TheVideoEditor.editSettings.crossFade = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_repeatSetting_delay_valueChanged(_ sender: VSSlider) {
        let value = self.slider_repeatSetting_delay.value
        self.lbl_slider_repeatSetting_delay.text = value.description
        TheVideoEditor.editSettings.delay = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_repeatSetting_speed_valueChanged(_ sender: VSSlider) {
        let value = self.slider_repeatSetting_speed.value
        self.lbl_slider_repeatSetting_speed.text = value.description
        TheVideoEditor.editSettings.speed = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_boundsSetting_delay_valueChanged(_ sender: VSSlider) {
        let value = self.slider_boundsSetting_delay.value
        self.lbl_slider_boundsSetting_delay.text = value.description
        TheVideoEditor.editSettings.delay = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    @IBAction func slider_boundsSetting_speed_valueChanged(_ sender: VSSlider) {
        let value = self.slider_boundsSetting_speed.value
        self.lbl_slider_boundsSetting_speed.text = value.description
        TheVideoEditor.editSettings.speed = CGFloat(value)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    func showRightRepeatSetting(){
        self.view_repeat_setting.alpha = 1
        self.view_color_setting.alpha = 0
        self.view_filter_setting.alpha = 0
        self.view_text_setting.alpha = 0
        self.subview_repeat_repeat.alpha = 1
        self.onRepeat_repeat(self)
    }
    func showRightColorSetting(){
        self.view_repeat_setting.alpha = 0
        self.view_color_setting.alpha = 1
        self.view_filter_setting.alpha = 0
        self.view_text_setting.alpha = 0
        self.onColor_color(self)
    }
    func showRightFilterSetting(){
        self.view_repeat_setting.alpha = 0
        self.view_color_setting.alpha = 0
        self.view_filter_setting.alpha = 1
        self.view_text_setting.alpha = 0
        self.reloadFilterSetting()
    }
    func showRightTextSetting() {
        self.view_repeat_setting.alpha = 0
        self.view_color_setting.alpha = 0
        self.view_filter_setting.alpha = 0
        self.view_text_setting.alpha = 1
        self.onText_Setting_textSetting(self)
    }
    
    @IBAction func onRepeat_repeat(_ sender: Any) {
        self.lbl_repeat_title.text = "REPEAT"
        self.btn_repeat_repeat.isSelected = true
        self.btn_repeat_bounce.isSelected = false
        self.subview_repeat_repeat.alpha = 1
        self.subview_repeat_bounce.alpha = 0
    }
    @IBAction func onRepeat_bounce(_ sender: Any) {
        self.lbl_repeat_title.text = "BOUNCE"
        self.btn_repeat_repeat.isSelected = false
        self.btn_repeat_bounce.isSelected = true
        self.subview_repeat_repeat.alpha = 0
        self.subview_repeat_bounce.alpha = 1
    }
    
    @IBAction func onColor_color(_ sender: Any) {
        self.lbl_color_title.text = "COLOR"
        self.btn_color_color.isSelected = true
        self.subview_color_color.alpha = 1
        self.btn_color_light.isSelected = false
        self.subview_color_light.alpha = 0
        self.btn_color_tone.isSelected = false
        self.subview_color_tone.alpha = 0
        self.btn_color_vignette.isSelected = false
        self.subview_color_vignette.alpha = 0
    }
    @IBAction func onColor_light(_ sender: Any) {
        self.lbl_color_title.text = "LIGHT"
        self.btn_color_color.isSelected = false
        self.subview_color_color.alpha = 0
        self.btn_color_light.isSelected = true
        self.subview_color_light.alpha = 1
        self.btn_color_tone.isSelected = false
        self.subview_color_tone.alpha = 0
        self.btn_color_vignette.isSelected = false
        self.subview_color_vignette.alpha = 0
    }
    @IBAction func onColor_tone(_ sender: Any) {
        self.lbl_color_title.text = "TONE"
        self.btn_color_color.isSelected = false
        self.subview_color_color.alpha = 0
        self.btn_color_light.isSelected = false
        self.subview_color_light.alpha = 0
        self.btn_color_tone.isSelected = true
        self.subview_color_tone.alpha = 1
        self.btn_color_vignette.isSelected = false
        self.subview_color_vignette.alpha = 0
    }
    @IBAction func onColor_vignette(_ sender: Any) {
        self.lbl_color_title.text = "VIGNETTE"
        self.btn_color_color.isSelected = false
        self.subview_color_color.alpha = 0
        self.btn_color_light.isSelected = false
        self.subview_color_light.alpha = 0
        self.btn_color_tone.isSelected = false
        self.subview_color_tone.alpha = 0
        self.btn_color_vignette.isSelected = true
        self.subview_color_vignette.alpha = 1
    }
    
    func reloadFilterSetting(){
        self.col_filter_type.delegate = self
        self.col_filter_type.dataSource = self;
        self.col_filter_type.reloadData()
    }
    func reloadFontSetting(){
        self.col_font_type.delegate = self
        self.col_font_type.dataSource = self;
        self.col_font_type.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.col_filter_type){
            return TheVideoFilterManager.filterNames.count
        }
        return TheGlobalPoolManager.allFonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.col_filter_type){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewID.FilterCell, for: indexPath) as! FilterCell
            
            InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 0.0)
            if (indexPath.row == TheVideoEditor.editSettings.filterIdx) {
                InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 2.0)
            }
            
            cell.showFilteredImage(indexPath.row)
            
            cell.layoutIfNeeded()
            cell.setNeedsLayout()
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewID.FontCell, for: indexPath) as! FontCell
        cell.m_title.text = "ABC"
        cell.m_title.font = UIFont.init(name: TheGlobalPoolManager.allFonts[indexPath.row], size: 16.0)!
        cell.m_title.numberOfLines = 0
        cell.m_title.textColor = UIColor.white
        cell.layoutIfNeeded()
        cell.setNeedsLayout()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == self.col_filter_type){
            let width = (collectionView.frame.width - 32.0 - 12.0) / 4.0
            let height = width * 1.4
            
            return CGSize(width: width, height: height)
        }
        let width = (self.col_font_type.frame.width - 40.0) / 3.0
        let height: CGFloat = width * 0.75
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.col_filter_type){
            if (TheVideoEditor.editSettings.filterIdx == indexPath.row) {
                return
            }
            
            if (TheVideoEditor.editSettings.filterIdx > -1) {
                if let prevCell = collectionView.cellForItem(at: IndexPath(row: TheVideoEditor.editSettings.filterIdx, section: 0)) as? FilterCell {
                    InterfaceManager.makeRadiusControl(prevCell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 0.0)
                }
            }
            
            TheVideoEditor.editSettings.filterIdx = indexPath.row
            
            if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
                InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 2.0)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }else{
            if (TheVideoEditor.selectedFontObjectIdx == -1) {
                return
            }
            nSelectedFontIdx = indexPath.row
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.fontIdx = nSelectedFontIdx
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    @IBAction func onText_Align_Left(_ sender: Any) {
        self.btn_text_align_left.isSelected = true
        self.btn_text_align_right.isSelected = false
        self.btn_text_align_center.isSelected = false
        self.btn_text_align_justify.isSelected = false
        
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Left
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }
    @IBAction func onText_Align_Right(_ sender: Any) {
        self.btn_text_align_left.isSelected = false
        self.btn_text_align_right.isSelected = true
        self.btn_text_align_center.isSelected = false
        self.btn_text_align_justify.isSelected = false
        
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Right
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }
    @IBAction func onText_Align_Center(_ sender: Any) {
        self.btn_text_align_left.isSelected = false
        self.btn_text_align_right.isSelected = false
        self.btn_text_align_center.isSelected = true
        self.btn_text_align_justify.isSelected = false
        
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Center
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }
    @IBAction func onText_Align_Justify(_ sender: Any) {
        self.btn_text_align_left.isSelected = false
        self.btn_text_align_right.isSelected = false
        self.btn_text_align_center.isSelected = false
        self.btn_text_align_justify.isSelected = true
        
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Justify
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }
    @IBAction func onText_Setting_textSetting(_ sender: Any) {
        self.lbl_text_title.text = "TEXT SETTINGS"
        self.btn_text_textSetting.isSelected = true
        self.subview_text_textSetting.alpha = 1
        self.btn_text_background.isSelected = false
        self.subview_text_background.alpha = 0
        self.btn_text_font.isSelected = false
        self.subview_text_font.alpha = 0
        self.btn_text_angle.isSelected = false
        self.subview_text_angle.alpha = 0
    }
    @IBAction func onText_Setting_background(_ sender: Any) {
        self.lbl_text_title.text = "BACKGROUND"
        self.btn_text_textSetting.isSelected = false
        self.subview_text_textSetting.alpha = 0
        self.btn_text_background.isSelected = true
        self.subview_text_background.alpha = 1
        self.btn_text_font.isSelected = false
        self.subview_text_font.alpha = 0
        self.btn_text_angle.isSelected = false
        self.subview_text_angle.alpha = 0
    }
    @IBAction func onText_Setting_font(_ sender: Any) {
        self.lbl_text_title.text = "FONT"
        self.btn_text_textSetting.isSelected = false
        self.subview_text_textSetting.alpha = 0
        self.btn_text_background.isSelected = false
        self.subview_text_background.alpha = 0
        self.btn_text_font.isSelected = true
        self.subview_text_font.alpha = 1
        self.btn_text_angle.isSelected = false
        self.subview_text_angle.alpha = 0
        self.reloadFontSetting()
    }
    @IBAction func onText_Setting_angle(_ sender: Any) {
        self.lbl_text_title.text = "ANGLE"
        self.btn_text_textSetting.isSelected = false
        self.subview_text_textSetting.alpha = 0
        self.btn_text_background.isSelected = false
        self.subview_text_background.alpha = 0
        self.btn_text_font.isSelected = false
        self.subview_text_font.alpha = 0
        self.btn_text_angle.isSelected = true
        self.subview_text_angle.alpha = 1
    }
}
